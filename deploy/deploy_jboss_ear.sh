#!/bin/sh

SCRIPTPATH="$(cd "${0%/*}" 2>/dev/null; echo "$PWD"/"${0##*/}")"
BASEPATH=`dirname $SCRIPTPATH`
CONFIG_FILE="$BASEPATH/config.sh"
source $CONFIG_FILE

cp $RELEASEDIRECTORY/deployment-cm/* /opt/jboss/server/default/deploy/polopoly/.
if [ "$?" == "0" ]
  then
    echo "Copied cm server ear, connection properties war and content hub war to jboss"
  else
    echo "Failed to copy cm server ear, connection properties war and content hub war"
    exit 1
fi

#cp $RELEASEDIRECTORY/deployment-cm/cm-server*.ear /opt/jboss/server/default/deploy/polopoly/.
#if [ "$?" == "0" ]
#  then
#    echo "Deployed cm server ear"
#  else
#    echo "Failed to deploy cm server ear"
#    exit 1
#fi
#inform "Waiting for cm-server ear to deploy."
#sleepFor "30"

#cp $RELEASEDIRECTORY/deployment-cm/connection-properties*.war /opt/jboss/server/default/deploy/polopoly/.
#if [ "$?" == "0" ]
#  then
#    echo "Deployed connection-properties war"
#  else
#    echo "Failed to deploy connection-properties war"
#    exit 1
#fi
#inform "Waiting for connection-properties war to deploy."
#sleepFor "30"

#cp $RELEASEDIRECTORY/deployment-cm/content-hub.war /opt/jboss/server/default/deploy/polopoly/.
#if [ "$?" == "0" ]
#  then
#    echo "Deployed content-hub.war"
#  else
#    echo "Failed to deploy content-hub.war"
#    exit 1
#fi
#inform "Waiting for content-hub.war to deploy."
#sleepFor "30"
 
