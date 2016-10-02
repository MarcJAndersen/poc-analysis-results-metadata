#!/bin/sh

THISDIR=`dirname $0`
cd ${THISDIR}
(gnome-terminal -x "res-ttl/poc-fuseki-server.sh")
(gnome-terminal -x "application-html/poc-html-server-start.sh")

