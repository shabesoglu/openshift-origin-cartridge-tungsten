#
# This script replaces variables that appear in tpm .tpl files with a syntax
# that can be used by ERB within an OpenShift environment.
#
#replicator.master.listen.uri=thl://<%= ENV['OPENSHIFT_TUNGSTEN_HOST_HOST}:<%= ENV['OPENSHIFT_TUNGSTEN_REPL_SVC_THL_PORT'] %>/

# Catch the first set of embedded periods
# Re-iterated multiple times to cover embedded properties
# on the same line
s/(.*)(@{.*)\.(.*})/\1\2_\3/g
s/(.*)(@{.*)\.(.*})/\1\2_\3/g
s/(.*)(@{.*)\.(.*})/\1\2_\3/g
s/(.*)(@{.*)\.(.*})/\1\2_\3/g
s/(.*)(@{.*)\.(.*})/\1\2_\3/g
s/(.*)(@{.*)\.(.*})/\1\2_\3/g
s/(.*)(@{.*)\.(.*})/\1\2_\3/g
s/(.*)(@{.*)\.(.*})/\1\2_\3/g
s/(.*)(@{.*)\.(.*})/\1\2_\3/g
s/(.*)(@{.*)\.(.*})/\1\2_\3/g
s/(.*)(@{.*)\.(.*})/\1\2_\3/g
s/(.*)(@{.*)\.(.*})/\1\2_\3/g
s/(.*)(@{.*)\.(.*})/\1\2_\3/g

#
# Process most of the single place-holder items
# Because of the greedy nature of .*, this pattern
# needs to be reiterated to cover cases where the patter
# appears multiple times on a line.  Any regex
# experts in the house that can find a more elegant
# way, please do!
#
s/(.*)@{(.*)}/\1<%= ENV['OPENSHIFT_TUNGSTEN_\2'] %>/g
s/(.*)@{(.*)}/\1<%= ENV['OPENSHIFT_TUNGSTEN_\2'] %>/g
s/(.*)@{(.*)}/\1<%= ENV['OPENSHIFT_TUNGSTEN_\2'] %>/g
s/(.*)@{(.*)}/\1<%= ENV['OPENSHIFT_TUNGSTEN_\2'] %>/g
s/(.*)@{(.*)}/\1<%= ENV['OPENSHIFT_TUNGSTEN_\2'] %>/g
s/(.*)@{(.*)}/\1<%= ENV['OPENSHIFT_TUNGSTEN_\2'] %>/g
s/(.*)@{(.*)}/\1<%= ENV['OPENSHIFT_TUNGSTEN_\2'] %>/g
s/(.*)@{(.*)}/\1<%= ENV['OPENSHIFT_TUNGSTEN_\2'] %>/g
s/(.*)@{(.*)}/\1<%= ENV['OPENSHIFT_TUNGSTEN_\2'] %>/g
s/(.*)@{(.*)}/\1<%= ENV['OPENSHIFT_TUNGSTEN_\2'] %>/g
s/(.*)@{(.*)}/\1<%= ENV['OPENSHIFT_TUNGSTEN_\2'] %>/g
s/(.*)@{(.*)}/\1<%= ENV['OPENSHIFT_TUNGSTEN_\2'] %>/g
s/(.*)@{(.*)}/\1<%= ENV['OPENSHIFT_TUNGSTEN_\2'] %>/g
s/(.*)@{(.*)}/\1<%= ENV['OPENSHIFT_TUNGSTEN_\2'] %>/g

