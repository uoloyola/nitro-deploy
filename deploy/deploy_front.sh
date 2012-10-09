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
# DEPLOY TO FRONT SERVERS
#

for FRONT in ${FRONTSERVERS[@]}
do
  ssh polopoly@$FRONT /opt/polopoly/scripts/front/clean_webapps.sh
  scp -B $RELEASEDIRECTORY/deployment-front/* $FRONT:/opt/tomcat/webapps/.

  if [ "$?" == "0" ]
  then
    echo "Deployed new front webapp ($FRONT)"
  else
    echo "Failed deploying new front webapp ($FRONT)!"
    exit 1
  fi
done
