filename qbtab 'CDISC-pilot-TAB1X01.xml';
filename map 'CDISC-pilot-TAB1X01-Generate.map';

libname qbtab xmlv2 automap=replace xmlmap=map;

proc contents data=qbtab._all_ varnum;
run;


proc print data=qbtab.measure width=min;
run;


proc print data=qbtab.description width=min;
run;



