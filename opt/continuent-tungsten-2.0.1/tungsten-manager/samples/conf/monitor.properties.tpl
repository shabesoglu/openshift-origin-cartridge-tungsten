##############################
# MONITOR.PROPERTIES.MYSQL   #
##############################
#
# Monitor properties sample file.  Copy this file to monitor.properties  

# Monitor notifier.  Select one of the available nicknames, e.g., gcnotifier.
notifier=gcnotifier

########################
# NOTIFIER DEFINITIONS #
########################

# Defines the group communications notifier, which sends a message to 
# the network to give resource status.  
notifier.gcnotifier=com.continuent.tungsten.monitor.notifiers.GroupCommunicationsNotifier
# Location of group communications config file.  This must start with "/" and
# be a file located in the conf directory. 
notifier.gcnotifier.properties=/hedera.properties
# Name of the group communications channel. 
notifier.gcnotifier.channelName=@{DATASERVICENAME}.monitoring
# Delay to use before joining the group
notifier.gcnotifier.joinDelay=20


# Defines logging notifier used for testing.  This notifier writes a message
# to backmon.log to report resource status. 
notifier.logging=com.continuent.tungsten.monitor.notifiers.LogNotifier

########################
# DATASERVICE DEFINITIONS
########################
cluster.name=@{DATASERVICENAME}
cluster.member=@{HOST.HOST}

########################
# MISC DEFINITIONS
########################
startup.delay=10
