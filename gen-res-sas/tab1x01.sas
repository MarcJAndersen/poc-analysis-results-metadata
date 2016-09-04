/*
Display               : Table 14-1.01 Summary of Populations
AnalysisResult        :
Analysis Parameter(s) :
Analysis Variable(s)  : ITTFL SAFFL EFFFL COMP24FL DISCONFL
Reason                : pre-specified in SAP
Data References (incl. Selection Criteria): ADSL
Documentation         : SAP Section 9.1
Programming Statements:

proc freq data = pilot.adsl;
tables (ittfl saffl efffl comp24fl disconfl)*trt01pn / missing;
run;

*/


options linesize=200 nocenter;
options pagesize=100;
options formchar="|----|+|---+=|-/\<>*";
options msglevel=i;

/* filename source url "https://github.com/phuse-org/phuse-scripts/raw/master/data/adam/cdisc/adsl.xpt"; */

filename source "../sample-xpt/adsl.xpt"; 
libname source xport ;

proc format;
    value $trt01p(notsorted)
        "Placebo"="Placebo"
        "Xanomeline Low Dose"="Xanomeline Low Dose"
        "Xanomeline High Dose"="Xanomeline High Dose"
        ;
run;

/* To be documented:

    The data contains disconfl which gives the number discontinuing for value "Y".
    
    introducing compfl - as there is no completer flag: usee disconfl value "N" for count of completers
    However, here it is preferred to count number of "Y" - but that may be changed in the SPARQL query.
    
    This is worth discussion - example on how the defintions interact, and that it is not apparant from
    the specification.
    
*/    
data work.adsl ;
    set source.adsl ;
    format trt01p $trt01p.;
/*    length compfl $1; */
/*    compfl= ifc(DCREASCD="Completed", "Y", " "); */

label ittfl="Intent-To-Treat (ITT)";
label saffl="Safety";
label efffl="Efficacy"; 
label comp24fl="Complete Week 24";
/* label compfl="Complete Study"; */
label disconfl="Complete Study";
run;

/* To be documented:

    using trt01p and not trt01pn - as using character variables make the code below simpler
    
*/    
    
proc tabulate data=adsl missing;
    ods output table=work.tab_14_1x01;
    class trt01p / preloadfmt ORDER=DATA; /* trt01p not trt01pn */
    class ittfl saffl efffl comp24fl /* compfl */ disconfl; 
    table ittfl saffl efffl comp24fl /* compfl */ disconfl, 
        (trt01p all)*(N*f=f3.0 pctn<ittfl saffl efffl comp24fl /* compfl */ disconfl >*f=f3.0);
run;


/*------------------------------------------------------------------------*\
** Program : report_to_rrdf.sas
** Purpose : Transfer dataset report to RRDFQBCRND excel workbook format
\*------------------------------------------------------------------------*/

proc contents data=work.tab_14_1x01 varnum;
run;

proc print data=work.tab_14_1x01 width=min;
run;

data forexport;
    length ittfl saffl efffl comp24fl /* compfl */ disconfl trt01p $200;
    set work.tab_14_1x01;
    keep ittfl saffl efffl comp24fl /* compfl */ disconfl;
    keep trt01p;
    keep procedure factor;
    length procedure factor $50;
    keep unit denominator;
    length unit denominator $50;
    unit=" ";

    keep measure;

    array adim(*) ittfl saffl efffl comp24fl /* compfl */ disconfl trt01p;

    do i=1 to dim(adim);
        select;
        when (upcase(vname(adim(i))) = upcase("disconfl") and _type_ in ("100001","000001")
            and missing(adim(i)) ) do;
        putlog adim(i)= @;
        adim(i)="N"; /* recoding missing to N */
        putlog " changed to " adim(i)=;
        end;
        when (missing(adim(i))  ) do;
        adim(i)="_ALL_";
        end;
        otherwise do; 
          /* no change */
        end;
        end;
    end;


    factor="quantity";
    procedure="count";
    denominator=" ";
    measure=N;
    output;

    if substr(_type_,1,1)="1" then do;
    factor="proportion";
    procedure="percent";
    /* assuming only one variable as denominator, excluding the first position representing TRT01P  */
    denominator=vname(adim(index(substr(_type_,2),"1"))); 
    measure= pctN_100000;
    output;
    end;

    if substr(_type_,1,1)="0" then do;
    factor="proportion";
    procedure="percent";
    /* assuming only one variable as denominator, except the first TRT01P */
    denominator=vname(adim(index(substr(_type_,2),"1"))); 
    measure= pctN_000000;
    output;
    end;

run;

proc print data=forexport width=min;
run;

proc contents data=forexport varnum;
run;

proc export data=forexport file="../res-csv/TAB1X01.csv" replace;
run;

data skeletonSource1;
    if 0 then do;
        set forexport; /* To get the labels  TODO: check if there are name clashes - or implement differently */
        end;
        length compType compName codeType nciDomainValue compLabel Comment $512;
        keep compType compName codeType nciDomainValue compLabel Comment;
    
    Comment= " ";
    compType= "dimension"; compName="trt01p";    compLabel=vlabelx(compName); codeType="DATA"; nciDomainValue= " "; output;
    /* change compName to label of variable */
    compType= "dimension"; compName="ittfl";    compLabel=vlabelx(compName); codeType="DATA"; nciDomainValue= " "; output;
    compType= "dimension"; compName="saffl";    compLabel=vlabelx(compName); codeType="DATA"; nciDomainValue= " "; output;
    compType= "dimension"; compName="efffl";    compLabel=vlabelx(compName); codeType="DATA"; nciDomainValue= " "; output;
    compType= "dimension"; compName="comp24fl";  compLabel=vlabelx(compName); codeType="DATA"; nciDomainValue= " "; output;
    /* The next variable should be  disconfl - see note above */  
    compType= "dimension"; compName="disconfl";  compLabel=vlabelx(compName); codeType="DATA"; nciDomainValue= " "; output;
/*    compType= "dimension"; compName="compfl";  compLabel=vlabelx(compName); codeType="DATA"; nciDomainValue= " "; output; */

    compType= "dimension"; compName="procedure"; compLabel="Statistical Procedure"; codeType="DATA"; nciDomainValue= " ";output;
    compType= "dimension"; compName="factor";    compLabel="Type of procedure (quantity, proportion...)"; codeType="DATA"; nciDomainValue= " "; output;

    compType= "measure"; compName="measure";      compLabel="Value of the statistical measure"; codeType=" "; nciDomainValue=" "; output;
    compType= "attribute"; compName="unit";        compLabel="Unit of measure"; codeType=" "; nciDomainValue=" "; output;
    compType= "attribute"; compName="denominator"; compLabel="Denominator for a proportion (oskr) subset on which a statistic is based"; codeType=" "; nciDomainValue=" "; output;

    stop;
    
run;


data skeletonSource2;
length compType compName codeType nciDomainValue compLabel Comment $512;
    
compType= "metadata";
compName= "obsURL";
codeType= " ";
nciDomainValue= " ";
compLabel= "https://phuse-scripts.googlecode.com/svn/trunk/scriptathon2014/data/adsl.xpt";
Comment= "obsFileName";
output; 

compType= "metadata";
compName= "obsFileName";
codeType= " ";
nciDomainValue= " ";
compLabel= "tab1x01.csv";
Comment= "obsFileName";
output; 

compType= "metadata";
compName= "dataCubeFileName";
codeType= " ";
nciDomainValue= " ";
compLabel= "DC-TAB1X01";
Comment= "Cube name prefix (will be appended with version number by script. --> No. Will be set in code based on domainName parameter)";
output; 

compType= "metadata";
compName= "cubeVersion";
codeType= " ";
nciDomainValue= " ";
compLabel= "0.0.0";
Comment= "Version of cube with format n.n.n";
output; 

compType= "metadata";
compName= "createdBy";
codeType= " ";
nciDomainValue= " ";
compLabel= "Foo";
Comment= "Person who configures this spreadsheet and runs the creation script to create the cube";
output; 

compType= "metadata";
compName= "description";
codeType= " ";
nciDomainValue= " ";
compLabel= "Data from adsl1.sas program";
Comment= "Cube description";
output; 

compType= "metadata";
compName= "providedBy";
codeType= " ";
nciDomainValue= " ";
compLabel= "PhUSE Results Metadata Working Group";
Comment= " ";
output; 

compType= "metadata";
compName= "comment";
codeType= " ";
nciDomainValue= " ";
compLabel= "";
Comment= "Table 14-1.01 Summary of Populations";
output; 

compType= "metadata";
compName= "title";
codeType= " ";
nciDomainValue= " ";
compLabel= "Demographics Analysis Results";
Comment= "Table 14-1.01 Summary of Populations";
output; 

compType= "metadata";
compName= "label";
codeType= " ";
nciDomainValue= " ";
compLabel= "Table 14-1.01 Summary of Populations";
Comment= " ";
output; 

compType= "metadata";
compName= "wasDerivedFrom";
codeType= " ";
nciDomainValue= " ";
compLabel= "tab1x01.csv";
Comment= "Data source (obsFileName). Set this programmtically based on name of input file!";
output; 

compType= "metadata";
compName= "domainName";
codeType= " ";
nciDomainValue= " ";
compLabel= "TAB1X01";
Comment= "The domain name, also part of the spreadsheet tab name";
output; 

compType= "metadata";
compName= "obsFileNameDirec";
codeType= " ";
nciDomainValue= " ";
compLabel= "!example";
Comment= "The directory containd the wasDerivedFrom file";
output; 

compType= "metadata";
compName= "dataCubeOutDirec";
codeType= " ";
nciDomainValue= " ";
compLabel= "!temporary";
Comment= " ";
output; 

/* This enables the experimental extension providing reference to the underlying data */
compType= "metadata";
compName= "extension.rrdfqbcrnd0";
codeType= " ";
nciDomainValue= " ";
compLabel= "TRUE";
Comment= " ";
output; 
    
run;

data skeletonSource;
    set skeletonSource1 skeletonSource2;
run;
    
proc export data=skeletonSource file="../res-csv/TAB1X01-Components.csv" replace;
run;


