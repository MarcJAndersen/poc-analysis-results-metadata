/*
Display               : Table 14-1.03 Summary of Number of Subjects by Site
AnalysisResult        :
Analysis Parameter(s) :
Analysis Variable(s)  : ITTFL SAFFL EFFFL COMP24FL DISCONFL
Reason                : pre-specified in SAP
Data References (incl. Selection Criteria): ADSL
Documentation         : SAP Section 9.1
Programming Statements:


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
%let tablename=TAB1X03;
%let tablelabel=%str(Table 14-1.03 Summary of Number of Subjects by Site);
%let tableheader=%str(Summary of Number of Subjects by Site);
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
        
data work.adsl ;
    set source.adsl ;
    format trt01p $trt01p.;
run;


%let tabulateOutputDs=work.&tablename.;

proc tabulate data=adsl missing;
    ods output table=&tabulateOutputDs.X;
    class siteid sitegr1;
    class ITTFL EFFFL COMP24FL;
    class trt01p / preloadfmt ORDER=DATA; /* trt01p not trt01pn */
    table
        sitegr1*siteid, (trt01p all)*(ITTFL EFFFL COMP24FL)*(n*f=f3.0)
        ;
run;

data &tabulateOutputDs.;
    set &tabulateOutputDs.X;
    where ITTFL ne "N" and  EFFFL ne "N" and COMP24FL ne "N";
run;


%include "include_tabulate_to_csv.sas" /source;

proc sort data=observations;
    by &classvarlist. procedure factor denominator;
run;

data _null_;
    set observations;
    by &classvarlist. procedure factor denominator;
    if not (first.denominator and last.denominator) then do;
        putlog _n_= &classvarlist. procedure= factor= denominator= measure=;
        if last.denominator then do;
        abort cancel;
        end;
        end;
run;

