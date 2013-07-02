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
    if [ -f $file ]; 
    then
      echo "removing $file"
      rm $file
    fi
  done
done
