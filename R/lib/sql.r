library(RMariaDB)
library(data.table)

RunSQL <- function (
  SQL = 'select * from RKIFaelle;'
  , prepare="set @i := 1;") {
  
  rmariadb.settingsfile <- "/home/thomas/git/R/RKI-Dashboard/R/lib/mariadb.cnf"
  
  rmariadb.db <- "RKI"
  
  DB <- dbConnect(RMariaDB::MariaDB(),default.file=rmariadb.settingsfile,group=rmariadb.db)
  dbExecute(DB, prepare)
  rsQuery <- dbSendQuery(DB, SQL)
  dbRows<-dbFetch(rsQuery)
  # Clear the result.
  
  dbClearResult(rsQuery)
  
  dbDisconnect(DB)
  
  return(dbRows)
}
