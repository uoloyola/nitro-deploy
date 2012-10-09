#!/bin/sh
# Stop remote tomcats on fronts, admin and search

SCRIPTPATH="$(cd "${0%/*}" 2>/dev/null; echo "$PWD"/"${0##*/}")"
BASEPATH=`dirname $SCRIPTPATH`
CONFIG_FILE="$BASEPATH/config.sh"
source $CONFIG_FILE

for SERVER in ${ADMINSERVERS[@]}
do
  ssh polopoly@$SERVER /opt/polopoly/scripts/adm/stop_tomcat.sh
  if [ "$?" == "0" ]
  then
    echo "Stopped tomcat on remote server ($SERVER)"
  else
    echo -e "$ERROR Failed to stop tomcat on remote server ($SERVER)"
    echo -e "Ignore for now. Fix shutdown on adm."		
    #exit 1
  fi
done

for SERVER in ${SOLRMASTERSERVERS[@]}
do
  ssh polopoly@$SERVER /opt/polopoly/scripts/search/stop_tomcat.sh
  if [ "$?" == "0" ]
  then
    echo "Stopped tomcat on remote server ($SERVER)"
  else
    echo -e "$ERROR Failed to stop tomcat on remote server ($SERVER)"
    exit 1
  fi
done

