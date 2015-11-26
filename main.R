options(echo = TRUE)

# set cran mirror location
r <- getOption("repos")
r["CRAN"] <- "http://cran.rstudio.com"
options(repos = r)

# we need devtools to get repos from github
library('devtools')
# we use the optparse package for command line options parsing
install.packages("optparse",verbose=FALSE,quiet=TRUE)
library(optparse)

write("Installing keboola libraries",stderr())

# install keboola libraries
devtools::install_github("cloudyr/aws.signature", ref = "master", quiet = TRUE)
devtools::install_github("keboola/sapi-r-client", ref = "master", quiet = TRUE)
devtools::install_github("keboola/provisioning-r-client", ref = "master", quiet = TRUE)
devtools::install_github("keboola/redshift-r-client", ref = "master", quiet = TRUE)
devtools::install_github("keboola/shiny-lib", ref = "refactor", quiet = TRUE)

write("Installing shinyapps package",stderr())

# install other necessary stuff from github
devtools::install_github("rstudio/shinyapps", ref = "master", quiet = TRUE)

library(shinyapps)


option_list <- list(
    make_option(c("-v", "--verbose"), action="store_true", default=TRUE,
                    help="Print extra output [default]"),
    make_option(c("-d", "--command"), default="deploy",help="Either 'deploy' or 'archive'"),
    
    make_option(c("-a", "--account"), default="keboola",
                    help="The account name for shinyApps.io [default %default]"),
    make_option(c("-n", "--appName"), help = "The name of the application to be deployed"),
    make_option(c("-t", "--token"), help = "The token to use for app deployment"),
    make_option(c("-s", "--secret"), help = "The secret associated with the token"),
	make_option(c("-u", "--username"), help = "The username for the repository if private"),
	make_option(c("-p", "--password"), help = "The user's password for the repository if private"),
	make_option(c("-c", "--cranPackages"), help = "list of cran packages to install", default=""),
	make_option(c("-g", "--githubPackages"), help = "list of github packages to install", default="")
)

opt <- parse_args(OptionParser(option_list=option_list))

print("received options")

print(opt)


allArgs <- c("help","verbose","command","account","appName",
			 "token","secret","username",
			 "password","cranPackages","githubPackages")

if (opt$command == "") opt$command <- "deploy"

requiredArgs <- c("appName","token","secret")

missingArgs <- requiredArgs[!(requiredArgs %in% names(opt))]
unknownArgs <- names(opt)[!(names(opt) %in% allArgs)]

if (length(unknownArgs) > 0) {
	stop(paste("Sorry, I don't understand the following options:",paste(unknownArgs,collapse=", ")))
}

if (length(missingArgs) > 0) {
	stop(paste("Sorry, the following required options are missing:",paste(missingArgs,collapse=", ")))
}
	
# call into shinyapps with keboola account credentials
shinyapps::setAccountInfo(name='keboola', token=opt$token, secret=opt$secret)

if (opt$command == "archive") {
	# archive the application
	terminateApp(appName=opt$appName)
} else {
	# define a helper function for trimming strings (is there no base r function for this?)
	trim <- function (x) gsub("^\\s+|\\s+$", "", x)
	if (!is.null(opt$cranPackages) && opt$cranPackages != "") {
		# we need to install any packages that we've been told to
		cranPackages <- trim(unlist(strsplit(opt$cranPackages,",")))
		print(cranPackages)
		lapply(cranPackages, function(x){
			print(paste("Installing package",x,"from cran."))
			install.packages(x, verbose=FALSE, quiet=TRUE)
		})
	} else print("No cran packages to install")
	if (!is.null(opt$githubPackages) && opt$githubPackages != ""){
		# we need to install any github packages that we've been told to.
		githubPackages <- trim(unlist(strsplit(opt$githubPackages,",")))
		print(githubPackages)
		lapply(githubPackages, function(x){
			print(paste("Installing package",x,"from github."))
			devtools::install_github(x, quiet = TRUE)
		})
	} else print("No github packages to install")
	# and deploy the app
	deployApp(appDir="/home/app", appName=opt$appName)	
}

# end
