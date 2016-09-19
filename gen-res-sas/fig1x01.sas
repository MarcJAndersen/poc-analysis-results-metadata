/*
Display               : Figure 14-1.01 Kaplan Meier Curve
AnalysisResult        :
Analysis Parameter(s) :
Analysis Variable(s)  : 
Reason                : pre-specified in SAP
Data References (incl. Selection Criteria): 
Documentation         : SAP Section 9.1
Programming Statements:

*/


options linesize=200 nocenter;
options formchar="|----|+|---+=|-/\<>*";
options msglevel=i;

*filename source url "https://github.com/phuse-org/phuse-scripts/raw/master/data/adam/cdisc/addte.xpt";
filename source "../../phuse-scripts/data/adam/cdisc/adtte.xpt";
libname source xport ;

%let dssource=https://github.com/phuse-org/phuse-scripts/raw/master/data/adam/cdisc/adae.xpt;
%let tablename=FIG1X01;
%let tablelabel=%str(Figure 14-1.01 Kaplan Meier Curve);
%let tableheader=%str(Kaplan Meier Curve);
%let tableprogram=%lowcase(&tablename.).sas;

filename expcsvda "..\res-csv\%upcase(&tablename.).csv";
filename expcsvco "..\res-csv\%upcase(&tablename.)-Components.csv";

data adtte_1;
  set source.adtte;
run;

*Get product limit estimates;
ods select ProductLimitEstimates Quartiles Means CensoredSummary HomTests ;
ods output ProductLimitEstimates=prodlim;
  proc lifetest data = adtte_1 method = PL alpha = 0.05;
    time aval * cnsr (1);
    strata trtp;
  run;
ods output close;

*Get life table estimates;
ods select LifetableEstimates;
ods output LifetableEstimates = _dsrplest;
  proc lifetest data=adtte_1 method=LT intervals=0 50 100 150 200 alpha=0.05;
    time aval * cnsr (1);
    strata trtp;
    survival out=_dsrsvest conftype=LINEAR;
  run;
ods output close;


proc sort data=adtte_1;
by trtp aval cnsr;
run;

proc sql noprint;
select count(*) into :_cnt from adtte_1 where aval lt 0;
quit;

proc sort data=adtte_1 out=frame_trtp(keep=trtp) nodupkey;
by trtp;
run;


proc sql noprint;
  select count(*) into :_cnt from adtte_1 where cnsr ^in (0, 1);
quit;

%put &_cnt;

proc sql noprint;
  create table lasttime as select distinct trtp, max(aval) as lasttime from prodlim group by trtp;
quit;

data frame_tm;
  set frame_trtp;
  _cnt=1;
  aval=input(scan("0 50 100 150 200",_cnt,' '),best.);
  do while(aval ne .);
    output;
    _cnt=_cnt+1;
   aval=input(scan("0 50 100 150 200",_cnt,' '),best.);
  end;
run;

data _tmp_;
  set prodlim(keep=trtp aval censor failed survival failure stderr) frame_tm(rename=(aval=tabtime)) ;
run;
proc sql noprint;
  create table _pllt_ as 
    select a.*, b.lasttime from _tmp_ 
    as a left join lasttime as b on b.trtp eq a.trtp order by trtp, aval, tabtime ;
quit;

data _pl_lt_ (rename=(aval=time));
  set _pllt_;
  by trtp aval ;
  surv=survival;
  retain _surv;
  IF first.trtp then do;
    _surv = .; 
  end;
  IF aval le lasttime THEN DO;
    if surv ne . then _surv = surv;
    else surv = _surv;
  END;
  if censor eq 1 then do;
    censor_surv = surv;
    censor_flag='|';
  end;
run;

proc format;
  picture na .='N/A' other=[10.1] ;
  value dummyfmt 1=' ';
run;


data fig_14_1x01;
  set _pl_lt_;
  keep surv time trtp censor_surv censor_flag;
run;

/*------------------------------------------------------------------------*\
** Program : report_to_rrdf.sas
** Purpose : Transfer dataset report to RRDFQBCRND excel workbook format
\*------------------------------------------------------------------------*/

proc contents data=work.fig_14_1x01 varnum;
run;

proc print data=work.fig_14_1x01 width=min;
run;

proc sort data=fig_14_1x01 nodupkey;
by _all_;
run;


data fig_14_1x01_1(drop=censor_surv censor_flag);
  set fig_14_1x01;
  paramcd="surv";
  measure=surv;
  procedure="percent";
  factor="probability";
  pbfl="Y";
  output;
  paramcd="censor";
  measure=censor_surv;;
  procedure="percent";
  factor="censor";
  censfl="Y";
  pbfl="";
  output;
run;


data forexport;
    length pbfl censfl trt01p $200;
    set work.fig_14_1x01_1;
	where missing(measure) ne 1;
    keep pbfl censfl;
    keep trt01p;
    keep procedure factor paramcd time;
    length procedure factor $50;
    keep unit denominator;
    length unit denominator $50;
    unit=" ";
    denominator=" ";
    
    keep measure;
	trt01p=trtp;

    array adim(*) pbfl censfl;

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
run;


proc sort data=forexport dupout=dups nodupkey;
by trt01p pbfl censfl paramcd time procedure factor unit denominator;
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
    compType= "dimension"; compName="trt01p";    compLabel=vlabelx(compName); codeType="DATA"; nciDomainValue= " "; output;
    /* change compName to label of variable */
    compType= "dimension"; compName="pbfl";    compLabel=vlabelx(compName); codeType="DATA"; nciDomainValue= " "; output;
    compType= "dimension"; compName="censfl";    compLabel=compName; codeType="DATA"; nciDomainValue= " "; output;
    compType= "dimension"; compName="paramcd";    compLabel=compName; codeType="DATA"; nciDomainValue= " "; output;
    compType= "dimension"; compName="time";    compLabel=compName; codeType="DATA"; nciDomainValue= " "; output;

    compType= "dimension"; compName="procedure"; compLabel="Statistical Procedure"; codeType="DATA"; nciDomainValue= " ";output;
    compType= "dimension"; compName="factor";    compLabel="Type of procedure (quantity, proportion...)"; codeType="DATA"; nciDomainValue= " "; output;

    compType= "measure"; compName="measure";      compLabel="Value of the statistical measure"; codeType=" "; nciDomainValue=" "; output;
    compType= "attribute"; compName="unit";        compLabel="Unit of measure"; codeType=" "; nciDomainValue=" "; output;
    compType= "attribute"; compName="denominator"; compLabel="Denominator for a proportion (oskr) subset on which a statistic is based"; codeType=" "; nciDomainValue=" "; output;
    
run;


data skeletonSource2;
length compType compName codeType nciDomainValue compLabel Comment $512;
    
compType= "metadata";
compName= "obsURL";
codeType= " ";
nciDomainValue= " ";
compLabel= "https://phuse-scripts.googlecode.com/svn/trunk/scriptathon2014/data/adtte.xpt";
Comment= "obsFileName";
output; 

compType= "metadata";
compName= "obsFileName";
codeType= " ";
nciDomainValue= " ";
compLabel= "fig1x01.csv";
Comment= "obsFileName";
output; 

compType= "metadata";
compName= "dataCubeFileName";
codeType= " ";
nciDomainValue= " ";
compLabel= "DC-FIG1X01";
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
compLabel= "Data from adtte.sas program";
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
Comment= "Figure 14-1.01 Kaplan Meier Curve";
output; 

compType= "metadata";
compName= "title";
codeType= " ";
nciDomainValue= " ";
compLabel= "Survival Probabilities";
Comment= "Figure 14-1.01 Kaplan Meier Curve";
output; 

compType= "metadata";
compName= "label";
codeType= " ";
nciDomainValue= " ";
compLabel= "Figure 14-1.01 Kaplan Meier Curve";
Comment= " ";
output; 

compType= "metadata";
compName= "wasDerivedFrom";
codeType= " ";
nciDomainValue= " ";
compLabel= "fig1x01.csv";
Comment= "Data source (obsFileName). Set this programmtically based on name of input file!";
output; 

compType= "metadata";
compName= "domainName";
codeType= " ";
nciDomainValue= " ";
compLabel= "FIG1X01";
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

run;

data skeletonSource;
    set skeletonSource1 skeletonSource2;
run;
    
proc export data=skeletonSource file=expcsvco replace dbms=csv;
run;
