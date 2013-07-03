#
# This set expression will produce a list of Tungsten environment
# variables referenced in the .erb file in which they appear with
# the name of the Tungsten internal property.  They are output
# in the form:
#
# tungsten.property = TUNGSTEN_ENVIRONENT_VAR
#
# This expression needs to be run with 'sed -n -E' to work effectively
#
s/([^=]*)=<%= ENV\['([^']*)'] %>.*/\1=\2/p
#s/(.*)<%= ENV\['([^']*)'] %>.*/\2/p


