#####################################
# CHECKER.MYSQLSERVER.PROPERTIES    #
#####################################

name=mysql_response
class=com.continuent.tungsten.monitor.checkers.JDBCMySQLDatabaseServerChecker

# delay between each monitoring run - default 3000ms
frequency=@{MGR_MONITOR_INTERVAL}
# connection will be renewed after this period
reconnectAfter=30000
serverName=@{HOST.HOST}
host=@{APPLIER.REPL_DBHOST}
vendor=mysql
port=@{APPLIER.REPL_DBPORT}
driver=com.mysql.jdbc.Driver
url=jdbc:mysql://@{APPLIER.REPL_DBHOST}:@{APPLIER.REPL_DBPORT}/tungsten
username=@{APPLIER.REPL_DBLOGIN}
password=@{APPLIER.REPL_DBPASSWORD}
query=select 1
queryTimeout=@{MON_DB_QUERY_TIMEOUT}
queryFileName=mysql_checker_query.sql



