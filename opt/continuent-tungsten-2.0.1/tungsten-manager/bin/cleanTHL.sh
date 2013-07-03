#!/bin/bash
if [ $# -ne 1 ];
then
  echo "usage: $0 <thl-log-directory>"
  exit 1
fi

thl_log_dir=$1

if [ ! -d $thl_log_dir ];
then
  echo "The path $thl_log_dir must refer to an existing directory"
  exit 1
fi

rm -rfv $thl_log_dir/* | sort
exit $?

