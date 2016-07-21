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

    
*/


options linesize=200 nocenter;
options formchar="|----|+|---+=|-/\<>*";
options msglevel=i;

*filename source url "https://github.com/phuse-org/phuse-scripts/raw/master/data/adam/cdisc/adsl.xpt";
*filename source "C:\PhARM\CDISCPilot\m5\datasets\cdiscpilot01\analysis\adam\datasets/adsl.xpt";
filename source "../../phuse-scripts/data/adam/cdisc/adsl.xpt"; 
libname source xport ;

filename expcsvda "..\res-csv\TAB1X02_1.csv";

filename expcsvco "..\res-csv\TAB1X02_1-Components.csv";

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
    length compfl aedisfl dthdisfl lefdisfl ltfdisfl pdndisfl pviodisfl stsdisfl wbsdisfl etfl $1;
	etfl= ifc(comp24fl="Y", " ", "Y");
    compfl= ifc(DCREASCD="Completed", "Y", " ");
	aedisfl=ifc(dcdecod="ADVERSE EVENT", "Y", " ");
	dthdisfl=ifc(dcdecod="DEATH", "Y", " ");
	lefdisfl=ifc(dcdecod="LACK OF EFFICACY", "Y", " ");
	ltfdisfl=ifc(dcdecod="LOST TO FOLLOW-UP", "Y", " ");
	pdndisfl=ifc(dcdecod="PHYSICIAN DECISION", "Y", " ");
	pviodisfl=ifc(dcdecod="PROTOCOL VIOLATION", "Y", " ");
	stsdisfl=ifc(dcdecod="STUDY TERMINATED BY SPONSOR", "Y", " ");
	wbsdisfl=ifc(dcdecod="WITHDRAWAL BY SUBJECT", "Y", " ");
    label compfl="Complete Study";
run;

proc tabulate data=adsl missing;
    ods output table=work.tab_14_1x02;
    class trt01p / preloadfmt ORDER=DATA; /* trt01p not trt01pn */
    class etfl ittfl saffl comp24fl compfl aedisfl dthdisfl lefdisfl ltfdisfl pdndisfl pviodisfl stsdisfl wbsdisfl/* disconfl */; 
    table etfl ittfl saffl comp24fl compfl aedisfl dthdisfl lefdisfl ltfdisfl pdndisfl pviodisfl stsdisfl wbsdisfl/* disconfl */, 
        (trt01p all)*(N*f=f3.0 pctn<etfl ittfl saffl comp24fl compfl aedisfl dthdisfl lefdisfl ltfdisfl pdndisfl pviodisfl stsdisfl wbsdisfl /* disconfl*/>*f=f3.0);
run;


/*------------------------------------------------------------------------*\
** Program : report_to_rrdf.sas
** Purpose : Transfer dataset report to RRDFQBCRND excel workbook format
\*------------------------------------------------------------------------*/

proc contents data=work.tab_14_1x02 varnum;
run;

proc print data=work.tab_14_1x02 width=min;
run;

data forexport;
    length etfl ittfl saffl comp24fl compfl /* disconfl */ trt01p aedisfl dthdisfl lefdisfl ltfdisfl pdndisfl pviodisfl stsdisfl wbsdisfl $200;
	label aedisfl="Adverse Event" dthdisfl="Death" lefdisfl="Lack of Efficacy" ltfdisfl="Lost to Follow-up" 
          pdndisfl="Physician Decided to withdraw Subject" pviodisfl="Protocol violation" stsdisfl="Sponsor decision" 
          wbsdisfl="Subject decided to withdraw" etfl="Early termination prior to week 24";
    set work.tab_14_1x02;
    keep ittfl saffl comp24fl compfl aedisfl dthdisfl lefdisfl ltfdisfl pdndisfl pviodisfl stsdisfl wbsdisfl etfl;
    keep trt01p;
    keep procedure factor;
    length procedure factor $50;
    keep unit denominator;
    length unit denominator $50;
    unit=" ";

    keep measure;

    array adim(*) etfl ittfl saffl comp24fl compfl aedisfl dthdisfl lefdisfl ltfdisfl pdndisfl pviodisfl stsdisfl wbsdisfl trt01pn;

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
    measure= PctN_10000000000000;
    output;
    end;

    if substr(_type_,1,1)="0" then do;
    factor="proportion";
    procedure="percent";
    /* assuming only one variable as denominator, except the first TRT01PN */
    denominator=vname(adim(index(substr(_type_,2),"1"))); 
    measure= PctN_00000000000000;
    output;
    end;

run;

proc sort data=forexport nodupkey;
by trt01p  etfl ittfl  saffl  comp24fl  aedisfl  dthdisfl  lefdisfl  ltfdisfl  pdndisfl  pviodisfl  stsdisfl  wbsdisfl  procedure  factor  unit  denominator;
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
	compType= "dimension"; compName="etfl";      compLabel=vlabelx(compName); codeType="DATA"; nciDomainValue= " "; output;
    compType= "dimension"; compName="ittfl";     compLabel=vlabelx(compName); codeType="DATA"; nciDomainValue= " "; output;
    compType= "dimension"; compName="saffl";     compLabel=vlabelx(compName); codeType="DATA"; nciDomainValue= " "; output;
    compType= "dimension"; compName="comp24fl";  compLabel=vlabelx(compName); codeType="DATA"; nciDomainValue= " "; output;
    compType= "dimension"; compName="compfl";    compLabel=vlabelx(compName); codeType="DATA"; nciDomainValue= " "; output;
    compType= "dimension"; compName="trt01p";    compLabel=vlabelx(compName); codeType="DATA"; nciDomainValue= " "; output;
    compType= "dimension"; compName="aedisfl";   compLabel=vlabelx(compName); codeType="DATA"; nciDomainValue= " "; output;
	compType= "dimension"; compName="dthdisfl";  compLabel=vlabelx(compName); codeType="DATA"; nciDomainValue= " "; output;
	compType= "dimension"; compName="lefdisfl";  compLabel=vlabelx(compName); codeType="DATA"; nciDomainValue= " "; output;
	compType= "dimension"; compName="ltfdisfl";  compLabel=vlabelx(compName); codeType="DATA"; nciDomainValue= " "; output;
	compType= "dimension"; compName="pdndisfl";  compLabel=vlabelx(compName); codeType="DATA"; nciDomainValue= " "; output;
	compType= "dimension"; compName="pviodisfl"; compLabel=vlabelx(compName); codeType="DATA"; nciDomainValue= " "; output;
	compType= "dimension"; compName="stsdisfl";  compLabel=vlabelx(compName); codeType="DATA"; nciDomainValue= " "; output;
	compType= "dimension"; compName="wbsdisfl";  compLabel=vlabelx(compName); codeType="DATA"; nciDomainValue= " "; output;
    compType= "dimension"; compName="procedure"; compLabel="Statistical Procedure"; codeType="DATA"; nciDomainValue= " ";output;
    compType= "dimension"; compName="factor";    compLabel="Type of procedure (quantity, proportion...)"; codeType="DATA"; nciDomainValue= " "; output;

    compType= "attribute"; compName="unit";      compLabel="Unit of measure"; codeType=" "; nciDomainValue=" "; output;
    compType= "attribute"; compName="denominator"; compLabel="Denominator for a proportion (oskr) subset on which a statistic is based"; codeType=" "; nciDomainValue=" "; output;
    compType= "measure"; compName="measure";     compLabel="Value of the statistical measure"; codeType=" "; nciDomainValue=" "; output;

    
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
compLabel= "tab1x02_1.csv";
Comment= "obsFileName";
output; 

compType= "metadata";
compName= "dataCubeFileName";
codeType= " ";
nciDomainValue= " ";
compLabel= "DC-TAB1X02_1";
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
Comment= "Table 14-1.02 Summary of Disposition (version _1)";
output; 

compType= "metadata";
compName= "title";
codeType= " ";
nciDomainValue= " ";
compLabel= "Demographics Analysis Results";
Comment= "Table 14-1.02 Summary of Disposition (version _1)";
output; 

compType= "metadata";
compName= "label";
codeType= " ";
nciDomainValue= " ";
compLabel= "Table 14-1.02 Summary of Disposition (version _1)";
Comment= " ";
output; 

compType= "metadata";
compName= "wasDerivedFrom";
codeType= " ";
nciDomainValue= " ";
compLabel= "tab1x02_1.csv";
Comment= "Data source (obsFileName). Set this programmtically based on name of input file!";
output; 

compType= "metadata";
compName= "domainName";
codeType= " ";
nciDomainValue= " ";
compLabel= "TAB1X02_1";
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


