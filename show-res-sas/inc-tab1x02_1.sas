proc print data=tab1x02_1 width=min;
    var
 comp24flVarLabel    comp24flLevelLabel    
 etflVarLabel        etflLevelLabel        
 aedisflVarLabel       aedisflLevelLabel   
 dthdisflVarLabel       dthdisflLevelLabel 
 stsdisflVarLabel       stsdisflLevelLabel 
 ltfdisflVarLabel    ltfdisflLevelLabel    
 pdndisflVarLabel    pdndisflLevelLabel    
 lefdisflVarLabel    lefdisflLevelLabel    
 pviodisflVarLabel    pviodisflLevelLabel  
 wbsdisflVarLabel    wbsdisflLevelLabel    
        col1z1 col1z2 col2z1 col2z2 col3z1 col3z2;
run;

data tab1x02_1_pres;
    set tab1x02_1;
        /* This could be derived in the SPARQL query */

    array aVarlabel(*) comp24flVarLabel etflVarLabel aedisflVarLabel
dthdisflVarLabel stsdisflVarLabel ltfdisflVarLabel pdndisflVarLabel
lefdisflVarLabel pviodisflVarLabel wbsdisflVarLabel;

    array aLevellabel(*) comp24flLevelLabel etflLevelLabel
aedisflLevelLabel dthdisflLevelLabel stsdisflLevelLabel
ltfdisflLevelLabel pdndisflLevelLabel lefdisflLevelLabel
pviodisflLevelLabel wbsdisflLevelLabel;

    length rowlabel $200;
    rowlabel=" ";
    do i=1 to dim(aLevellabel);
        if aLevellabel(i)="Y" then do;
        rowlabel=catx("/", rowlabel, aVarlabel(i));
        end;
    end;

    format col1z2 col2z2 col3z2 f5.1;
run;

ods html file="tab1x02_1.html" style=minimal;
* ods pdf file="tab1x02_1.pdf" style=minimal;
* ods tagsets.rtf file="tab1x02_1.rtf";

proc report data=tab1x02_1_pres missing nofs split="¤";
    column
        (" "                    rowlabel)
        ("Placebo"              col1z1URI col1z1 col1z2URI col1z2)
        ("Xanomeline¤Low Dose"  col2z1URI col2z1 col2z2URI col2z2)
        ("Xanomeline¤High Dose" col3z1URI col3z1 col3z2URI col3z2)
/*        ("Total"                col4z1URI col4z1 col4z2URI col4z2) */
        ;

/* Width statement only applies for listing output.

   The use of  call define(_col_, "format" ... is included to show how to programmatically
   change the format. As all values uses the same format, it is not needed for this table.

    */

    define rowlabel / " " display width=25 flow;

/* Replace code below with macro call, for main column 1 to 4, sub column 1 to 2 */    

    define col1z1URI / noprint;
    define col1z1 / " " width=6 flow display;
    compute col1z1;
    call define(_col_,"URL",col1z1URI);
    endcomp;

    define col1z2URI / noprint;
    define col1z2 / " " width=6 flow display;
    compute col1z2;
    call define(_col_,"format", "pctfmt.");
    call define(_col_,"URL",col1z2URI);
    endcomp;

    define col2z1 / " " width=6 flow display;
    define col2z1URI / noprint;
    compute col2z1;
    call define(_col_,"URL",col2z1URI);
    endcomp;

    define col2z2URI / noprint;
    define col2z2 / " " width=6 flow display;
    compute col2z2;
    call define(_col_,"format", "pctfmt.");
    call define(_col_,"URL",col2z2URI);
    endcomp;

    define col3z1URI / noprint;
    define col3z1 / " " width=6 flow display;
    compute col3z1;
    call define(_col_,"URL",col3z1URI);
    endcomp;

    define col3z2URI / noprint;
    define col3z2 / " " width=6 flow display;
    compute col3z2;
    call define(_col_,"format", "pctfmt.");
    call define(_col_,"URL",col3z2URI);
    endcomp;

/*
    define col4z1URI / noprint;
    define col4z1 / " " width=6 flow display;
    compute col4z1;
    call define(_col_,"URL",col4z1URI);
    endcomp;

    define col4z2URI / noprint;
    define col4z2 / " " width=6 flow display;
    compute col4z2;
    call define(_col_,"format", "pctfmt.");
    call define(_col_,"URL",col4z2URI);
    endcomp;
*/
run;

ods html close;
* ods tagsets.rtf close;
* ods pdf close;
