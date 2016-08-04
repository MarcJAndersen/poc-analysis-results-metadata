/*------------------------------------------------------------------------*\
** Program : check-apache-jena-with-proc-groovy.sas
** Purpose : Basic test of using Apache Jena java using proc groovy
** Notes: This is first version. Java code is not ideal.
** Notes: The macro getxml should be part of ../../SAS-SPARQLwrapper/sparqlquery.sas
** Status: ok    
\*------------------------------------------------------------------------*/

options linesize=200;

options mprint nocenter;

/* !!! TODO !!!
make macro variables for the changing everything to absolute paths

in the proc groovy use forward slash - and not backward slash

*/

proc groovy  ;
%let jenalib=%str(../../apache-jena-2.13.0/lib);  
%let jenalib=%str(H:\projects-s114h\GitHub\apache-jena-2.13.0/lib);  
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
m.read("H:/projects-s114h/GitHub/rrdfqbcrnd0/rrdfqb/inst/extdata/cube-vocabulary-rdf/cube.ttl");
m.read("H:/projects-s114h/GitHub/poc-analysis-results-metadata/res-ttl/CDISC-pilot-TAB1X02.ttl") ;
        
// https://jena.apache.org/documentation/javadoc/arq/org/apache/jena/query/QueryFactory.html    
Query query = QueryFactory.read("H:/projects-s114h/GitHub/poc-analysis-results-metadata/sparql-rq/tab1x02.rq") ;
QueryExecution qexec = QueryExecutionFactory.create(query, m) ;

//  https://jena.apache.org/documentation/javadoc/arq/org/apache/jena/query/ResultSetFormatter.html
ResultSet rs = qexec.execSelect() ;
//       ResultSetFormatter.outputAsXML(System.out, rs);
FileOutputStream os = new FileOutputStream("H:/projects-s114h/GitHub/poc-analysis-results-metadata/show-res-sas/check-CDISC-pilot-TAB1X02.xml");            
ResultSetFormatter.outputAsXML(os, rs);
os.close();

System.out.println("Done");

endsubmit;
quit;

%include "../../SAS-SPARQLwrapper/sparqlreadxml.sas";

%sparqlreadxml(
    sparqlquerysxlemap=%str(../../SAS-SPARQLwrapper/sparqlquery-sxlemap.map),
    sparqlqueryresultxml=check-CDISC-pilot-TAB1X02.xml,
    frsxlemap=SXLEMAP,
    resultdsn=tab1x02,
    debug=Y
);


proc print data=tab1x02 width=min;
    var comp24flLevelLabel dcreascdLevelLabel col1z1 col1z2 col2z1 col2z2 col3z1 col3z2 col4z1 col4z2;
run;

/* The rest is from get-tab1x02.sas - put in  include file, so the code is shared */

proc format;
    picture pctfmt(round max=6) low-high='0009%)' (prefix="(");
run;

run;
data tab1x02_pres;
    set tab1x02;
    roworder=ifn(dcreascdLevelLabel="_ALL_",1,2);
    
        /* This could be derived in the SPARQL query */
    length rowgrouplabel $200;
    rowgrouplabel= ifc( roworder=1, comp24flVarLabel, ifc(roworder=2, dcreascdVarLabel, "**check program**"));
    
    length rowlabel $200;
    rowlabel= ifc( roworder=1, comp24flLevelLabel, ifc(roworder=2, dcreascdLevelLabel, "**check program**"));

    format col1z1 col2z1 col3z1 col4z1 f5.0;
    format col1z2 col2z2 col3z2 col4z2 pctfmt.;
run;

ods html file="tab1x02.html"(title= "Table 14.1.2 from ARM RDF data cube")
    style=minimal;
* ods pdf file="tab1x02.pdf" style=minimal;
* ods tagsets.rtf file="tab1x02.rtf";




title;

proc report data=tab1x02_pres missing nofs split="¤";
    column
        (" "                    roworder rowgrouplabel rowlabel)
        ("Placebo"              col1z1URI col1z1 col1z2URI col1z2)
        ("Xanomeline¤Low Dose"  col2z1URI col2z1 col2z2URI col2z2)
        ("Xanomeline¤High Dose" col3z1URI col3z1 col3z2URI col3z2)
        ("Total"                col4z1URI col4z1 col4z2URI col4z2)
        ;

/* Width statement only applies for listing output.

   The use of  call define(_col_, "format" ... is included to show how to programmatically
   change the format. As all values uses the same format, it is not needed for this table.

    */

        define roworder / " " order noprint;
        define rowgrouplabel / " " order noprint;
        compute before rowgrouplabel;
        line @1 rowgrouplabel $200.;
        endcomp;
        compute after rowgrouplabel;
        line @1 " ";
        endcomp;
        
    define rowlabel / " " display width=25 flow;

/* Replace code below with macro call, for main column 1 to 4, sub column 1 to 2 */    

    define col1z1URI / noprint;
    define col1z1 / " " width=6 flow display;
    compute col1z1;
    call define(_col_,"URL",col1z1URI);
    endcomp;

    define col1z2URI / noprint;
    define col1z2 / " " width=6 flow display;
    compute col1z2;
    call define(_col_,"format", "pctfmt.");
    call define(_col_,"URL",col1z2URI);
    endcomp;

    define col2z1 / " " width=6 flow display;
    define col2z1URI / noprint;
    compute col2z1;
    call define(_col_,"URL",col2z1URI);
    endcomp;

    define col2z2URI / noprint;
    define col2z2 / " " width=6 flow display;
    compute col2z2;
    call define(_col_,"format", "pctfmt.");
    call define(_col_,"URL",col2z2URI);
    endcomp;

    define col3z1URI / noprint;
    define col3z1 / " " width=6 flow display;
    compute col3z1;
    call define(_col_,"URL",col3z1URI);
    endcomp;

    define col3z2URI / noprint;
    define col3z2 / " " width=6 flow display;
    compute col3z2;
    call define(_col_,"format", "pctfmt.");
    call define(_col_,"URL",col3z2URI);
    endcomp;

    define col4z1URI / noprint;
    define col4z1 / " " width=6 flow display;
    compute col4z1;
    call define(_col_,"URL",col4z1URI);
    endcomp;

    define col4z2URI / noprint;
    define col4z2 / " " width=6 flow display;
    compute col4z2;
    call define(_col_,"format", "pctfmt.");
    call define(_col_,"URL",col4z2URI);
    endcomp;

run;

ods html close;
* ods tagsets.rtf close;
* ods pdf close;
