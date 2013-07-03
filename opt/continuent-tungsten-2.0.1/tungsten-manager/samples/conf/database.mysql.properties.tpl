# Basic configuration properties for mysql. 
databaseHost=localhost
databasePort=3306
#databaseStartCommand=sudo /etc/init.d/mysql start
#databaseStopCommand=sudo /etc/init.d/mysql stop
databaseStartCommand=sudo /sbin/service mysqld start
databaseStopCommand=sudo /sbin/service mysqld stop
databaseAdminUser=testuser
databaseAdminPassword=secret
