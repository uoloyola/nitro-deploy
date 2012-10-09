#'!/bin/sh

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
# DEPLOY TO SOLR SERVERS
#
for SOLR in ${SOLRMASTERSERVERS[@]}
do
  ssh polopoly@$SOLR /opt/polopoly/scripts/search/clean_solr_data.sh
  if [ "$?" == "0" ]
  then
    echo "Cleaned solr indexes data ($SOLR)"
  else
    echo "Failed cleaning solr indexes data ($SOLR)!"
    exit 1
  fi
done

for SOLR in ${SOLRSLAVESERVERS[@]}
do
  ssh polopoly@$SOLR /opt/polopoly/scripts/front/clean_solr_data.sh
  if [ "$?" == "0" ]
  then
    echo "Cleaned solr indexes data ($SOLR)"
  else
    echo "Failed cleaning solr indexes data ($SOLR)!"
    exit 1
  fi
done

