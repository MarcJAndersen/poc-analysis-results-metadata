SETLOCAL ENABLEDELAYEDEXPANSION
REM Get path for the script
Set ScriptInvocation=%0
Set ScriptName=%~n0
Set ScriptFullPath=%~f0
Set ScriptPath=%~p0

SET FUSEKI_HOME=c:\opt\apache-jena-fuseki-2.0.0
SET FUSEKI_BASE=c:\opt\apache-jena-fuseki-2.0.0

cd/d %ScriptPath%
java -Xmx1200M -cp %FUSEKI_HOME%\fuseki-server.jar org.apache.jena.fuseki.cmd.FusekiCmd --config=poc-fuseki-config.ttl


