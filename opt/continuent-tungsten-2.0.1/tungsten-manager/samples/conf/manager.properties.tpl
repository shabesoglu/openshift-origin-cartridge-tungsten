# Default properties file for Service Manager.  Copy this file to 
# manager.properties and update values as needed for your installation. 
#
# Note:  The ${manager.home} property is set automatically by Service 
# Manager start scripts.  As long as you are running the service manager
# from these scripts no changes are necessary.  
#

# Persistent storage properties. 
## REVIEW: REMOVE
manager.db.url=jdbc:derby:${manager.home}/private/db;create=true
manager.db.driver=org.apache.derby.jdbc.EmbeddedDriver

# Location of hedera.properties file. 
manager.gc.hedera_properties=${manager.home}/conf/hedera.properties

# Location of properties files for replicator and router
manager.replicator.properties=${manager.home}/../tungsten-replicator/conf/replicator.properties
manager.router.properties=${manager.home}/../tungsten-sqlrouter/conf/router.properties

# If default_join=true and manager was not in a group before, it will try to
# join the given GC. 
manager.gc.default_join=true
manager.gc.group=@{DATASERVICENAME}
manager.gc.member=@{HOST.HOST}

#
# Properties that determine the number of retries and the 
# delay between retries if a NIC/network is not available
# for the cluster network.
#
manager.gc.retryInterval=30
manager.gc.retryCount=60

manager.autoOnline=true

# RMI host and default port. 
manager.rmi.host=localhost
manager.rmi.port=@{MGR_RMI_PORT}


# Port used for RMI calls.  If set to -1, the port will be allocated
# dynamically by the JMX library.  Otherwise, it will be set to the value
# of this port. Default value is 12000
manager.rmi.beanPort=@{MGR_RMI_REMOTE_PORT}

#
# Default timeout for RMI calls in ms
#
manager.rmi.default_timeout=500000000
## IMPORTANT NOTE: This value is intentionally set
## very high so that we can work on finding potential
## hanging issues.  It will need to be used with
## some logic in QueueManager.takeFeedback() where 
## we will periodically time out while polling
## for a response to a given request.


# Port number for file server
## REMOVE
manager.file_server.port=@{MGR_FILE_SERVER_PORT}

# Service directory containing property files for handlers. 
## REMOVE
manager.handlers.dir=${manager.home}/handlers

# A list of resources that should be activated automatically on initial
# start-up. Effective only if manager has joined GC (eg. default_join=true).
### REMOVE 
manager.handlers.auto_activate=ClusterManagementHandler

# The factory class used to handle event routing, state management, and membership
# management
## REMOVE 
manager.factory=com.continuent.tungsten.manager.core.mapping.MappingFactory

#
# Class that will receive notifications from the monitor and will take appropriate actions
# via the manager, with other components - for failover, etc.
#
## REMOVE 
manager.cluster.policy=com.continuent.tungsten.cluster.manager.policy.EnterprisePolicyManager

#
# Default mode for the policy manager
#
manager.policy.mode=@{MGR_POLICY_MODE}

# 
# JMX proxy for managing replication.
#
## REMOVE 
manager.replicator.proxy=@{MGR_REPLICATOR_PROXY}

#
# Indicates whether to start up the integral monitor
#
## REMOVE 
manager.monitor.start=true

#
# Indicates whether to start up the policy manager.
# This should only be set to false if problems are
# suspected with the policy manager.
#
## REMOVE 
manager.policy.start=true

#
# Indicates which address can be used to
# arbitrate determination of a primary partition.
#
## REMOVE 
manager.policy.arbitrator=www.google.com,www.bloomberg.com
 
#
# Maximum number of seconds to wait for router answers
# After this delay, a silent router will be discarded
# Negative or zero values means "wait forever"
# Default is 20 seconds
#
manager.idle.router.timeout=@{MGR_IDLE_ROUTER_TIMEOUT}


#
# Timeout for internal synchronization requests. 
#
## Which side is this on?  If on the coordinator side, one effect etc.
manager.sync.timeout=60000


#
# Indicates how often to sample the policy manager
# in order to determine it's liveness. Default
# is to sample every 1 second
#
# REVIEW: WORKAROUND FOR HANGING ISSUE.  CONSIDER REMOVING
#
policy.liveness.samplePeriodSecs=@{MGR_POLICY_LIVENESS_SAMPLE_PERIOD_SECS}

#
# Indicates how many consecutive sample periods
# can pass without progress before it becomes
# a liveness issue. The default is 30 sample periods
# which, when combined with the default sample period,
# equates to 30 seconds
#
# REVIEW: WORKAROUND FOR HANGING ISSUE.  CONSIDER REMOVING
#
policy.liveness.thresholdPeriods=@{MGR_POLICY_LIVENESS_SAMPLE_PERIOD_THRESHOLD}


#
# This timeout is used when 'pinging' a manager and the process used
# to do so is to send a message through GC and to wait for a response.
# This represents the ping round trip and is a simple test
# to see if a manager is responsive via the GC channel.
#
policy.liveness.manager.ping.timeout=2000

#
# After the first time a manager detects that the membership that
# it currently observes does not tally with an active 'ping' of
# each member via group communications, this value determines
# how many additional times the manager should retry the
# membership before failing safe. Retries happen every 10
# seconds, by default.
#
policy.invalid.membership.retry.threshold=2

#
# Indicates how long, in seconds, dataSourcePing() should
# use for a timeout in order to establish liveness
# for a data source. The default value for a
# database server ping is 15 seconds.
#
policy.liveness.dsPingTimeout=@{MGR_DB_PING_TIMEOUT}

#
# If a dbping fails more than this number, then the resource
# associated with the db server is marked as failed. The
# default is 1 which means to mark the resource as failed
# after a single dbping failure. Host pings
# are retried every 10 seconds, by default, and
# the timeout for the ping is determined as in the above
# property. You can calculate how long it will take
# for the cluster manager to mark the data source
# associated with the host as a FAILED resource by using
# the following formula:
#
#  time-to-fail-seconds = dbping.fail * (10 + dsPingTimeout))
#
# With a default value of 0, the time-to-fail-seconds is:
# 
#  time-to-fail-seconds =  1 * (10 + 15) = ~25 seconds
#
# This means that database server outages need to persist for at least 35
# seconds for a failure to be triggered.
#
#
policy.liveness.dbping.fail.threshold=1

#
# Indicates the timeout length, in seconds, a ping operation
# uses when trying to establish liveness of a host. The
# default value for this timeout is 5 seconds.
#
## REVIEW: default = 5?  Change default in tpm
## since this may be too low for cloud environments
##
policy.liveness.hostPingTimeout=@{MGR_HOST_PING_TIMEOUT}

#
# If a host ping fails more than this number of times, 
# associated with the host is marked as failed. The
# default is 3 which means to mark the resource as failed
# after a three host ping failures. Host pings
# are retried every 10 seconds - ping-sample-interval - by default, 
# and the timeout for the ping is determined as in the above
# property. You can calculate how long it will take
# for the cluster manager to mark the data source
# associated with the host as a FAILED resource by using
# the following formula:
#
#  max-time-to-fail-seconds = hostPing.fail.threshold 
#						* ((ping-sample-interval + hostPingTimeout)
#							* number-of-datasources)
#
# With a default value of 1, the max-time-to-fail-seconds for a 
# three datasource service is:
# 
#  max-time-to-fail-seconds = 1 * ((10 + 5) * 3) = ~45 seconds
#
# Note that in the above calculation, we assume that the ping will 'hang' 
# until the timeout expires but, in practice, if a host is completely gone,
# the ping will return immediately.  For this reason, failure is more likely
# to be detected sooner.  If we assume that the actual time consumed by
# 'ping' is 1/2 second, the calculation looks like this:
#
#  min-time-to-fail-seconds = 1 * ((10 + .5) * 3) = ~33 seconds
#
# This means that network outages need to persist for at least 33-45
# seconds for a failure to be triggered.
#
policy.liveness.hostPing.fail.threshold=1

#
# Comma-separated list of ping method(s) to use when checking for
# host liveness.  Supported method names are default (uses
# TCP/IP port 7 for non-root account, otherwise ICMP), and ping
# (uses OS ping utility).
#
policy.liveness.hostPingMethods=default


#
# The period of time between internally-generated
# manager heartbeats. This value determines the minimum
# latency of many fault detection rules.
# REVIEW: Change name from the prior to the latter...
policy.liveness.heartbeat.intervalMsecs=1000
#policy.rules.execution.intervalMsecs=1000


#
# If we miss heartbeats more than this number of times,
# it signals a manager/monitoring liveness issue.
#
## REVIEW: Change name from the prior to the latter
policy.liveness.heartbeat.fail.threshold=5
#policy.rules.execution.fail.threshold=5

#
# The replicator purge needs to be executed with a timeout since, if
# it's hanging, it's a potential liveness issue.  On the other hand,
# there may be a scenario where killing a DB server thread takes longer
# than we think, in which case we need to be able to adjust this timeout
# accordingly.  
#
# The value is the number of seconds to wait for purge to return
# before timing out.
#
policy.liveness.purgeTimeout=120

#
# If this property is set to true, the enterprise rules
# will set an online slave datasource to OFFLINE if the 
# associated replicator is not ONLINE. The default
# is NOT to fence the replicator to OFFLINE.
#
## REVIEW: Policy should be to fence after a timeout, with -1 being 'never fence it'
## What about logic that puts replicator back online- should retry more than once?
policy.fence.slaveReplicator=@{MGR_POLICY_FENCE_SLAVE_REPLICATOR} 

#
# If this property is set to true, the enterprise rules
# will set an online master datasource to OFFLINE if the 
# associated replicator is not ONLINE. The default
# is to leave master datasources ONLINE independent of the
# replicator state.
# 
## Policy should be to fence after a timeout, with -1 being 'never fence it'
## What about logic that puts replicator back online- should retry more than once?
policy.fence.masterReplicator=@{MGR_POLICY_FENCE_MASTER_REPLICATOR} default

#
# If this property is set to true, the enterprise rules
# will set an OFFLINE datasource to ONLINE if the 
# associated replicator is ONLINE and the DATASERVER 
# is ONLINE.  This only occurs in automatic mode.
# 
policy.recover.offline.datasources=true


# Indicates that the manager should release
# a local VIP the second time it is started by the wrapper.
# In this case, the first time will just be a normal manager startup but
# subsequent restarts will increment the number of invocations.
#
manager.vip.release.invocation=2

#
# Path to executable VIP release script
#
manager.vip.release.script=@{CURRENT_RELEASE_DIRECTORY}/cluster-home/bin/vip-release-helper

#
# Indicates that the manager should invoke the local fail-safe
# script during the fifth invocation of the manager. The manager
# will then exit
#
manager.failsafe.invocation=5

#
# Path to executable local fail-safe script
#
manager.failsafe.script=${manager.home}/../cluster-home/bin/fail-safe-helper true

# 
# Enables or disables failsafe processing of vip
# By default, vips are always failsafe and this means that if
# a manager exits, and is not in maintennce mode, any bound vip
# will be released.  This processing can be disabled by setting
# this property to false, but this is not recommended unless
# you are having trouble with vips being released due to false positives
#
manager.vip.isFailSafe=true

#
# Number of dispatch periods after which a manager failure causes associated
# resources to be marked as failed as well. 
#
manager.fail.threshold=@{MGR_POLICY_FAIL_THRESHOLD}

#
# Number of seconds per fail dispatch
#
manager.fail.dispatchPeriod=10

#
# Indicates the complete set of cluster members
#
manager.global.members=@{DATASERVICE_MEMBERS}
## Is this overridden in dataservices.properties?

#
# Indicates the a set of hosts that can be used to test
# for cluster interconnect network connectivity.  These
# hosts must be accessible either on the same network
# used by the members or must route throught the same
# network.
#
manager.global.witnesses=@{DATASERVICE_WITNESSES}
# Test witness host during normal operation
# Check to be sure we have majority with witness host?
# Only use witness hosts if there are only two potential members

#
# The following properties are used by VIP management
#

#
# Indicates whether or not the manager should maintain a VIP
# that is bound to the master database server.
#
vip.isEnabled=@{MGR_VIP_ENABLED}

#
# Indicates the IP address to be bound for the VIP
#
vip.address=@{MGR_VIP_IPADDRESS_NETMASK}

#
# Indicates the full path to the ifconfig command
# for the user that runs tungsten
#
vip.ifconfig_path=@{MGR_VIP_IFCONFIG_PATH}

#
# Indicates the full path to the arp command
# for the user that runs tungsten
#
vip.arp_path=@{MGR_VIP_ARP_PATH}

#
# Indicates the full path to the script that we use to
# encapsulate bind/release/delete of VIP
#
vip.vip_management_helper=@{CURRENT_RELEASE_DIRECTORY}/tungsten-manager/bin/vip_management_helper

#
# Indicates the prefix to use when executing root-level
# commands
#
manager.sudoCommandPrefix=@{ROOT_PREFIX}

#
# Indicates that the manager should keep slaves
# in a read-only state at all times and also
# ensure that masters are read/write
#
manager.readOnlySlaves=@{MGR_RO_SLAVE} - default is true

#
# Indicates that a 'destructive purge' should be done. A 'destructive' purge
# is something that a master replicator can do, and causes it to kill all
# mysql sessions that were not started by the replicator's 'tungsten' user.
# This is done as a prelude to doing a final flush on the master so that we
# are 100% sure that the last write to the master is done by Tungsten and
# not by an application.
#
manager.destructive.purge=true

# Move timeout for purge down here...

#
# Indicates that the manager should forward replicator notifications
# to routers.  This is turned on by default
#
manager.notifications.send=true

#
# Indicates how long to wait for a router notification to be delivered
# This quantity is in milliseconds
#
manager.notifications.timeout=@{MGR_NOTIFICATIONS_TIMEOUT}
## Belongs up above.
## Move properties that are internal to lower in the file.

#
# The amount of time, in milliseconds, to wait for routers to respond
# when executing interactive status commands in cctrl.
#
manager.router.timeout=@{MGR_ROUTER_STATUS_TIMEOUT}
# Make sure that the manager is only displaying the state it knows about
# with the exception of the connection counts.
# Use information from handshake of the router gateway 
# Consider having the router connect to only the coordinator

#
# The number of seconds to which a slave must be current with the master
# in order to qualify as a candidate for failover.  Defaults to
# 15 minutes (900 seconds).
#
policy.slave.promotion.latency.threshold=900
# Make this configurable with a default with a real argument

#
# How frequently, in seconds, to generate a remote service heartbeat/poll
# for remote services.
#
policy.remote.service.heartbeat.interval=5

#
# This property determines how many seconds the manager will delay,
# after seeing a remote service in the stopped state, before
# the composite data source associated with the service is shunned. 
policy.remote.service.timeout.threshold=60
#
# Connector 

#
# This property determines whether or not the manager should periodically 
# check for missing members.
#
policy.check.missing=true

#
# The following two properties determine whether or not an http
# service is started to serve API requests.  If so, then the service
# will be started on the specified port, with the specified document root.
#
manager.api.http.enabled=@{MGR_API}
manager.api.http.root=/manager
manager.api.http.port=@{MGR_API_PORT}
manager.api.http.listenAddress=@{MGR_API_ADDRESS}

#####################################################################
#
# WARNING: DO NOT MODIFY ANY OF THE PROPERTIES BEYOND THIS LOCATION
# WITHOUT THE DIRECTION OF CONTINUENT SUPPORT OR RISK SITE OUTAGES
# OR DATA LOSS
#
######################################################################

#
# Automatically determine optimal level for router notification
# timeouts.
#
policy.notification.adjust.auto=false

#
# Interval to use in order to backoff router notification timeout
# after it's previously adjusted to a higher value. This
# defaults to an hour
#
policy.notification.adjust.backoff=2000

#
# The maximum possible timeout for notifications.  After this number,
# warnings are generated in the log.
#
policy.notification.max.timeout=5000

#
# The number of notification delivery failures that will
# trigger an adjustment.
#
policy.notification.adjust.threshold=5

#
# The number of successful notification deliveries that
# will trigger a backoff
#
policy.notification.adjust.success.threshold=10

#
# The number of backoff attempts before the timeout
# will be leveled.
#
policy.notification.adjust.backoff.try=3

#
# If set to true, causes the manager to dump an extensive amount of information
# into the error log when there's a critical error.
#
manager.error.diag=false

#
# Number of events to store the ring buffer for manager diagnostics
#
manager.diag.size=1000





