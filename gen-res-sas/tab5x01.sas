/*
Display               : Table 14-5.01 Incidence of Treatment Emergent Adverse Events by Treatment Group
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

filename source "../../phuse-scripts/data/adam/cdisc/adae.xpt"; 
libname source xport ;

%let dssource=https://github.com/phuse-org/phuse-scripts/raw/master/data/adam/cdisc/adae.xpt;
%let tablename=TAB5X01;
%let tablelabel=%str(Table 14-5.01 Incidence of Treatment Emergent Adverse Events by Treatment Group);
%let tableheader=%str(Adverse Events);
%let tableprogram=%lowcase(&tablename.).sas;

filename expcsvda "..\res-csv\%upcase(&tablename.).csv";

filename expcsvco "..\res-csv\%upcase(&tablename.)-Components.csv";

        
data work.ADAE ;
    set source.ADAE ;
    array aflc(*) AOCCFL AOCCSFL AOCCPFL;
    array afln(*) AOCCFLN AOCCSFLN AOCCPFLN;
    do i=1 to dim(aflc);
        afln(i)=ifc(aflc(i)="Y",1,0);
        end;
    rename aesoc=aesoc aedecod=aedecod trtemfl=trtemfl aoccfl=aoccfl aoccsfl=aoccsfl aoccpfl=aoccpfl;
run;

/*
proc contents data=adae varnum;
run;

proc print data=adae width=min;
    by usubjid;
    id usubjid;
    var aeseq AESOC AEDECOD TRTEMFL AOCCFL AOCCSFL AOCCPFL;
run;
*/


/*
            <adamref:AnalysisVariable ItemOID="ADAE.TRTA"/>
            <adamref:AnalysisVariable ItemOID="ADAE.AEBODSYS"/>
            <adamref:AnalysisVariable ItemOID="ADAE.AEDECOD"/>
*/

%let tabulateOutputDs=work.tab_&tablename.;
*%let orderfmt=$orderfmt;
/* (drop=AOCCFLN AOCCSFLN AOCCPFLN rename=(sum=countdistinct)) */

/*

proc tabulate data=adae missing;
    ods output table=&tabulateOutputDs. ;
    where also saffl="Y";
    where also trtemfl="Y";
    class saffl trtemfl;
    class AESOC AEDECOD;
    class trta;
    var AOCCFLN AOCCSFLN AOCCPFLN;
    table saffl*trtemfl*(AOCCFLN AESOC*(AOCCSFLN AEDECOD*AOCCPFLN)), trta*(sum*f=F5.0 n*f=f5.0) ;
run;

*/


proc tabulate data=adae missing;
    ods output table=&tabulateOutputDs._ALL ;
    where also saffl="Y";
    where also trtemfl="Y";
    class saffl trtemfl;
    class trta;
    var AOCCFLN;
    table saffl*trtemfl,AOCCFLN, trta*(sum*f=F5.0 n*f=f5.0)  / rtspace=50;
run;

proc tabulate data=adae missing;
    ods output table=&tabulateOutputDs._SOC ;
    where also saffl="Y";
    where also trtemfl="Y";
    class saffl trtemfl;
    class AESOC;
    class trta;
    var AOCCFLN AOCCSFLN;
    table saffl*trtemfl,AESOC*AOCCSFLN, trta*(sum*f=F5.0 n*f=f5.0)  / rtspace=50;
run;

proc tabulate data=adae missing;
    ods output table=&tabulateOutputDs._DECOD ;
    where also saffl="Y";
    where also trtemfl="Y";
    class saffl trtemfl;
    class AESOC AEDECOD;
    class trta;
    var  AOCCPFLN;
    table saffl*trtemfl,AESOC*AEDECOD*AOCCPFLN, trta*(sum*f=F5.0 n*f=f5.0) / rtspace=50;
run;

data &tabulateOutputDs.;
    set &tabulateOutputDs._DECOD(rename=(AOCCPFLN_sum=countdistinct AOCCPFLN_n=count))
        &tabulateOutputDs._ALL  (rename=(AOCCFLN_sum=countdistinct  AOCCFLN_n=count ))
        &tabulateOutputDs._SOC  (rename=(AOCCSFLN_sum=countdistinct AOCCSFLN_n=count))
        ;
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

