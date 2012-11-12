#!/bin/sh
# Start remote tomcats on admin and search

SCRIPTPATH="$(cd "${0%/*}" 2>/dev/null; echo "$PWD"/"${0##*/}")"
BASEPATH=`dirname $SCRIPTPATH`
CONFIG_FILE="$BASEPATH/config.sh"
source $CONFIG_FILE

for SERVER in ${SOLRMASTERSERVERS[@]}
do
  ssh polopoly@$SERVER /etc/init.d/tomcat start
  if [ "$?" == "0" ]
  then
    echo "Started tomcat on remote server ($SERVER)"
  else
    echo -e "$ERROR Failed to start tomcat on remote server ($SERVER)"
    exit 1
  fi
done

for SERVER in ${ADMINSERVERS[@]}
do
  ssh polopoly@$SERVER /etc/init.d/tomcat start
  if [ "$?" == "0" ]
  then
    echo "Started tomcat on remote server ($SERVER)"
  else
    echo -e "$ERROR Failed to start tomcat on remote server ($SERVER)"
    exit 1
  fi
done

