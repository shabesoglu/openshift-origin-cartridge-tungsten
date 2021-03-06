# 
# connector.properties configuration file for Tungsten Connector
#

#
# Server protocol. Can be "mysql" or "postgresql"
#
server.protocol = @{CONN_DB_PROTOCOL}

#
# Server version, where the number preceding "-myosotis-x.x.x" should be 
# replaced by the actual database server version
#
server.version = @{CONN_DB_VERSION}

#
# Port on which to listen to incoming connections.
#
server.port = @{CONN_LISTEN_PORT}

#
# Optionally define a bind address on which to listen for incoming connections.
# Can either be a machine name or a textual representation of its IP address.
# When not specified, equal to "any" or "*", the connector will listen to any/all 
# addresses
#
server.listen.address = @{CONN_LISTEN_ADDRESS}

#
# JDBC driver URL options - Deprecated. For SmartScale, see "useSmartScale=" and
# "sessionId="
# Must begin with a question mark ("?" character)
# Multiple options must be separated by an ampersand ("&" character)
#
jdbc.driver.options = @{CONN_DRIVEROPTIONS}

#
# User map file
#
user.map.filename = ../../tungsten-connector/conf/user.map

#
# The connector will close the client-side connection if inactive for more than
# this this value, in milliseconds
# A value of zero is interpreted as an infinite timeout (default)
#
connection.close.idle.timeout = 0

#
# (MySQL only) When a client application connects without specifying a database 
# name, the proxy will connect to the database specified here. To disable this
# feature (and have no available connection), set this flag to "none" (without 
# quotes). When unspecified, default will be "mysql"
#
forcedDBforUnspecConnections = @{CONN_CLIENTDEFAULTDB}

#
# Marker for Tungsten commands. String following this marker will be interpreted 
# as a specific tungsten command
# defaults to -- TUNGSTEN:
#
tungsten.command.begin.marker=-- TUNGSTEN:

#
# Marker for end of Tungsten commands. If empty or not declared, the command will
# be supposed to finish at the end of the line
#
#tungsten.command.end.marker=

#
# Marker for SQL-Router URL properties that can be embedded in comments.
# If this marker is present in an embeded comment in a SQL statement,
# the connection used for that statement will use the exact properties
# specified.  The format of the string must be:
#   /* TUNGSTEN_URL_PROPERTY=<urlProperties> */ 
#
# An example of URL properties to cause a query to be sent to a
# slave is:
#
# /* TUNGSTEN_URL_PROPERTY=qos=RO_RELAXED&maxAppliedLatency=10 */
#
# Note that any valid properties can be put into this string.
# This can be embedded anywhere in any SQL statement.  It is primarily
# meant as a 'selective' alternative to read/write splitting.
#
selective.rwsplitting.marker=TUNGSTEN_URL_PROPERTY

#
# This property, if set to true, overrides the default read/write
# splitting behavior, which is to send any select query that has
# a 'direct connection' to that connection, and, instead, to only
# send queries to a 'direct connection' if the marker, above, is found.
#
selective.rwsplitting=false

#
# When set to true, selects will be routed as much as possible to slaves
# a session consistent approach. All connections using the same sessionId will
# be able to see each other's writes, but others write might be out-dated
# depending on slave latency
#           
useSmartScale=@{CONN_SMARTSCALE}

#
# When using SmartScale, the session ID can defined here and will be 
# connector-wide. Possible values are DATABASE, USER or CONNECTION
# For a per-connection session id, used the value PROVIDED_IN_DBNAME here and 
# set your session ID via the database name with which your application 
# connects, for example: "<db_name>?sessionId=<session_id>". 
# Note that any session id set via the database name will have precedence over
# the one defined here
#
sessionId=@{CONN_SMARTSCALE_SESSIONID}

#
# When this flag is set to true, the connector will monitor certain types of 
# errors (closed connection, I/O exceptions and SQL Exception with SQL state 
# "08S01") and try to reconnect to the data source.
# Note that no reconnection will be attempted when in the middle of a 
# transaction or while executing a request.
# When false, errors are forwarded to the client application which will have to
# handle the reconnection procedure
#
autoReconnect=@{CONN_AUTORECONNECT}

#
# Tungsten connector intercepts a standard MySQL 'show slave status' command
# and returns a result based on the Tungsten replication system state rather
# than the MySQL native replication state.  This is done in order to provide
# backwards compatibility for applications that use the slave status for a
# variety of purposes, including to determine if a slave is sufficiently
# up to date.  If you specify 'true' for this parameter, Tungsten will report
# a secondsBehindMaster value that is adjusted by adding the delta beween
# the current time and the time that the last transaction was applied to the
# slave.  By doing this, applications are protected from the possibility that
# the replication has stopped or is otherwise delayed in reporting the
# actual latency.  You should only set this option to 'true' if your site 
# has a high volume of writes.  Otherwise, leave the option to the
# default of 'false'.  With this option set, the reported value for
# secondsBehindMaster will always be the latency of the last committed
# transaction on the slave, no matter how long ago the commit occurred.
#
showRelativeSlaveStatus=@{CONN_SLAVE_STATUS_IS_RELATIVE}

#
# Queries used by the show slave status command are found in these files.
# The connector will not start unless the file required by show slave status
# exists and is readable.
#
showSlaveStatusFilename=show_slave_status.sql
showSlaveStatusRelativeFilename=show_slave_status_relative.sql

requestAnalyzerClassName=org.continuent.myosotis.analyzer.DefaultRequestAnalyzer
requestAnalyzerConfigFileName=../../tungsten-connector/conf/default_request_analyzer.regex

#
# Client applications using JDBC cannot pass Tungsten URL options (like QoS or
# maxAppliedLatency) because the JDBC driver parses and ignores them. The 
# following character, when found in a database name, will be treated as a 
# marker for Tungsten URL options.
# If you need to pass regular JDBC url option to the client application driver, 
# just add a usual '&' in front of them
# Example JDBC URL for getting a slave with 10ms max latency, and forcing 
# client application driver to use unicode:
# jdbc:mysql://connector_host:9999/dbname@qos=RO_RELAXED&maxAppliedLatency=10?useUnicode=true
# Recommended and tested markers: '@', '!', '#', '$'
# Default: '@'
#
optionMarkerInDbName=@

#
# When client application issues a 'use <database_name>', the connector will 
# allow the change on the current connection(s)
# However, with @direct read/write splitting, the read-only connections are
# backed by a pool which has to be switch upon database change, so a reconnection
# to the new pool must occur
# This option should be set to true when using @direct entries in user.map
#
useDBreconnects=false

#
# Should the connector print warning logs when a client application disconnects
# abruptly or has the wrong credentials?
# Default is true, print them
#
printConnectionWarnings=true

#
# This will turn the Connector into a 'bridge', connecting directly to a master
# (RW_STRICT) or a slave (RO_RELAXED).
# By default, the connector acts as a 'router' (OFF)
#
bridgeMode=OFF

#
# With brideMode other than OFF, adjust sizes of buffers between client 
# application and MySQL server
# Default is 1024B (1M). 0 or less fall-back to 1B
#
bridgeServerToClientBufferSize=1024
bridgeClientToServerBufferSize=1024
