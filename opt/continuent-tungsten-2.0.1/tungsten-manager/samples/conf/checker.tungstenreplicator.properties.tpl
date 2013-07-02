#######################
# CHECKER DEFINITIONS #
#######################

# Replicator checker properties. 
#
class=com.continuent.tungsten.monitor.checkers.TungstenReplicatorOSSChecker
frequency=@{MGR_MONITOR_INTERVAL}
name=tungsten_replicator_status

# Replicator database jdbc URL - should be the public one (ie. NOT localhost)
# This information will be used by the sql router to create data sources dynamically
# host name and port where uni/cluster is running. Defaults to 127.0.0.1:10000
jmxHostName=localhost
jmxHostPort=@{REPL_RMI_PORT}

# JMX server settings - should not need to be modified
jmxService=replicator
jmxUrlBase=service:jmx:rmi:///jndi/rmi://
jmxDomain=com.continuent.tungsten.replicator.conf
managerJmxDomain=com.continuent.tungsten.replicator.management
jmxResourceMonitorName=ReplicatorMonitor
jmxResourceManagerName=ReplicationServiceManager
sourceId=@{HOST.HOST}
clusterName=@{DATASERVICENAME}
