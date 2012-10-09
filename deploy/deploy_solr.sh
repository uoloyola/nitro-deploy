#!/bin/sh

SCRIPTPATH="$(cd "${0%/*}" 2>/dev/null; echo "$PWD"/"${0##*/}")"
BASEPATH=`dirname $SCRIPTPATH`
CONFIG_FILE="$BASEPATH/config.sh"
source $CONFIG_FILE

if [ -z "$SOLRMASTERSERVERS" ]
then
  echo "Missing solr server configuration in file $CONFIG_FILE"
  exit 1
fi

#
# DEPLOY TO SOLR MASTERS
#
for SOLRMASTER in ${SOLRMASTERSERVERS[@]}
do
  ssh polopoly@$SOLRMASTER /opt/polopoly/scripts/search/clean_webapps.sh
  scp -B $RELEASEDIRECTORY/deployment-servers/* $SOLRMASTER:/opt/tomcat/webapps/.

  if [ "$?" == "0" ]
  then
    echo "Deployed new solr master webapp ($SOLRMASTER)"
  else
    echo "Failed to deploy solr master webapp ($SOLRMASTER)!"
    exit 1
  fi
done
