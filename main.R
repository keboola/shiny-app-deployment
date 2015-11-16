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

# first argument should be token
token <- args[1]

# second should be the secret
secret <- args[2]

# Name of the application
appName <- args[3]

write("Got Token and Secret", stderr())

# set cran mirror location
r <- getOption("repos")
r["CRAN"] <- "http://cran.rstudio.com"
options(repos = r)

library(shinyapps)

# now we need to hook up with our shinyappsio account
shinyapps::setAccountInfo(name='keboola', token=token, secret=secret)

write("Account Info Set",stderr())

# cross fingers, and deploy (We are assuming that we're in the app home dir
deployApp("/home/app", appName=appName)

