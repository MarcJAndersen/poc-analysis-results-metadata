---
title: "Create TAB1X01 as RDF data cube"
author: "mja@statgroup.dk"
date: "2016-07-20"
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
tab1x01ObsDataCsvFn<- file.path("../res-csv", "TAB1X01.csv")
tab1x01ObsData <- read.csv(tab1x01ObsDataCsvFn,stringsAsFactors=FALSE)

tab1x01MetaDataCsvFn<- file.path("../res-csv", "TAB1X01-Components.csv")
tab1x01MetaData <- read.csv(tab1x01MetaDataCsvFn,stringsAsFactors=FALSE)
```

# Create cube


```r
tab1x01.cube.fn<- BuildCubeFromDataFrames(tab1x01MetaData, tab1x01ObsData )
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
```

```r
cat("TAB1X01 cube stored as ", normalizePath(tab1x01.cube.fn), "\n")
```

```
## TAB1X01 cube stored as  C:\Users\ma\AppData\Local\Temp\RtmpW0WWex\DC-TAB1X01-R-V-0-0-0.ttl
```
# Copy cube to destination directory


```r
targetFile<- file.path(targetDir,"CDISC-pilot-TAB1X01.ttl")

if (file.copy( tab1x01.cube.fn, targetFile, overwrite=TRUE)) {
   cat("RDF data cube copied to ", normalizePath(targetFile), "\n")
 }
```

```
## RDF data cube copied to  h:\projects-s114h\GitHub\poc-analysis-results-metadata\res-ttl\CDISC-pilot-TAB1X01.ttl
```




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
##  [5] magrittr_1.5    evaluate_0.9    stringi_1.1.1   tools_3.2.5    
##  [9] stringr_1.0.0   memoise_1.0.0
```

