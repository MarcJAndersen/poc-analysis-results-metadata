set sascmdstem= 
REM Locate SAS using
REM ftype SAS.Application
REM This could do it automagically:
REM for /f "delims== tokens=1,2" %f in ('ftype SAS.Application') do set sascmdstem=%g
set sascmd=%sascmdstem% -sysin 

REM Locate Rscript using
REM dir /s/b %ProgramFiles%\Rscript.exe		
set Rcmdstem="C:\Program Files\R\R-3.2.5\bin\Rscript.exe"
set Rcmd=%Rcmdstem% --verbose

REM pushd ..\gen-res-sas
REM %sascmd% tab1x01.sas
REM popd

REM pushd ..\use-rrdfqbcrnd0
REM %Rcmd% -e "library(knitr); knit('tab1x01-ttl.Rmd')" 
REM popd

pushd show-res-sas
%sascmd% get-tab1x01-with-proc-groovy.sas
popd
