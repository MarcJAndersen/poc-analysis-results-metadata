/*------------------------------------------------------------------------*\
** Program : check-apache-jena-with-proc-groovy.sas
** Purpose : Basic test of using Apache Jena java using proc groovy
** Notes: This is first version. Java code is not ideal.
** Notes: The macro getxml should be part of ../../SAS-SPARQLwrapper/sparqlquery.sas
** Status: ok    
\*------------------------------------------------------------------------*/

options linesize=200;
options mprint nocenter;

libname this ".";

%let cubestemname=fig1x01;
%let cubettlfile=../res-ttl/CDISC-pilot-%upcase(&cubestemname).ttl;
%let rqfile=../sparql-rq/&cubestemname..rq;
%let outxmlfile=check-CDISC-pilot-%upcase(&cubestemname).xml;
%let tabletitle=%str(Figure 14-1.01 Kaplan Meier Curve);
filename htmlpath "../application-html";

/* * /
* BEGIN: SPARQL query and store SAS dataset;
%include "include-jena-groovy.sas" /source;

* Trick store it as a local file;
data this.&cubestemname.;
    set &cubestemname.;
run;

proc contents data=this.&cubestemname. varnum;
run;
* END: SPARQL query and store SAS dataset;
/* */

* Trick: retrieve the local file;
* When developing the presentation part;
* comment out the query part between BEGIN/END above;
data &cubestemname.;
    set this.&cubestemname.;
run;

data fig1x01_1(rename=(_trt01p=trt01p _time=time));
  set fig1x01;
  if index(pbfl,"-Y")>0 then paramcd="SURV";
  else paramcd="CENS";
  _time=input(scan(time,2,"-"),best12.);
  _trt01p=scan(trt01p,2,"-");
  drop time trt01p;
run; 
proc sort data=fig1x01_1;
by time trt01p col1z1URI  ;
run;

proc transpose data=fig1x01_1 out=fig1x01_t;
id paramcd;
by time trt01p col1z1URI  ;
var col1z1;
run;

data fig1x01_t1;
  set fig1x01_t;
  if missing(cens) ne 1 then censor_flag="||";
  rename cens=censor_surv trt01p=trtp;
run;

proc print data=fig1x01_t1 width=min;
    var trtp time surv censor_flag censor_surv col1z1URI;
run;

options nomautolocdisplay mfile mprint;
proc template;
  define statgraph KM;
  begingraph;
    layout lattice / columns=1 rowgutter=8 rowweights=(1);
      columnaxes;
        columnaxis;
      endcolumnaxes;
      layout overlay / yaxisopts=(griddisplay=on offsetmin=0 linearopts=(viewmin=0 viewmax=1 tickvaluelist=(0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1) minorticks=true) labelattrs=(Family="Arial Unicode MS")) xaxisopts=(griddisplay=on offsetmin=0 linearopts=(viewmin=0 viewmax=200 tickvaluelist=(0 50 100 150 200) minorticks=true) labelattrs=(Family="Arial Unicode MS"));
        stepplot x=time y=SURV / group=trtp name='s' primary=true url=col1z1URI;
        scatterplot x=time y=censor_SURV / group=trtp markercharacter=censor_flag markercharacterattrs=(size=11)  url=col1z1URI;
        layout gridded / autoalign=AUTO border=false;
          entry halign=center "||| Censored";
          entry halign=center "Log-Rank p=<.0001";
          discretelegend 's' / valueattrs=(size=8) border=off location=inside across=1;
        endlayout;
      endlayout;
    endlayout;
  endgraph;
end;
run;

ods listing exclude all;
ods graphics on / imagefmt=png imagemap=on border=off height=3.6in width=6in imagename="fig1x01";
ods html path =htmlpath(url=none) 
         file = "fig1x01.html";
  title1 font='Arial Unicode MS' color=black "Figure 14-1" ;
  title2 font='Arial Unicode MS' color=black "Time to Dermatologic Event by Treatment Group" ;
  proc sgrender data=fig1x01_t1 template=KM;
    dynamic _prttl=0 _prsttl=0 _prfnt=0 ;
    footnote1 font='Arial Unicode MS' j=left color=black "*Generated using PROC LIFETEST";
  run;
ods html close;
ods graphics / reset=all;
ods listing select all;

ods listing exclude all;
ods graphics on / imagefmt=svg imagemap=off /* not needed for HTML5 svg -see http://support.sas.com/documentation/cdl/en/odsug/67921/HTML/default/viewer.htm#p0kroq43yu0lspn16hk1u4c65lti.htm */
border=off height=3.6in width=6in;
ods html5 options(svg_mode="inline") path =htmlpath /* (url=none)  */
         file = "fig1x01_svga.html";
  title1 font='Arial Unicode MS' color=black "Figure 14-1" ;
  title2 font='Arial Unicode MS' color=black "Time to Dermatologic Event by Treatment Group" ;
  proc sgrender data=fig1x01_t1 template=KM;
    footnote1 font='Arial Unicode MS' j=left color=black "*Generated using PROC LIFETEST";
  run;
ods html5 close;
ods graphics / reset=all;
ods listing select all;

