@SETLOCAL ENABLEDELAYEDEXPANSION
@ECHO OFF
REM Get path for the script
Set ScriptInvocation=%0
Set ScriptName=%~n0
Set ScriptFullPath=%~f0
Set ScriptPath=%~p0
cd/d %ScriptPath%


REM Locate SAS using
REM ftype SAS.Application
set sascmdstem="C:\Program Files\SASHome\SASFoundation\9.4\sas.exe" -config "C:\Program Files\SASHome\SASFoundation\9.4\SASV9.CFG"
REM This could do it automagically - except for the space in Program Files make it more tricky, well it can be done:
REM for /f "delims==- tokens=1,2,3" %f in ('ftype SAS.Application') do set sascmdstem="%g" -%h
REM For batch execution of programs see Example 7: Creating a Batch File That Runs Programs Consecutively
REM http://support.sas.com/documentation/cdl/en/hostwin/67962/HTML/default/viewer.htm#p16esisc4nrd5sn1ps5l6u8f79k6.htm
REM For use status code see Return Codes and Completion Status
REM http://support.sas.com/documentation/cdl/en/hostwin/67962/HTML/default/viewer.htm#n0d8f2zgsbjtqwn1f384lia2nlbm.htm
set sascmd=%sascmdstem% -nosplash -nologo -icon -sysin 

REM Locate Rscript using
REM dir /s/b %ProgramFiles%\Rscript.exe		
set Rcmdstem="C:\Program Files\R\R-3.2.5\bin\Rscript.exe"
set Rcmd=%Rcmdstem% --verbose

: goto :alldone

:build-gen-res
pushd ..\gen-res-sas
set targetfilecsv1=..\res-csv\TAB1X02.csv
if exist %targetfilecsv1% del %targetfilecsv1%
set targetfilecsv2=..\res-csv\TAB1X02-Components.csv
if exist %targetfilecsv2% del %targetfilecsv2%
echo %sascmd% tab1x02.sas
%sascmd% tab1x02.sas
if %ERRORLEVEL% gtr 1 goto :stop
popd

:build-res-ttl
pushd ..\use-rrdfqbcrnd0
set targetfilettl=..\res-ttl\CDISC-pilot-TAB1X02.ttl
if exist %targetfilettl% del %targetfilettl%
%Rcmd% -e "library(knitr); knit('tab1x02-ttl.Rmd')" 
popd

:build-show-res
pushd ..\show-res-sas
set prgsasgenhtml=get-tab1x02-with-proc-groovy.sas
set targetfilehtml=..\show-res-sas\tab1x02.html
if exist %targetfilehtml% del %targetfilehtml%
if not exist %prgsasgenhtml% goto :prgsasgenhtmlfilenotfound
echo %sascmd% %prgsasgenhtml%
%sascmd% %prgsasgenhtml%
if %ERRORLEVEL% gtr 1 goto :stop
popd

goto :alldone

:prgsasgenhtmlfilenotfound
echo File %prgsasgenhtml% not found
echo Script can not continue
goto :eof

:stop
echo Got errorlevel %errorlevel%
popd
goto :eof

:alldone
dir %targetfilecsv1% %targetfilecsv2% %targetfilettl% %targetfilehtml%
