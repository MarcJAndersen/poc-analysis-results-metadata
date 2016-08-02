--
title: "Create TAB1X02_1 as RDF data cube"
author: "mja@statgroup.dk"
date: "2016-08-02"
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
targetName<- "TAB1X02_1"
(targetName)
```

```
## [1] "TAB1X02_1"
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
## [1] "../res-ttl/CDISC-pilot-TAB1X02_1.ttl"
```

```r
targetObsrqFile<- file.path(targetDir, paste("CDISC-pilot-", targetName, "-observations", ".rq", sep=""))
(targetObsrqFile)
```

```
## [1] "../res-ttl/CDISC-pilot-TAB1X02_1-observations.rq"
```



