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

%let cubestemname=tab3x01;
%let cubettlfile=../res-ttl/CDISC-pilot-%upcase(&cubestemname).ttl;
%let rqfile=../sparql-rq/&cubestemname..rq;
%let outxmlfile=check-CDISC-pilot-%upcase(&cubestemname).xml;
%let tabletitle=%str(Table 14.3.1 from ARM RDF data cube);

%include "include-jena-groovy.sas" /source;

data this.tab3x01;
    set tab3x01;
run;


proc contents data=this.tab3x01 varnum;
run;

data tab3x01;
    set this.tab3x01;
run;

proc print data=tab3x01 width=min;
var 
/*
    agegr1label agegr1value
    ethniclabel ethnicvalue
    sexlabel sexvalue
    durdsgr1label durdsgr1value
    bmiblgr1label bmiblgr1value
    */
    procedurez1 factorz1
col1z1URI col1z1 /* col1z2URI col1z2 */
col2z1URI col2z1 /* col2z2URI col2z2 */
col3z1URI col3z1 /* col3z2URI col3z2 */
;

run;

/* The rest is from get-tab3x01.sas - put in  include file, so the code is shared */

proc format;
    picture pctfmt(round max=6)
        low-high='0009%)' (prefix="(")
        . = " "
        ;

    invalue col1order
        "age"=1
"agegr1"=2
"sex"=3
"ethnic"=4
"mmsetot"=5
"durdis"=6
"durdsgr1"=7
"educlvl"=8
"weightbl"=9
"heightbl"=10
"bmibl"=111
"bmiblgr1"=11
        ;

    invalue col1order
        "base"=1
        "aval"=2
        "chg"=3
        ;
    invalue col2order
"n"=1
"mean"=2
"stddev"=3
"median"=4
"min"=5
"max"=6
        ;
    
run;

/*

   value $sexfmt
       'N' = 'n[a]'
       'F' = 'F'
       'M' = 'M';

   value $agegrfmt
       'N'     = 'n[a]'
       '<65'   = '<65'
       '65-80' = '65-80'
       '>80'   = '>80';
   
   value $racefmt
       'N' = 'n[a]'
       'WHITE' = 'White'
       'BLACK OR AFRICAN AMERICAN' = 'Black or African American'
       'AMERICAN INDIAN OR ALASKA NATIVE' = 'American Indian or Alaska Native';
   
   value $ethfmt
       'N' = 'n[a]'
       'NOT HISPANIC OR LATINO' = 'Not Hispanic or Latino'
       'HISPANIC OR LATINO' = 'Hispanic or Latino';
   
   value trt01an
       0="Placebo"
       54="Xanomeline Low Dose"
       81="Xanomeline High Dose"
       ;

   */

data tab3x01_pres;
    set tab3x01;

    length colRES1label colRES2label $1200;

    /* derive order and variable names from the dataset */
    colRES1order=0;
    colRES1label=" "; /* Variable name */
    colRES2order=0;
    colRES2label=" "; /*Category level/Statistic */

/*
        colRES1order+1;
    colRES2order+1;
    */
    
    array alabel(*) agegr1label ethniclabel sexlabel durdsgr1label bmiblgr1label;
    array avalue(*) agegr1value ethnicvalue sexvalue durdsgr1value bmiblgr1value;

    length for_var $32;

            /* should use denominator col1z2denominator - but denominator should be the same for all columns */


    select;
        when (scan(procedurez1,-1,"/")="procedure-count" ) do;
        do i=1 to dim(alabel);
            if avalue(i) ne "_ALL_" then do;
            for_var= col1z2denominator;
            colRES1label=catx(" /?/ ", colRES1label, alabel(i) );
            colRES2label=catx(" /?/ ", colRES2label, avalue(i) );
            colRES2order=1;
        end;
        end;
        end;
        otherwise do;
          for_var= scan(factorz1,-1,"-");
          colRES1label= scan(factorz1,-1,"-"); /* change to label for factor */
          colRES2label= scan(procedurez1,-1,"-"); /* change to label for procedure */
          colRES2order= input( scan(procedurez1,-1,"-"), col2order. );
       end;


    end;

colRES1order= input( for_var, col1order. );
    format col1z1 col2z1 col3z1 best6.;
*    format col1z2 col2z2 col3z2 pctfmt.; 
run;

ods html file="tab3x01.html"(title= "Table 14.1.2 from ARM RDF data cube")
    style=minimal;
* ods pdf file="tab3x01.pdf" style=minimal;
* ods tagsets.rtf file="tab3x01.rtf";




title;

proc sort data=tab3x01_pres;
    by
    factorz1        
    procedurez1 
    agegr1label agegr1value
    ethniclabel ethnicvalue
    sexlabel sexvalue
    durdsgr1label durdsgr1value
    bmiblgr1label bmiblgr1value
;
run;


proc report data=tab3x01_pres missing nofs split="�";
    column
        (" " colRES1order colRES1label colRES2order colRES2label  )
        ("Placebo"              col1z1URI col1z1 /* col1z2URI col1z2 */ )
        ("Xanomeline�Low Dose"  col2z1URI col2z1 /* col2z2URI col2z2 */ )
        ("Xanomeline�High Dose" col3z1URI col3z1 /* col3z2URI col3z2 */ )
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
