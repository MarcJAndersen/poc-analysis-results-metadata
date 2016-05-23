/*------------------------------------------------------------------------*\
** Program : check-apache-jena-with-proc-groovy.sas
** Purpose : Basic test of using Apache Jena java using proc groovy
** Notes: This is first version. Java code is not ideal.
** Notes: The macro getxml should be part of ../../SAS-SPARQLwrapper/sparqlquery.sas
** Status: ok    
\*------------------------------------------------------------------------*/

options mprint nocenter;

proc groovy  ;
%let jenalib=%str(../../apache-jena-2.13.0/lib);  
add classpath="&jenalib./commons-codec-1.6.jar";
add classpath="&jenalib./commons-csv-1.0.jar";
add classpath="&jenalib./commons-lang3-3.3.2.jar";
add classpath="&jenalib./httpclient-4.2.6.jar";
add classpath="&jenalib./httpclient-cache-4.2.6.jar";
add classpath="&jenalib./httpcore-4.2.5.jar";
add classpath="&jenalib./jackson-annotations-2.3.0.jar";
add classpath="&jenalib./jackson-core-2.3.3.jar";
add classpath="&jenalib./jackson-databind-2.3.3.jar";
add classpath="&jenalib./jcl-over-slf4j-1.7.6.jar";
add classpath="&jenalib./jena-arq-2.13.0.jar";
add classpath="&jenalib./jena-core-2.13.0.jar";
add classpath="&jenalib./jena-iri-1.1.2.jar";
add classpath="&jenalib./jena-tdb-1.1.2.jar";
add classpath="&jenalib./jsonld-java-0.5.1.jar";
add classpath="&jenalib./libthrift-0.9.2.jar";
add classpath="&jenalib./log4j-1.2.17.jar";
add classpath="&jenalib./slf4j-api-1.7.6.jar";
add classpath="&jenalib./slf4j-log4j12-1.7.6.jar";
add classpath="&jenalib./xercesImpl-2.11.0.jar";
add classpath="&jenalib./xml-apis-1.4.01.jar";

submit;
import java.io.FileOutputStream;

import com.hp.hpl.jena.query.ARQ ;
import com.hp.hpl.jena.query.Query ;
import com.hp.hpl.jena.query.QueryExecution ;
import com.hp.hpl.jena.query.QueryExecutionFactory ;
import com.hp.hpl.jena.query.QueryFactory ;
import com.hp.hpl.jena.query.ResultSet ;
import com.hp.hpl.jena.query.ResultSetFormatter ;

import org.apache.jena.riot.RDFDataMgr ;
import org.apache.jena.riot.RDFLanguages ;
import com.hp.hpl.jena.rdf.model.Model ;
import com.hp.hpl.jena.rdf.model.ModelFactory ;
/* Apache Jena see https://jena.apache.org/tutorials/rdf_api.html */

// https://jena.apache.org/documentation/javadoc/jena/org/apache/jena/rdf/model/ModelFactory.html
Model m = ModelFactory.createDefaultModel() ;
m.read("../../rrdfqbcrnd0/rrdfqb/inst/extdata/cube-vocabulary-rdf/cube.ttl");
m.read("../res-ttl/CDISC-pilot-TAB1X01.ttl") ;
        
// https://jena.apache.org/documentation/javadoc/arq/org/apache/jena/query/QueryFactory.html    
Query query = QueryFactory.read("../sparql-rq/tab1x01.rq") ;
QueryExecution qexec = QueryExecutionFactory.create(query, m) ;

//  https://jena.apache.org/documentation/javadoc/arq/org/apache/jena/query/ResultSetFormatter.html
ResultSet rs = qexec.execSelect() ;
//       ResultSetFormatter.outputAsXML(System.out, rs);
FileOutputStream os = new FileOutputStream("check-CDISC-pilot-TAB1X01.xml");            
ResultSetFormatter.outputAsXML(os, rs);
os.close();

System.out.println("Done");

endsubmit;
quit;

/* code below from
../../SAS-SPARQLwrapper/sparqlquery.sas
*/

%macro getxml(
    sparqlquerysxlemap=%str(../../SAS-SPARQLwrapper/sparqlquery-sxlemap.map),
    tempnamestem=check-CDISC-pilot-TAB1X01,
    frsxlemap=SXLEMAP,
    resultdsn=tab1x01,
    debug=Y
);

filename sqresult "&tempnamestem..xml";

%local rc;

%let rc=%sysfunc(fileref(&frsxlemap.));
%if &rc ne 0 %then %do;    
    filename  &frsxlemap. "&sparqlquerysxlemap";
    %end;
    
%if %sysfunc(fileexist(sqresult)) %then %do;
    %put sparqlquery: filename SQRESULT %sysfunc(pathname(sqresult)) does not exist.;
        %if %qupcase(&problemHandling.)=ABORTCANCEL %then %do;
        data _null_;
            abort cancel;
            run;
            %end;
        %else %do;
            %return;
            %end;
        %end;
    
libname   sqresult xmlv2 xmlmap=&frsxlemap. access=READONLY encoding="utf-8";

%IF %qupcase(&debug)=%qupcase(Y) %then %do;
    title2 "sqresult.variable";
    proc contents data=sqresult.variable varnum;
        run;
        
    proc print data=sqresult.variable width=min;
    run;
    
    title2 "sqresult.binding";
    proc contents data=sqresult.binding varnum;
    run;
    
    proc print data=sqresult.binding width=min;
    run;
    
    title2 "sqresult.literal";
    proc contents data=sqresult.literal varnum;
    run;
    
    proc print data=sqresult.literal width=min; 
    run;
    title2;

%end;

data binding1;
    set SQRESULT.binding;
    name= translate(strip(name),"_","-"); /*maybe use other method, like replace - with _ etc */
run;
    
data variable1;
    set sqresult.variable;
    length var_datatype $64;
    var_datatype=" ";
    max_length=1; /* default length for character of 1 character - to handle no records in result */
    name= translate(strip(name),"_","-"); /*maybe use other method, like replace - with _ etc */
run;

/* go through all records and determine datatype and maximal
    length.
    Use that to make attribute statements
    */
data sq;
   if _n_=1 then do;
       if 0  then do;
           set variable1;
           end;
       declare hash variable(dataset: "variable1" );
       variable.defineKey('name');
       variable.defineData(all: "YES");
       variable.defineDone();
       /* make empty dataset - way of handling the case with no records in result */
       variable.output(dataset:"work.variable2");    

       end;
        
    merge
        sqresult.literal
        binding1
        end=AllDone
        ;
    by binding_CNT binding_ORDINAL;
    length valuetext $32000;
    length valuetexttype $65;
/*    length valuetextlang $2; */
    if missing(uri) then do;
        valuetext=literal;
        valuetexttype=datatype;
/* I do not understand why lang is blank. In SAS XMLmapper the lang column is populated 
        valuetextlang=lang;
*/
        end;
    else do;
        valuetext=uri;
        valuetexttype="uri";
/*
        valuetextlang=" ";
*/        
        end;

    keep binding_CNT name valuetext;
/*
    keep valuetextlang;
    */
    
    rc=variable.find();
    if rc ne 0 then do;
        putlog name= " unexpected name";
        end;
    else do;
        select;
        when (var_datatype=valuetexttype) do; 
       /* nothing */
        end;
        when (missing(var_datatype)) do; 
           var_datatype=valuetexttype;
           variable.replace();
        end;
        otherwise do;
           putlog name= var_datatype= valuetexttype= " unexpected more than one datatype";
           putlog " setting type to string";
           var_datatype="http://www.w3.org/2001/XMLSchema#string";
           variable.replace();
        end;
        end;

        if length(valuetext)>max_length then do;
           max_length=length(valuetext);
           variable.replace();
        end;  

   end;

   if alldone then do;
      variable.output(dataset:"work.variable2");    
   end;
run;

proc sort data=work.variable2;
    by variable_ORDINAL;
run;

%IF %qupcase(&debug)=%qupcase(Y) %then %do;
title2 "work.variable2";    
proc print data=work.variable2 width=min;
run;
%end;

/* This could also be stored in a hash or made as a format and combined in the step above */
data work.variable3;
    set work.variable2;
    length var_informat $33 var_type $1;
    select;
    /* Add additonal data types here */
    when (var_datatype="http://www.w3.org/2001/XMLSchema#string"  ) do; var_type="C"; var_informat=" "; end;
    when (var_datatype="http://www.w3.org/2001/XMLSchema#integer" ) do; var_type="N"; var_informat="best."; end;
    when (var_datatype="http://www.w3.org/2001/XMLSchema#long"    ) do; var_type="N"; var_informat="best."; end;
    when (var_datatype="http://www.w3.org/2001/XMLSchema#double"  ) do; var_type="N"; var_informat="best."; end;
    when (var_datatype="http://www.w3.org/2001/XMLSchema#float"   ) do; var_type="N"; var_informat="best."; end;
    when (var_datatype="http://www.w3.org/2001/XMLSchema#decimal" ) do; var_type="N"; var_informat="best."; end;
    when (var_datatype="http://www.w3.org/2001/XMLSchema#dateTime") do; var_type="N"; var_informat="E8601DT."; end;
    when (var_datatype="http://www.w3.org/2001/XMLSchema#date"    ) do; var_type="N"; var_informat="E8601DA."; end;
    when (var_datatype="http://www.w3.org/2001/XMLSchema#time"    ) do; var_type="N"; var_informat="E8601TM."; end;
    when (var_datatype="http://www.w3.org/2001/XMLSchema#boolean" ) do; var_type="C"; var_informat=" "; end;
    otherwise do; var_type="C"; var_informat=" "; end;
    end;

run;


%local dsid rc;
%let dsid=%sysfunc(open(work.variable3,i)); 
%if (&dsid = 0) %then %do;
     %put sparqlresult: Unexpected problem;
     %put %sysfunc(sysmsg());
     %end;
%else %do;
%syscall set(dsid); 

/* Re-arrange the dataset -
   this is essentially:
        PROC TRANSPOSE;
        by binding_CNT;
        var valuetext;
        id name;
        run;
*/

/* Could also generate the code as text file and subsequently include it */

/* The length statement below is to re-size the character variables. This
   gives a warning - it can be programmed in other ways. */    
data &resultdsn;

%let i=1;        
%let rc=%sysfunc(fetchobs(&dsid,&i));
%do %while(&rc=0);
keep &name.;
/* keep %unquote(%trim(&name.))_lang; */
%if %qupcase(&var_type)=%qupcase(N) %then %do;
format &name. &var_informat.;
%end;
%if %qupcase(&var_type)=%qupcase(C) %then %do;
length &name. %unquote($%trim(&max_length.));
%end;
%let i=%eval(&i+1);        
%let rc=%sysfunc(fetchobs(&dsid,&i));
%end;


    merge

%let i=1;        
%let rc=%sysfunc(fetchobs(&dsid,&i));
%do %while(&rc=0);
sq(where=(name_&variable_ORDINAL.="%trim(&name)")
   rename=(
name=name_&variable_ORDINAL.
%if %qupcase(&var_type)=%qupcase(N) %then %do;
valuetext=%unquote(%trim(&name.)_c)
%end;
%else %do;
valuetext=&name.
%end;
/* valuetextlang=%unquote(%trim(&name.))_lang */
        )
)
%let i=%eval(&i+1);        
%let rc=%sysfunc(fetchobs(&dsid,&i));
%end;            
;
by binding_CNT;

%let i=1;        
%let rc=%sysfunc(fetchobs(&dsid,&i));
%do %while(&rc=0);
%if %qupcase(&var_type)=%qupcase(N) %then %do;
&name.=input(%unquote(%trim(&name.)_c),&var_informat.);
drop %unquote(%trim(&name.)_c);
%end;
%let i=%eval(&i+1);        
%let rc=%sysfunc(fetchobs(&dsid,&i));
%end;

%if &dsid > 0 %then 
   %let rc=%sysfunc(close(&dsid));
%end;
        run;        
* *******************************************************************;        
* Warning ... Multiple lengths were specified for the variable ...;
* can be ignored. ;
* *******************************************************************;         

libname sqresult clear;

%IF %qupcase(&debug)=%qupcase(N) %then %do;
title2 "&resultdsn.";    
proc print data=&resultdsn. width=min;
        run;
title2;
%end;
%MEND;

%getxml();

proc print data=tab1x01 width=min;
    var ittfl col1z1 col1z2 col2z1 col2z2 col3z1 col3z2;
run;
