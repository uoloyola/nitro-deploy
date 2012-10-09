#!/bin/bash
####################################################################
# Use this script to download distribution files form 
# kataweb ftp distribution repository
#
# This script will automatically clean-up old distributions, 
# use MAX_KEEP to set the number of dists that should
# be kept in ftp. 
####################################################################

# for this script to work you must add the following line in ~/.netrc : 
# machine ftp.where-you-keep-the.dist login your-login-name password your-password

SCRIPTPATH="$(cd "${0%/*}" 2>/dev/null; echo "$PWD"/"${0##*/}")"
BASEPATH=`dirname $SCRIPTPATH`
CONFIG_FILE="$BASEPATH/deploy/config.sh"
source $CONFIG_FILE


if [ -z "$FTP_DIST_FOLDER" ]; then
  echo "you must define the FTP_DIST_FOLDER variable first" 
  exit 1 
fi
FTP_SERVER="ftp.kataweb.it"
MAX_KEEP=3


remove_file() {
 filename=$FTP_DIST_FOLDER/$1
 lftp $FTP_SERVER -e "rm $filename; exit;"
}

# first we check if there are old dists in the repo that we should clean up
COUNTER=0
for DIST in `lftp $FTP_SERVER -e "ls -t $FTP_DIST_FOLDER; exit;" | awk '{print $9}'`
do
  let COUNTER=COUNTER+1 
  if [ $COUNTER -gt $MAX_KEEP ]
    then
    remove_file $DIST
  fi 
done

inform "Environment: $DEPLOYENVIRONMENT"
inform "downloading to $DISTDIRECTORY"

# then either list or donwlad
if [ $# -ne 1 ] 
 then
 inform "Usage: $0 release_dist.jar" 
 inform "the following release are available in the remote repo: "
 lftp $FTP_SERVER -e "ls $FTP_DIST_FOLDER; exit;"
else
 inform "downloading $1"
 lftp $FTP_SERVER -e "lcd $DISTDIRECTORY; get $FTP_DIST_FOLDER/$1; exit;"
fi
