#!/bin/sh

SCRIPTPATH="$(cd "${0%/*}" 2>/dev/null; echo "$PWD"/"${0##*/}")"
BASEPATH=`dirname $SCRIPTPATH`
CONFIG_FILE="$BASEPATH/config.sh"
source $CONFIG_FILE

if [ -z "$ADMINSERVERS" ]
then
  echo "Missing admin server configuration in file $CONFIG_FILE"
  exit 1
fi

#
# DEPLOY TO ADMIN SERVERS
#
for ADMIN in ${ADMINSERVERS[@]}
do
  ssh polopoly@$ADMIN /opt/polopoly/scripts/adm/clean_webapps.sh
  scp -B $RELEASEDIRECTORY/deployment-polopoly-gui/* $ADMIN:/opt/tomcat/webapps/.

  if [ "$?" == "0" ]
  then
    echo "Deployed new polopoly admin webapp ($ADMIN)"
  else
    echo "Failed to deploy polopoly admin webapp ($ADMIN)!"
    exit 1
  fi
done
 
