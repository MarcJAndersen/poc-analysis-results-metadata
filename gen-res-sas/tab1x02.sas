/*
Display               : Table 14-1.02 - Summary of End of Study Data
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
MJA 2016-07-20     The CDISC report output 14-1.02 provides p-values.
    The code below shows how it can be done.
    
*/

options linesize=200 nocenter;
options pagesize=80;
options formchar="|----|+|---+=|-/\<>*";
options msglevel=i;

*filename source url "https://github.com/phuse-org/phuse-scripts/raw/master/data/adam/cdisc/adsl.xpt";
*filename source "C:\PhARM\CDISCPilot\m5\datasets\cdiscpilot01\analysis\adam\datasets/adsl.xpt";

filename source "../../phuse-scripts/data/adam/cdisc/adsl.xpt"; 
libname source xport ;

%let dssource=https://github.com/phuse-org/phuse-scripts/raw/master/data/adam/cdisc/adsl.xpt;
%let tablename=TAB1X02;
%let tablelabel=%str(Table 14-1.02 - Summary of End of Study Data);
%let tableheader=%str(Summary of End of Study Data);
%let tableprogram=%lowcase(&tablename.).sas;

filename expcsvda "..\res-csv\%upcase(&tablename.).csv";

filename expcsvco "..\res-csv\%upcase(&tablename.)-Components.csv";

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
run;

%MACRO FindPvalues;

    title "Ignore this: this is only for obtaining p-values - they are not used for the rdf data cube";

    data adslx;
        set adsl;
        
    /* Trying to obtain p-values from report */
    length loefl aefl $1;
    LOEFL= ifc(dcreascd="Lack of Efficacy","Y","N");
    AEFL= ifc(dcreascd="Adverse Event","Y","N");
    run;
    
proc freq data=adslx;
  table COMP24FL*TRT01P/chisq fisher exact;
run;

title "Ignore this: this is only for obtaining p-values - they are not used for the rdf data cube";
title2 "Overall test for difference - however, does not match output";
proc freq data=adslx;
  where COMP24FL="N";
  table DCREASCD* TRT01P/ chisq fisher exact;
run;

title2 "Test for Lack of Efficacy and Adverse events separately - does not give a result comparable to the output";
proc freq data=adslx;
  where COMP24FL="N";
  table LOEFL* TRT01P/ chisq fisher exact;
  table AEFL* TRT01P/ chisq fisher exact;
run;
title;

proc tabulate data=adslx missing;
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

%let tabulateOutputDs=work.tab_&tablename.;

proc tabulate data=adsl missing;
    ods output table=&tabulateOutputDs._all;
    class trt01p / preloadfmt ORDER=DATA; /* trt01p not trt01pn */
    class comp24fl / preloadfmt order=data;
    class DCREASCD / preloadfmt order=data;
    table comp24fl comp24fl*DCREASCD,
        (trt01p all)*(N*f=f3.0 colpctn*f=f3.0) / printmiss;
run;

/* Reduce the output to only what is required MJA 2016-07-20  */

data &tabulateOutputDs.;
    set &tabulateOutputDs._all;
/*    if missing(dcreascd) or vvalue(comp24fl)="Early Termination (prior to Week 24)"; */
    if missing(dcreascd) or comp24fl="N"; 

    if  missing(N) and n(PctN_100, PctN_000)>0 then do;
        N=0;    
        end;
    
run;

%include "include_tabulate_to_csv.sas" /source;
