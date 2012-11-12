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

step0(){
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
}

step1(){
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
}

step2(){
#
# STOP JBOSS
#
if [ $JBOSS_REDEPLOY ] || [ $CLEAN_DB ]; then
 inform "Step 2. Stopping jboss."
 /etc/init.d/jboss "stop"
 if [ "$?" != "0" ]
 then
 echo -e "$ERROR Failed jboss stop. Stopping!"
 exit 1
 fi
else
 inform "Skipping (JBOSS_REDEPLOY or CLEAN_DB not set): Step 2. Stopping jboss."
fi
}

step3(){
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
}

step4(){
inform "Step 4. Distributing solr indexer and solr master webapps."
./deploy/deploy_solr.sh
if [ "$?" != "0" ]
then
  echo -e "$ERROR Failed deploy_solr. Stopping!"
  exit 1
fi
}

step5(){
if [ $CLEAN_DB ]; then
 inform "Step 5. Cleaning solr indexes data."
  ./deploy/clean_solr_data.sh 
  if [ "$?" != "0" ]
   then
    echo -e "$ERROR Failed cleaning solr indexes data. Stopping!"
    exit 1
  fi
else
 inform "Skipping (CLEAN_DB not set): Step 5. Cleaning solr indexes data."
fi
}

step6(){
if [ $CLEAN_DB ]; then
  inform "Step 6. Init and clear db."
  ./deploy/init_db.sh
  if [ "$?" != "0" ]
  then
    echo -e "$ERROR Failed init_db. Stopping!"
    exit 1
  fi
else
 inform "Skipping (CLEAN_DB not set): Step 6. Init and clear db."
fi
}

step7(){
#
# Deploy CM server ear and connection.properties war
if [ $JBOSS_REDEPLOY ]; then
 inform "Step 7. Deploying CM server ear and connection properties wars."
 ./deploy/deploy_jboss_ear.sh
 if [ "$?" != "0" ]
 then
  echo -e "$ERROR Failed deploying CM server ear and connection properties . Stopping!"
  exit 1
 fi
else
 inform "Skipping (JBOSS_REDEPLOY not set): Step 7. Deploying CM server ear and connection properties wars."
fi
}

step8(){
# Start JBoss
if [ $JBOSS_REDEPLOY ] || [ $CLEAN_DB ]; then
 inform "Step 8. Starting jboss."
 /etc/init.d/jboss "start"
 if [ "$?" != "0" ]
 then
  echo -e "$ERROR Failed jboss start. Stopping!"
  exit 1
 fi
 waitForJboss
else
 inform "Skipping (JBOSS_REDEPLOY or CLEAN_DB not set): Step 8. Starting jboss."
fi
}

step9(){
if [ $JBOSS_REDEPLOY ] || [ $CLEAN_DB ]; then
 inform "Step 9. Importing polopoly content."
 ./initial_polopoly_import.sh
 if [ "$?" != "0" ]
 then
  echo -e "$ERROR Failed initial_polopoly_import. Stopping!"
  exit 1
 fi
else
 inform "Skipping (JBOSS_REDEPLOY or CLEAN_DB not set): Step 9. Importing polopoly content."
fi
}

step10(){
inform "Step 10. Importing project content."
./import_content.sh
if [ "$?" != "0" ]
then
  echo -e "$ERROR Failed import_content. Stopping!"
  exit 1
fi
}

step11(){
#
# START REMOTE TOMCAT SERVERS
#
inform "Step 11. Starting remote tomcat servers."
./deploy/start_remote_tomcats.sh
if [ "$?" != "0" ]
then
  echo -e "$ERROR Failed start_remote_tomcats. Stopping!"
  exit 1
fi
}

step12(){
inform "Step 12. Stopping tomcat, distributing webapps and restarting tomcat on fronts."
./deploy/stop_deploy_restart_fronts.sh
if [ "$?" != "0" ]
then
  echo -e "$ERROR Failed stop_deploy_restart_fronts. Stopping!"
  exit 1
fi
}

step13(){
#
# DEPLOY TO DISASTER RECOVERY ENV
#
if [  "$DEPLOYENVIRONMENT" == "production" ]; then
 inform "Step 13. Deploying to Disaster Recovery environment."
 ./deploy/deploy_disaster_recovery.sh
 if [ "$?" != "0" ]
  then
   echo -e "$ERROR Failed deploy_disaster_recovery. Stopping!"
   exit 1
 fi
else
 inform "Skipping (DEPLOYENVIRONMENT is not production): Step 13. Deploying to Disaster Recovery environment."
fi
}

runstep(){
case "$1" in
0) step0 ;;
1) step1 ;;
2) step2 ;;
3) step3 ;;
4) step4 ;;
5) step5 ;;
6) step6 ;;
7) step7 ;;
8) step8 ;;
9) step9 ;;
10) step10 ;;
11) step11 ;;
12) step12 ;;
13) step13 ;;
*) echo "Invalid step number $1" ;;
esac
}

if [ -n "$1" ]; then
 if ! [[ $1 =~ ^[0-9]+$ ]] || ! [[ $1 -ge 0 ]] || ! [[ $1 -le 13 ]]; then
   echo "$1 is not a valid step number! (0-13)"
   exit 1
 fi
fi

START="$1"; shift
[ -z "$START" ] && START=0
for i in $(seq "$START" 13); do
 runstep $i
done
inform "The release is finished!"
