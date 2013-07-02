#!/bin/bash

##################################
# server list
##################################

# List the servers that make your cluster.
# Their role will be defined in the values below

NODE1=""
NODE2=""
NODE3=""
NODE4=""
NODE5=""
NODE6=""
# the witness server should be a server outside the cluster
WITNESS=


##################################
# Values needed by all recipes
##################################
# The place where tungsten will be installed
export CONTINUENT_ROOT=/opt/continuent

# The user running the installed software on every server.
# This user must have ssh access to every server
export USER=tungsten

# Location of connector-J in the installation server
export CONNECTORJ=/opt/continuent/mysql-connector-java-5.1.16-bin.jar

# Credentials to access the database for Tungsten replicator.
# This user must have all privileges + GRANT option
export DATASOURCE_USER=tungsten
export DATASOURCE_PASSWORD=secret

# Credentials to access the database from the application, using Tungsten connector
# This user must have only the needed privileges to run the application.
# It is recommended that it also gets the 'REPLICATION CLIENT' privilege. 
export APPLICATION_USER=tungsten_testing
export APPLICATION_PASSWORD=private
export APPLICATION_PORT=9999

# This is the version of the database. 
# If not provided, the installer will try to detect it from a running database server
export DB_VERSION=autodetect

# Database port, used for replication
export DATASOURCE_PORT=3306

# Location of the script used by MySQL to start and stop the server (default: /etc/init.d/mysql)
# The installer will try to detect it
export DATASOURCE_BOOT_SCRIPT=autodetect

# Location where the binary logs are saved. This location must be visible by the user running  Tungsten
export MYSQL_BINARY_LOG_DIRECTORY=/var/lib/mysql

# Location of the my.cnf file. The installer will try to detect it, if not provided
export MYSQL_CONF=autodetect

# What the cluster should do after installation. 
# By default, all services will start and the status of the cluster will be reported
export START_OPTION=--start-and-report

# Set this option to "true" if Tungsten needs to access resources as root.
# This is commonly needed when running backups with xtrabackup or when the manager needs
# to start or restart a database server
export ROOT_COMMAND=true

# Location of the script that stores environment variables used by Tungsten for ease of maintenance
# If you set this option, your $PATH will be modified, so that you'll be able to access 
# Tungsten executable and maintenance directories more easily
export PROFILE_SCRIPT="~/.bashrc"

# Use this variable to include more options in the installation template (e.g.: MORE_OPTIONS="--channels=10")
export MORE_OPTIONS=""

#####################################################
# Values needed by standard deployment (std) recipes
#####################################################
# this is the name of the data service
export DS_NAME=chicago

# The master is assigned to the firt node in the list 
export MASTER=$NODE1

# List of slaves. If you want less than two slaves, you need to delete the extra one
export SLAVES=$NODE2,$NODE3

# List of connectors. You should remove the ones that you don't want
# and the nodes that have not been defined at the start of this list
export CONNECTORS=$NODE1,$NODE2,$NODE3,$NODE4

#############################################
# Values needed by double site (sor) recipes
#############################################
# (Disregard the lines below if you are installing a standard cluster only)
# Name of the active data service
export DS_NAME1=europe

# Which server is the master
export MASTER1=$NODE1

# list of slaves
export SLAVES1=$NODE2

# Which witness is used for this cluster
export WITNESS1=$WITNESS

# List of connectors for the active cluster
export CONNECTORS1=$NODE1,$NODE2

# Name of the passive (relay) data service
export DS_NAME2=asia

# which server is the RELAY
export MASTER2=$NODE3

# slaves connected to the relay server
export SLAVES2=$NODE4

# witness for passive cluster
export WITNESS2=$WITNESS

# Connectors for the passive cluster
export CONNECTORS2=$NODE3,$NODE4

# Name of the composite data service that includes both the active and the passive data services
export COMPOSITE_DS=world

##################################
# Values needed by the sor3 recipe
##################################
# export DS_NAME3=america
# export MASTER3=$NODE5
# export SLAVES3=$NODE6
# export WITNESS3=$WITNESS
# export CONNECTORS3=$NODE5,$NODE6
