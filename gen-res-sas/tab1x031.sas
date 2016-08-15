/*
Display               : Table 14-1.03 Summary of Number of Subjects by Site
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
options formchar="|----|+|---+=|-/\<>*";
options msglevel=i;

filename source url "https://github.com/phuse-org/phuse-scripts/raw/master/data/adam/cdisc/adsl.xpt";
*filename source "C:\PhARM\CDISCPilot\m5\datasets\cdiscpilot01\analysis\adam\datasets\adsl.xpt";


/* filename source "../sample-xpt/adsl.xpt"; */
libname source xport ;

proc format;
    value $trt01p(notsorted)
        "Placebo"="Placebo"
        "Xanomeline Low Dose"="Xanomeline Low Dose"
        "Xanomeline High Dose"="Xanomeline High Dose"
        ;
run;

*Concatenate site and pooled site ids to one variable and create rows for total column;        
data adsl_1 ;
    set source.adsl ;
    length compfl $1.;
    compfl= ifc(DCREASCD="Completed", "Y", " ");
	sitefull=compress("s" || siteid || "_" || sitegr1);
	trt01p=put(trt01p,$trt01p.);
	output;
	trt01p="Total";
	output;
    label compfl="Complete Study";
run;

*Create additional variable trtftyp by combining flag type and treatment to facilitate summarization;
data adsl_2;
  set adsl_1(where=(ittfl="Y") in=itt) adsl_1(where=(efffl="Y") in=eff) adsl_1(where=(compfl="Y") in=comp);
  if itt then ftype="ITTFL";
  if eff then ftype="EFFFL";
  if comp then ftype="CMPFL";
  flag="Y";
  trtftype=trim(trt01p) || "_" || ftype;
  keep usubjid sitefull trtftype flag;
run;

proc sort data=adsl_2;
by usubjid trtftype;
run;

proc transpose data=adsl_2 out=adsl_t;
var flag;
by usubjid trtftype;
id sitefull;
run;

*Store all the site variables in a macro variable;
proc sql noprint;
  create table sites as
     select distinct sitefull, "Full name for site " || compress(sitefull) as labsitvars from adsl_2;
  select distinct sitefull into :lsitvars separated by " " from sites;
  select distinct labsitvars into :lsitlab separated by "*" from sites;
quit;
%put &lsitvars;
%put &lsitlab;

proc tabulate data=adsl_t missing;
    ods output table=work.tab_14_1x03;
    class trtftype / ORDER=DATA; 
    class &lsitvars; 
    table &lsitvars, 
        (trtftype all)*(N*f=f3.0 pctn<&lsitvars>*f=f3.0);
run;


/*------------------------------------------------------------------------*\
** Program : report_to_rrdf.sas
** Purpose : Transfer dataset report to RRDFQBCRND excel workbook format
\*------------------------------------------------------------------------*/

proc contents data=work.tab_14_1x03 varnum;
run;

proc print data=work.tab_14_1x03 width=min;
run;

%macro prepexport;
data forexport;
    length &lsitvars $200;
	label 
	%do i=1 %to %sysfunc(countw(&lsitvars)); 
  	  %scan(&lsitvars,&i)="%scan(&lsitlab,&i,*)"
    %end;;          
    set work.tab_14_1x03;
    keep &lsitvars /* disconfl */;
    keep trtftype;
    keep procedure factor;
    length procedure factor $50;
    keep unit denominator;
    length unit denominator $50;
    unit=" ";

    keep measure;

    array adim(*) &lsitvars trtftype;

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
    /* assuming only one variable as denominator, except the first TRT01PN */
    denominator=vname(adim(index(substr(_type_,2),"1"))); 
    measure= PctN_100000000000000000;
    output;
    end;

    if substr(_type_,1,1)="0" then do;
    factor="proportion";
    procedure="percent";
    /* assuming only one variable as denominator, except the first TRT01PN */
    denominator=vname(adim(index(substr(_type_,2),"1"))); 
    measure= PctN_000000000000000000;
    output;
    end;

run;
%mend prepexport;
option mprint;
%prepexport;

proc sort data=forexport nodupkey;
by trtftype &lsitvars  procedure  factor  unit  denominator;
run;

proc print data=forexport width=min;
run;

proc contents data=forexport varnum;
run;

proc export data=forexport file="..\res-csv\TAB1X03.csv" replace;
run;

data skeletonSource1;
    if 0 then do;
        set forexport; /* To get the labels  TODO: check if there are name clashes - or implement differently */
        end;
        length compType compName codeType nciDomainValue compLabel Comment $512;
        keep compType compName codeType nciDomainValue compLabel Comment;
    Comment= " ";
    compType= "dimension"; compName="trtftype";    compLabel=vlabelx(compName); codeType="DATA"; nciDomainValue= " "; output;


    /* change compName to label of variable */
	do i=1 to %sysfunc(countw(&lsitvars));
      compType= "dimension"; compName=scan("&lsitvars",i);    compLabel=vlabelx(compName); codeType="DATA"; nciDomainValue= " "; output;
	end;
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
compLabel= "https://phuse-scripts.googlecode.com/svn/trunk/scriptathon2014/data/adsl.xpt";
Comment= "obsFileName";
output; 

compType= "metadata";
compName= "obsFileName";
codeType= " ";
nciDomainValue= " ";
compLabel= "tab1x03.csv";
Comment= "obsFileName";
output; 

compType= "metadata";
compName= "dataCubeFileName";
codeType= " ";
nciDomainValue= " ";
compLabel= "DC-TAB1X03";
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
Comment= "Table 14-1.03 Summary of Number of Subjects by Site";
output; 

compType= "metadata";
compName= "title";
codeType= " ";
nciDomainValue= " ";
compLabel= "Demographics Analysis Results";
Comment= "Table 14-1.03 Summary of Number of Subjects by Site";
output; 

compType= "metadata";
compName= "label";
codeType= " ";
nciDomainValue= " ";
compLabel= "Table 14-1.03 Summary of Number of Subjects by Site";
Comment= " ";
output; 

compType= "metadata";
compName= "wasDerivedFrom";
codeType= " ";
nciDomainValue= " ";
compLabel= "tab1x03.csv";
Comment= "Data source (obsFileName). Set this programmtically based on name of input file!";
output; 

compType= "metadata";
compName= "domainName";
codeType= " ";
nciDomainValue= " ";
compLabel= "TAB1X03";
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
    
proc export data=skeletonSource file="..\res-csv\TAB1X03-Components.csv" replace;
run;


