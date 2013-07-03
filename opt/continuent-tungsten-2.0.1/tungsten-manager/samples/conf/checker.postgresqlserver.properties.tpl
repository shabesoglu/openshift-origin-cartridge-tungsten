##########################################
# CHECKER.POSTGRESQLSERVER.PROPERTIES    #
##########################################

name=postgresql_response
class=com.continuent.tungsten.monitor.checkers.PGWALChecker

# delay between each monitoring run - default 3000ms
frequency=@{MGR_MONITOR_INTERVAL}
# connection will be renewed after this period
reconnectAfter=30000
serverName=@{HOST.HOST}
host=@{HOST.HOST}
vendor=@{APPLIER.REPL_DBJDBCVENDOR}
driver=@{APPLIER.REPL_DBJDBCDRIVER}
url=jdbc:postgresql://@{APPLIER.REPL_DBHOST}:@{APPLIER.REPL_DBPORT}/@{APPLIER.REPL_DBLOGIN}
username=@{APPLIER.REPL_DBLOGIN}
password=@{APPLIER.REPL_DBPASSWORD}
query=select 1
