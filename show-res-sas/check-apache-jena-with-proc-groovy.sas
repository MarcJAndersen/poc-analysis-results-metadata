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
    sparqlresultxml=check-CDISC-pilot-TAB1X01.xml,
    frsxlemap=SXLEMAP,
    resultdsn=tab1x01,
    debug=Y
);


proc print data=tab1x01 width=min;
    var ittfl col1z1 col1z2 col2z1 col2z2 col3z1 col3z2;
run;
