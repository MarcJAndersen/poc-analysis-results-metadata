--
title: "Create TAB1X02_1 as RDF data cube"
author: "mja@statgroup.dk"
date: "2016-09-03"
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

# Introduction
This script creates RDF data cubes from .csv files.

# Setup

All files are stored in the directory

```r
targetName<- "TAB1X02"
(targetName)
```

```
## [1] "TAB1X02"
```

```r
targetDir<- "../res-ttl"
(targetDir)
```

```
## [1] "../res-ttl"
```

```r
targetFile<- file.path(targetDir, paste("CDISC-pilot-", targetName, ".ttl", sep=""))
(targetFile)
```

```
## [1] "../res-ttl/CDISC-pilot-TAB1X02.ttl"
```

```r
targetObsrqFile<- file.path(targetDir, paste("CDISC-pilot-", targetName, "-observations", ".rq", sep=""))
(targetObsrqFile)
```

```
## [1] "../res-ttl/CDISC-pilot-TAB1X02-observations.rq"
```


# Loading libraries


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
library(knitr)
```

# Show parameters



```r
param.df<- data.frame(filepathname=apply(array(c(targetName, targetDir, targetFile, targetObsrqFile, target2DrqFile)),1,normalizePath,mustWork = FALSE) )
```

```
## Error in array(c(targetName, targetDir, targetFile, targetObsrqFile, target2DrqFile)): objekt 'target2DrqFile' blev ikke fundet
```

```r
rownames(param.df)<-c("Target file name", "Target diretory", "Target File", "Observation query file", "Row-column query file")
```

```
## Error in rownames(param.df) <- c("Target file name", "Target diretory", : objekt 'param.df' blev ikke fundet
```

```r
knitr::kable(param.df)
```

```
## Error in inherits(x, "list"): objekt 'param.df' blev ikke fundet
```

# Load CSV files


```r
ObsDataCsvFn<- file.path("../res-csv", paste( targetName, ".csv", sep=""))
cat("Observations CSV file ", normalizePath(ObsDataCsvFn), "\n")
```

```
## Observations CSV file  h:\projects-s114h\GitHub\poc-analysis-results-metadata\res-csv\TAB1X02.csv
```

```r
ObsData <- read.csv(ObsDataCsvFn,stringsAsFactors=FALSE)
MetaDataCsvFn<- file.path("../res-csv", paste( targetName, "-Components.csv", sep=""))
cat("MetaData CSV file ", normalizePath(MetaDataCsvFn), "\n")
```

```
## MetaData CSV file  h:\projects-s114h\GitHub\poc-analysis-results-metadata\res-csv\TAB1X02-Components.csv
```

```r
MetaData <- read.csv(MetaDataCsvFn,stringsAsFactors=FALSE)
```

# Create cube


```r
cube.fn<- BuildCubeFromDataFrames(MetaData, ObsData )
```

```
## !!!!!!!!!
## !!!!!!!!!
## !!!!!!!!!
## !!!!!!!!!
## !!!!!!!!!
```

```r
cat(targetName, " ", "cube stored as ", normalizePath(cube.fn), "\n")
```

```
## TAB1X02   cube stored as  C:\Users\ma\AppData\Local\Temp\Rtmp2fj0Bq\DC-TAB1X02-R-V-0-0-0.ttl
```
# Copy cube to destination directory


```r
if (file.copy( cube.fn, targetFile, overwrite=TRUE)) {
   cat("RDF data cube copied to ", normalizePath(targetFile), "\n")
 }
```

```
## RDF data cube copied to  h:\projects-s114h\GitHub\poc-analysis-results-metadata\res-ttl\CDISC-pilot-TAB1X02.ttl
```

# Get SPARQL query for observations

This is lifted from the example rrdfqbcrndex/vignettes/cube-from-workbook.Rmd.


```r
checkCube <- new.rdf()  # Initialize
temp<- load.rdf(targetFile, format="TURTLE", appendTo= checkCube)
cat("Reading RDF Data Cube from file ", normalizePath(targetFile), "\n")
```

```
## Reading RDF Data Cube from file  h:\projects-s114h\GitHub\poc-analysis-results-metadata\res-ttl\CDISC-pilot-TAB1X02.ttl
```

```r
summarize.rdf(checkCube)
```

```
## [1] "Number of triples: 1812"
```

```r
## Get the values in the cube
dsdName<- GetDsdNameFromCube( checkCube )
domainName<- GetDomainNameFromCube( checkCube )
forsparqlprefix<- GetForSparqlPrefix( domainName )
## Get cube components
componentsRq<- GetComponentSparqlQuery( forsparqlprefix, dsdName )
components<- as.data.frame(sparql.rdf(checkCube, componentsRq), stringsAsFactors=FALSE)
components$vn<- gsub("crnd-dimension:|crnd-attribute:|crnd-measure:","",components$p)
knitr::kable(components[,c("vn", "label")])
```



|vn        |label                                            |
|:---------|:------------------------------------------------|
|comp24fl  |Completion Status:                               |
|dcreascd  |Reason for Early Termination (prior to Week 24): |
|factor    |Type of procedure (quantity, proportion...)      |
|procedure |Statistical Procedure                            |
|trt01p    |Planned Treatment for Period 01                  |

```r
## Get code lists
codelistsRq<- GetCodeListSparqlQuery( forsparqlprefix, dsdName )
codelists<- as.data.frame(sparql.rdf(checkCube, codelistsRq), stringsAsFactors=FALSE)
codelists$vn<- gsub("crnd-dimension:|crnd-attribute:|crnd-measure:","",codelists$dimension)
codelists$clc<- gsub("code:","",codelists$cl)
knitr::kable(codelists[,c("vn", "clc", "clprefLabel")])
```



|vn        |clc                         |clprefLabel          |
|:---------|:---------------------------|:--------------------|
|comp24fl  |comp24fl-N                  |N                    |
|comp24fl  |comp24fl-Y                  |Y                    |
|comp24fl  |comp24fl-_                  |_                    |
|comp24fl  |comp24fl-_ALL_              |_ALL_                |
|comp24fl  |comp24fl-_NONMISS_          |_NONMISS_            |
|dcreascd  |dcreascd-Adverse_Event      |Adverse Event        |
|dcreascd  |dcreascd-Completed          |Completed            |
|dcreascd  |dcreascd-Death              |Death                |
|dcreascd  |dcreascd-I/E_Not_Met        |I/E Not Met          |
|dcreascd  |dcreascd-Lack_of_Eefficacy  |Lack of Eefficacy    |
|dcreascd  |dcreascd-Lost_to_Follow-up  |Lost to Follow-up    |
|dcreascd  |dcreascd-Missing            |Missing              |
|dcreascd  |dcreascd-Physician_decision |Physician decision   |
|dcreascd  |dcreascd-Protocol_violation |Protocol violation   |
|dcreascd  |dcreascd-Sponsor_decision   |Sponsor decision     |
|dcreascd  |dcreascd-Withdrew_Consent   |Withdrew Consent     |
|dcreascd  |dcreascd-_ALL_              |_ALL_                |
|dcreascd  |dcreascd-_NONMISS_          |_NONMISS_            |
|factor    |factor-_ALL_                |_ALL_                |
|factor    |factor-_NONMISS_            |_NONMISS_            |
|factor    |factor-proportion           |proportion           |
|factor    |factor-quantity             |quantity             |
|procedure |procedure-count             |count                |
|procedure |procedure-percent           |percent              |
|trt01p    |trt01p-Placebo              |Placebo              |
|trt01p    |trt01p-Xanomeline_High_Dose |Xanomeline High Dose |
|trt01p    |trt01p-Xanomeline_Low_Dose  |Xanomeline Low Dose  |
|trt01p    |trt01p-_ALL_                |_ALL_                |
|trt01p    |trt01p-_NONMISS_            |_NONMISS_            |

```r
## Get dimensions
dimensionsRq <- GetDimensionsSparqlQuery( forsparqlprefix )
dimensions<- sparql.rdf(checkCube, dimensionsRq)
knitr::kable(dimensions)
```



|p                        |
|:------------------------|
|crnd-dimension:factor    |
|crnd-dimension:dcreascd  |
|crnd-dimension:comp24fl  |
|crnd-dimension:procedure |
|crnd-dimension:trt01p    |

```r
## Get attributes
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
## prefix dccs: <http://www.example.org/dc/tab1x02/dccs/>
## prefix ds: <http://www.example.org/dc/tab1x02/ds/>
## prefix crnd-dimension: <http://www.example.org/dc/dimension#>
## prefix crnd-attribute: <http://www.example.org/dc/attribute#>
## prefix crnd-measure: <http://www.example.org/dc/measure#>
## 
## select * where {
## ?s a qb:Observation  ;
##     qb:dataSet ds:dataset-TAB1X02 ;
##     crnd-dimension:factor ?factor;
##     crnd-dimension:dcreascd ?dcreascd;
##     crnd-dimension:comp24fl ?comp24fl;
##     crnd-dimension:procedure ?procedure;
##     crnd-dimension:trt01p ?trt01p;
##     crnd-attribute:denominator ?denominator;
##     crnd-attribute:unit ?unit;
##     crnd-measure:measure ?measure .      
## optional{ ?factor skos:prefLabel ?factorvalue . }
## optional{ ?dcreascd skos:prefLabel ?dcreascdvalue . }
## optional{ ?comp24fl skos:prefLabel ?comp24flvalue . }
## optional{ ?procedure skos:prefLabel ?procedurevalue . }
## optional{ ?trt01p skos:prefLabel ?trt01pvalue . }
## } 
## order by ?s
```

```r
cat(observationsRq, file=targetObsrqFile)
observations<- as.data.frame(sparql.rdf(checkCube, observationsRq ), stringsAsFactors=FALSE)
knitr::kable(observations[ 1:10 ,
   c(paste0(sub("crnd-dimension:|crnd-attribute:|crnd-measure:", "", dimensions), "value"),sub("crnd-dimension:|crnd-attribute:|crnd-measure:", "", attributes), "measure")])
```



|factorvalue |dcreascdvalue     |comp24flvalue |procedurevalue |trt01pvalue |denominator |unit |measure      |
|:-----------|:-----------------|:-------------|:--------------|:-----------|:-----------|:----|:------------|
|quantity    |Adverse Event     |N             |count          |Placebo     |            |NA   |8            |
|proportion  |Adverse Event     |N             |percent        |Placebo     |trt01p      |NA   |9.3023255814 |
|quantity    |Completed         |N             |count          |Placebo     |            |NA   |0            |
|proportion  |Completed         |N             |percent        |Placebo     |trt01p      |NA   |0            |
|quantity    |Death             |N             |count          |Placebo     |            |NA   |1            |
|proportion  |Death             |N             |percent        |Placebo     |trt01p      |NA   |1.1627906977 |
|quantity    |I/E Not Met       |N             |count          |Placebo     |            |NA   |1            |
|proportion  |I/E Not Met       |N             |percent        |Placebo     |trt01p      |NA   |1.1627906977 |
|quantity    |Lack of Eefficacy |N             |count          |Placebo     |            |NA   |3            |
|proportion  |Lack of Eefficacy |N             |percent        |Placebo     |trt01p      |NA   |3.488372093  |

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
## prefix dccs: <http://www.example.org/dc/tab1x02/dccs/>
## prefix ds: <http://www.example.org/dc/tab1x02/ds/>
## prefix crnd-dimension: <http://www.example.org/dc/dimension#>
## prefix crnd-attribute: <http://www.example.org/dc/attribute#>
## prefix crnd-measure: <http://www.example.org/dc/measure#>
##  select * where { 
##  ?s a qb:Observation  ; 
##  qb:dataSet ds:dataset-TAB1X02  ; 
##  crnd-dimension:factor ?factor;
## crnd-dimension:dcreascd ?dcreascd;
## crnd-dimension:comp24fl ?comp24fl;
## crnd-dimension:procedure ?procedure;
## crnd-dimension:trt01p ?trt01p; 
##  crnd-attribute:denominator ?denominator;
## crnd-attribute:unit ?unit; 
##  crnd-measure:measure      ?measure .      
##  optional{ ?factor skos:prefLabel ?factorvalue . }
## optional{ ?dcreascd skos:prefLabel ?dcreascdvalue . }
## optional{ ?comp24fl skos:prefLabel ?comp24flvalue . }
## optional{ ?procedure skos:prefLabel ?procedurevalue . }
## optional{ ?trt01p skos:prefLabel ?trt01pvalue . } 
##  optional{ crnd-dimension:factor rdfs:label ?factorlabel . }
## optional{ crnd-dimension:dcreascd rdfs:label ?dcreascdlabel . }
## optional{ crnd-dimension:comp24fl rdfs:label ?comp24fllabel . }
## optional{ crnd-dimension:procedure rdfs:label ?procedurelabel . }
## optional{ crnd-dimension:trt01p rdfs:label ?trt01plabel . } 
##  BIND( IRI(crnd-dimension:factor) as ?factorIRI)
## BIND( IRI(crnd-dimension:dcreascd) as ?dcreascdIRI)
## BIND( IRI(crnd-dimension:comp24fl) as ?comp24flIRI)
## BIND( IRI(crnd-dimension:procedure) as ?procedureIRI)
## BIND( IRI(crnd-dimension:trt01p) as ?trt01pIRI) 
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



|factorlabel                                 |factorvalue |factorIRI             |dcreascdlabel                                    |dcreascdvalue      |dcreascdIRI             |comp24fllabel      |comp24flvalue |comp24flIRI             |procedurelabel        |procedurevalue |procedureIRI             |trt01plabel                     |trt01pvalue          |trt01pIRI             |denominator |unit |measure      |measureIRI |
|:-------------------------------------------|:-----------|:---------------------|:------------------------------------------------|:------------------|:-----------------------|:------------------|:-------------|:-----------------------|:---------------------|:--------------|:------------------------|:-------------------------------|:--------------------|:---------------------|:-----------|:----|:------------|:----------|
|Type of procedure (quantity, proportion...) |proportion  |crnd-dimension:factor |Reason for Early Termination (prior to Week 24): |Death              |crnd-dimension:dcreascd |Completion Status: |N             |crnd-dimension:comp24fl |Statistical Procedure |percent        |crnd-dimension:procedure |Planned Treatment for Period 01 |Xanomeline High Dose |crnd-dimension:trt01p |trt01p      |NA   |0            |ds:obs034  |
|Type of procedure (quantity, proportion...) |quantity    |crnd-dimension:factor |Reason for Early Termination (prior to Week 24): |I/E Not Met        |crnd-dimension:dcreascd |Completion Status: |N             |crnd-dimension:comp24fl |Statistical Procedure |count          |crnd-dimension:procedure |Planned Treatment for Period 01 |Xanomeline Low Dose  |crnd-dimension:trt01p |            |NA   |0            |ds:obs063  |
|Type of procedure (quantity, proportion...) |quantity    |crnd-dimension:factor |Reason for Early Termination (prior to Week 24): |Lost to Follow-up  |crnd-dimension:dcreascd |Completion Status: |N             |crnd-dimension:comp24fl |Statistical Procedure |count          |crnd-dimension:procedure |Planned Treatment for Period 01 |Xanomeline High Dose |crnd-dimension:trt01p |            |NA   |0            |ds:obs039  |
|Type of procedure (quantity, proportion...) |proportion  |crnd-dimension:factor |Reason for Early Termination (prior to Week 24): |Protocol violation |crnd-dimension:dcreascd |Completion Status: |N             |crnd-dimension:comp24fl |Statistical Procedure |percent        |crnd-dimension:procedure |Planned Treatment for Period 01 |_ALL_                |crnd-dimension:trt01p |trt01p      |NA   |1.1811023622 |ds:obs102  |
|Type of procedure (quantity, proportion...) |proportion  |crnd-dimension:factor |Reason for Early Termination (prior to Week 24): |_ALL_              |crnd-dimension:dcreascd |Completion Status: |_             |crnd-dimension:comp24fl |Statistical Procedure |percent        |crnd-dimension:procedure |Planned Treatment for Period 01 |Xanomeline Low Dose  |crnd-dimension:trt01p |trt01p      |NA   |0            |ds:obs084  |
|Type of procedure (quantity, proportion...) |quantity    |crnd-dimension:factor |Reason for Early Termination (prior to Week 24): |Missing            |crnd-dimension:dcreascd |Completion Status: |N             |crnd-dimension:comp24fl |Statistical Procedure |count          |crnd-dimension:procedure |Planned Treatment for Period 01 |Placebo              |crnd-dimension:trt01p |            |NA   |0            |ds:obs013  |
|Type of procedure (quantity, proportion...) |quantity    |crnd-dimension:factor |Reason for Early Termination (prior to Week 24): |Lack of Eefficacy  |crnd-dimension:dcreascd |Completion Status: |N             |crnd-dimension:comp24fl |Statistical Procedure |count          |crnd-dimension:procedure |Planned Treatment for Period 01 |Placebo              |crnd-dimension:trt01p |            |NA   |3            |ds:obs009  |
|Type of procedure (quantity, proportion...) |quantity    |crnd-dimension:factor |Reason for Early Termination (prior to Week 24): |Protocol violation |crnd-dimension:dcreascd |Completion Status: |N             |crnd-dimension:comp24fl |Statistical Procedure |count          |crnd-dimension:procedure |Planned Treatment for Period 01 |Xanomeline Low Dose  |crnd-dimension:trt01p |            |NA   |1            |ds:obs073  |
|Type of procedure (quantity, proportion...) |proportion  |crnd-dimension:factor |Reason for Early Termination (prior to Week 24): |Lack of Eefficacy  |crnd-dimension:dcreascd |Completion Status: |N             |crnd-dimension:comp24fl |Statistical Procedure |percent        |crnd-dimension:procedure |Planned Treatment for Period 01 |Xanomeline High Dose |crnd-dimension:trt01p |trt01p      |NA   |1.1904761905 |ds:obs038  |
|Type of procedure (quantity, proportion...) |proportion  |crnd-dimension:factor |Reason for Early Termination (prior to Week 24): |_ALL_              |crnd-dimension:dcreascd |Completion Status: |_             |crnd-dimension:comp24fl |Statistical Procedure |percent        |crnd-dimension:procedure |Planned Treatment for Period 01 |_ALL_                |crnd-dimension:trt01p |trt01p      |NA   |0            |ds:obs112  |

# Session information

```r
sessionInfo()
```

```
## R version 3.2.5 (2016-04-14)
## Platform: x86_64-w64-mingw32/x64 (64-bit)
## Running under: Windows 10 x64 (build 14393)
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


