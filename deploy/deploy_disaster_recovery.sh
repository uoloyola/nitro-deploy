#!/bin/sh

SCRIPTPATH="$(cd "${0%/*}" 2>/dev/null; echo "$PWD"/"${0##*/}")"
BASEPATH=`dirname $SCRIPTPATH`
CONFIG_FILE="$BASEPATH/config.sh"
source $CONFIG_FILE

if [ -z "$FRONTSERVERS_DR" ]
then
  echo "Missing front server DR configuration in file $CONFIG_FILE"
  exit 1
fi

#
# DEPLOY TO FRONT SERVERS DR
#

for FRONT in ${FRONTSERVERS_DR[@]}
do
  ssh polopoly@$FRONT /opt/polopoly/scripts/front/clean_webapps.sh
  scp -B $RELEASEDIRECTORY/deployment-front/* $FRONT:/opt/tomcat/webapps/.

  if [ "$?" == "0" ]
  then
    echo "Deployed new front DR webapp ($FRONT)"
  else
    echo "Failed deploying new front DR  webapp ($FRONT)!"
    exit 1
  fi
done

if [ -z "$ADMINSERVERS_DR" ]
then
  echo "Missing admin server DR configuration in file $CONFIG_FILE"
  exit 1
fi

#
# DEPLOY TO ADMIN SERVERS DR
#
for ADMIN in ${ADMINSERVERS_DR[@]}
do
  ssh polopoly@$ADMIN /opt/polopoly/scripts/adm/clean_webapps.sh
  scp -B $RELEASEDIRECTORY/deployment-polopoly-gui/* $ADMIN:/opt/tomcat/webapps/.

  if [ "$?" == "0" ]
  then
    echo "Deployed new polopoly admin DR webapp ($ADMIN)"
  else
    echo "Failed to deploy polopoly admin DR webapp ($ADMIN)!"
    exit 1
  fi
done

if [ -z "$SOLRMASTERSERVERS_DR" ]
then
  echo "Missing solr server DR configuration in file $CONFIG_FILE"
  exit 1
fi

#
# DEPLOY TO SOLR MASTERS DR
#
for SOLRMASTER in ${SOLRMASTERSERVERS_DR[@]}
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


# DEPLOY TO JBOSS DR
scp -B  $RELEASEDIRECTORY/deployment-cm/* $JBOSS_HOST_DR:/opt/jboss/server/default/deploy/polopoly/.
if [ "$?" == "0" ]
  then
    echo "Copied cm server ear, connection properties war and content hub war to jboss DR"
  else
    echo "Failed to copy cm server ear, connection properties war and content hub war to jboss DR"
    exit 1
fi

