#!/bin/sh

SCRIPTPATH="$(cd "${0%/*}" 2>/dev/null; echo "$PWD"/"${0##*/}")"
BASEPATH=`dirname $SCRIPTPATH`
CONFIG_FILE="$BASEPATH/config.sh"
source $CONFIG_FILE

#
# UNPACK THE LATEST POLOPOLY RELEASE 
#
if [ -z "$DISTDIRECTORY" ]
then
  echo "Distribution directory not specified in $CONFIG_FILE"
  exit 1
fi

cd "$DISTDIRECTORY" 
if [ "$?" != "0" ]
then
    echo "Failed to change into directory $DISTDIRECTORY"
    exit 1
fi

# If no specific release jar is given, use the latest
if [ -z "$1" ]
then
  RELEASEJAR=`ls -tr *.tar.gz|tail -1`
else
  RELEASEJAR=$1
fi

if [ ! -e "$RELEASEJAR" ]
then
    echo "Failed to locate a release in $DISTDIRECTORY"
    if [ ! -e "latest_release" ] 
    then 
        echo "redeploying latest release .."
        exit 0
    else
        exit 1
    fi
else
    # Remove old idea of which release that is the latest 
    rm -f latest_release
fi



# Demand confirmation from user
while true; do
    read -p "Do you wish to release $RELEASEJAR ? (y/n):" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit 1;;
        * ) echo "Please answer yes or no.";;
    esac
done

# Create a release directory based on release files name, move release file there
# and jump into the directory
DIRNAME=`echo $RELEASEJAR | sed -e "s/\..*//"`
mkdir "$DIRNAME"
ln -s "$DIRNAME" "latest_release"
mv "$RELEASEJAR" "$DIRNAME/"
cd "$DIRNAME"

# Unpack release in release directory
echo "Unpacking release file: $RELEASEJAR"
tar xzf "$RELEASEJAR"

rm -f $RELEASEDIRECTORY
ln -s "$DISTDIRECTORY/$DIRNAME/dist" $RELEASEDIRECTORY
cd "$RELEASEDIRECTORY/deployment-config"
unzip "config.zip" 

if [ "$?" == "0" ]
then
    echo "Unpacked Polopoly successfully"
else
    echo "Failed to unpack Polopoly release!"
    exit 1
fi
