/*------------------------------------------------------------------------*\
** Program :get-tab1x01-with-proc-groovy.sas 
** Purpose : generate table 14.1.1
** Notes: 
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

proc print data=tab1x01 width=min;
    var ittfl col1z1 col1z2 col2z1 col2z2 col3z1 col3z2 col4z1 col4z2;
run;


/* The rest is from get-tab1x01.sas - put in  include file, so the code is shared */

proc format;
    picture pctfmt(round max=6) low-high='0009%)' (prefix="(");
run;

run;
data tab1x01_pres;
    set tab1x01;
	/* This could be derived in the SPARQL query */
    rowlabel= catx(" ", ifc( ittfllevellabel    ="Y",ittflVarLabel, " "),    
        ifc( saffllevellabel    ="Y",safflVarLabel, " "),    
        ifc( efffllevellabel    ="Y",effflVarLabel, " "),    
        ifc( comp24fllevellabel ="Y",comp24flVarLabel, " "), 
        ifc( disconfllevellabel   ="N",disconflVarLabel, " ") );

    format col1z1 col2z1 col3z1 col4z1 f5.0;
    format col1z2 col2z2 col3z2 col4z2 pctfmt.;
run;

ods html file="tab1x01.html"(title= "Table 14.1.1 from ARM RDF data cube")
    style=minimal;
* ods pdf file="tab1x01.pdf" style=minimal;
* ods tagsets.rtf file="tab1x01.rtf";




title;

proc report data=tab1x01_pres missing nofs split="¤";
    column
        (" "                    rowlabel)
        ("Placebo"              col1z1URI col1z1 col1z2URI col1z2)
        ("Xanomeline¤Low Dose"  col2z1URI col2z1 col2z2URI col2z2)
        ("Xanomeline¤High Dose" col3z1URI col3z1 col3z2URI col3z2)
        ("Total"                col4z1URI col4z1 col4z2URI col4z2)
        ;

/* Width statement only applies for listing output.

   The use of  call define(_col_, "format" ... is included to show how to programmatically
   change the format. As all values uses the same format, it is not needed for this table.

    */
        
    define rowlabel / " " display width=25 flow;

/* Replace code below with macro call, for main column 1 to 4, sub column 1 to 2 */    

    define col1z1URI / noprint;
    define col1z1 / " " width=6 flow display;
    compute col1z1;
    call define(_col_,"URL",col1z1URI);
    endcomp;

    define col1z2URI / noprint;
    define col1z2 / " " width=6 flow display;
    compute col1z2;
    call define(_col_,"format", "pctfmt.");
    call define(_col_,"URL",col1z2URI);
    endcomp;

    define col2z1 / " " width=6 flow display;
    define col2z1URI / noprint;
    compute col2z1;
    call define(_col_,"URL",col2z1URI);
    endcomp;

    define col2z2URI / noprint;
    define col2z2 / " " width=6 flow display;
    compute col2z2;
    call define(_col_,"format", "pctfmt.");
    call define(_col_,"URL",col2z2URI);
    endcomp;

    define col3z1URI / noprint;
    define col3z1 / " " width=6 flow display;
    compute col3z1;
    call define(_col_,"URL",col3z1URI);
    endcomp;

    define col3z2URI / noprint;
    define col3z2 / " " width=6 flow display;
    compute col3z2;
    call define(_col_,"format", "pctfmt.");
    call define(_col_,"URL",col3z2URI);
    endcomp;

    define col4z1URI / noprint;
    define col4z1 / " " width=6 flow display;
    compute col4z1;
    call define(_col_,"URL",col4z1URI);
    endcomp;

    define col4z2URI / noprint;
    define col4z2 / " " width=6 flow display;
    compute col4z2;
    call define(_col_,"format", "pctfmt.");
    call define(_col_,"URL",col4z2URI);
    endcomp;

run;

ods html close;
* ods tagsets.rtf close;
* ods pdf close;
