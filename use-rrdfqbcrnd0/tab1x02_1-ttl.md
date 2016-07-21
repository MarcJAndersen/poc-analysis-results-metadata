--
title: "Create TAB1X02_1 as RDF data cube"
author: "mja@statgroup.dk"
date: "2016-07-21"
output:
  html_document:
    toc: true
    theme: united
  pdf_document:
    toc: true
    highlight: zenburn
  md_document:
    variant: markdown_github
---


# Setup

This script creates RDF data cubes from .csv files.


```r
library(rrdfancillary)
```

```
## Loading required package: rJava
```

```
## Loading required package: methods
```

```
## Loading required package: rrdf
```

```
## Loading required package: rrdflibs
```

```r
library(rrdfcdisc)
```

```
## Loading required package: RCurl
```

```
## Loading required package: bitops
```

```
## 
## Attaching package: 'RCurl'
```

```
## The following object is masked from 'package:rJava':
## 
##     clone
```

```
## Loading required package: devtools
```

```r
library(rrdfqb)
```

```
## Loading required package: xlsx
```

```
## Loading required package: xlsxjars
```

```r
library(rrdfqbcrnd0)
```

All files are stored in the directory

```r
targetDir<- "../res-ttl"
(targetDir)
```

```
## [1] "../res-ttl"
```

# Load CSV files


```r
tab1x02ObsDataCsvFn<- file.path("../res-csv", "TAB1X02_1.csv")
tab1x02ObsData <- read.csv(tab1x02ObsDataCsvFn,stringsAsFactors=FALSE)

tab1x02MetaDataCsvFn<- file.path("../res-csv", "TAB1X02_1-Components.csv")
tab1x02MetaData <- read.csv(tab1x02MetaDataCsvFn,stringsAsFactors=FALSE)
```

# Create cube


```r
tab1x02.cube.fn<- BuildCubeFromDataFrames(tab1x02MetaData, tab1x02ObsData )
```

```
## !!!!!!!!!
## !!!!!!!!!
## !!!!!!!!!
## !!!!!!!!!
## !!!!!!!!!
## !!!!!!!!!
## !!!!!!!!!
## !!!!!!!!!
## !!!!!!!!!
## !!!!!!!!!
## !!!!!!!!!
## !!!!!!!!!
## !!!!!!!!!
## !!!!!!!!!
## !!!!!!!!!
## !!!!!!!!!
```

```r
cat("TAB1X02 cube stored as ", normalizePath(tab1x02.cube.fn), "\n")
```

```
## TAB1X02 cube stored as  C:\Users\ma\AppData\Local\Temp\RtmpELWaqW\DC-TAB1X02_1-R-V-0-0-0.ttl
```
# Copy cube to destination directory


```r
targetFile<- file.path(targetDir,"CDISC-pilot-TAB1X02_1.ttl")

if (file.copy( tab1x02.cube.fn, targetFile, overwrite=TRUE)) {
   cat("RDF data cube copied to ", normalizePath(targetFile), "\n")
 }
```

```
## RDF data cube copied to  h:\projects-s114h\GitHub\poc-analysis-results-metadata\res-ttl\CDISC-pilot-TAB1X02_1.ttl
```
# Get SPARQL query for observations

This is lifted from the example rrdfqbcrndex/vignettes/cube-from-workbook.Rmd.


```r
checkCube <- new.rdf()  # Initialize
temp<- load.rdf(targetFile, format="TURTLE", appendTo= checkCube)
summarize.rdf(checkCube)
```

```
## [1] "Number of triples: 4183"
```

## Get the values in the cube
First set values for accessing the cube.

```r
dsdName<- GetDsdNameFromCube( checkCube )
domainName<- GetDomainNameFromCube( checkCube )
forsparqlprefix<- GetForSparqlPrefix( domainName )
```

## Get cube components

The cube components are shown in the next output.

```r
componentsRq<- GetComponentSparqlQuery( forsparqlprefix, dsdName )
components<- as.data.frame(sparql.rdf(checkCube, componentsRq), stringsAsFactors=FALSE)
components$vn<- gsub("crnd-dimension:|crnd-attribute:|crnd-measure:","",components$p)
knitr::kable(components[,c("vn", "label")])
```



|vn        |label                                       |
|:---------|:-------------------------------------------|
|aedisfl   |Adverse Event                               |
|comp24fl  |Completers of Week 24 Population Flag       |
|compfl    |Complete Study                              |
|dthdisfl  |Death                                       |
|etfl      |Early termination prior to week 24          |
|factor    |Type of procedure (quantity, proportion...) |
|ittfl     |Intent-To-Treat Population Flag             |
|lefdisfl  |Lack of Efficacy                            |
|ltfdisfl  |Lost to Follow-up                           |
|pdndisfl  |Physician Decided to withdraw Subject       |
|procedure |Statistical Procedure                       |
|pviodisfl |Protocol violation                          |
|saffl     |Safety Population Flag                      |
|stsdisfl  |Sponsor decision                            |
|trt01p    |Planned Treatment for Period 01             |
|wbsdisfl  |Subject decided to withdraw                 |

The codelists are shown in the next output.

```r
codelistsRq<- GetCodeListSparqlQuery( forsparqlprefix, dsdName )
codelists<- as.data.frame(sparql.rdf(checkCube, codelistsRq), stringsAsFactors=FALSE)
codelists$vn<- gsub("crnd-dimension:|crnd-attribute:|crnd-measure:","",codelists$p)
```

```
## Error in `$<-.data.frame`(`*tmp*`, "vn", value = character(0)): replacement has 0 rows, data has 51
```

```r
codelists$clc<- gsub("code:","",codelists$cl)
knitr::kable(codelists[,c("vn", "clc", "prefLabel")])
```

```
## Error in `[.data.frame`(codelists, , c("vn", "clc", "prefLabel")): undefined columns selected
```


The dimensions are shown in the next output.

```r
dimensionsRq <- GetDimensionsSparqlQuery( forsparqlprefix )
dimensions<- sparql.rdf(checkCube, dimensionsRq)
knitr::kable(dimensions)
```



|p                        |
|:------------------------|
|crnd-dimension:factor    |
|crnd-dimension:trt01p    |
|crnd-dimension:wbsdisfl  |
|crnd-dimension:pviodisfl |
|crnd-dimension:procedure |
|crnd-dimension:compfl    |
|crnd-dimension:ittfl     |
|crnd-dimension:ltfdisfl  |
|crnd-dimension:comp24fl  |
|crnd-dimension:dthdisfl  |
|crnd-dimension:pdndisfl  |
|crnd-dimension:saffl     |
|crnd-dimension:etfl      |
|crnd-dimension:lefdisfl  |
|crnd-dimension:aedisfl   |
|crnd-dimension:stsdisfl  |

Then the attributes as shown in the next output.

```r
attributesRq<- GetAttributesSparqlQuery( forsparqlprefix )
attributes<- sparql.rdf(checkCube, attributesRq)
knitr::kable(attributes)
```



|p                          |
|:--------------------------|
|crnd-attribute:denominator |
|crnd-attribute:unit        |

## Get observations
And finally the SPARQL query for observations, showing only the first 10 observations.

```r
observationsRq<- GetObservationsSparqlQuery( forsparqlprefix, domainName, dimensions, attributes )
cat(observationsRq)
```

```
## prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
## prefix skos: <http://www.w3.org/2004/02/skos/core#>
## prefix prov: <http://www.w3.org/ns/prov#>
## prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
## prefix dcat: <http://www.w3.org/ns/dcat#>
## prefix owl: <http://www.w3.org/2002/07/owl#>
## prefix xsd: <http://www.w3.org/2001/XMLSchema#>
## prefix pav: <http://purl.org/pav>
## prefix dc: <http://purl.org/dc/elements/1.1/>
## prefix dct: <http://purl.org/dc/terms/>
## prefix mms: <http://rdf.cdisc.org/mms#>
## prefix cts: <http://rdf.cdisc.org/ct/schema#>
## prefix cdiscs: <http://rdf.cdisc.org/std/schema#>
## prefix cdash-1-1: <http://rdf.cdisc.org/std/cdash-1-1#>
## prefix cdashct: <http://rdf.cdisc.org/cdash-terminology#>
## prefix sdtmct: <http://rdf.cdisc.org/sdtm-terminology#>
## prefix sdtm-1-2: <http://rdf.cdisc.org/std/sdtm-1-2#>
## prefix sdtm-1-3: <http://rdf.cdisc.org/std/sdtm-1-3#>
## prefix sdtms-1-3: <http://rdf.cdisc.org/sdtm-1-3/schema#>
## prefix sdtmig-3-1-2: <http://rdf.cdisc.org/std/sdtmig-3-1-2#>
## prefix sdtmig-3-1-3: <http://rdf.cdisc.org/std/sdtmig-3-1-3#>
## prefix sendct: <http://rdf.cdisc.org/send-terminology#>
## prefix sendig-3-0: <http://rdf.cdisc.org/std/sendig-3-0#>
## prefix adamct: <http://rdf.cdisc.org/adam-terminology#>
## prefix adam-2-1: <http://rdf.cdisc.org/std/adam-2-1#>
## prefix adamig-1-0: <http://rdf.cdisc.org/std/adamig-1-0#>
## prefix adamvr-1-2: <http://rdf.cdisc.org/std/adamvr-1-2#>
## prefix qb: <http://purl.org/linked-data/cube#>
## prefix rrdfqbcrnd0: <http://www.example.org/rrdfqbcrnd0/>
## prefix code: <http://www.example.org/dc/code/>
## prefix dccs: <http://www.example.org/dc/tab1x02_1/dccs/>
## prefix ds: <http://www.example.org/dc/tab1x02_1/ds/>
## prefix crnd-dimension: <http://www.example.org/dc/dimension#>
## prefix crnd-attribute: <http://www.example.org/dc/attribute#>
## prefix crnd-measure: <http://www.example.org/dc/measure#>
## 
## select * where {
## ?s a qb:Observation  ;
##     qb:dataSet ds:dataset-TAB1X02_1 ;
##     crnd-dimension:factor ?factor;
##     crnd-dimension:trt01p ?trt01p;
##     crnd-dimension:wbsdisfl ?wbsdisfl;
##     crnd-dimension:pviodisfl ?pviodisfl;
##     crnd-dimension:procedure ?procedure;
##     crnd-dimension:compfl ?compfl;
##     crnd-dimension:ittfl ?ittfl;
##     crnd-dimension:ltfdisfl ?ltfdisfl;
##     crnd-dimension:comp24fl ?comp24fl;
##     crnd-dimension:dthdisfl ?dthdisfl;
##     crnd-dimension:pdndisfl ?pdndisfl;
##     crnd-dimension:saffl ?saffl;
##     crnd-dimension:etfl ?etfl;
##     crnd-dimension:lefdisfl ?lefdisfl;
##     crnd-dimension:aedisfl ?aedisfl;
##     crnd-dimension:stsdisfl ?stsdisfl;
##     crnd-attribute:denominator ?denominator;
##     crnd-attribute:unit ?unit;
##     crnd-measure:measure ?measure .      
## optional{ ?factor skos:prefLabel ?factorvalue . }
## optional{ ?trt01p skos:prefLabel ?trt01pvalue . }
## optional{ ?wbsdisfl skos:prefLabel ?wbsdisflvalue . }
## optional{ ?pviodisfl skos:prefLabel ?pviodisflvalue . }
## optional{ ?procedure skos:prefLabel ?procedurevalue . }
## optional{ ?compfl skos:prefLabel ?compflvalue . }
## optional{ ?ittfl skos:prefLabel ?ittflvalue . }
## optional{ ?ltfdisfl skos:prefLabel ?ltfdisflvalue . }
## optional{ ?comp24fl skos:prefLabel ?comp24flvalue . }
## optional{ ?dthdisfl skos:prefLabel ?dthdisflvalue . }
## optional{ ?pdndisfl skos:prefLabel ?pdndisflvalue . }
## optional{ ?saffl skos:prefLabel ?safflvalue . }
## optional{ ?etfl skos:prefLabel ?etflvalue . }
## optional{ ?lefdisfl skos:prefLabel ?lefdisflvalue . }
## optional{ ?aedisfl skos:prefLabel ?aedisflvalue . }
## optional{ ?stsdisfl skos:prefLabel ?stsdisflvalue . }
## } 
## order by ?s
```

```r
observations<- as.data.frame(sparql.rdf(checkCube, observationsRq ), stringsAsFactors=FALSE)
knitr::kable(observations[ 1:10 ,
   c(paste0(sub("crnd-dimension:|crnd-attribute:|crnd-measure:", "", dimensions), "value"),sub("crnd-dimension:|crnd-attribute:|crnd-measure:", "", attributes), "measure")])
```



|factorvalue |trt01pvalue |wbsdisflvalue |pviodisflvalue |procedurevalue |compflvalue |ittflvalue |ltfdisflvalue |comp24flvalue |dthdisflvalue |pdndisflvalue |safflvalue |etflvalue |lefdisflvalue |aedisflvalue |stsdisflvalue |denominator |unit |measure      |
|:-----------|:-----------|:-------------|:--------------|:--------------|:-----------|:----------|:-------------|:-------------|:-------------|:-------------|:----------|:---------|:-------------|:------------|:-------------|:-----------|:----|:------------|
|quantity    |NA          |_ALL_         |_ALL_          |count          |_ALL_       |_ALL_      |_ALL_         |_ALL_         |_ALL_         |_ALL_         |_ALL_      |Y         |_ALL_         |_ALL_        |_ALL_         |            |NA   |136          |
|proportion  |NA          |_ALL_         |_ALL_          |percent        |_ALL_       |_ALL_      |_ALL_         |_ALL_         |_ALL_         |_ALL_         |_ALL_      |Y         |_ALL_         |_ALL_        |_ALL_         |etfl        |NA   |53.543307087 |
|quantity    |NA          |_ALL_         |_ALL_          |count          |_ALL_       |Y          |_ALL_         |_ALL_         |_ALL_         |_ALL_         |_ALL_      |_ALL_     |_ALL_         |_ALL_        |_ALL_         |            |NA   |254          |
|proportion  |NA          |_ALL_         |_ALL_          |percent        |_ALL_       |Y          |_ALL_         |_ALL_         |_ALL_         |_ALL_         |_ALL_      |_ALL_     |_ALL_         |_ALL_        |_ALL_         |ittfl       |NA   |100          |
|quantity    |NA          |_ALL_         |_ALL_          |count          |_ALL_       |_ALL_      |_ALL_         |_ALL_         |_ALL_         |_ALL_         |Y          |_ALL_     |_ALL_         |_ALL_        |_ALL_         |            |NA   |254          |
|proportion  |NA          |_ALL_         |_ALL_          |percent        |_ALL_       |_ALL_      |_ALL_         |_ALL_         |_ALL_         |_ALL_         |Y          |_ALL_     |_ALL_         |_ALL_        |_ALL_         |saffl       |NA   |100          |
|quantity    |NA          |_ALL_         |_ALL_          |count          |_ALL_       |_ALL_      |_ALL_         |N             |_ALL_         |_ALL_         |_ALL_      |_ALL_     |_ALL_         |_ALL_        |_ALL_         |            |NA   |136          |
|proportion  |NA          |_ALL_         |_ALL_          |percent        |_ALL_       |_ALL_      |_ALL_         |N             |_ALL_         |_ALL_         |_ALL_      |_ALL_     |_ALL_         |_ALL_        |_ALL_         |comp24fl    |NA   |53.543307087 |
|quantity    |NA          |_ALL_         |_ALL_          |count          |_ALL_       |_ALL_      |_ALL_         |Y             |_ALL_         |_ALL_         |_ALL_      |_ALL_     |_ALL_         |_ALL_        |_ALL_         |            |NA   |118          |
|proportion  |NA          |_ALL_         |_ALL_          |percent        |_ALL_       |_ALL_      |_ALL_         |Y             |_ALL_         |_ALL_         |_ALL_      |_ALL_     |_ALL_         |_ALL_        |_ALL_         |comp24fl    |NA   |46.456692913 |

## Get observations with labels

The SPARQL query for observations with labels for variables, showing only the first 10 observations.

```r
observationsDescriptionRq<- GetObservationsWithDescriptionSparqlQuery( forsparqlprefix, domainName, dimensions, attributes )
cat(observationsDescriptionRq)
```

```
## prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
## prefix skos: <http://www.w3.org/2004/02/skos/core#>
## prefix prov: <http://www.w3.org/ns/prov#>
## prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
## prefix dcat: <http://www.w3.org/ns/dcat#>
## prefix owl: <http://www.w3.org/2002/07/owl#>
## prefix xsd: <http://www.w3.org/2001/XMLSchema#>
## prefix pav: <http://purl.org/pav>
## prefix dc: <http://purl.org/dc/elements/1.1/>
## prefix dct: <http://purl.org/dc/terms/>
## prefix mms: <http://rdf.cdisc.org/mms#>
## prefix cts: <http://rdf.cdisc.org/ct/schema#>
## prefix cdiscs: <http://rdf.cdisc.org/std/schema#>
## prefix cdash-1-1: <http://rdf.cdisc.org/std/cdash-1-1#>
## prefix cdashct: <http://rdf.cdisc.org/cdash-terminology#>
## prefix sdtmct: <http://rdf.cdisc.org/sdtm-terminology#>
## prefix sdtm-1-2: <http://rdf.cdisc.org/std/sdtm-1-2#>
## prefix sdtm-1-3: <http://rdf.cdisc.org/std/sdtm-1-3#>
## prefix sdtms-1-3: <http://rdf.cdisc.org/sdtm-1-3/schema#>
## prefix sdtmig-3-1-2: <http://rdf.cdisc.org/std/sdtmig-3-1-2#>
## prefix sdtmig-3-1-3: <http://rdf.cdisc.org/std/sdtmig-3-1-3#>
## prefix sendct: <http://rdf.cdisc.org/send-terminology#>
## prefix sendig-3-0: <http://rdf.cdisc.org/std/sendig-3-0#>
## prefix adamct: <http://rdf.cdisc.org/adam-terminology#>
## prefix adam-2-1: <http://rdf.cdisc.org/std/adam-2-1#>
## prefix adamig-1-0: <http://rdf.cdisc.org/std/adamig-1-0#>
## prefix adamvr-1-2: <http://rdf.cdisc.org/std/adamvr-1-2#>
## prefix qb: <http://purl.org/linked-data/cube#>
## prefix rrdfqbcrnd0: <http://www.example.org/rrdfqbcrnd0/>
## prefix code: <http://www.example.org/dc/code/>
## prefix dccs: <http://www.example.org/dc/tab1x02_1/dccs/>
## prefix ds: <http://www.example.org/dc/tab1x02_1/ds/>
## prefix crnd-dimension: <http://www.example.org/dc/dimension#>
## prefix crnd-attribute: <http://www.example.org/dc/attribute#>
## prefix crnd-measure: <http://www.example.org/dc/measure#>
##  select * where { 
##  ?s a qb:Observation  ; 
##  qb:dataSet ds:dataset-TAB1X02_1  ; 
##  crnd-dimension:factor ?factor;
## crnd-dimension:trt01p ?trt01p;
## crnd-dimension:wbsdisfl ?wbsdisfl;
## crnd-dimension:pviodisfl ?pviodisfl;
## crnd-dimension:procedure ?procedure;
## crnd-dimension:compfl ?compfl;
## crnd-dimension:ittfl ?ittfl;
## crnd-dimension:ltfdisfl ?ltfdisfl;
## crnd-dimension:comp24fl ?comp24fl;
## crnd-dimension:dthdisfl ?dthdisfl;
## crnd-dimension:pdndisfl ?pdndisfl;
## crnd-dimension:saffl ?saffl;
## crnd-dimension:etfl ?etfl;
## crnd-dimension:lefdisfl ?lefdisfl;
## crnd-dimension:aedisfl ?aedisfl;
## crnd-dimension:stsdisfl ?stsdisfl; 
##  crnd-attribute:denominator ?denominator;
## crnd-attribute:unit ?unit; 
##  crnd-measure:measure      ?measure .      
##  optional{ ?factor skos:prefLabel ?factorvalue . }
## optional{ ?trt01p skos:prefLabel ?trt01pvalue . }
## optional{ ?wbsdisfl skos:prefLabel ?wbsdisflvalue . }
## optional{ ?pviodisfl skos:prefLabel ?pviodisflvalue . }
## optional{ ?procedure skos:prefLabel ?procedurevalue . }
## optional{ ?compfl skos:prefLabel ?compflvalue . }
## optional{ ?ittfl skos:prefLabel ?ittflvalue . }
## optional{ ?ltfdisfl skos:prefLabel ?ltfdisflvalue . }
## optional{ ?comp24fl skos:prefLabel ?comp24flvalue . }
## optional{ ?dthdisfl skos:prefLabel ?dthdisflvalue . }
## optional{ ?pdndisfl skos:prefLabel ?pdndisflvalue . }
## optional{ ?saffl skos:prefLabel ?safflvalue . }
## optional{ ?etfl skos:prefLabel ?etflvalue . }
## optional{ ?lefdisfl skos:prefLabel ?lefdisflvalue . }
## optional{ ?aedisfl skos:prefLabel ?aedisflvalue . }
## optional{ ?stsdisfl skos:prefLabel ?stsdisflvalue . } 
##  optional{ crnd-dimension:factor rdfs:label ?factorlabel . }
## optional{ crnd-dimension:trt01p rdfs:label ?trt01plabel . }
## optional{ crnd-dimension:wbsdisfl rdfs:label ?wbsdisfllabel . }
## optional{ crnd-dimension:pviodisfl rdfs:label ?pviodisfllabel . }
## optional{ crnd-dimension:procedure rdfs:label ?procedurelabel . }
## optional{ crnd-dimension:compfl rdfs:label ?compfllabel . }
## optional{ crnd-dimension:ittfl rdfs:label ?ittfllabel . }
## optional{ crnd-dimension:ltfdisfl rdfs:label ?ltfdisfllabel . }
## optional{ crnd-dimension:comp24fl rdfs:label ?comp24fllabel . }
## optional{ crnd-dimension:dthdisfl rdfs:label ?dthdisfllabel . }
## optional{ crnd-dimension:pdndisfl rdfs:label ?pdndisfllabel . }
## optional{ crnd-dimension:saffl rdfs:label ?saffllabel . }
## optional{ crnd-dimension:etfl rdfs:label ?etfllabel . }
## optional{ crnd-dimension:lefdisfl rdfs:label ?lefdisfllabel . }
## optional{ crnd-dimension:aedisfl rdfs:label ?aedisfllabel . }
## optional{ crnd-dimension:stsdisfl rdfs:label ?stsdisfllabel . } 
##  BIND( IRI(crnd-dimension:factor) as ?factorIRI)
## BIND( IRI(crnd-dimension:trt01p) as ?trt01pIRI)
## BIND( IRI(crnd-dimension:wbsdisfl) as ?wbsdisflIRI)
## BIND( IRI(crnd-dimension:pviodisfl) as ?pviodisflIRI)
## BIND( IRI(crnd-dimension:procedure) as ?procedureIRI)
## BIND( IRI(crnd-dimension:compfl) as ?compflIRI)
## BIND( IRI(crnd-dimension:ittfl) as ?ittflIRI)
## BIND( IRI(crnd-dimension:ltfdisfl) as ?ltfdisflIRI)
## BIND( IRI(crnd-dimension:comp24fl) as ?comp24flIRI)
## BIND( IRI(crnd-dimension:dthdisfl) as ?dthdisflIRI)
## BIND( IRI(crnd-dimension:pdndisfl) as ?pdndisflIRI)
## BIND( IRI(crnd-dimension:saffl) as ?safflIRI)
## BIND( IRI(crnd-dimension:etfl) as ?etflIRI)
## BIND( IRI(crnd-dimension:lefdisfl) as ?lefdisflIRI)
## BIND( IRI(crnd-dimension:aedisfl) as ?aedisflIRI)
## BIND( IRI(crnd-dimension:stsdisfl) as ?stsdisflIRI) 
##  BIND( IRI( ?s ) AS ?measureIRI) 
##  }
```

```r
observationsDesc<- as.data.frame(sparql.rdf(checkCube, observationsDescriptionRq ), stringsAsFactors=FALSE)
knitr::kable(observationsDesc[ 1:10 ,
     c(paste0(rep(sub("crnd-dimension:|crnd-attribute:|crnd-measure:", "", dimensions),each=3),
       c("label", "value", "IRI")),
       sub("crnd-dimension:|crnd-attribute:|crnd-measure:", "", attributes), "measure", "measureIRI"
       )]
       )
```



|factorlabel                                 |factorvalue |factorIRI             |trt01plabel                     |trt01pvalue          |trt01pIRI             |wbsdisfllabel               |wbsdisflvalue |wbsdisflIRI             |pviodisfllabel     |pviodisflvalue |pviodisflIRI             |procedurelabel        |procedurevalue |procedureIRI             |compfllabel    |compflvalue |compflIRI             |ittfllabel                      |ittflvalue |ittflIRI             |ltfdisfllabel     |ltfdisflvalue |ltfdisflIRI             |comp24fllabel                         |comp24flvalue |comp24flIRI             |dthdisfllabel |dthdisflvalue |dthdisflIRI             |pdndisfllabel                         |pdndisflvalue |pdndisflIRI             |saffllabel             |safflvalue |safflIRI             |etfllabel                          |etflvalue |etflIRI             |lefdisfllabel    |lefdisflvalue |lefdisflIRI             |aedisfllabel  |aedisflvalue |aedisflIRI             |stsdisfllabel    |stsdisflvalue |stsdisflIRI             |denominator |unit |measure      |measureIRI |
|:-------------------------------------------|:-----------|:---------------------|:-------------------------------|:--------------------|:---------------------|:---------------------------|:-------------|:-----------------------|:------------------|:--------------|:------------------------|:---------------------|:--------------|:------------------------|:--------------|:-----------|:---------------------|:-------------------------------|:----------|:--------------------|:-----------------|:-------------|:-----------------------|:-------------------------------------|:-------------|:-----------------------|:-------------|:-------------|:-----------------------|:-------------------------------------|:-------------|:-----------------------|:----------------------|:----------|:--------------------|:----------------------------------|:---------|:-------------------|:----------------|:-------------|:-----------------------|:-------------|:------------|:----------------------|:----------------|:-------------|:-----------------------|:-----------|:----|:------------|:----------|
|Type of procedure (quantity, proportion...) |quantity    |crnd-dimension:factor |Planned Treatment for Period 01 |NA                   |crnd-dimension:trt01p |Subject decided to withdraw |_ALL_         |crnd-dimension:wbsdisfl |Protocol violation |_ALL_          |crnd-dimension:pviodisfl |Statistical Procedure |count          |crnd-dimension:procedure |Complete Study |_ALL_       |crnd-dimension:compfl |Intent-To-Treat Population Flag |_ALL_      |crnd-dimension:ittfl |Lost to Follow-up |_ALL_         |crnd-dimension:ltfdisfl |Completers of Week 24 Population Flag |_ALL_         |crnd-dimension:comp24fl |Death         |_ALL_         |crnd-dimension:dthdisfl |Physician Decided to withdraw Subject |_ALL_         |crnd-dimension:pdndisfl |Safety Population Flag |Y          |crnd-dimension:saffl |Early termination prior to week 24 |_ALL_     |crnd-dimension:etfl |Lack of Efficacy |_ALL_         |crnd-dimension:lefdisfl |Adverse Event |_ALL_        |crnd-dimension:aedisfl |Sponsor decision |_ALL_         |crnd-dimension:stsdisfl |            |NA   |254          |ds:obs005  |
|Type of procedure (quantity, proportion...) |proportion  |crnd-dimension:factor |Planned Treatment for Period 01 |NA                   |crnd-dimension:trt01p |Subject decided to withdraw |_ALL_         |crnd-dimension:wbsdisfl |Protocol violation |_ALL_          |crnd-dimension:pviodisfl |Statistical Procedure |percent        |crnd-dimension:procedure |Complete Study |_ALL_       |crnd-dimension:compfl |Intent-To-Treat Population Flag |_ALL_      |crnd-dimension:ittfl |Lost to Follow-up |_ALL_         |crnd-dimension:ltfdisfl |Completers of Week 24 Population Flag |_ALL_         |crnd-dimension:comp24fl |Death         |_ALL_         |crnd-dimension:dthdisfl |Physician Decided to withdraw Subject |_ALL_         |crnd-dimension:pdndisfl |Safety Population Flag |_ALL_      |crnd-dimension:saffl |Early termination prior to week 24 |_ALL_     |crnd-dimension:etfl |Lack of Efficacy |_ALL_         |crnd-dimension:lefdisfl |Adverse Event |_ALL_        |crnd-dimension:aedisfl |Sponsor decision |_ALL_         |crnd-dimension:stsdisfl |dthdisfl    |NA   |98.818897638 |ds:obs030  |
|Type of procedure (quantity, proportion...) |proportion  |crnd-dimension:factor |Planned Treatment for Period 01 |NA                   |crnd-dimension:trt01p |Subject decided to withdraw |_ALL_         |crnd-dimension:wbsdisfl |Protocol violation |_ALL_          |crnd-dimension:pviodisfl |Statistical Procedure |percent        |crnd-dimension:procedure |Complete Study |_ALL_       |crnd-dimension:compfl |Intent-To-Treat Population Flag |_ALL_      |crnd-dimension:ittfl |Lost to Follow-up |_ALL_         |crnd-dimension:ltfdisfl |Completers of Week 24 Population Flag |_ALL_         |crnd-dimension:comp24fl |Death         |_ALL_         |crnd-dimension:dthdisfl |Physician Decided to withdraw Subject |_ALL_         |crnd-dimension:pdndisfl |Safety Population Flag |_ALL_      |crnd-dimension:saffl |Early termination prior to week 24 |_ALL_     |crnd-dimension:etfl |Lack of Efficacy |_ALL_         |crnd-dimension:lefdisfl |Adverse Event |_ALL_        |crnd-dimension:aedisfl |Sponsor decision |_ALL_         |crnd-dimension:stsdisfl |pdndisfl    |NA   |98.818897638 |ds:obs034  |
|Type of procedure (quantity, proportion...) |proportion  |crnd-dimension:factor |Planned Treatment for Period 01 |Xanomeline Low Dose  |crnd-dimension:trt01p |Subject decided to withdraw |_ALL_         |crnd-dimension:wbsdisfl |Protocol violation |_ALL_          |crnd-dimension:pviodisfl |Statistical Procedure |percent        |crnd-dimension:procedure |Complete Study |_ALL_       |crnd-dimension:compfl |Intent-To-Treat Population Flag |_ALL_      |crnd-dimension:ittfl |Lost to Follow-up |_ALL_         |crnd-dimension:ltfdisfl |Completers of Week 24 Population Flag |N             |crnd-dimension:comp24fl |Death         |_ALL_         |crnd-dimension:dthdisfl |Physician Decided to withdraw Subject |_ALL_         |crnd-dimension:pdndisfl |Safety Population Flag |_ALL_      |crnd-dimension:saffl |Early termination prior to week 24 |_ALL_     |crnd-dimension:etfl |Lack of Efficacy |_ALL_         |crnd-dimension:lefdisfl |Adverse Event |_ALL_        |crnd-dimension:aedisfl |Sponsor decision |_ALL_         |crnd-dimension:stsdisfl |comp24fl    |NA   |66.666666667 |ds:obs115  |
|Type of procedure (quantity, proportion...) |proportion  |crnd-dimension:factor |Planned Treatment for Period 01 |Xanomeline Low Dose  |crnd-dimension:trt01p |Subject decided to withdraw |_ALL_         |crnd-dimension:wbsdisfl |Protocol violation |_ALL_          |crnd-dimension:pviodisfl |Statistical Procedure |percent        |crnd-dimension:procedure |Complete Study |_ALL_       |crnd-dimension:compfl |Intent-To-Treat Population Flag |_ALL_      |crnd-dimension:ittfl |Lost to Follow-up |_ALL_         |crnd-dimension:ltfdisfl |Completers of Week 24 Population Flag |_ALL_         |crnd-dimension:comp24fl |Death         |_ALL_         |crnd-dimension:dthdisfl |Physician Decided to withdraw Subject |_ALL_         |crnd-dimension:pdndisfl |Safety Population Flag |_ALL_      |crnd-dimension:saffl |Early termination prior to week 24 |_ALL_     |crnd-dimension:etfl |Lack of Efficacy |_ALL_         |crnd-dimension:lefdisfl |Adverse Event |_ALL_        |crnd-dimension:aedisfl |Sponsor decision |_ALL_         |crnd-dimension:stsdisfl |wbsdisfl    |NA   |88.095238095 |ds:obs140  |
|Type of procedure (quantity, proportion...) |proportion  |crnd-dimension:factor |Planned Treatment for Period 01 |Placebo              |crnd-dimension:trt01p |Subject decided to withdraw |_ALL_         |crnd-dimension:wbsdisfl |Protocol violation |_ALL_          |crnd-dimension:pviodisfl |Statistical Procedure |percent        |crnd-dimension:procedure |Complete Study |_ALL_       |crnd-dimension:compfl |Intent-To-Treat Population Flag |_ALL_      |crnd-dimension:ittfl |Lost to Follow-up |_ALL_         |crnd-dimension:ltfdisfl |Completers of Week 24 Population Flag |_ALL_         |crnd-dimension:comp24fl |Death         |Y             |crnd-dimension:dthdisfl |Physician Decided to withdraw Subject |_ALL_         |crnd-dimension:pdndisfl |Safety Population Flag |_ALL_      |crnd-dimension:saffl |Early termination prior to week 24 |_ALL_     |crnd-dimension:etfl |Lack of Efficacy |_ALL_         |crnd-dimension:lefdisfl |Adverse Event |_ALL_        |crnd-dimension:aedisfl |Sponsor decision |_ALL_         |crnd-dimension:stsdisfl |dthdisfl    |NA   |2.3255813953 |ds:obs051  |
|Type of procedure (quantity, proportion...) |quantity    |crnd-dimension:factor |Planned Treatment for Period 01 |Xanomeline High Dose |crnd-dimension:trt01p |Subject decided to withdraw |_ALL_         |crnd-dimension:wbsdisfl |Protocol violation |_ALL_          |crnd-dimension:pviodisfl |Statistical Procedure |count          |crnd-dimension:procedure |Complete Study |_ALL_       |crnd-dimension:compfl |Intent-To-Treat Population Flag |_ALL_      |crnd-dimension:ittfl |Lost to Follow-up |_ALL_         |crnd-dimension:ltfdisfl |Completers of Week 24 Population Flag |_ALL_         |crnd-dimension:comp24fl |Death         |_ALL_         |crnd-dimension:dthdisfl |Physician Decided to withdraw Subject |_ALL_         |crnd-dimension:pdndisfl |Safety Population Flag |_ALL_      |crnd-dimension:saffl |Early termination prior to week 24 |_ALL_     |crnd-dimension:etfl |Lack of Efficacy |Y             |crnd-dimension:lefdisfl |Adverse Event |_ALL_        |crnd-dimension:aedisfl |Sponsor decision |_ALL_         |crnd-dimension:stsdisfl |            |NA   |1            |ds:obs087  |
|Type of procedure (quantity, proportion...) |proportion  |crnd-dimension:factor |Planned Treatment for Period 01 |Placebo              |crnd-dimension:trt01p |Subject decided to withdraw |_ALL_         |crnd-dimension:wbsdisfl |Protocol violation |_ALL_          |crnd-dimension:pviodisfl |Statistical Procedure |percent        |crnd-dimension:procedure |Complete Study |_ALL_       |crnd-dimension:compfl |Intent-To-Treat Population Flag |_ALL_      |crnd-dimension:ittfl |Lost to Follow-up |Y             |crnd-dimension:ltfdisfl |Completers of Week 24 Population Flag |_ALL_         |crnd-dimension:comp24fl |Death         |_ALL_         |crnd-dimension:dthdisfl |Physician Decided to withdraw Subject |_ALL_         |crnd-dimension:pdndisfl |Safety Population Flag |_ALL_      |crnd-dimension:saffl |Early termination prior to week 24 |_ALL_     |crnd-dimension:etfl |Lack of Efficacy |_ALL_         |crnd-dimension:lefdisfl |Adverse Event |_ALL_        |crnd-dimension:aedisfl |Sponsor decision |_ALL_         |crnd-dimension:stsdisfl |ltfdisfl    |NA   |1.1627906977 |ds:obs055  |
|Type of procedure (quantity, proportion...) |quantity    |crnd-dimension:factor |Planned Treatment for Period 01 |Placebo              |crnd-dimension:trt01p |Subject decided to withdraw |_ALL_         |crnd-dimension:wbsdisfl |Protocol violation |_ALL_          |crnd-dimension:pviodisfl |Statistical Procedure |count          |crnd-dimension:procedure |Complete Study |_ALL_       |crnd-dimension:compfl |Intent-To-Treat Population Flag |Y          |crnd-dimension:ittfl |Lost to Follow-up |_ALL_         |crnd-dimension:ltfdisfl |Completers of Week 24 Population Flag |_ALL_         |crnd-dimension:comp24fl |Death         |_ALL_         |crnd-dimension:dthdisfl |Physician Decided to withdraw Subject |_ALL_         |crnd-dimension:pdndisfl |Safety Population Flag |_ALL_      |crnd-dimension:saffl |Early termination prior to week 24 |_ALL_     |crnd-dimension:etfl |Lack of Efficacy |_ALL_         |crnd-dimension:lefdisfl |Adverse Event |_ALL_        |crnd-dimension:aedisfl |Sponsor decision |_ALL_         |crnd-dimension:stsdisfl |            |NA   |86           |ds:obs040  |
|Type of procedure (quantity, proportion...) |quantity    |crnd-dimension:factor |Planned Treatment for Period 01 |Placebo              |crnd-dimension:trt01p |Subject decided to withdraw |_ALL_         |crnd-dimension:wbsdisfl |Protocol violation |_ALL_          |crnd-dimension:pviodisfl |Statistical Procedure |count          |crnd-dimension:procedure |Complete Study |_ALL_       |crnd-dimension:compfl |Intent-To-Treat Population Flag |_ALL_      |crnd-dimension:ittfl |Lost to Follow-up |_ALL_         |crnd-dimension:ltfdisfl |Completers of Week 24 Population Flag |N             |crnd-dimension:comp24fl |Death         |_ALL_         |crnd-dimension:dthdisfl |Physician Decided to withdraw Subject |_ALL_         |crnd-dimension:pdndisfl |Safety Population Flag |_ALL_      |crnd-dimension:saffl |Early termination prior to week 24 |_ALL_     |crnd-dimension:etfl |Lack of Efficacy |_ALL_         |crnd-dimension:lefdisfl |Adverse Event |_ALL_        |crnd-dimension:aedisfl |Sponsor decision |_ALL_         |crnd-dimension:stsdisfl |            |NA   |26           |ds:obs044  |




# Session information

```r
sessionInfo()
```

```
## R version 3.2.5 (2016-04-14)
## Platform: x86_64-w64-mingw32/x64 (64-bit)
## Running under: Windows 10 x64 (build 10586)
## 
## locale:
## [1] LC_COLLATE=Danish_Denmark.1252  LC_CTYPE=Danish_Denmark.1252   
## [3] LC_MONETARY=Danish_Denmark.1252 LC_NUMERIC=C                   
## [5] LC_TIME=Danish_Denmark.1252    
## 
## attached base packages:
## [1] methods   stats     graphics  grDevices utils     datasets  base     
## 
## other attached packages:
##  [1] rrdfqbcrnd0_0.2.4   rrdfqb_0.2.4        xlsx_0.5.7         
##  [4] xlsxjars_0.6.1      rrdfcdisc_0.2.4     devtools_1.11.1    
##  [7] RCurl_1.95-4.8      bitops_1.0-6        rrdfancillary_0.2.4
## [10] rrdf_2.1.2          rrdflibs_1.4.0      rJava_0.9-8        
## [13] knitr_1.13         
## 
## loaded via a namespace (and not attached):
##  [1] packrat_0.4.7-1 digest_0.6.9    withr_1.0.1     formatR_1.4    
##  [5] magrittr_1.5    evaluate_0.9    highr_0.6       stringi_1.1.1  
##  [9] tools_3.2.5     stringr_1.0.0   memoise_1.0.0
```

