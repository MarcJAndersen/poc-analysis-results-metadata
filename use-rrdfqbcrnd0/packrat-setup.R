## remove packrat directory and rstudio files before running
## these commands.

## R-studio Create new project from directory

## To avoid conflict with System library and user library
## all packages used are install 


install.packages("rJava")

install.packages("RCurl")
install.packages("xlsx")
install.packages("XML")

library(devtools)
install_github("egonw/rrdf", subdir="rrdflibs") 
install_github("egonw/rrdf", subdir="rrdf", build_vignettes = FALSE) 

library(rJava)
library(RCurl)
library(xlsx)
library(XML)
library(rrdflibs)
library(rrdf)

install.packages(c("DiagrammeR","DiagrammeRsvg"))
install.packages(c("webshot"))

## packrat::extlib("devtools")

## packrat::extlib("rJava")
## packrat::extlib("rrdflibs") 
## packrat::extlib("rrdf")

## packrat::extlib("RCurl")
## packrat::extlib("xlsx")
## packrat::extlib("XML")


## If installation fails - then verify
## - all packages neccessary for the local packages are installed
## - after upgrading R, some packages may need to be installed
##
packrat::set_opts(local.repos ="../../rrdfqbcrnd0" )
packrat::install_local("rrdfancillary")
packrat::install_local("rrdfcdisc")
packrat::install_local("rrdfqb")
packrat::install_local("rrdfqbcrnd0")
packrat::install_local("rrdfqbcrndex") 	
packrat::install_local("rrdfqbcrndcheck")
packrat::install_local("rrdfqbpresent")

library("rrdfancillary")
library("rrdfcdisc")
library("rrdfqb")
library("rrdfqbcrnd0")
library("rrdfqbcrndex") 	
library("rrdfqbcrndcheck")
library("rrdfqbpresent")


## packrat::install_github( "MarcJAndersen/rrdfqbcrnd0", subdir="rrdfancillary")
## packrat::install_github( "MarcJAndersen/rrdfqbcrnd0", subdir="rrdfcdisc")
## packrat::install_github( "MarcJAndersen/rrdfqbcrnd0", subdir="rrdfqb")
## packrat::install_github( "MarcJAndersen/rrdfqbcrnd0", subdir="rrdfqbcrnd0")
## packrat::install_github( "MarcJAndersen/rrdfqbcrnd0", subdir="rrdfqbcrndex") 	
## packrat::install_github( "MarcJAndersen/rrdfqbcrnd0", subdir="rrdfqbcrndcheck")
## packrat::install_github( "MarcJAndersen/rrdfqbcrnd0", subdir="rrdfqbpresent")

# packrat::bundle()
# packrat::unbundle("../use-rrdfqbcrnd0/packrat/bundles/use-rrdfqbcrnd0-2016-05-03.tar.gz",".")
