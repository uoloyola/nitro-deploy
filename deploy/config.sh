#!/bin/sh
################################################################
# This script will source the correct configuration file 
# for the current environment.
# Environment information is extracted from the hostname
################################################################

DEPLOY_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# expecting hostname in the form: jboss.stage.per
CONFIG_PREFIX=`echo $HOSTNAME | cut -d"." -f2`

source $DEPLOY_DIR/$CONFIG_PREFIX.config

CONFIG_LOADED=true

###############################################
# Non installation specific variables follows 

COL_RED="\x1b[31;01m"
COL_ORANGE="\x1b[33;01m"
COL_BLUE="\x1b[34;01m"
COL_PURPLE="\x1b[35;06m"
COL_RESET="\x1b[39;49;00m"

# Pre-defined, colorized text strings
ERROR=$COL_RED"ERROR"$COL_RESET
WARNING=$COL_ORANGE"WARNING"$COL_RESET

##############################################
# General functions


# Demands confirmation from user to continue
function getConfirmation {
	while true; do
		read -p "Do you want to continue? (y/n):" yn
			case $yn in
			[Yy]* ) break;;
	[Nn]* ) return 1;;
	* ) echo "Please answer yes or no.";;
	esac
		done
		return 0
}

function waitForJboss {
    SLEEP_TIME=5
    MAX_TRIES=12
    URL=http://$JBOSS_HOST:8081/connection-properties/connection.properties
    echo -n "Waiting for for Jboss to start: "
    while [ 1 = 1 ]; do
      [ $MAX_TRIES -eq 0 ] && echo " max wait exceeded. halting deploy!" && exit 1
      let MAX_TRIES-=1
      echo -n "."
      curl $URL &>/dev/null
      [ $? -eq 0 ] && echo " Jboss is up!"  && return 0
      sleep 5
    done
}

# Sleep for a number of seconds, given by the argument
# If no argument is given, it defaults to 5 seconds 
function sleepFor {
	SLEEP_TIME=5
		if [ ! -z "$1" ] 
			then
				SLEEP_TIME=$1
				fi

				echo -n "Waiting for $SLEEP_TIME seconds: " 
				for SECOND in `seq $SLEEP_TIME -1 1` 
					do
						echo -n "$SECOND, "
							sleep 1
							done
							echo "0"
}

# Echoes the message given as argument 1 to screen
# A color code for the text can be given as argument 2 
# if no color code is supplied, default is purple
function inform {
	TEXTCOLOR=$COL_PURPLE
		if [ ! -z $2 ]
			then
				TEXTCOLOR=$2
				fi 
				echo -e $TEXTCOLOR"$1"$COL_RESET
}

# Check for mandatory variables that are critical, in order to minimize 
# the risk of a release script malfunctions
function checkMandatoryVariables {
	if [ -z "$MUSTBEDEFINED" ]
		then
			echo "Could not find info about mandatory variables in config file"
			return 1 
			fi
			for MANDATORY in ${MUSTBEDEFINED[@]}
	do
		VARIABLE=${!MANDATORY}
	if [ -z "$VARIABLE" ]
		then 
			echo "Undefined variable \"$MANDATORY\""
			return 1
			fi
			done
			return 0
}

