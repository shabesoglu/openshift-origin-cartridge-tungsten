#!/bin/bash
set +x
for props in `find $CONTINUENT_ROOT/tungsten/*/conf/ -type f -name \*.properties -print`;
do
  #echo $props
  for propline in `cat $props | grep -v "^#" | grep -e "^.[^=]*="`;
  do
    #echo "####### 1 ########"
    #echo $propline
    prop=`echo $propline | awk -F\= '{print $1}' | tr -d ' ' | grep "."`
    value=`echo $propline | awk -F\= '{print $2}'| tr -d ' '`
    hasPeriod=`echo $prop | grep "\."`
    if [ $? -eq 0 ];
    then
      if [ "$value" != "" ];
      then
        infiles=`grep -l -e "$prop\$" *.erb`
        if [ "$infiles" != "" ];
        then
          for infile in `echo $infiles`;
          do
             trimmedValue=`echo "$value" | tr -d ' '`
             echo "setting property $prop in $infile to '$trimmedValue'"
             echo $trimmedValue >> $infile
          done
        fi
      fi
    fi
  done
done

