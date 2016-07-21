/*------------------------------------------------------------------------*\
** Program : 
** Purpose : 
** Endpoint: localhost    
** Notes: 
\*------------------------------------------------------------------------*/

options mprint nocenter;

%include "../../pharm/SAS-SPARQLwrapper/sparqlquery.sas";
%include "../../pharm/SAS-SPARQLwrapper/SPARQLREADXML.sas";

/* %let sparqlendpoint=http://192.168.1.115:3030/arm/query; */
%let sparqlendpoint=http://localhost:3030/arm/query;

%sparqlquery(
    endpoint=&sparqlendpoint.,
    queryfile=%str(../../PhARM/poc-analysis-results-metadata/sparql-rq/tab1x02_1.rq),
    resultdsn=tab1x02_1,
    sparqlquerysxlemap=%str(../../pharm/SAS-SPARQLwrapper/sparqlquery-sxlemap.map)
);

%include "inc-tab1x02_1.sas" / source2;
