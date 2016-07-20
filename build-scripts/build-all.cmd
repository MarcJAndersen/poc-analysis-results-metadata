@SETLOCAL ENABLEDELAYEDEXPANSION
@ECHO OFF
REM Get path for the script
Set ScriptInvocation=%0
Set ScriptName=%~n0
Set ScriptFullPath=%~f0
Set ScriptPath=%~p0
cd/d %ScriptPath%

call build-tab1x01.cmd
call build-tab1x02.cmd


