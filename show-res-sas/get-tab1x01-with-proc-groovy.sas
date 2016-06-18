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

%include "../../SAS-SPARQLwrapper/sparqlreadxml.sas";

%sparqlreadxml(
    sparqlquerysxlemap=%str(../../SAS-SPARQLwrapper/sparqlquery-sxlemap.map),
    sparqlqueryresultxml=check-CDISC-pilot-TAB1X01.xml,
    frsxlemap=SXLEMAP,
    resultdsn=tab1x01,
    debug=Y
);


proc print data=tab1x01 width=min;
    var ittfl col1z1 col1z2 col2z1 col2z2 col3z1 col3z2 col4z1 col4z2;
run;


/* The rest is from get-tab1x01.sas - could be an include file */

data tab1x01_pres;
    set tab1x01;
	/* This could be derived in the SPARQL query */
    rowlabel= catx(" ", ifc( ittfllevellabel    ="Y",ittflVarLabel, " "),    
        ifc( saffllevellabel    ="Y",safflVarLabel, " "),    
        ifc( efffllevellabel    ="Y",effflVarLabel, " "),    
        ifc( comp24fllevellabel ="Y",comp24flVarLabel, " "), 
        ifc( compfllevellabel   ="Y",compflVarLabel, " ") );
    format col1z2 col2z2 col3z2 col4z2 f5.1;
run;

ods html file="tab1x01.html" style=minimal;
* ods pdf file="tab1x01.pdf" style=minimal;
* ods tagsets.rtf file="tab1x01.rtf";

proc report data=tab1x01_pres missing nofs;
    column rowlabel
        (col1z1URI col1z1 col1z2URI col1z2)
        (col2z1URI col2z1 col2z2URI col2z2)
        (col3z1URI col3z1 col3z2URI col3z2)
        (col4z1URI col4z1 col4z2URI col4z2)
        ;
    define rowlabel / display width=40 flow;
    define col1z1 / display;
    define col2z1 / display;
    define col3z1 / display;
    
    define col1z2 / display;
    define col2z2 / display;
    define col3z2 / display;

    define col1z1URI / noprint;
    compute col1z1;
    call define(_col_,"URL",col1z1URI);
    endcomp;
    define col1z2URI / noprint;
    compute col1z2;
    call define(_col_,"URL",col1z2URI);
    endcomp;

    define col2z1URI / noprint;
    compute col2z1;
    call define(_col_,"URL",col2z1URI);
    endcomp;
    define col2z2URI / noprint;
    compute col2z2;
    call define(_col_,"URL",col2z2URI);
    endcomp;

    define col3z1URI / noprint;
    compute col3z1;
    call define(_col_,"URL",col3z1URI);
    endcomp;
    define col3z2URI / noprint;
    compute col3z2;
    call define(_col_,"URL",col3z2URI);
    endcomp;

    define col4z1URI / noprint;
    compute col4z1;
    call define(_col_,"URL",col4z1URI);
    endcomp;
    define col4z2URI / noprint;
    compute col4z2;
    call define(_col_,"URL",col4z2URI);
    endcomp;

run;

ods html close;
* ods tagsets.rtf close;
* ods pdf close;
