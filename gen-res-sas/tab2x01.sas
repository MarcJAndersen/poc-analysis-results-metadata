/*
Display               : Table 14-2.01 - Summary of Demographic and Baseline Characteristics
AnalysisResult        :
Analysis Parameter(s) :
Analysis Variable(s)  : 
            ResultIdentifier="treatment group comparison for continuous variables"
            <adamref:AnalysisVariable ItemOID="ADSL.AGE"/>
            <adamref:AnalysisVariable ItemOID="ADSL.MMSETOT"/>
            <adamref:AnalysisVariable ItemOID="ADSL.DURDIS"/>
            <adamref:AnalysisVariable ItemOID="ADSL.EDUCLVL"/>
            <adamref:AnalysisVariable ItemOID="ADSL.WEIGHTBL"/>
            <adamref:AnalysisVariable ItemOID="ADSL.HEIGHTBL"/>
            <adamref:AnalysisVariable ItemOID="ADSL.BMIBL"/>
            ResultIdentifier="treatment group comparison for categorical variables"
            Reason="pre-specified in protocol">
            <!-- AnalysisVariables may reference both an ItemGroup and an Item  -->
            <!-- in cases where there are multiple analysis variables from different datasets -->
            <adamref:AnalysisVariable ItemOID="ADSL.AGEGR1"/>
            <adamref:AnalysisVariable ItemOID="ADSL.SEX"/>
            <adamref:AnalysisVariable ItemOID="ADSL.RACE"/>
            <adamref:AnalysisVariable ItemOID="ADSL.DURDSGR1"/>
            <adamref:AnalysisVariable ItemOID="ADSL.BMIBLGR1"/>

TODO(XX): use ethnic - not race !!

Reason                : pre-specified in protocol
Data References (incl. Selection Criteria): ADSL
Documentation         : 
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
%let tablename=TAB2X01;
%let tablelabel=%str(Table 14-2.01 - Summary of Demographic and Baseline Characteristics);
%let tableheader=%str(Demographics Analysis Results);
%let tableprogram=%lowcase(&tablename.).sas;

filename expcsvda "..\res-csv\%upcase(&tablename.).csv";

filename expcsvco "..\res-csv\%upcase(&tablename.)-Components.csv";

proc format;
    value $trt01p(notsorted)
        "Placebo"="Placebo"
        "Xanomeline Low Dose"="Xanomeline Low Dose"
        "Xanomeline High Dose"="Xanomeline High Dose"
        ;

    /* Some of the formats should be moved to the presentation program */
           value $destats
     'NC'       = 'n[a]'
     'MEANC'    = 'Mean'
     'STDC'     = 'SD'
     'MEDIANC'  = 'Median'
     'Q1Q3C'    = 'Q1, Q3'
	 'MINMAXC'  = 'Min, Max'
	 'MISSINGC' = 'Missing';

   value $destatso
     'NC'       = 0
     'MEANC'    = 1
     'STDC'     = 2
     'MEDIANC'  = 3
     'Q1Q3C'    = 4
     'MINMAXC'  = 5
     'MISSINGC' = 6
     'MIN'      =-101
     'MAX'      =-102
     'Q1'      =-103
     'Q3'      =-104
     'MEAN'    =-105
     'MEDIAN'  =-106
     'N'=-107
       'STD'=-108
       ;

   value $sexfmt
       'N' = 'n[a]'
       'F' = 'F'
       'M' = 'M';

   value $sexfmto
       'N' = 1
       'F' = 2
       'M' = 3;
   
   value $agegrfmt
       'N'     = 'n[a]'
       '<65'   = '<65'
       '65-80' = '65-80'
       '>80'   = '>80';
   
   value $agegrfmto
       'N'     = 1
       '<65'   = 2
       '65-80' = 3
       '>80'   = 4;
   
   value $racefmt
       'N' = 'n[a]'
       'WHITE' = 'White'
       'BLACK OR AFRICAN AMERICAN' = 'Black or African American'
       'AMERICAN INDIAN OR ALASKA NATIVE' = 'American Indian or Alaska Native';
   
   value $racefmto
       'N' = 1
       'WHITE' = 2
       'BLACK OR AFRICAN AMERICAN' = 3
       'AMERICAN INDIAN OR ALASKA NATIVE' = 4;
   
   value $ethfmt
       'N' = 'n[a]'
       'NOT HISPANIC OR LATINO' = 'Not Hispanic or Latino'
       'HISPANIC OR LATINO' = 'Hispanic or Latino';
   
   value $ethfmto
       'N' = 1
       'NOT HISPANIC OR LATINO' = 2
       'HISPANIC OR LATINO' = 3;

   value trt01ano
       0="3"
       54="2"
       81="1"
       ;
   
   value trt01an
       0="Placebo"
       54="Xanomeline Low Dose"
       81="Xanomeline High Dose"
       ;

   value $orderfmt
       "sex"="$sexfmto."
       "agegr1"="$agegrfmto."
       "race"="$racefmt."
       "ethnic"="$ethfmto."
       "trt01an"="trt01ano."
       other=" "
       ;
        

run;
        
data work.adsl ;
    set source.adsl ;
    format trt01p $trt01p.;
run;


proc tabulate data=adsl missing;
    ods output table=work.tab_14_2x01;
    where ittfl = 'Y';
    class ittfl;
    class sex;
    format sex $sexfmt.;
    class agegr1;
    format agegr1 $agegrfmt.;
    class race;
    format race $racefmt.;
    class ethnic;
    format ethnic $ethfmt.;
    var age;
    var weightbl mmsetot durdis educlvl weightbl heightbl bmibl;
    class durdsgr1 bmiblgr1;
    class trt01p / preloadfmt ORDER=DATA; /* trt01p not trt01pn */
    table
        ittfl,
        age*(n*f=f3.0 /*nmiss*/ mean stddev median min max)
        (/*all*/ agegr1)*(n*f=f3.0 pctn</*all*/ agegr1>*f=f3.0) /* TODO: the all can not be shown as it is duplicated; should use nonmiss_agegr1 * (n*f=f3.0 agegr1*f=f3.0 to get total for non missing values */
        (/*all*/ sex)*(n*f=f3.0 pctn</*all*/ sex>*f=f3.0)
        (/*all*/ race)*(n*f=f3.0 pctn</*all*/ race>*f=f3.0)
        /* TODO nmiss is not handled in rrdfqbcrnd0 */
        MMSETOT*(n*f=f3.0 /*nmiss*/ mean stddev median min max)
        DURDIS*(n*f=f3.0 /*nmiss*/ mean stddev median min max)
        DURDSGR1*(n*f=f3.0 pctn<DURDSGR1>*f=f3.0)
        EDUCLVL*(n*f=f3.0 /*nmiss*/ mean stddev median min max)
        WEIGHTBL*(n*f=f3.0 /*nmiss*/ mean stddev median min max)
        HEIGHTBL*(n*f=f3.0 /*nmiss*/ mean stddev median min max)       
        BMIBL*(n*f=f3.0 /*nmiss*/ mean stddev median min max)
        BMIBLGR1*(n*f=f3.0 pctn<BMIBLGR1>*f=f3.0)
        ,
        trt01p all;
run;

%let tabulateOutputDs=work.tab_14_2x01;

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

