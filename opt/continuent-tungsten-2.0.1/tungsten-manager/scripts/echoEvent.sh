#!/bin/bash
#
# Tungsten Manager @VERSION@
# (c) 2009 Continuent, Inc.  All rights reserved.
#
# This script demonstrates how different policy-manager generated
# events are to be interpreted.  Each event has a set of parameters
# which will be delivered to this script, positionally, and which
# the script has the responsibility for interpreting as required.
#
#
# This is the default script for the monitoring extensions for
# Tungsten Enterprise
#
MANAGER_EVENTS_LOG="`dirname $0`/../log/events.log"

log () {
 echo $* >> $MANAGER_EVENTS_LOG
}


#
# Stage args in this array. Positional args
# do not seem to work properly beyond 10 args
args=("$@")


#
# Create a single string from a set of script args
#  
# string concatArgs(<start offset>, <max arg count>)
#
concatArgs() {
  result=""
  let index=$1
  let maxArgs=$2
  while [ $index -le $maxArgs ];
  do
    if [ "$result" != "" ];
    then
      result+=" "
    fi
    result+="${args[index]}"
    let index=index+1
  done
  echo $result
}

#
# All events start with the time the event was generated
#
dateCreated=${args[0]}
#
# All events have a 'level' which is one of:
#
#  INFO     - Informational
#  WARN     - Warning of a potential issue
#  ERROR     - Some significant fault occured
#  FATAL    - The cluster has lost all means of maintaining
#             availability.
#  RECOVERY   - The system is taking some action to recover 
#               to a highly-available state
#
level=${args[1]}

#
# All events have an event type. The currently supported events,
# and what they represent, are:
#
#   onResourceStateTransition  - A state transition has occurred for a system
#                  resource. These resources are:
#                  MANAGER - Tungsten Manager
#                  REPLICATOR - Tungsten Replicator
#                  DATASERVER - A mysql, posgresql or oracle server
#
#   onDataSourceStateTransition - A state transition has occured for a dataSource
#
#   onPolicyAction           - The policy manager has taken some sort of action
#                              due to rules firing.
#
#   onDataSourceCreate       - A new DataSource has been created.
#
#   onFailover               - A failover has occurred, resulting in a new master.
#
#   onResourceNotification   - A generic notification for which
#                             there is no clear category.
# 
eventType=${args[2]}

#
# Every event has the name of the cluster from which the event comes.
cluster=${args[3]}

#
# We handle specific types of events here.
#
case "$eventType" in
   #
   # Event: onDataSourceCreate
   #
   # This event occurs any time a new DataSource is created by the system.
   #
   # Parameters passed to this event are:
   #
   #  resourceType - it's always DATASOURCE
   #  name - the name of the datasource.  By default, this is the node name.
   #  role - the role of the newly created DataSource: master, slave
   #  state - the state of the newly created DataSource: ONLINE, OFFLINE, STANDBY
   #  message - a message from the system about the creation.
   # 
   onDataSourceCreate)
    resourceType=${args[4]}
    name=${args[5]}
    role=${args[6]}
    state=${args[7]}
    message=`concatArgs 8 $#`
    log "$dateCreated $level: $resourceType was created on node $name with role $role and is now $state"
  ;;
  
   #
   # Event: onResourceStateTransition
   #
   # This event occurs any time a system resource changes state.
   #
   # Parameters passed to onResourceStateTransition are:
   #
   #  resourceType - these are system resources like REPLICATOR, DATASERVER, MANAGER
   #  name - the name of the resource.  By default, this is the node name.
   #  prevState - the state of the resource before the transition
   #  newState - the state of the resource after the transition
   #  message - a message from the system about the transition
   # 
   onResourceStateTransition)
    resourceType=${args[4]}
    name=${args[5]}
    prevState=${args[6]}
    newState=${args[7]}
    message=`concatArgs 7 $#`
    log "$dateCreated $level: $resourceType $name STATE TRANSITION: $prevState => $newState"
  ;;
  
   #
   # Event: onDataSourceStateTransition
   #
   # ThdateCreated.getMonth()is event occurs any time a DataSource changes role or state.
   #
   # Parameters passed to onDataSourceStateTransition are:
   #
   #  rdateCreated.getMonth()esourceType - this is always DATASOURCE
   #  name - the name of the DataSource.  By default, this is the node name.
   #  prevRole - the role of the DataSource before the transition: master, slave
   #  prevState - the state of the resource before the transition: 
   #	 	ONLINE, OFFLINE, STANDBY, FAILED, SHUNNED
   #  newRole - the role of the DataSource after the transition: master, slave
   #  newState - the state of the DataSource after the transition
   #  message - a message from the system about the transition
   # 
  onDataSourceStateTransition)
    resourceType=${args[4]}
    name=${args[5]}
    prevRole=${args[6]}
    prevState=${args[7]}
    newRole=${args[8]}
    newState=${args[9]}
    message=`concatArgs 10 $#`
    log "$dateCreated $level: $resourceType $name STATE TRANSITION: $prevRole:$prevState => $newRole:$newState"
  ;;
  
   #
   # Event: onFailover
   #
   # This event occurs any time the policy manager successfully fails over
   # from a failed master to a new master.
   #
   # Parameters passed to onFailover are:
   #
   #  resourceType - this is always DATASOURCE
   #  failedMasterName - the name of thonDataSourceStateTransitione DataSource that has failed.
   #  failedMasterRole - the role of the DataSource before the failover
   #  failedMasterState - the state of the resource before the failover
   #  newMasterName - the name of the new master
   #  newMasterRole - the role of the DataSource after the failover
   #  newMasterState - the state of the DataSource after the failover
   #  message - a message from the system about the failover
   # 
   onFailover)
    resourceType=${args[4]}
    failedMasterName=${args[5]}
    failedMasterRole=${args[6]}
    failedMasterState=${args[7]}
    newMasterName=${args[8]}
    log "$dateCreated $level: FAILOVER: $resourceType $failedMasterName FAILED OVER TO $resourceType $newMasterName"
  ;;
  
  #
  # Event: onRecovery
  #
  # This event occurs any time the policy manager needs to recovery some 
  # cluster component in order to maintain the highest levels of availability.
  # An example of such a recovery would be when a slave DataSource has been set to FAILED
  # because the associated database server (DATASERVER) stopped.  At some point, 
  # when the database server is restarted, the system will attempt to recovery the
  # DataSource to the ONLINE state.  This will cause a onRecovery event.
  #
  # Parameters passed to onRecovery are:
  #
  #  resourceType - the type of the resource that precipitated the recovery
  #  resourceName - the name of the resource that precipitated the recovery
  #  resourceState - the state of the resource that precipitated the recovery
  #  message - a message from the system about the recovery details
  # 
  onRecovery)
    resourceType=${args[4]}
    resourceName=${args[5]}
    resourceState=${args[6]}
    message=`concatArgs 7 $#`
    log "$dateCreated $level: $message CAUSED BY: $resourceType $resourceName IS IN STATE $resourceState"
  ;;
  
   #
   # Event: onPolicyAction
   #
   # This event occurs any time the policy manager needs to take some kind
   # of action to maintain the cluster state as well as possible.  Typically,
   # this type of action will take place when there's some sort of a failure
   # in the recovery logic such that the policy manager needs to do further
   # fencing of the issue. For example, if the policy manager can't recover
   # a replicator that has gone offline, it may shun the associated datasource
   # in order to prevent looping in the recovery logic.
   #
   # Parameters passed to onPolicyAction are:
   #
   #  resourceType - the type of the resource that precipitated the action
   #  resourceName - the name of the resource that precipitated the action
   #  resourceState - the state of the resource that precipitated the action
   #  message - a message from the system about the action details
   # 
   onPolicyAction)
    resourceType=${args[4]}
    resourceName=${args[5]}
    resourceState=${args[6]}
    message=`concatArgs 7 $#`
    log "$dateCreated $level: POLICY ACTION: $message PERFORMED BECAUSE $resourceType $resourceName IS IN STATE $resourceState"
  ;;
  
  #
  # The following logic will be taken for any undocumented events.
  *)
    log "UNDOCUMENTED EVENT $eventType"
    log "$eventType ARGS: $*"
    log "$dateCreated $level: $*"
  ;;
esac


