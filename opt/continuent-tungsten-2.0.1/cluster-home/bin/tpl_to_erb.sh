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
  for file in `find $dir_to_start -type f -name \*.tpl -print`; 
  do 
    #echo $file;
    filename_and_type=`basename $file`
    filename_only=${filename_and_type%.*}
    directory=`dirname $file`
    erbfile="${directory}/${filename_only}.erb"
    echo "$filename_and_type ==> $erbfile"
    cat $file | sed -E -f tpl_to_erb.sed  > $erbfile
  done
done
