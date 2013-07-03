# mysql.properties
name=mysql
command.start=service @{REPL_BOOT_SERVICE_NAME} start
command.stop=service @{REPL_BOOT_SERVICE_NAME} stop
command.restart=service @{REPL_BOOT_SERVICE_NAME} restart
command.status=service @{REPL_BOOT_SERVICE_NAME} status