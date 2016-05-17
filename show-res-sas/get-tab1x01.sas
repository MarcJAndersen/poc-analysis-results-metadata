/*------------------------------------------------------------------------*\
** Program : example-localhost-07.sas
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
    queryfile=%str(../sparql-rq/tab1x01.rq),
    resultdsn=tab1x01,
    sparqlquerysxlemap=%str(../../SAS-SPARQLwrapper/sparqlquery-sxlemap.map)
);

proc print data=tab1x01 width=min;
    var ittfl col1z1 col1z2 col2z1 col2z2 col3z1 col3z2;
run;

data tab1x01_pres;
    set tab1x01;
	/* This could be derived in the SPARQL query */
    rowlabel= catx(" ", ifc( ittfllevellabel    ="Y",ittflVarLabel, " "),    
        ifc( saffllevellabel    ="Y",safflVarLabel, " "),    
        ifc( efffllevellabel    ="Y",effflVarLabel, " "),    
        ifc( comp24fllevellabel ="Y",comp24flVarLabel, " "), 
        ifc( compfllevellabel   ="Y",compflVarLabel, " ") );
    format col1z2 col2z2 col3z2 f5.1;
run;

ods html file="tab1x01.html" style=minimal;
* ods pdf file="tab1x01.pdf" style=minimal;
* ods tagsets.rtf file="tab1x01.rtf";

proc report data=tab1x01_pres missing nofs;
    column rowlabel (col1z1URI col1z1 col1z2URI col1z2) (col2z1 col2z2) (col3z1 col3z2);
    define rowlabel / display width=40 flow;
    define col1z1 / display;
    define col2z1 / display;
    define col3z1 / display;
    
    define col1z2 / display;
    define col2z2 / display;
    define col3z2 / display;

    define col1z1URI / noprint;
    compute col1z1;
    call define(_col_,"URL",col1z1URI);
    endcomp;
    define col1z2URI / noprint;
    compute col1z2;
    call define(_col_,"URL",col1z2URI);
    endcomp;
run;

ods html close;
* ods tagsets.rtf close;
* ods pdf close;