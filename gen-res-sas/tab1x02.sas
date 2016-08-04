/*
Display               : Table 14-1.02 Table 14-1.02 - Summary of End of Study Data
AnalysisResult        :
Analysis Parameter(s) :
Analysis Variable(s)  : ADSL.COMP24FL, ADSL.DCREASCD
Reason                : pre-specified in SAP
Data References (incl. Selection Criteria): ADSL
Documentation         : SAP Section 9.1
Programming Statements:

proc freq data=adsl;
  table COMP24FL*TRT01P/chisq fisher exact;
run;

proc freq data=adsl;
  where COMP24FL="N";
  table DCREASCD* TRT01P/ chisq fisher exact;
run;

Notes:
MJA 2016-07-20     The CDISC report output 14-1.02 provides p-values. The code below attempts to reproduce the p-values.
    
*/


options linesize=200 nocenter;
options pagesize=80;
options formchar="|----|+|---+=|-/\<>*";
options msglevel=i;

*filename source url "https://github.com/phuse-org/phuse-scripts/raw/master/data/adam/cdisc/adsl.xpt";
*filename source "C:\PhARM\CDISCPilot\m5\datasets\cdiscpilot01\analysis\adam\datasets/adsl.xpt";

filename source "../../phuse-scripts/data/adam/cdisc/adsl.xpt"; 
libname source xport ;

filename expcsvda "..\res-csv\TAB1X02.csv";

filename expcsvco "..\res-csv\TAB1X02-Components.csv";

proc format;
    value $trt01p(notsorted)
        "Placebo"="Placebo"
        "Xanomeline Low Dose"="Xanomeline Low Dose"
        "Xanomeline High Dose"="Xanomeline High Dose"
        ;

/* * this is for presentation; 
    value $comp24fl(notsorted)
"Y"="Completed Week 24"
"N"="Early Termination (prior to Week 24)"
" "="Missing"
;        
    */

    value $comp24fl(notsorted)  /* to force sorting in proc tabulate output MJA 2016-08-04  */
"Y"="Y"
"N"="N"
" "=" "
;        
        
/* * this is for presentation; 
 value $dcreascd(notsorted)
"Adverse Event" ="Adverse Event"
"Death" ="Death"
"Lack of Efficacy" ="Lack of Eefficacy"
"Lost to Follow-up" ="Lost to Follow-up"
"Withdrew Consent" ="Subject decided to withdraw"
"Physician Decision" ="Physician decided to withdraw subject"
"I/E Not Met" ="Protocol criteria not met"
"Protocol Violation" ="Protocol violation"
"Sponsor Decision" ="Sponsor decision"
"Missing" = "Missing"
;
 */

 value $dcreascd(notsorted)  /* to force sorting in proc tabulate output MJA 2016-08-04  */
"Adverse Event" ="Adverse Event"
"Death" ="Death"
"Lack of Efficacy" ="Lack of Eefficacy"
"Lost to Follow-up" ="Lost to Follow-up"
"Withdrew Consent" ="Withdrew Consent"
"Physician Decision" ="Physician decision"
"I/E Not Met" ="I/E Not Met"
"Protocol Violation" ="Protocol violation"
"Sponsor Decision" ="Sponsor decision"
"Missing" = "Missing"
;

run;
        
data work.adsl ;
    set source.adsl ;
    format trt01p $trt01p.;
    label comp24fl="Completion Status:";
    format comp24fl $comp24fl.;
    format DCREASCD $DCREASCD.;
    label DCREASCD="Reason for Early Termination (prior to Week 24):";

    /* Trying to obtain p-values from report */
    length loefl aefl $1;
    LOEFL= ifc(dcreascd="Lack of Efficacy","Y","N");
    AEFL= ifc(dcreascd="Adverse Event","Y","N");
run;

%MACRO FindPvalues;
title "Ignore this: this is only for obtaining p-values - they are not used for the rdf data cube";
proc freq data=adsl;
  table COMP24FL*TRT01P/chisq fisher exact;
run;

title "Ignore this: this is only for obtaining p-values - they are not used for the rdf data cube";
title2 "Overall test for difference - however, does not match output";
proc freq data=adsl;
  where COMP24FL="N";
  table DCREASCD* TRT01P/ chisq fisher exact;
run;

title2 "Test for Lack of Efficacy and Adverse events separately - does not give a result comparable to the output";
proc freq data=adsl;
  where COMP24FL="N";
  table LOEFL* TRT01P/ chisq fisher exact;
  table AEFL* TRT01P/ chisq fisher exact;
run;
title;

proc tabulate data=adsl missing;
title "Ignore this: trying proc tabulate";
    class trt01p / preloadfmt ORDER=DATA; /* trt01p not trt01pn */
    class comp24fl / preloadfmt order=data;
    class DCREASCD / preloadfmt order=data;
    table comp24fl, (trt01p all)*(N*f=f3.0 pctn<comp24fl>*f=f3.0) / printmiss box="Part 1";
    table comp24fl*DCREASCD,
        (trt01p all)*(N*f=f3.0 pctn<comp24fl*DCREASCD>*f=f3.0) / printmiss box="Part 2 - only use for Early Termination (prior to Week 24)" ;
    table comp24fl comp24fl*DCREASCD,
        (trt01p all)*(N*f=f3.0 pctn<comp24fl comp24fl*DCREASCD>*f=f3.0) / printmiss box="This is a combination of a Part 1 and Part 2 - but does not give expected results" ;
run;
title;

%MEND;

/* In proc tabulate colpctn provides the percentage relative to the overall number.
   This is not handled in the rrdf package. The approach below provides the
   desired results.
    */


proc tabulate data=adsl missing;
    ods output table=work.tab_14_1x02_tabu;
    class trt01p / preloadfmt ORDER=DATA; /* trt01p not trt01pn */
    class comp24fl / preloadfmt order=data;
    class DCREASCD / preloadfmt order=data;
    table comp24fl comp24fl*DCREASCD,
        (trt01p all)*(N*f=f3.0 colpctn*f=f3.0) / printmiss;
run;

proc contents data=work.tab_14_1x02_tabu varnum;
run;

proc print data=work.tab_14_1x02_tabu width=min;
run;

/* Reduce the output to only what is required MJA 2016-07-20  */

data work.tab_14_1x02;
    set work.tab_14_1x02_tabu;
/*    if missing(dcreascd) or vvalue(comp24fl)="Early Termination (prior to Week 24)"; */
    if missing(dcreascd) or comp24fl="N"; 

    if  missing(N) and n(PctN_100, PctN_000)>0 then do;
        N=0;    
        end;
    

    
run;

proc print data=work.tab_14_1x02 width=min;
run;


/*------------------------------------------------------------------------*\
** Program : report_to_rrdf.sas
** Purpose : Transfer dataset report to RRDFQBCRND excel workbook format
\*------------------------------------------------------------------------*/


data forexport;
    length trt01p comp24fl DCREASCD $200;
    set work.tab_14_1x02;
    keep comp24fl dcreascd;
    keep trt01p;
    keep procedure factor;
    length procedure factor $50;
    keep unit denominator;
    length unit denominator $50;
    unit=" ";

    keep measure;

    array adim(*) trt01p comp24fl dcreascd;

    do i=1 to dim(adim);
        select;
        when (missing(adim(i))) do;
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
    measure= pctN_100;
    output;
    end;

    if substr(_type_,1,1)="0" then do;
    factor="proportion";
    procedure="percent";
    /* assuming only one variable as denominator, except the first TRT01P */
    denominator=vname(adim(index(substr(_type_,2),"1"))); 
    measure= pctN_000;
    output;
    end;

run;

proc sort data=forexport nodupkey;
    by trt01p comp24fl DCREASCD procedure  factor  unit  denominator;
run;

proc print data=forexport width=min;
run;

proc contents data=forexport varnum;
run;

proc export data=forexport file=expcsvda replace dbms=csv;
run;

data skeletonSource1;
    if 0 then do;
        set forexport; /* To get the labels  TODO: check if there are name clashes - or implement differently */
        end;
        length compType compName codeType nciDomainValue compLabel Comment $512;
        keep compType compName codeType nciDomainValue compLabel Comment;
    Comment= " ";
    /* change compName to label of variable */
    compType= "dimension"; compName="comp24fl";  compLabel=vlabelx(compName); codeType="DATA"; nciDomainValue= " "; output;
    compType= "dimension"; compName="trt01p";    compLabel=vlabelx(compName); codeType="DATA"; nciDomainValue= " "; output;
    compType= "dimension"; compName="dcreascd";  compLabel=vlabelx(compName); codeType="DATA"; nciDomainValue= " "; output;
    compType= "dimension"; compName="procedure"; compLabel="Statistical Procedure"; codeType="DATA"; nciDomainValue= " ";output;
    compType= "dimension"; compName="factor";    compLabel="Type of procedure (quantity, proportion...)"; codeType="DATA"; nciDomainValue= " "; output;
    compType= "attribute"; compName="unit";      compLabel="Unit of measure"; codeType=" "; nciDomainValue=" "; output;
    compType= "attribute"; compName="denominator"; compLabel="Denominator for a proportion (oskr) subset on which a statistic is based"; codeType=" "; nciDomainValue=" "; output;
    compType= "measure"; compName="measure";     compLabel="Value of the statistical measure"; codeType=" "; nciDomainValue=" "; output;

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
compLabel= "tab1x02.csv";
Comment= "obsFileName";
output; 

compType= "metadata";
compName= "dataCubeFileName";
codeType= " ";
nciDomainValue= " ";
compLabel= "DC-TAB1X02";
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
Comment= "Table 14-1.02 Summary of End of Study Data";
output; 

compType= "metadata";
compName= "title";
codeType= " ";
nciDomainValue= " ";
compLabel= "Demographics Analysis Results";
Comment= "Table 14-1.02 Summary of End of Study Data";
output; 

compType= "metadata";
compName= "label";
codeType= " ";
nciDomainValue= " ";
compLabel= "Table 14-1.02 Summary of End of Study Data";
Comment= " ";
output; 

compType= "metadata";
compName= "wasDerivedFrom";
codeType= " ";
nciDomainValue= " ";
compLabel= "tab1x02.csv";
Comment= "Data source (obsFileName). Set this programmtically based on name of input file!";
output; 

compType= "metadata";
compName= "domainName";
codeType= " ";
nciDomainValue= " ";
compLabel= "TAB1X02";
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

proc export data=skeletonSource file=expcsvco replace dbms=csv;
run;


%put expcsvda: %sysfunc(pathname(expcsvda));
%put expcsvco: %sysfunc(pathname(expcsvco));
