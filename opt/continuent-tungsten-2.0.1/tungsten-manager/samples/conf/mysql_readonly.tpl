#!/bin/bash
# Make MySQL read-only
mysql -h@{APPLIER.REPL_DBHOST} --port=@{APPLIER.REPL_DBPORT} -u@{APPLIER.REPL_DBLOGIN} -p@{APPLIER.REPL_DBPASSWORD} -e "SET GLOBAL read_only = $1;"
mysql -h@{APPLIER.REPL_DBHOST} --port=@{APPLIER.REPL_DBPORT} -u@{APPLIER.REPL_DBLOGIN} -p@{APPLIER.REPL_DBPASSWORD} -e "SHOW VARIABLES LIKE '%read_only%';"