# we need devtools to get repos from github
library('devtools')

write("Installing shinyapps package",stderr())

# install other necessary stuff from github
devtools::install_github("rstudio/shinyapps", ref = "master")

# get the command line arguments
args <- commandArgs(trailingOnly = TRUE)

# first argument should be token
token <- args[1]

# second should be the secret
secret <- args[2]

write("Got Token and Secret",stderr())

library(shinyapps)

# now we need to hook up with our shinyappsio account
#shinyapps::setAccountInfo(name='keboola', token=token, secret=secret)

write("Account Info Set",stderr())

# cross fingers, and deploy (We are assuming that we're in the app home dir
#shinyapps::deployApp(appDir="/home/app")

