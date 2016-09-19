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

%let cubestemname=tab5x01;
%let cubettlfile=../res-ttl/CDISC-pilot-%upcase(&cubestemname).ttl;
%let rqfile=../sparql-rq/&cubestemname..rq;
%let outxmlfile=check-CDISC-pilot-%upcase(&cubestemname).xml;
%let tabletitle=%str(Table 14.5.1 from ARM RDF data cube);

%include "include-jena-groovy.sas" /source;

data this.&cubestemname.;
    set &cubestemname.;
run;

proc contents data=this.&cubestemname. varnum;
run;

data &cubestemname.;
    set this.&cubestemname.;
run;

proc print data=&cubestemname.(obs=10) width=min;
var 
/*
    agegr1label agegr1value
    ethniclabel ethnicvalue
    sexlabel sexvalue
    durdsgr1label durdsgr1value
    bmiblgr1label bmiblgr1value
    */
saffl   
trtemfl 
aesoc   
aedecod 
    procedurez1 factorz1
col1z1URI col1z1 /* col1z2URI col1z2 */
col2z1URI col2z1 /* col2z2URI col2z2 */
col3z1URI col3z1 /* col3z2URI col3z2 */
;

run;

/* The rest is from some get-*..sas - put in  include file, so the code is shared */

proc format;
    picture pctfmt(round max=6)
        low-high='0009%)' (prefix="(")
        . = " "
        ;

    invalue col1order
        
        ;
    invalue col2order
"n"=1
"mean"=2
"stddev"=3
"median"=4
"min"=5
        "max"=6
        "countdistinct"=0
        "count"=1
        ;
    
run;

data &cubestemname.1;
    set &cubestemname.;
    AESOCisNotAll= (aesocvalue ne "_ALL_");
    AEDECODisNotAll= (aedecodvalue ne "_ALL_");
run;

proc sort data=&cubestemname.1;
    by AESOCisNotAll aesocvalue AEDECODisNotAll aedecodvalue;
run;

data &cubestemname._pres;
    set &cubestemname.1;
    by AESOCisNotAll aesocvalue AEDECODisNotAll aedecodvalue;

    length colRES1label colRES2label $1200;

    /* derive order and variable names from the dataset */

    select;
    when (AESOCisNotAll and AEDECODisNotAll) do;
    colRES2order+1;
    end;
    when (AESOCisNotAll and not AEDECODisNotAll) do;
    colRES1order+1;
    colRES2order=0;
    end;
    when (not AESOCisNotAll and not AEDECODisNotAll) do;
    colRES1order=1;
    colRES2order=1;
    end;
    end;

    colRES1label=" "; /* Variable name */
    colRES2label=" "; /*Category level/Statistic */

    colRES1label=aesocvalue;
    colRES2label=catx( " / ",aedecodvalue,scan(procedurez1,-1,"-")) ;
    format col1z1 col2z1 col3z1 best6.;
*    format col1z2 col2z2 col3z2 pctfmt.; 
run;

ods html file="&cubestemname..html"(title= "&tabletitle.")
    style=minimal;
* ods pdf file="&cubestemname..pdf" style=minimal;
* ods tagsets.rtf file="&cubestemname..rtf";




title;

proc sort data=&cubestemname._pres;
    by
    factorz1        
    procedurez1 
;
run;


proc report data=&cubestemname._pres missing nofs split="¤";
    column
        (" " colRES1order colRES1label colRES2order colRES2label  )
        ("Placebo"              col1z1URI col1z1 /* col1z2URI col1z2 */ )
        ("Xanomeline¤Low Dose"  col2z1URI col2z1 /* col2z2URI col2z2 */ )
        ("Xanomeline¤High Dose" col3z1URI col3z1 /* col3z2URI col3z2 */ )
        ;

/* Width statement only applies for listing output.

   The use of  call define(_col_, "format" ... is included to show how to programmatically
   change the format. As all values uses the same format, it is not needed for this table.

    */

/*
        define roworder / " " order noprint;
        define rowgrouplabel / " " order noprint;
        compute before rowgrouplabel;
        line @1 rowgrouplabel $200.;
        endcomp;
        compute after rowgrouplabel;
        line @1 " ";
        endcomp;
       
    define rowlabel / " " display width=25 flow;
    */
    define colRES1order /noprint order;
    define colRES1label / order display  width=40 flow;
    define  colRES2order / noprint order  ;
   define  colRES2label/ order display width=20 flow;
    
/* Replace code below with macro call, for main column 1 to 4, sub column 1 to 2 */    

    define col1z1URI / noprint;
    define col1z1 / " " width=6 flow display;
    compute col1z1;
    call define(_col_,"URL",col1z1URI);
    endcomp;

/*
    define col1z2URI / noprint;
    define col1z2 / " " width=6 flow display;
    compute col1z2;
    call define(_col_,"format", "pctfmt.");
    call define(_col_,"URL",col1z2URI);
    endcomp;
*/    
    define col2z1 / " " width=6 flow display;
    define col2z1URI / noprint;
    compute col2z1;
    call define(_col_,"URL",col2z1URI);
    endcomp;

/*
    define col2z2URI / noprint;
    define col2z2 / " " width=6 flow display;
    compute col2z2;
    call define(_col_,"format", "pctfmt.");
    call define(_col_,"URL",col2z2URI);
    endcomp;
    */
    
    define col3z1URI / noprint;
    define col3z1 / " " width=6 flow display;
    compute col3z1;
    call define(_col_,"URL",col3z1URI);
    endcomp;

/*
    define col3z2URI / noprint;
    define col3z2 / " " width=6 flow display;
    compute col3z2;
    call define(_col_,"format", "pctfmt.");
    call define(_col_,"URL",col3z2URI);
    endcomp;
    */
    
run;

ods html close;
* ods tagsets.rtf close;
* ods pdf close;
