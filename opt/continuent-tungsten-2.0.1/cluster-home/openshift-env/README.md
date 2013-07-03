This is a summary of what has been completed, to date, to get things set up for configuration via ERB processing in OpenShift.

This directory contains files that can be used in the OpenShift env directory in order to define all properties required for configuring Tungsten components.  Each component has one or more configuration files, in the standard Tungsten directory structure, which, when processed by the ERB in Openshift, will yield a valid configuration file. There is only one exception to this:

For the replicator, there is a file tungsten-replicator/conf/replicator.properties.masterslave and this file should be renamed to:

static-<%= ENV['OPENSHIFT_APP_NAME'] %>.properties just before ERB processing takes place.

A few conventions were followed:

<%= ENV['OPENSHIFT_APP_NAME'] %> is used as the dataservice/cluster name
<%= ENV['OPENSHIFT_MYSQL_DB_USERNAME'] %> and <%= ENV['OPENSHIFT_MYSQL_DB_PASSWORD'] %> are used for the replicator user and replicator password.
<%= ENV['OPENSHIFT_MYSQL_DB_HOST'] %> is used anywhere a host name is required and for data service member names as well.  These should end up as the datasource name.

There are 73 .erb files for use in the environment.  All of these should have valid values except that those that specify ports (named *PORT*) may need to change.  There are also 7 out of these 73 files that have the string TBD and that will need to be set up properly for configuration to work.

No doubt there are a few loose ends, and some config files won't get set up properly. It should be simple to fix, however.  Either assign a reasonable default value to the *.properties.erb file in the Tungsten distribution or set the property with the value of an OpenShift environment variable and add the new variable to the 'env' directory.

OpenShift properties are referenced, directly, in the following files:

TUNGSTEN_APPLIER_REPL_DBHOST.erb:<%= ENV['OPENSHIFT_MYSQL_DB_HOST'] %>
TUNGSTEN_APPLIER_REPL_DBLOGIN.erb:<%= ENV['OPENSHIFT_MYSQL_DB_USERNAME'] %>
TUNGSTEN_APPLIER_REPL_DBPASSWORD.erb:<%= ENV['OPENSHIFT_MYSQL_DB_PASSWORD'] %>
TUNGSTEN_APPLIER_REPL_DBPORT.erb:<%= ENV['OPENSHIFT_MYSQL_DB_PORT'] %>
TUNGSTEN_CLUSTERNAME.erb:<%= ENV['OPENSHIFT_APP_NAME'] %>
TUNGSTEN_CURRENT_RELEASE_DIRECTORY.erb:<%= ENV['OPENSHIFT_REPO_DIR'] %>/opt/continuent/tungsten
TUNGSTEN_DATASERVICENAME.erb:<%= ENV['OPENSHIFT_APP_NAME'] %>
TUNGSTEN_EXTRACTOR_REPL_DBHOST.erb:<%= ENV['OPENSHIFT_MYSQL_DB_HOST'] %>
TUNGSTEN_EXTRACTOR_REPL_DBLOGIN.erb:<%= ENV['OPENSHIFT_MYSQL_DB_USERNAME'] %>
TUNGSTEN_EXTRACTOR_REPL_DBPASSWORD.erb:<%= ENV['OPENSHIFT_MYSQL_DB_PASSWORD'] %>
TUNGSTEN_EXTRACTOR_REPL_DBPORT.erb:<%= ENV['OPENSHIFT_MYSQL_DB_PORT'] %> 
TUNGSTEN_EXTRACTOR_REPL_MASTER_LOGDIR.erb:<%= ENV['OPENSHIFT_MYSQL_DB_LOG_DIR'] %>
TUNGSTEN_HOST_HOST.erb:<%= ENV['OPENSHIFT_MYSQL_DB_HOST'] %>
TUNGSTEN_REPL_SVC_SCHEMA.erb:tungsten_<%= ENV['OPENSHIFT_APP_NAME'] %>
TUNGSTEN_SERVICE_DEPLOYMENT_SERVICE.erb:<%= ENV['OPENSHIFT_APP_NAME'] %>
TUNGSTEN_SERVICE_DSNAME.erb:<%= ENV['OPENSHIFT_APP_NAME'] %>
TUNGSTEN_SERVICE_REPL_BACKUP_STORAGE_DIR.erb:<%= ['OPENSHIFT_DATA_DIR'] %>/backups
TUNGSTEN_SERVICE_REPL_LOG_DIR.erb:<%= ENV['OPENSHIFT_DATA_DIR'] %>/thl/<%= ENV['OPENSHIFT_APP_NAME'] %> 
TUNGSTEN_SERVICE_REPL_RELAY_LOG_DIR.erb:<%= ENV['OPENSHIFT_DATA_DIR'] %>/relay/<%= ENV['OPENSHIFT_APP_NAME'] %>


Good luck!




