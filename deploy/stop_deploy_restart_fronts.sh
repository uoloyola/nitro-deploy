#!/bin/sh

SCRIPTPATH="$(cd "${0%/*}" 2>/dev/null; echo "$PWD"/"${0##*/}")"
BASEPATH=`dirname $SCRIPTPATH`
CONFIG_FILE="$BASEPATH/config.sh"
source $CONFIG_FILE

if [ -z "$FRONTSERVERS" ]
then
  echo "Missing front server configuration in file $CONFIG_FILE"
  exit 1
fi

#
# STOP, DEPLOY AND START FRONT SERVERS
#

for FRONT in ${FRONTSERVERS[@]}
do
  ssh polopoly@$FRONT /etc/init.d/tomcat force-stop
  ssh polopoly@$FRONT /opt/polopoly/scripts/front/clean_webapps.sh
  scp -B $RELEASEDIRECTORY/deployment-front/* $FRONT:/opt/tomcat/webapps/.
  ssh polopoly@$FRONT /etc/init.d/tomcat start

  if [ "$?" == "0" ]
  then
    echo "Stopped tomcat, deployed new front webapp and restarted tomcat ($FRONT)"
  else
    echo "Failed to stop tomcat, deploy new front webapp and restart tomcat ($FRONT)!"
    exit 1
  fi
  # Wait 5 seconds before the next front
  sleep 5
done
