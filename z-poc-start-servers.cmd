@SETLOCAL ENABLEDELAYEDEXPANSION
REM Get path for the script
@Set ScriptInvocation=%0
@Set ScriptName=%~n0
@Set ScriptFullPath=%~f0
@Set ScriptPath=%~p0


start cmd "poc: Fuseki server" /d "%ScriptPath%" /c "res-ttl\poc-fuseki-server.cmd"
start cmd "poc: HTML server" /d "%ScriptPath%" /c "application-html\poc-html-server-start.cmd"
