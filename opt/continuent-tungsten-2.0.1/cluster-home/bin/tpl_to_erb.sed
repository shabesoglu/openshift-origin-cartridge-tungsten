#
# This script replaces variables that appear in tpm .tpl files with a syntax
# that can be used by ERB within an OpenShift environment.
#
#
# Replace embedded '.' with '_' inside of tpm placeholders
# plus replace tpm placeholder introducer with an erb
# style introducer and prefix for TUNGSTEN
#
s/@{([^{]*)\./<%= ENV['TUNGSTEN_\1_/g

#
# This one does the same as above, but for lines that
# don't include embedded '.'
s/@{([^{]*)/<%= ENV['TUNGSTEN_\1/g

#
# Replace the '}' for all new erb-stype placeholders
# with the erb-style termination "'] %>"  
s/(ENV[^}]*)}/\1'] %>/g

