#!/bin/sh

SCRIPTPATH="$(cd "${0%/*}" 2>/dev/null; echo "$PWD"/"${0##*/}")"
BASEPATH=`dirname $SCRIPTPATH`
CONFIG_FILE="$BASEPATH/config.sh"
source $CONFIG_FILE

ssh -t polopoly@$DB_HOST /opt/polopoly/scripts/db/clear_polopoly_db.sh
  if [ "$?" == "0" ]
  then
    echo "Cleared polopoly db"
  else
    echo -e "$ERROR Failed to clear polopoly db"
    exit 1
  fi
