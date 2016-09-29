## install.packages("RMySQL")
## gives error
## libmariadb.so.2: cannot open shared object file: No such file or directory
## but the files exists as 
## /usr/lib64/mariadb/libmariadb.so.2
## the prerequisites in https://cran.r-project.org/web/packages/RMySQL/README.html are met
## Solution in /etc/ld.so.conf.d/mariadb-x86_64.conf    add a line with /usr/lib64/mariadb
## MariaDB on fedora: https://fedoraproject.org/wiki/MariaDB
## Start mariadb for session by
##    systemctl start mariadb

## for d2rq jdbc - get mariadb-java-client (I used mariadb-java-client-1.5.2.jar) and store in
## /opt/d2rq-0.8.1/lib/db-drivers/

## install.packages("DBI")
library(RMySQL)
library(DBI)
## Docs suggest to connect to my-db as defined in ~/.my.cnf
## https://github.com/rstats-db/RMySQL
## https://mariadb.com/kb/en/mariadb/configuring-mariadb-with-mycnf/
## http://stackoverflow.com/questions/2482234/how-to-know-mysql-my-cnf-location
con <- dbConnect(RMySQL::MySQL(), username="root", password="mariadb")
res <- dbSendQuery(con, paste( "DROP  DATABASE IF EXISTS cdiscpilot01;"))
res <- dbSendQuery(con, paste( "CREATE DATABASE cdiscpilot01;"))
dbDisconnect(con)


con <- dbConnect(RMySQL::MySQL(), username="root", password="mariadb", dbname="cdiscpilot01" )
dbListTables(con)

## install.packages("SASxport")
library(SASxport)
adae.xpt.fn<-"../../phuse-scripts/data/adam/cdisc/adae.xpt"
## adae<- read.xport(adae.xpt.fn,include.formats=TRUE)
lookup.xport(adae.xpt.fn)
adae<- read.xport(adae.xpt.fn)
## Defining varchar for all, note the apply should only be done on the character variables - use lookup.xport(adae.xpt.fn) to identify
## setNames( as.list(paste("varchar(",apply(adae,MARGIN=2,FUN=function(x){max(nchar(x))}),")")), names(adae))

## dbWriteTable(con, "ADAE", adae[,c("USUBJID", "AESEQ", "ASTDT")], field.type=list(USUBJID="VARCHAR(20)", AESEQ="int", ASTDT="date"),overwrite = TRUE,row.names=FALSE)
## dbWriteTable(con, "ADAE", adae, field.type=list(USUBJID="VARCHAR(20)", AESEQ="int", ASTDT="date"),overwrite = TRUE,row.names=FALSE)
dbWriteTable(con, "ADAE", adae, overwrite = TRUE,row.names=FALSE)
names(adae)

# dbWriteTable(con, "ADAE", adae, field.type=list(USUBJID="VARCHAR(20)"), overwrite = TRUE,row.names=FALSE)
res <- dbSendQuery(con, "ALTER TABLE ADAE ADD PRIMARY KEY(USUBJID, AESEQ)")
dbListFields(con, "ADAE")

## Understand dates
## attributes(adae$ASTDT)
## SASformat(adae)
## SASiformat(adae)
## class(adae$ASTDT)
## class(adae$RACEN)
## is.numeric.Date(adae$ASTDT)
## is.factor(adae$RACEN)
## is.factor(adae$AEOUT)
## is.integer(adae$RACEN)
## dbWriteTable(con, "ADAE", adae, overwrite = TRUE)
## # http://stackoverflow.com/questions/8864174/rmysql-dbwritetable-with-field-types
## adaey<- adae[,c("USUBJID", "ASTDT")]
## adaey$ASTDT<-  as.Date(adaey$ASTDT)
## head(adaey)
## dbWriteTable(con, "ADAEY", adaey, field.type=list(USUBJID="TEXT", ASTDT="date"),overwrite = TRUE,row.names=FALSE)

## adaey2<- dbReadTable(con, "ADAEY")
## as.Date(adaey2$ASTDT) - adaey$ASTDT

## # You can fetch all results:
## res <- dbSendQuery(con, "SELECT * FROM ADAEY")
## dbColumnInfo(res)
## adaey2.return<-dbFetch(res)
## dbClearResult(res)

dbDataType(RMySQL::MySQL(), adae$ASTDT[1])

# Disconnect from the database
dbDisconnect(con)


## d2rq conversion

targetDir<- "../res-ttl"
cdiscpilot01mapttlFn<- file.path(tempdir(), "cdiscpilot01-d2rq-mapping.ttl")
cdiscpilot01ttlFn<- file.path(tempdir(), "cdiscpilot01.ttl")

d2rqbaseURL<- "http://www.example.org/datasets/"
d2rqjdbcstring<- '"jdbc:mariadb://localhost:3306/cdiscpilot01?user=root&password=mariadb"'

## -b option does not work with -l
## /opt/d2rq-0.8.1/generate-mapping reports Unknown argument: -b
system(
    paste("/opt/d2rq-0.8.1/generate-mapping",
             " -o ", cdiscpilot01mapttlFn,
             " ", d2rqjdbcstring, " "
          )
)


system(paste("/opt/d2rq-0.8.1/dump-rdf",
             " -b ", d2rqbaseURL,
             " -o ", cdiscpilot01ttlFn,
             " ", d2rqjdbcstring, " "
             ))
 


if (file.copy(cdiscpilot01mapttlFn, targetDir, overwrite = TRUE)) {
cat( "File ", cdiscpilot01mapttlFn, " copied to directory ", targetDir, "\n")
}


if (file.copy(cdiscpilot01ttlFn, targetDir, overwrite = TRUE)) {
cat( "File ", cdiscpilot01ttlFn, " copied to directory ", targetDir, "\n")
}
