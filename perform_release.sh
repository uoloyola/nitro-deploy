#!/bin/bash
####################################################################
# This is the main release script
#
# There should be no evironment specific configuration in this file
# All configuration goes into deploy/${targetEnv}.config
####################################################################

SCRIPTPATH="$(cd "${0%/*}" 2>/dev/null; echo "$PWD"/"${0##*/}")"
BASEPATH=`dirname $SCRIPTPATH`
CONFIG_FILE="$BASEPATH/deploy/config.sh"
source $CONFIG_FILE

#CLASSPATH=$CLASSPATH:/opt/polopoly/install/lib/slf4j-api-1.6.0.jar:/opt/polopoly/install/lib/slf4j-jdk14-1.6.0.jar
#export CLASSPATH

# Redirect stdin and stdout to log file also
exec > >(tee install.log)
exec 2>&1

STARTINFO="Started "`basename $0`" at "`date`", environment: $DEPLOYENVIRONMENT"
inform "$STARTINFO"

checkMandatoryVariables
if [ "$?" != "0" ]
then
  echo -e "$ERROR Missing mandatory variable in config file \"$CONFIG_FILE\". Stopping!"
  exit 1
fi

#
# UNPACKING THE RELEASE IN DISTRIBUTION DIRECTORY 
#
inform "Step 0. Unpacking the release."
./deploy/unpack_release.sh "$1"
if [ "$?" != "0" ]
then
  echo -e "$ERROR Failed unpack_release. Stopping!"
  exit 1
fi

#
# STOP REMOTE POLOPOLY SERVERS
#
inform "Step 1. Stopping remote backend tomcat servers."
./deploy/stop_backend_tomcats.sh
if [ "$?" != "0" ]
then
  echo -e "$ERROR Failed stop_remote_tomcats. Stopping!"
  exit 1
fi

#
# STOP JBOSS
#
inform "Step 2. Stopping jboss."
/etc/init.d/jboss "stop"
if [ "$?" != "0" ]
then
echo -e "$ERROR Failed jboss stop. Stopping!"
exit 1
fi

#
# DISTRIBUTE THE RELEASE
#
inform "Step 3. Distributing admin webapps."
./deploy/deploy_admin.sh 
if [ "$?" != "0" ]
then
  echo -e "$ERROR Failed deploy_admin. Stopping!"
  exit 1
fi

inform "Step 4. Distributing solr indexer and solr master webapps."
./deploy/deploy_solr.sh
if [ "$?" != "0" ]
then
  echo -e "$ERROR Failed deploy_solr. Stopping!"
  exit 1
fi

if [ $CLEAN_DB ]; then
 inform "Step 5. Cleaning solr indexes data."
  ./deploy/clean_solr_data.sh 
  if [ "$?" != "0" ]
   then
    echo -e "$ERROR Failed cleaning solr indexes data. Stopping!"
    exit 1
  fi
fi

if [ $CLEAN_DB ]; then
  inform "Step 5.b Init and clear db."
  ./deploy/init_db.sh
  if [ "$?" != "0" ]
  then
    echo -e "$ERROR Failed init_db. Stopping!"
    exit 1
  fi
fi


#
# Deploy CM server ear and connection.properties war
inform "Step 6. Deploying CM server ear and connection properties wars."
./deploy/deploy_jboss_ear.sh
if [ "$?" != "0" ]
then
  echo -e "$ERROR Failed deploying CM server ear and connection properties . Stopping!"
  exit 1
fi

# Start JBoss
inform "Step 7. Starting jboss."
/etc/init.d/jboss "start"
if [ "$?" != "0" ]
then
echo -e "$ERROR Failed jboss start. Stopping!"
exit 1
fi
waitForJboss


inform "Step 8. Importing polopoly content."
./deploy/initial_polopoly_import.sh
if [ "$?" != "0" ]
then
  echo -e "$ERROR Failed initial_polopoly_import. Stopping!"
  exit 1
fi


inform "Step 9. Importing project content."
./deploy/import_content.sh
if [ "$?" != "0" ]
then
  echo -e "$ERROR Failed import_content. Stopping!"
  exit 1
fi

inform "Step 10. Stopping frontend tomcats."
./deploy/stop_frontend_tomcats.sh
if [ "$?" != "0" ]
then
  echo -e "$ERROR Fail during frontend tomcats shutdown. Stopping!"
  exit 1
fi


inform "Step 11. Distributing front webapps."
./deploy/deploy_front.sh
if [ "$?" != "0" ]
then
  echo -e "$ERROR Failed deploy_front. Stopping!"
  exit 1
fi


#
# START REMOTE TOMCAT SERVERS
#
inform "Step 12. Starting remote tomcat servers."
./deploy/start_remote_tomcats.sh
if [ "$?" != "0" ]
then
  echo -e "$ERROR Failed start_remote_tomcats. Stopping!"
  exit 1
fi

inform "The release is finished!"
