#!/bin/bash

##############################
# server list
##############################

#NODE1=qa.te1.continuent.com
#NODE2=qa.te2.continuent.com
#NODE3=qa.te3.continuent.com
#NODE4=qa.te4.continuent.com

#NODE1=qa.ttt1.continuent.com
#NODE2=qa.ttt2.continuent.com
#NODE3=qa.ttt3.continuent.com
#NODE4=qa.ttt4.continuent.com

#NODE1=qa.tx1.continuent.com
#NODE2=qa.tx2.continuent.com
#NODE3=qa.tx3.continuent.com
#NODE4=qa.tx8.continuent.com

WITNESS=witness.continuent.com

##############################
# Values needed by all recipes
##############################
export CONTINUENT_ROOT=/opt/continuent/cookbook_test
export USER=tungsten
export CONNECTORJ=/opt/continuent/mysql-connector-java-5.1.16-bin.jar
export DATASOURCE_USER=tungsten
export DATASOURCE_PASSWORD=secret
export APPLICATION_USER=tungsten_testing
export APPLICATION_PASSWORD=private
export APPLICATION_PORT=9999
export DB_VERSION=5.1.63
export DATASOURCE_PORT=3306
export DATASOURCE_BOOT_SCRIPT=/etc/init.d/mysql 
export MYSQL_BINARY_LOG_DIRECTORY=/var/lib/mysql
export MYSQL_CONF=/etc/my.cnf
export START_OPTION=--start-and-report
export ROOT_COMMAND=true
export CONNECTOR_DIRECT_RW=127.0.0.1
export CONNECTOR_DIRECT_RO=127.0.0.2
# export MORE_OPTIONS=--repl-backup-method=mysqldump
export MORE_OPTIONS=--mgr-listen-interface=eth1 --backup-directory=/var/continuent/backups --repl-backup-method=mysqldump
# export PROFILE_SCRIPT="~/.bashrc"

##############################
# Values needed by std recipes
##############################
export DS_NAME=lonelycluster
export MASTER=$NODE1
export SLAVES=$NODE2,$NODE3
export CONNECTORS=$NODE2,$NODE4


##############################
# Values needed by sor recipes
##############################
export DS_NAME1=europe
export MASTER1=$NODE1
export SLAVES1=$NODE2
export WITNESS1=$WITNESS
export CONNECTORS1=$NODE1,$NODE2

export DS_NAME2=asia
export MASTER2=$NODE3
export SLAVES2=$NODE4
export WITNESS2=$WITNESS
export CONNECTORS2=$NODE3,$NODE4

export COMPOSITE_DS=world

