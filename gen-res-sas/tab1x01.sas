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
options pagesize=80;
options formchar="|----|+|---+=|-/\<>*";
options msglevel=i;

*filename source url "https://github.com/phuse-org/phuse-scripts/raw/master/data/adam/cdisc/adsl.xpt";
*filename source "C:\PhARM\CDISCPilot\m5\datasets\cdiscpilot01\analysis\adam\datasets/adsl.xpt";

filename source "../../phuse-scripts/data/adam/cdisc/adsl.xpt"; 
libname source xport ;

%let dssource=https://github.com/phuse-org/phuse-scripts/raw/master/data/adam/cdisc/adsl.xpt;
%let tablename=TAB1X01;
%let tablelabel=%str(Table 14-1.01 Summary of Populations);
%let tableheader=%str(Summary of Populations);
%let tableprogram=%lowcase(&tablename.).sas;

filename expcsvda "..\res-csv\%upcase(&tablename.).csv";

filename expcsvco "..\res-csv\%upcase(&tablename.)-Components.csv";


proc format;
    value $trt01p(notsorted)
        "Placebo"="Placebo"
        "Xanomeline Low Dose"="Xanomeline Low Dose"
        "Xanomeline High Dose"="Xanomeline High Dose"
        ;
run;

/* To be documented:

    The data contains disconfl which gives the number discontinuing for value "Y".
    
    introducing compfl - as there is no completer flag: use disconfl value "N" for count of completers

    However, here it is preferred to count number of "Y" - but that may be changed in the SPARQL query.
    
    This is worth discussion - example on how the defintions interact, and that it is not apparant from
    the specification.
    
*/    

data work.adsl ;
    set source.adsl ;
    format trt01p $trt01p.;
/*    length compfl $1; */
/*    compfl= ifc(DCREASCD="Completed", "Y", " "); */
/* label compfl="Complete Study"; */

label ittfl="Intent-To-Treat (ITT)";
label saffl="Safety";
label efffl="Efficacy"; 
label comp24fl="Complete Week 24";
label disconfl="Complete Study";
run;

/* To be documented:

    using trt01p and not trt01pn - as using character variables make the code below simpler
    
*/    
    
%let tabulateOutputDs=work.tab_&tablename.;

proc tabulate data=adsl missing;
    ods output table=&tabulateOutputDs.;
    class trt01p / preloadfmt ORDER=DATA; /* trt01p not trt01pn */
    class ittfl saffl efffl comp24fl /* compfl */ disconfl; 
    table ittfl saffl efffl comp24fl /* compfl */ disconfl, 
        (trt01p all)*(N*f=f3.0 pctn<ittfl saffl efffl comp24fl /* compfl */ disconfl >*f=f3.0);
run;

%include "include_tabulate_to_csv.sas" /source;

