/*------------------------------------------------------------------------*\
** Program : example-localhost-07.sas
** Purpose : Basic test of SAS-SPARQLwrapper using a query and local server
** Endpoint: localhost    
** Notes: SAS must be invoked with unicode support   
** Status: ok    
\*------------------------------------------------------------------------*/

options linesize=200;

options mprint nocenter;

libname this ".";

%let cubestemname=tab1x01;
%let cubettlfile=../res-ttl/CDISC-pilot-%upcase(&cubestemname).ttl;
%let rqfile=../sparql-rq/&cubestemname..rq;
%let outxmlfile=check-CDISC-pilot-%upcase(&cubestemname).xml;
%let tabletitle=%str(Table 14.1.1 from ARM RDF data cube);

%include "include-jena-groovy.sas" /source;

data this.&cubestemname.;
    set &cubestemname.;
run;

proc contents data=this.&cubestemname. varnum;
run;

data &cubestemname.;
    set this.&cubestemname.;
run;

proc print data=tab1x01 width=min;
    var ittfl col1z1 col1z2 col2z1 col2z2 col3z1 col3z2  col4z1 col4z2;
run;

data tab1x01_pres;
    set tab1x01;
	/* This could be derived in the SPARQL query */
    rowlabel= catx(" ", ifc( ittfllevellabel    ="Y",ittflVarLabel, " "),    
        ifc( saffllevellabel    ="Y",safflVarLabel, " "),    
        ifc( efffllevellabel    ="Y",effflVarLabel, " "),    
        ifc( comp24fllevellabel ="Y",comp24flVarLabel, " "), 
        ifc( compfllevellabel   ="Y",compflVarLabel, " ") );
    format col1z2 col2z2 col3z2 col4z2 f5.1;
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

    define col2z1URI / noprint;
    compute col2z1;
    call define(_col_,"URL",col2z1URI);
    endcomp;
    define col2z2URI / noprint;
    compute col2z2;
    call define(_col_,"URL",col2z2URI);
    endcomp;

    define col3z1URI / noprint;
    compute col3z1;
    call define(_col_,"URL",col3z1URI);
    endcomp;
    define col3z2URI / noprint;
    compute col3z2;
    call define(_col_,"URL",col3z2URI);
    endcomp;

    define col43z1URI / noprint;
    compute col43z1;
    call define(_col_,"URL",col4z1URI);
    endcomp;
    define col43z2URI / noprint;
    compute col43z2;
    call define(_col_,"URL",col4z2URI);
    endcomp;

run;

ods html close;
* ods tagsets.rtf close;
* ods pdf close;
