/*
Display               : Table 14-3.01 Primary Endpoint Analysis: ADAS Cog (11) - Change from Baseline to Week 24 - LOCF
AnalysisResult        :
Analysis Parameter(s) :
Analysis Variable(s)  : 
 eason                : pre-specified in protocol
Data References (incl. Selection Criteria): A
Documentation         : 
Programming Statements:

*/


options linesize=200 nocenter;
options pagesize=80;
options formchar="|----|+|---+=|-/\<>*";
options msglevel=i;

*filename source url "https://github.com/phuse-org/phuse-scripts/raw/master/data/adam/cdisc/adsl.xpt";
*filename source "C:\PhARM\CDISCPilot\m5\datasets\cdiscpilot01\analysis\adam\datasets/adsl.xpt";

filename source "../../phuse-scripts/data/adam/cdisc/adqsadas.xpt"; 
libname source xport ;

%let dssource=https://github.com/phuse-org/phuse-scripts/raw/master/data/adam/cdisc/adqsadas.xpt;
%let tablename=TAB3X01_1;
%let tablelabel=%str(Table 14-3.01.01 Endpoint Analysis by Age Group: ADAS Cog (11) - Change from Baseline to Week 24 - LOCF);
%let tableheader=%str(Endpoint Analysis by Age Group);
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

   value $sexfmto
       'N' = 1
       'F' = 2
       'M' = 3;
   
   value $agegrfmto
       'N'     = 1
       '<65'   = 2
       '65-80' = 3
       '>80'   = 4;
   
   value $racefmto
       'N' = 1
       'WHITE' = 2
       'BLACK OR AFRICAN AMERICAN' = 3
       'AMERICAN INDIAN OR ALASKA NATIVE' = 4;
   
   value $ethfmto
       'N' = 1
       'NOT HISPANIC OR LATINO' = 2
       'HISPANIC OR LATINO' = 3;

   value trt01ano
       0="3"
       54="2"
       81="1"
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
        
data work.ADQSADAS ;
    set source.ADQSADAS ;
*    format trt01p $trt01p.;
run;

/* code in define-xml say atot */
/*
proc glm data = ADQSADAS;
  where EFFFL='Y' and ANL01FL='Y' and AVISIT='Week 24' and PARAMCD="ACTOT";
  class sitegr1;
  model CHG = trtpn sitegr1;
run;

proc glm data = ADQSADAS;
  where EFFFL='Y' and ANL01FL='Y' and AVISIT='Week 24' and PARAMCD="ACTOT";
  class trtpn sitegr1;
  model CHG = trtpn sitegr1 base;
  means trtpn;
  lsmeans trtpn / OM STDERR PDIFF CL;
run;
*/

/* Target:

Protocol: CDISCPILOT01 Page 1 of 1
Population: Efficacy
Table 14-3.01
Primary Endpoint Analysis: ADAS Cog (11) - Change from Baseline to Week 24 - LOCF
Placebo (N=79) Xanomeline Low Dose (N=81) Xanomeline High Dose (N=74)
Baseline
n                79 81 74
Mean (SD)        24.1 (12.19) 24.4 (12.92) 21.3 (11.74)
Median (Range)   21.0 (5;61) 21.0 (5;57) 18.0 (3;57)
Week 24 n        79 81 74
Mean (SD)        26.7 (13.79) 26.4 (13.18) 22.8 (12.48)
Median (Range)   24.0 (5;62) 25.0 (6;62) 20.0 (3;62)
Change from Baseline
    n            79 81 74
    Mean (SD)    2.5 (5.80) 2.0 (5.55) 1.5 (4.26)
Median (Range)   2.0 (-11;16) 2.0 (-11;17) 1.0 (-7;13)
p-value(Dose Response) [1][2] 0.245
p-value(Xan - Placebo) [1][3] 0.569 0.233

Diff of LS Means (SE) -0.5 (0.82) -1.0 (0.84) 95% CI (-2.1;1.1) (-2.7;0.7)
p-value(Xan High - Xan Low)[1][3] 0.520
Diff of LS Means (SE) -0.5 (0.84) 95% CI (-2.2;1.1)

[1] Based on Analysis of covariance (ANCOVA) model with treatment and site group as factors and baseline
value as a covariate.
[2] Test for a non-zero coefficient for treatment (dose) as a continuous variable.
[3] Pairwise comparison with treatment as a categorical variable: p-values without adjustment for multiple
comparisons.
Source: C:\cdisc_pilot\PROGRAMS\DRAFT\TFLs\rtf_eff1.sas 21:05 Monday, June 26, 2006
    
    */

%let tabulateOutputDs=work.tab_14_3x01;
*%let orderfmt=$orderfmt;

proc tabulate data = ADQSADAS missing;
    ods output table=&tabulateOutputDs.;
  where EFFFL='Y' and ANL01FL='Y' and AVISIT='Week 24' and PARAMCD="ACTOT";
  class trtpn sitegr1;
  class EFFFL ANL01FL AVISIT PARAMCD;
  class agegr1;
  var base chg aval;    
  table
      EFFFL*ANL01FL*AVISIT*PARAMCD,
      agegr1*(base chg aval), trtpn*(n*f=F3.0 mean*f=f4.1 stddev*f=F5.2 median*f=f4.1 (min max)*f=F4.0);
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

