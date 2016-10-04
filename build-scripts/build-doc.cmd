@echo off
SETLOCAL ENABLEDELAYEDEXPANSION
REM Get path for the script
Set ScriptInvocation=%0
Set ScriptName=%~n0
Set ScriptFullPath=%~f0
Set ScriptPath=%~p0
cd/d %ScriptPath%

REM Locate Rscript using
REM dir /s/b %ProgramFiles%\Rscript.exe		
set Rcmdstem="C:\Program Files\R\R-3.2.5\bin\Rscript.exe"
set Rcmd=%Rcmdstem% --verbose

: call :do-rmd ../use-rrdfqbcrnd0/ADAM-ds-as-ttl-using-d2rq.Rmd
call :do-rmd ../use-rrdfqbcrnd0/poc-application-overview.Rmd

goto :alldone


:do-rmd 
set RMDfilestem=%~n1
set RMDdir=%~p1

pushd %RMDdir%
%Rcmd% -e "library(rmarkdown); rmarkdown::render('%RMDfilestem%.Rmd')" 
popd

goto :eof

:no-show-res
echo Expected file not found - %targetfilehtml%
goto :eof

:stop
echo Got errorlevel %errorlevel%
popd
goto :eof

:alldone

