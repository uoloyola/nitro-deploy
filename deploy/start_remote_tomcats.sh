#!/bin/sh
# Start remote tomcats on fronts, admin and search

SCRIPTPATH="$(cd "${0%/*}" 2>/dev/null; echo "$PWD"/"${0##*/}")"
BASEPATH=`dirname $SCRIPTPATH`
CONFIG_FILE="$BASEPATH/config.sh"
source $CONFIG_FILE

for SERVER in ${SOLRMASTERSERVERS[@]}
do
  ssh polopoly@$SERVER /opt/polopoly/scripts/search/start_tomcat.sh
  if [ "$?" == "0" ]
  then
    echo "Started tomcat on remote server ($SERVER)"
  else
    echo -e "$ERROR Failed to start tomcat on remote server ($SERVER)"
    exit 1
  fi
done


if [ -z "$FRONTSERVERS" ]
then
  echo -e "$ERROR Missing front server configuration in file $CONFIG_FILE"
  exit 1
fi


for SERVER in ${FRONTSERVERS[@]}
do
  ssh polopoly@$SERVER /opt/polopoly/scripts/front/start_tomcat.sh
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
  ssh polopoly@$SERVER /opt/polopoly/scripts/adm/start_tomcat.sh
  if [ "$?" == "0" ]
  then
    echo "Started tomcat on remote server ($SERVER)"
  else
    echo -e "$ERROR Failed to start tomcat on remote server ($SERVER)"
    exit 1
  fi
done

