/*------------------------------------------------------------------------*\
** Program : check-connection-to-sparql-service.sas
** Purpose : Basic test of SAS-SPARQLwrapper using a query and local server
** Endpoint: localhost    
** Notes: SAS must be invoked with unicode support   
** Status: ok    
\*------------------------------------------------------------------------*/

options mprint nocenter;

%include "../../SAS-SPARQLwrapper/sparqlquery.sas";

/* %let sparqlendpoint=http://192.168.1.115:3030/arm/query; */

%let sparqlendpoint=http://localhost:3030/arm/query;

%sparqlquery(
    endpoint=&sparqlendpoint.,
    query=%str(select * where {?s ?p ?o} limit 20 ),
    sparqlquerysxlemap=%str(../../SAS-SPARQLwrapper/sparqlquery-sxlemap.map)
);

proc print data=queryresult width=min;
run;
