#!/bin/bash
if [ $# -ne 3 ];
then
  echo "usage: $0 <env-file> <prop-lookup-file> <out-dir>"
  exit 1
fi

envFile=$1
propLookup=$2
outDir=$3

if [ ! -f "$envFile" ];
then
  echo "$envFile does not exist or is not readable..."
  exit 1
fi

for name in `cat $envFile`;
do
   envFname=$outDir/${name}.erb
   props=`grep $name $propLookup | awk -F\= '{print $1}'`
   #echo "PROPERTIES FOR $name"
   #echo "####  $props ####"
   rm -f $envFname
   touch $envFname
   echo "###########################################################################" >> $envFname
   echo "#  Continuent Tungsten Environment variable definition for OpenShift" >> $envFname 
   echo "#" >> $envFname
   echo "#  $name.erb" >> $envFname
   echo "#" >> $envFname
   echo "#" >> $envFname
   echo "#  This environment variable is used to set the following Tungsten properties:" >> $envFname
   echo "#" >> $envFname
   for prop in `echo $props`;
   do
      echo "#  $prop" >> $envFname
   done  
   echo "#" >> $envFname
   echo "###########################################################################" >> $envFname
done

