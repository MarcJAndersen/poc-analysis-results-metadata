options nocenter;
options linesize=200;

data sellines;
    infile "cdiscpilot.txt" length=linelen;
    length line $1024;
    input line $varying. linelen;

    retain state 0;

    retain TableNo TableTitle TableProgSource;
    length TableNo TableTitle TableProgSource $1024;
    select;
    when (state=0 and line="14. SUMMARY TABLES AND FIGURES") do;
    state=1;
    end;
    when (state=1 and line=:"Table 14-") do;
    TableNo= Line;
    TableTitle="?";
    TableProgSource="?";
    state=2;
    end;
when (state=2) do;
TableTitle=line;
State=3;
end;
when (State=3 and line=:"Source: ") do;
TableProgSource=Line;
output;
State=1;
TableNo= "?";
TableTitle="?";
TableProgSource="?";
end;
otherwise do;
end;
end;
run;

data programs;
    set sellines;
    length programname tno $32;
    tno= scan(tableno,2," ");
    programname=scan(scan(TableProgSource,2," "),-1,"\");
    length issame $1;
    issame=ifc(tno=lag(tno),"Y","N");
    useit= ifc(issame="N" and not ( programname in ( "rtf_eff1__.sas", "rtf_eff1__.sas", "rtf_eff_mmrm_.sas")), "Y", "N");

run;

/*
proc report data=programs missing nofs;
    column TableNo TableTitle TableProgSource programname; 
    define TableNo / width=10 flow;
    define TableTitle / width=100 flow;
    define TableProgSource /width=20 flow; 
run;
*/

proc report data=programs missing nofs;
    column tno TableTitle  programname;
    where useit="Y";
    define TNo / width=10 flow;
    define TableTitle / width=120 flow;
    define programname / width=20 flow;
run;

data programsttl;
    set programs;
    where useit="Y";
    keep tno tabletitle programname;
run;

data dswrite;
    lenght member $65;
    member="work.programsttl";
    length ttlfilename $1024;
    ttlfilename="cdiscpilot-programs.ttl";
    subjectprefix="ds:obs";
run;

%include "../../SAS-RDF-writer/include-write-turtle.sas";

/*

prefix ds: <http://example.org/sasdataset#> 
prefix dsv: <http://example.org/sasdataset-variable#> 
prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
prefix xsd: <http://www.w3.org/2001/XMLSchema#> 

SELECT *
where {
?s rdf:type ds:work.programsttl ;
    ?p ?o .
}

        */
