#! /bin/sh
THISDIR=`dirname $0`
cd ${THISDIR}
python3 -m http.server 8080
