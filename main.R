# we need devtools to get repos from github
library('devtools')

write("Installing keboola libraries",stderr())

# install keboola libraries
devtools::install_github("cloudyr/aws.signature", ref = "master")
devtools::install_github("keboola/sapi-r-client", ref = "master")
devtools::install_github("keboola/provisioning-r-client", ref = "master")
devtools::install_github("keboola/redshift-r-client", ref = "master")
devtools::install_github("keboola/shiny-lib", ref = "master")

write("Installing shinyapps package",stderr())

# install other necessary stuff from github
devtools::install_github("rstudio/shinyapps", ref = "master")

# get the command line arguments
args <- commandArgs(trailingOnly = TRUE)

# What should this thing do?
command <- args[1]

# valid commands: deploy, archive [delete will be available in a future version]
validCommands <- c("deploy", "archive")

# make sure the given command is valid
if (!(command %in% validCommands)) {
    stop(paste("I'm sorry, but I don't know how to", command,". I only know how to", paste(validCommands,sep="and")))
}

# first argument should be token
token <- args[2]

# second should be the secret
secret <- args[3]

# Name of the application
appName <- args[4]


write("Got Token and Secret", stderr())

# set cran mirror location
r <- getOption("repos")
r["CRAN"] <- "http://cran.rstudio.com"
options(repos = r)

library(shinyapps)

# now we need to hook up with our shinyappsio account
shinyapps::setAccountInfo(name='keboola', token=token, secret=secret)

write("Account Info Set",stderr())

write(paste("attempting to deploy app", appName), stderr())

if (command == "deploy") {
    # cross fingers, and deploy (We are assuming that we're in the app home dir
    deployApp(appDir="/home/app", appName=appName)
} else if (command == "archive") {
    terminateApp(appName=appName)
} else {
    stop(paste("You shouldn't be here. I thought I said that I didn't know how to", command))
}
