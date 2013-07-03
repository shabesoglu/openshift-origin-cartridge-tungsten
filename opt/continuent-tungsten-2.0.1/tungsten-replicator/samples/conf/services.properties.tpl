#################################
# SERVICE-NAMES.PROPERTIES      #
#################################
#
# This file defines the main JMX port for the replicator process as well
# as the name of all replication services.  Each replication service 
# operates a separate replicator pipeline and has a separate JMX 
# OpenReplicatorManagerMBean interface. 
replicator.masterListenPortStart=2112
replicator.serviceRMIPortStart=10600

# RMI port to use for advertising JMX services
replicator.rmi_port=@{REPL_RMI_PORT}

# Comma-separate list of replicator service names.  Each replicator 
# service must have a corresponding static-<hostname>.<svcname>.properties file.  
replicator.services=replicator

# Host where replicator is running
replicator.host=@{HOST.HOST}

# Database connection information. 
replicator.global.db.user=$dataService.user$
replicator.global.db.password=$dataService.password$


# Used by manager to create data sources dynamically
cluster.name=@{CLUSTERNAME}
replicator.source_id=@{HOST.HOST}
replicator.resourceJdbcUrl=jdbc:mysql://@{HOST.HOST}:@{REPL_DBPORT}/\${DBNAME}?jdbcCompliantTruncation=false&zeroDateTimeBehavior=convertToNull&tinyInt1isBit=false&allowMultiQueries=true&yearIsDateType=false
replicator.resourceJdbcDriver=com.mysql.jdbc.Driver
replicator.resourceVendor=@{APPLIER.REPL_DBJDBCVENDOR}
replicator.resourceLogPattern=$serviceFacet.logPattern$
replicator.resourceLogDir=$serviceFacet.logDir$
replicator.resourcePort=@{APPLIER.REPL_DBPORT}
replicator.resourceDiskLogDir=$serviceFacet.diskLogDir$ 
replicator.resourceDataServerHost=@{HOST.HOST}



 
