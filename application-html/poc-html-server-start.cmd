SETLOCAL ENABLEDELAYEDEXPANSION

REM Get path for the script
Set ScriptInvocation=%0
Set ScriptName=%~n0
Set ScriptFullPath=%~f0
Set ScriptPath=%~p0

cd/d %ScriptPath%
c:\Python34\python.exe -m http.server
