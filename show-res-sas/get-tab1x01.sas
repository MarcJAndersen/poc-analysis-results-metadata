/*------------------------------------------------------------------------*\
** Program : example-localhost-07.sas
** Purpose : Basic test of SAS-SPARQLwrapper using a query and local server
** Endpoint: localhost    
** Notes: SAS must be invoked with unicode support   
** Status: ok    
\*------------------------------------------------------------------------*/

options mprint nocenter;

%include "../../SAS-SPARQLwrapper/sparqlquery.sas";

%sparqlquery(
    endpoint=http://192.168.1.115:3030/arm/query,
    queryfile=%str(../sparql-rq/tab1x01.rq),
    resultdsn=tab1x01,
    sparqlquerysxlemap=%str(../../SAS-SPARQLwrapper/sparqlquery-sxlemap.map)
);

proc print data=tab1x01 width=min;
    var col1z1 col1z2 col2z1 col2z2 col3z1 col3z2;
run;
