#!/bin/bash
#
# This script backs up the datasource on the current host or, if passed
# the optional datasource name, that datasource
#
# Usage: datasource_backup.sh [datasource-hostname] [--agent backup-agent]
#
# The script should be run as the tungsten user to ensure the
# environment is set correctly.  Export the environment variables before
# calling the script to modify behavior
#

#
# Start Environment Variables
#

#
# Set this to zero if you want to backup
# while in maintenance mode
#
if [ -z "$NO_BACKUP_IN_MAINTENANCE_MODE" ];
then
  NO_BACKUP_IN_MAINTENANCE_MODE=0
fi

#
# Set this to zero if you want to backup
# a datasource that is the current master
#
if [ -z "$NO_BACKUP_CLUSTER_MASTER" ]
then
  NO_BACKUP_CLUSTER_MASTER=1
fi

#
# Put the datasource offline before doing the backup
#
if [ -z "$OFFLINE_BACKUP" ]
then
  OFFLINE_BACKUP=0
fi

#
# Only run this script on the coordinator
#
if [ -z "$COORDINATOR_ONLY" ]
then
  COORDINATOR_ONLY=0
fi

#
# The RMI port for the manager
#
if [ -z "$MANAGER_PORT" ]
then
  MANAGER_PORT=9997
fi

#
# Path to the cctrl utility
# This will try to find it in the current path and by 
# guessing the directory structure
#
if [ -z "$CCTRL" ]
then
  CCTRL=`which cctrl 2>/dev/null`
  if [ "$CCTRL" == "" ]; then
    THOME=`dirname $0`
    CCTRL="${THOME}/../../tungsten-manager/bin/cctrl"

    if [ ! -f $CCTRL ]; then
      echo "Unable to find the cctrl utility"
      exit 1
    fi
  fi
fi

#
# End Environment Variables
#

function ensure_cctrl()
{
  IFSOLD=$IFS
  IFS=""

  exception_count=-1
  iterations=0

  echo "Running '$1' in cctrl"
  
  # Run the script up to 5 times if there is an exception
  while [ $exception_count -ne "0" ]
  do
    if [ $iterations -ge 5 ]; then
      break
    fi

    output=`echo $1 | $CCTRL -expert -port $MANAGER_PORT`
    echo $output

    exception_count=`echo $output | grep -i exception | wc -l`
    iterations=$(($iterations+1))
  done

  IFS=$IFSOLD

  # If we get to this point and there are still exceptions, then there was a serious issue
  if [ $exception_count -ne "0" ]; then
    echo "Aborting script because an exception was found"
    
    if [ $OFFLINE_BACKUP -eq 1 ]
    then
      echo "datasource $datasource_hostname welcome" | $CCTRL -port $MANAGER_PORT
    fi
    
    exit 1
  fi
}

currentMode=`echo "ls" | $CCTRL -port $MANAGER_PORT | grep COORDINATOR | awk -F: '{print tolower($2)}'`
if [ $currentMode == "" ]; then
  echo "Unable to determine the current policy"
  exit 1
fi

master_hostname=""
# Determine the hostname for slaves in the cluster
# It is either passed in or we determine it based on
# the first ONLINE slave we encounter in the 'ls' listing.
datasource_hostname=`hostname`
backup_agent=""
while [ $# -gt 0 ]
do
  case "$1" in
    -agent)
      backup_agent="$2"; shift;;
    -find-source)
      datasource_hostname="nil";;
    *)  
      datasource_hostname=$1;
  esac
  shift
done

if [ $COORDINATOR_ONLY -eq 1 ]
then
	currentCoordinator=`echo "ls" | $CCTRL -port $MANAGER_PORT | grep COORDINATOR | awk -F [ '{print $2}' | awk -F : '{print $1}'`
	if [ $currentCoordinator != `hostname` ]; then
		echo "Cancelling backup because this server is not the current coordinator"
		exit 1
	fi
fi

if [ $NO_BACKUP_IN_MAINTENANCE_MODE  -eq 1 ]
then
  if [ "$currentMode" == "maintenance"  ]; then
    echo "Cancelling backup because the cluster is in MAINTENANCE mode"
    exit 1
  fi
fi

if [ $datasource_hostname == "nil" ]; then
	for h in `echo "members" | $CCTRL -port $MANAGER_PORT | grep ONLINE | awk -F \/ '{print $2}' | awk -F \( '{print $1}'`
	do
		datasource_exists=`echo "ls -l $h" | $CCTRL -port $MANAGER_PORT | grep "REPLICATOR" | grep "ONLINE"`
		datasource_type=`echo "$datasource_exists" | awk -F":|role=|," '{print $3}' | tr '[a-z]' '[A-Z]'`
		if [ "$datasource_exists" != "" ];
		then
			if [ "$datasource_type" == "MASTER" ];
			then
				master_hostname=$h
			else
				datasource_hostname=$h
				break
			fi
		fi
	done
	
	if [ "$datasource_hostname" == "nil" ]; then
		if [ "$master_hostname" != "" ]; then
			datasource_hostname=$master_hostname
		else
			echo "Cancelling backup because there is not an ONLINE datasource to backup"
			exit 1
		fi
	fi
fi

# Check to be sure the slave we selected is ONLINE
datasource_exists=`echo "ls -l $datasource_hostname" | $CCTRL -port $MANAGER_PORT | grep "REPLICATOR" | grep "ONLINE"`
datasource_type=`echo "$datasource_exists" | awk -F":|role=|," '{print $3}' | tr '[a-z]' '[A-Z]'`
if [ -z "$datasource_exists" ];
then
  echo "Data source $datasource_hostname does not exist or is not ONLINE"
  exit 1
fi

if [ $NO_BACKUP_CLUSTER_MASTER  -eq 1 ]
then
  if [ "$datasource_type" == "MASTER"  ]; then
    echo "Cancelling backup because $datasource_hostname is in the $datasource_type role"
    exit 1
  fi
fi

if [ "$backup_agent" == "" ]; then
  echo "Backing up $datasource_type data source $datasource_hostname"
else
  echo "Backing up $datasource_type data source $datasource_hostname using $backup_agent"
fi

if [ $OFFLINE_BACKUP -eq 1 ]
then
  ensure_cctrl "datasource $datasource_hostname shun"
  ensure_cctrl "replicator $datasource_hostname offline"
fi

ensure_cctrl "datasource $datasource_hostname backup $backup_agent"

if [ $OFFLINE_BACKUP -eq 1 ]
then
  ensure_cctrl "datasource $datasource_hostname welcome"
fi

# Normal exit
exit 0