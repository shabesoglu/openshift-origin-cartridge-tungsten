#!/bin/bash

#NODE1=qa.tx1.continuent.com
#NODE4=qa.tx8.continuent.com

# the witness server should be a server outside the cluster
WITNESS=witness.continuent.com

export CONTINUENT_ROOT=/opt/continuent/cookbook_test
export USER=tungsten
export DS_NAME=tinycluster
export CONNECTORJ=/opt/continuent/mysql-connector-java-5.1.16-bin.jar
export MASTER=$NODE1
export SLAVES=$NODE4
export CONNECTORS=$NODE1,$NODE4
export DATASOURCE_USER=tungsten
export DATASOURCE_PASSWORD=secret
export DATASOURCE_PORT=3306
export APPLICATION_USER=tungsten_testing
export APPLICATION_PASSWORD=private
export APPLICATION_PORT=9999
export DB_VERSION=5.1.63
export MYSQL_CONF=/etc/my.cnf
export DATASOURCE_BOOT_SCRIPT=/etc/init.d/mysql 
export MYSQL_BINARY_LOG_DIRECTORY=/var/lib/mysql
export START_OPTION=--start-and-report
export ROOT_COMMAND=true
export MORE_OPTIONS=--mgr-listen-interface=eth1 --backup-directory=/var/continuent/backups --repl-backup-method=xtrabackup

