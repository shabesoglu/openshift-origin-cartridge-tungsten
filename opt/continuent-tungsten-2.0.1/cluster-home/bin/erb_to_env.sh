#!/bin/bash
if [ $# -lt 1 ];
then
  echo "usage: $0 <directory_to_start_at>"
  exit 1
fi
directories=$*

for dir_to_start in $directories;
do
  echo
  echo "#####################################################"
  echo "PROCESSING $dir_to_start"
  echo "#####################################################"
  for file in `find $dir_to_start -type f -name \*.erb -print`; 
  do 
    echo "#####################################################"
    echo "PROCESSING $file"
    echo "#####################################################"
    #filename_and_type=`basename $file`
    #filename_only=${filename_and_type%.*}
    #env_file="${directory}/${filename_only}.erb"
    #echo "$filename_and_type ==> $erbfile"
    cat $file | sed -E -n -f erb_to_env.sed  
  done
done
