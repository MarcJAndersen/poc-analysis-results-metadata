SET FUSEKI_HOME=c:\opt\apache-jena-fuseki-2.0.0
SET FUSEKI_BASE=c:\opt\apache-jena-fuseki-2.0.0

java -Xmx1200M -cp %FUSEKI_HOME%\fuseki-server.jar org.apache.jena.fuseki.cmd.FusekiCmd --config=poc-fuseki-config.ttl


