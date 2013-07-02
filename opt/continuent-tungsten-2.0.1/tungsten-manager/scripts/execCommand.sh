#!/bin/bash
#
# Tungsten Manager @VERSION@
# (c) 2009 Continuent, Inc.  All rights reserved.
#
#
COMMANDS_LOG="`dirname $0`/../log/commands.log"

log () {
 echo "BEGIN: `date`" >> $COMMANDS_LOG
 echo "COMMAND:  $*" >> $COMMANDS_LOG
 echo "END: `date`" >> $COMMANDS_LOG
}

#
# All events start with the time the event was generated
#
log $*
$*
