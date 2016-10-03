# /bin/sh
THISDIR=`dirname $0`
cd ${THISDIR}
export FUSEKI_HOME=/opt/apache-jena-fuseki-2.0.0
${FUSEKI_HOME}/fuseki-server --config=poc-fuseki-config.ttl

