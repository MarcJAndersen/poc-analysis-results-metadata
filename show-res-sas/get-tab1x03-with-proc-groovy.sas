/*------------------------------------------------------------------------*\
** Program : check-apache-jena-with-proc-groovy.sas
** Purpose : Basic test of using Apache Jena java using proc groovy
** Notes: This is first version. Java code is not ideal.
** Notes: The macro getxml should be part of ../../SAS-SPARQLwrapper/sparqlquery.sas
** Status: ok    
\*------------------------------------------------------------------------*/

options linesize=200;

options mprint nocenter;

libname this ".";

%let cubestemname=tab1x03;
%let cubettlfile=../res-ttl/CDISC-pilot-%upcase(&cubestemname).ttl;
%let rqfile=../sparql-rq/&cubestemname..rq;
%let outxmlfile=check-CDISC-pilot-%upcase(&cubestemname).xml;
%let tabletitle=%str(Table 14.1.3 from ARM RDF data cube);

%include "include-jena-groovy.sas";

data this.&cubestemname.;
    set &cubestemname.;
run;


proc contents data=this.&cubestemname. varnum;
run;


data &cubestemname.;
    set this.&cubestemname.;
    label sitegr1value="Pooled id";
    label siteidvalue="Site id";
    label col1z1="ITT";  
label col2z1="Eff";  
label col3z1="Com";  
label col4z1="ITT";  
label col5z1="Eff";  
label col6z1="Com";  
label col7z1="ITT";  
label col8z1="Eff";  
label col9z1="Com";  
label col10z1="ITT"; 
label col11z1="Eff"; 
label col12z1="Com";
run;

proc print data=&cubestemname. width=min;
var 
    sitegr1value    siteidvalue
/*
    sitegr1 siteid 
    procedurez1 factorz1
*/    
col1z1URI  col1z1 
col2z1URI  col2z1 
col3z1URI  col3z1 
col4z1URI  col4z1 
col5z1URI  col5z1 
col6z1URI  col6z1 
col7z1URI  col7z1 
col8z1URI  col8z1 
col9z1URI  col9z1 
col10z1URI col10z1 
col11z1URI col11z1 
col12z1URI col12z1 
;

run;

ods html file="tab1x03.html"(title= "Table 14.1.3 from ARM RDF data cube")
    style=minimal;

proc report data=&cubestemname. missing nofs split="¤";
    column
        (" " sitegr1value    siteidvalue  )
        ("Placebo"
        col1z1URI col1z1 
        col2z1URI col2z1 
        col3z1URI col3z1 
              )
        ("Xanomeline¤Low Dose"
col4z1URI col4z1 
col5z1URI col5z1 
col6z1URI col6z1 
)
        ("Xanomeline¤High Dose"
        col7z1URI col7z1 
col8z1URI col8z1 
col9z1URI col9z1 
 )
        ("Total"
col10z1URI col10z1 
col11z1URI col11z1 
col12z1URI col12z1 
        )
        ;

    define sitegr1value     / order order=internal  ;
    define siteidvalue / order order=internal   width=40 flow;
    

%MACRO DefColumn;
    %local i;
 %do i=1 %to 12;   
    define col&i.z1URI / noprint;
    define col&i.z1 / " " width=6 flow display;
    compute col&i.z1;
    call define(_col_,"URL",col&i.z1URI);
    endcomp;
    %end;
    %MEND;

%DefColumn;

run;

ods html close;
* ods tagsets.rtf close;
* ods pdf close;
