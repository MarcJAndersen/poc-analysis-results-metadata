library(RMySQL)
library(DBI)
# Docs suggest to connect to my-db as defined in ~/.my.cnf
# https://github.com/rstats-db/RMySQL
# https://mariadb.com/kb/en/mariadb/configuring-mariadb-with-mycnf/
# http://stackoverflow.com/questions/2482234/how-to-know-mysql-my-cnf-location
con <- dbConnect(RMySQL::MySQL(), dbname="cdiscpilot01", username="root", password="mariadb")

dbListTables(con)

dbListFields(con, "adae")

library(SASxport)
adae.xpt.fn<-"../../phuse-scripts/data/adam/cdisc/adae.xpt"
# adae<- read.xport(adae.xpt.fn,include.formats=TRUE)
adae<- read.xport(adae.xpt.fn)
attributes(adae$ASTDT)
SASformat(adae)
SASiformat(adae)
class(adae$ASTDT)
class(adae$RACEN)
is.numeric.Date(adae$ASTDT)
is.factor(adae$RACEN)
is.factor(adae$AEOUT)
is.integer(adae$RACEN)
dbWriteTable(con, "adaex", adae, overwrite = TRUE)
# http://stackoverflow.com/questions/8864174/rmysql-dbwritetable-with-field-types
adaey<- adae[,c("USUBJID", "ASTDT")]
adaey$ASTDT<-  as.Date(adaey$ASTDT)
head(adaey)
dbWriteTable(con, "adaey", adaey, field.type=list(USUBJID="TEXT", ASTDT="date"),overwrite = TRUE,row.names=FALSE)

adaey2<- dbReadTable(con, "adaey")
as.Date(adaey2$ASTDT) - adaey$ASTDT

# You can fetch all results:
res <- dbSendQuery(con, "SELECT * FROM adaey")
dbColumnInfo(res)
adaey2.return<-dbFetch(res)
dbClearResult(res)



# Disconnect from the database
dbDisconnect(con)
