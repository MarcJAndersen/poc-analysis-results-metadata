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

REM Program
set prgsasbuild=tab1x03.sas
REM Outputs
set targetfilecsv1=..\res-csv\TAB1X03.csv
set targetfilecsv2=..\res-csv\TAB1X03-Components.csv


REM Program
set Rmdbuildttl=tab1x03-ttl.Rmd
REM outputs
set targetfilettl=..\res-ttl\CDISC-pilot-TAB1X03.ttl

REM Program
set prgsasgenhtml=get-tab1x03-with-proc-groovy.sas
REM Outputs
set targetfilehtml=..\show-res-sas\tab1x03.html
set DirApplicationHTML=..\application-html

:build-gen-res
pushd ..\gen-res-sas
if exist %targetfilecsv1% del %targetfilecsv1%
if exist %targetfilecsv2% del %targetfilecsv2%
echo %sascmd% %prgsasbuild%
%sascmd% %prgsasbuild%
if %ERRORLEVEL% gtr 1 goto :stop
popd

:build-res-ttl
pushd ..\use-rrdfqbcrnd0
if exist %targetfilettl% del %targetfilettl%
%Rcmd% -e "library(knitr); knit('%Rmdbuildttl%')" 
popd

:build-show-res
pushd ..\show-res-sas
if exist %targetfilehtml% del %targetfilehtml%
if not exist %prgsasgenhtml% goto :prgsasgenhtmlfilenotfound
echo %sascmd% %prgsasgenhtml%
%sascmd% %prgsasgenhtml%
if %ERRORLEVEL% gtr 1 goto :stop
if not exist %targetfilehtml% goto :no-show-res
REM only copy if the directory is set
if [%DirApplicationHTML%] NEQ [] copy %targetfilehtml% %DirApplicationHTML%
popd

goto :alldone

:no-show-res
echo Expected file not found - %targetfilehtml%
goto :eof

:prgsasgenhtmlfilenotfound
echo File %prgsasgenhtml% not found
echo Script can not continue
goto :eof

:stop
echo Got errorlevel %errorlevel%
popd
goto :eof

:alldone
REM dir %targetfilecsv1% %targetfilecsv2% %targetfilettl% %targetfilehtml%
for %%f in (%targetfilecsv1% %targetfilecsv2% %targetfilettl% %targetfilehtml%) do echo %~ftzaI
