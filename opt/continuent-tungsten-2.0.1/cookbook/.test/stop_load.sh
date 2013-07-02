#!/bin/bash

TMP=/tmp

if [ -n "$TMPDIR" ]
then
    TMP=$TMPDIR
elif [ -n "$TEMPDIR" ]
then
    TMP=$TEMPDIR
else
    TMP=/tmp
fi

if [ ! -d $TMP ]
then
    echo "temporary directory $TMP not found"
    exit 1
fi

if [ -f $TMP/evaluator.pid ]
then
    PID=$(cat $TMP/evaluator.pid)
    if [ -n "$PID" ]
    then
        echo "stopping evaluator at pid $PID"
        kill $PID
        rm -f $TMP/evaluator.pid
    else
        echo "No pid found in $TMP/evaluator.pid"
    fi
else
    echo "could not find evaluator.pid"
    exit 1
fi


