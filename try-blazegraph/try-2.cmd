REM adressing issue
REM java.io.IOException: The process cannot access the file because another process has locked a portion of the file.
REM see https://sourceforge.net/p/bigdata/discussion/676946/thread/74643593/

java -server -Xmx4g -jar blazegraph.jar readBlobsAsync.properties
