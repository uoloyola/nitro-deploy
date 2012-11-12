#!/bin/sh
# Stop remote tomcats on admin and search

SCRIPTPATH="$(cd "${0%/*}" 2>/dev/null; echo "$PWD"/"${0##*/}")"
BASEPATH=`dirname $SCRIPTPATH`
CONFIG_FILE="$BASEPATH/config.sh"
source $CONFIG_FILE

for SERVER in ${ADMINSERVERS[@]}
do
  ssh polopoly@$SERVER /etc/init.d/tomcat force-stop
  if [ "$?" == "0" ]
  then
    echo "Stopped tomcat on remote server ($SERVER)"
  else
    echo -e "$ERROR Failed to stop tomcat on remote server ($SERVER)"
    exit 1
  fi
done

for SERVER in ${SOLRMASTERSERVERS[@]}
do
  ssh polopoly@$SERVER /etc/init.d/tomcat force-stop
  if [ "$?" == "0" ]
  then
    echo "Stopped tomcat on remote server ($SERVER)"
  else
    echo -e "$ERROR Failed to stop tomcat on remote server ($SERVER)"
    exit 1
  fi
done

