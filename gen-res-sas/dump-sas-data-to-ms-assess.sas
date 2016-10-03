/*

See ../../phuse-scripts/data/adam/cdisc/README.md

*/

options mprint;

data _null_;
    length fname $8 delfile $200;
    fname="XLS_EXP";
    delfile="c:\sasdata\cdiscpilot01.mdb";
    rc=filename(fname,delfile);
    if rc = 0 and fexist(fname) then do;
       rc=fdelete(fname);
       putlog "Deleted " delfile= rc=;
       end;
    rc=filename(fname);
run;

%MACRO LoadXPT(
    dsnprefix=,
    path=../../phuse-scripts/data/adam/cdisc,
    dbnamepath=%str(c:\sasdata\cdiscpilot01.mdb),
    keylist=,
    exportoption=
    );    
filename source "&path./&dsnprefix..xpt"; 
libname source xport ;
data &dsnprefix.;
     set source.&dsnprefix.;
run;

/* upcase of dsnprefix to match with R-package */

PROC EXPORT DATA=work.&dsnprefix.
            OUTTABLE= "%upcase(&dsnprefix.)"
            DBMS=ACCESS &exportoption;
     DATABASE="&dbnamepath.";
RUN;

PROC SQL;
CONNECT TO access( PATH="&dbnamepath." AUTOCOMMIT= no );
EXECUTE(ALTER TABLE %upcase(&dsnprefix.) ADD PRIMARY KEY(&keylist.) ) BY access;
  /* To commit the table CREATE and insert ; */
EXECUTE(jet::commit) BY access;
DISCONNECT FROM access;
QUIT;

%MEND;

/* the domainkeys are in define.xml as
    <ItemGroupDef OID="ADAE"
  def:DomainKeys >
    */

%LoadXPT(dsnprefix=adsl,keylist=%str(USUBJID));

/* keylist=%str(USUBJID, AETERM, ASTDT, AESEQ) */
%LoadXPT(dsnprefix=adae,keylist=%str(USUBJID, AESEQ) );

/* keylist=%str(USUBJID, PARAMCD, AVISIT, ADT) */
    
%LoadXPT(dsnprefix=adqsadas,keylist=%str(USUBJID, PARAMCD, AVISIT, ADT) );


/*


http://www.bullzip.com/products/a2m/doc/info.php


cd/d c:\sasdata\
"C:\Program Files (x86)\Bullzip\MS Access to MySQL\msa2mys.exe" settings=cdiscpilot01.ini,AUTORUN
REM I ignored the message on missing 32-bit OBDC driver

set mariadbuser=xxx
set mariadbpassword=xxx

in my.ini add "lower_case_table_names=0"

cd/d c:\sasdata\
"C:\Program Files\mariadb 10.1\bin\mysql.exe" "--defaults-file=C:\Program Files\mariadb 10.1\data\my.ini" --lower-case-table-names=0 -u%mariadbuser% --password=%mariadbpassword% <cdiscpilot01.sql

"c:\opt\d2rq-0.8.1\generate-mapping" -o cdiscpilot01-d2rq-mapping.ttl "jdbc:mariadb://localhost:3306/cdiscpilot01?user=%mariadbuser%&password=%mariadbpassword%"

"c:\opt\d2rq-0.8.1\dump-rdf" -b http://www.example.org/datasets/ -o cdiscpilot01.ttl "jdbc:mariadb://localhost:3306/cdiscpilot01?user=%mariadbuser%&password=%mariadbpassword%"

*/



