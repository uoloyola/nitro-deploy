#!/bin/sh
SCRIPTPATH="$(cd "${0%/*}" 2>/dev/null; echo "$PWD"/"${0##*/}")"
BASEPATH=`dirname $SCRIPTPATH`
CONFIG_FILE="$BASEPATH/config.sh"
source $CONFIG_FILE

java -jar $RELEASEDIRECTORY/deployment-config/polopoly-cli.jar import -s -c http://$JBOSS_HOST:8081/connection-properties/connection.properties $RELEASEDIRECTORY/deployment-config/polopoly-imports.jar
