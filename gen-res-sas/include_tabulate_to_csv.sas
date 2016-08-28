

%MACRO SetGlMacroVar(mv,default);
    %if not %symexist(this_glmvlist) %then %do;
        %global this_glmvlist;
        %let this_glmvlist=;
        %end;
    %if %sysfunc(indexw(%qupcase(&this_glmvlist),%qupcase(&mv)))=0 %then %do;
        %if %symexist(&mv) %then %do;
            /* no change */
            %*put SetGlMacroVar: &mv does not exists in this_glmvlist, but is defined as macro variable;
            %end;
        %else %do;
            %global &mv.;
            %let &mv=&default.;
            %let this_glmvlist=&this_glmvlist. &mv.;
            %end;
        %end;
    %put SetGlMacroVar: &mv.=&&&mv.;
%MEND;

%SetGlMacroVar(tabulateOutputDs,work.demo_tabulate);
%SetGlMacroVar(orderfmt,  );

proc contents data=&tabulateOutputDs. varnum;
run;


proc print data=&tabulateOutputDs.;
    format _all_;
run;

data tablesdef; /* well, only one table for now */
    length tablename $200;
    tablename=symget("tabulateOutputDs");
    output;
run;

/*

   Create macrovariables with the variable names.
   The macrovariables are specific for the table.
    
   Instead of having the macro variable, the processing later could be
   also done in the datastep using varname, getvarc, getvarn. Decided against this,
   as this is more complex code. The benefit would be that it could process more than
   one tbale.
   
    */
    
data _null_;
    set tablesdef;
    tableid=open(tablename,'i');
    if tableid=0 then do;
        length sysmsgtxt $200;
        sysmsgtxt=sysmsg();
        putlog "Could not open " tablename= ;
        putlog "Message: " sysmsgtxt=;
        abort cancel;
        end;
    length classvarlist classvarlistc classvarlistn classvarlistcCONV classvarlistnCONV resultvarlist renamevarlist $32000;
    classvarlist=" ";
    classvarlistc=" ";
    classvarlistn=" ";
    array cltype(0:1) classvarlistn classvarlistc;
    array cltypeCONV(0:1) classvarlistnCONV classvarlistcCONV;
    resultvarlist=" ";
    classvarfromposm1= varnum(tableid, "_Run_");
    classvartoposp1= varnum(tableid, "_type_");
    do i=classvarfromposm1+1 to classvartoposp1-1;
        classvarlist=catx(" ", classvarlist, varname(tableid,i));
        cltype(vartype(tableid,i)="C")=catx(" ", cltype(vartype(tableid,i)="C"), varname(tableid,i));
        cltypeCONV(vartype(tableid,i)="C")=catx(" ", cltypeCONV(vartype(tableid,i)="C"), cats(varname(tableid,i),"CONV"));
        renamevarlist= catx(" ", renamevarlist,cats(varname(tableid,i),"CONV","=",lowcase(varname(tableid,i))));
        end;
    resultfromposm1= varnum(tableid, "_TABLE_");
    resulttopos= attrn(tableid,'nvars');
    do i=resultfromposm1+1 to resulttopos /* -1 */;
        resultvarlist=catx(" ", resultvarlist, varname(tableid,i));
        end;
    rc=close(tableid);
    array vput(*) classvarlist classvarlistc classvarlistn classvarlistcCONV classvarlistnCONV resultvarlist renamevarlist;
    do i=1 to dim(vput);
        call symputx( vname(vput(i)), vput(i));
        putlog vput(i)=;
        end;
call symputx( "nclassvarlistc", countw(classvarlistc));
call symputx( "nclassvarlistn", countw(classvarlistn));

run;

%put classvarlist=&classvarlist.;
%put classvarlistc=&classvarlistc.;
%put classvarlistn=&classvarlistn.;
%put resultvarlist=&resultvarlist.;

data variablesdef; /* Naming inspired from define-xml */
    attrib DataType length=$32;
    attrib Label length=$32;
    attrib SASFieldName length=$32;
    attrib SASFormatName length=$32;
    attrib CodeListOID length=$32;
    attrib OriginDescription length=$32;
    
    call missing( DataType, Label, SASFieldName , SASFormatName,
        CodeListOID , OriginDescription );

delete;

run;

data codesdef;
    attrib name length=$32;
    attrib namelabel length=$200;
    attrib datatype length=$32;
    attrib codedvalue length=$32;
    attrib ordernumber length=$32;
    attrib decode  length=$200;
    call missing( name, nameorder, namelabel, datatype, codedvalue, codedvaluen, ordernumber, decode);
    delete;
run;

    
data observations;
    if 0 then do;
        set variablesdef;
        set codesdef;
        end;
    
    if _n_=1 then do;
        declare hash cval(dataset: "codesdef");
        rc= cval.definekey( "name", "codedvalue", "codedvaluen" );
        rc= cval.definedata(ALL:'YES' );
        rc= cval.definedone( );
        end;
    
    array results(*) &resultvarlist.;
    
    
    set &tabulateOutputDs. end=AllDone;
    /* add variable to dimension hash */
    /* add variable and code level to hash */
    
    keep &classvarlist.;
    keep _type_;
    denominatorpattern=_type_; /* inherit length from _type_ */
    denominatorpattern=" ";
    keep denominatorpattern;
    length procedure factor denominator $64;
    keep procedure factor denominator;
    length &classvarlistcCONV. &classvarlistnCONV. dummynCONV $200.; /* should have individual lengths */
    keep &classvarlistcCONV. &classvarlistnCONV. procedureCONV factorCONV denominatorCONV &classvarlistnCONV.;
    array cCONV(*)  &classvarlistcCONV. procedureCONV factorCONV denominatorCONV &classvarlistnCONV. dummynCONV;
    do i=1 to dim(cCONV);
        cCONV(i)=" ";
        end;
    
    /* Instead of arrays - should use getvarn and thereby travers variables */
    array resdimc(*) &classvarlistc. procedure factor denominator;
    array resdimcCONV(*) &classvarlistcCONV. procedureCONV factorCONV denominatorCONV;
    dummyn=.;
    drop dummyn;
    array resdimn(*) &classvarlistn. dummyn;
    array resdimnCONV(*) &classvarlistnCONV. dummynCONV;

    label procedure="Method for descriptive statistic";
    label factor="Names of variable for descriptive statistics";
    label denominator="Denominator for statistics";

    length mn $32;

    keep measure;
    do i=1 to dim(results);
        mn= vname(results(i));
        procedure=" ";
        factor=" ";
        denominator=" ";
        select;
        when (mn="N") do;
            procedure="count"; /* COUNT to be compliant with R package ? */
            factor="quantify"; /* could take the same as for PCTN */
            denominator=" ";
            measure=results(i);
            end;
        when (upcase(scan(mn,1,"_")) in ("PCTN")) do; /* TODO: will not work for variable with _ */
        putlog "!! " mn= ;
            procedure=lowcase(scan(mn,1,"_"));
            if procedure="pctn" then do;
                procedure="percent";
                factor="proportion";
                end;
            denominatorpattern=scan(mn,-1,"_");
            denominator=" ";
            if length(denominatorpattern) ne length(_type_) then do;
                putlog denominatorpattern= _type_= " does not have same length";
                abort cancel;
                end;
            do k=1 to length(denominatorpattern);
                if substr(denominatorpattern,k,1)="0" and substr(_type_,k,1)="1" then do;
                    /* TODO: does not handle more than one denomination */
                    /* Could do that by concatenating names to denominator */
                    denominator=lowcase(scan(symget("classvarlist"),k," "));
                    end;
                end;
            measure=results(i);
            end;
        when (upcase(scan(mn,-1,"_")) in ("N")) do;
            factor= lowcase(substr(mn, 1, length(mn)-length(procedure)-1));
            procedure="n";
            denominator=" ";
            denominatorpattern=" ";
            measure=results(i);
            end;
        otherwise do;
            procedure=lowcase(scan(mn,-1,"_"));
            factor= lowcase(substr(mn, 1, length(mn)-length(procedure)-1));
            denominatorpattern=" ";
            denominator=" ";
            measure=results(i);
            end;
        end;

    procedureCONV=procedure;
    factorCONV=factor;
    denominatorCONV=denominator;
    
    putlog mn= procedure= factor= denominator= _type_= denominatorpattern= measure=; 

 /* TODO: missing(measure) not ideal -
     standard deviation is undefined for n=2, and would like to have it in the results */

 /* one approach could be to use vname(results(i)) to determine what to do and also have a flag for std being included */
     
        if not missing(measure) then do;
            
            do j=1 to dim(resdimc); /* do not need to do it again for &classvarlistc. variables */
                name=lowcase(vname(resdimc(j)));
                namelabel=vlabel(resdimc(j));
                datatype= "character"; /* character in the SAS sense */
                codedvaluen= .;
                nameorder= j+0 /* dim(resdimn) */;
                if missing(resdimc(j)) then do;
                    codedvalue="_ALL_";
                    decode= "All";
                    ordernumber= " ";
                    end;
                else do;
                    codedvalue= resdimc(j);
                    decode= vvalue(resdimc(j));
                    if missing("&orderfmt.") then do;
                        ordernumber= " ";
                        end;
                    else do;
                        if missing(putc(name,"&orderfmt.")) or missing(codedvalue) then do;
                            ordernumber= " ";
                            end;
                        else do;  
                            ordernumber= putc(strip(codedvalue),putc(name,"&orderfmt."));
                            end;
                        end;
                    end;
                rc=cval.ref();
                putlog j= resdimc(j)= codedvalue= @ ;
                resdimcCONV(j)= codedvalue; /* Not ideal - should write to new variable in array resdimcc,
                    and then rename resdimcc to resdimc names and drop resdimc names for export */
                putlog "--> " resdimcCONV(j)= ;
                end;
            
            do j=1 to dim(resdimn)-1;
                name=lowcase(vname(resdimn(j)));
                putlog resdimn(j)= "$$";
                datatype= "numeric";  /* using numeric in the SAS sense */
                nameorder= j;
                if missing(resdimn(j)) then do;
                    codedvalue="_ALL_";
                    decode= "All";
                    ordernumber= " ";
                    end;
                else do;
                    codedvalue= " ";
                    codedvaluen= resdimn(j);
                    decode= vvalue(resdimn(j));
                    if missing("&orderfmt.") then do;
                        ordernumber= " ";
                        end;
                    else do;
                        if missing(putc(name,"&orderfmt.")) or missing(codedvaluen) then do;
                            ordernumber= " ";
                            end;
                        else do;
                            ordernumber= putn(codedvaluen,putc(name,"&orderfmt.")); 
                            end;
                        end;
                    rc=cval.ref();
                    resdimnCONV(j)= codedvaluen; /* Not ideal */
                    putlog "--> " resdimnCONV(j)= ;
                    end;
                end;

            output;

    end;

        end;
        
    if alldone then do;
        cval.output(dataset: "codes");
        end;
run;

/*
proc print data=observations;
run;

proc print data=codes;
run;
*/

data forexport1;
    set observations;    
/*
    keep colno rowno cellpartno;
    format colno rowno cellpartno z5.0;
    * assign values based on layout;
    colno=0; rowno=0; cellpartno=0;
    */
    length unit $1;
    unit=" ";
/*    factor=lowcase(factor);
    procedure=lowcase(procedure);
    denominator=lowcase(denominator); */

    drop _TYPE_ denominatorpattern;
    drop &classvarlistc. procedure factor denominator &classvarlistn.;

    rename &renamevarlist. procedureCONV=procedure factorCONV=factor denominatorCONV=denominator;

    /* Instead of renaming - have a seperate step doing the recoding from the original values */
run;    

data forexport;
    retain &classvarlist.;
    set forexport1;
run;

proc print data=forexport width=min;
run;

proc contents data=forexport varnum;
run;

proc export data=forexport file=expcsvda replace dbms=csv;
run;

data skeletonSource1;
    if 0 then do;
        set observations; /* To get the labels  TODO: check if there are name clashes - or implement differently */
        end;
        
    length compType compName codeType nciDomainValue compLabel Comment $512;
    keep compType compName codeType nciDomainValue compLabel Comment;
    Comment= " ";

    length classvarlist $32000;
    retain classvarlist "&classvarlist.";
    drop classvarlist nclassvarlist;
    if _n_=1 then do;
        nclassvarlist=countw(classvarlist," ");
        end;

    do i=1 to nclassvarlist;
        compType= "dimension";
        compName=lowcase(scan(classvarlist,i," "));
        compLabel=vlabelx(compName);
        codeType="DATA";
        nciDomainValue= " ";
        output;
        end;

    compType= "dimension";
    compName="procedure";
    compLabel="Statistical Procedure";
    codeType="DATA";
    nciDomainValue= " ";
    output;

    compType= "dimension";
    compName="factor";
    compLabel="Type of procedure (quantity, proportion...)";
    codeType="DATA";
    nciDomainValue= " ";
    output;

    compType= "attribute";
    compName="unit";
    compLabel="Unit of measure";
    codeType=" ";
    nciDomainValue=" ";
    output;

    compType= "attribute";
    compName="denominator";
    compLabel="Denominator for a proportion (oskr) subset on which a statistic is based";
    codeType=" ";
    nciDomainValue=" ";
    output;

    compType= "measure";
    compName="measure";
    compLabel="Value of the statistical measure";
    codeType=" ";
    nciDomainValue=" ";
    output;

    stop;
        
run;


data skeletonSource2;

length compType compName codeType nciDomainValue compLabel Comment $512;
    
compType= "metadata";
compName= "obsURL";
codeType= " ";
nciDomainValue= " ";
compLabel= "&dssource.";
Comment= "obsFileName";
output; 

compType= "metadata";
compName= "obsFileName";
codeType= " ";
nciDomainValue= " ";
compLabel= "%lowcase(&tablename.).csv";
Comment= "obsFileName";
output; 

compType= "metadata";
compName= "dataCubeFileName";
codeType= " ";
nciDomainValue= " ";
compLabel= "DC-%upcase(&tablename.)";
Comment= "Cube name prefix (will be appended with version number by script. --> No. Will be set in code based on domainName parameter)";
output; 

compType= "metadata";
compName= "cubeVersion";
codeType= " ";
nciDomainValue= " ";
compLabel= "0.0.0";
Comment= "Version of cube with format n.n.n";
output; 

compType= "metadata";
compName= "createdBy";
codeType= " ";
nciDomainValue= " ";
compLabel= "Foo";
Comment= "Person who configures this spreadsheet and runs the creation script to create the cube";
output; 

compType= "metadata";
compName= "description";
codeType= " ";
nciDomainValue= " ";
compLabel= "Data from &tableprogram. program";
Comment= "Cube description";
output; 

compType= "metadata";
compName= "providedBy";
codeType= " ";
nciDomainValue= " ";
compLabel= "PhUSE Results Metadata Working Group";
Comment= " ";
output; 

compType= "metadata";
compName= "comment";
codeType= " ";
nciDomainValue= " ";
compLabel= "";
Comment= "&tablelabel.";
output; 

compType= "metadata";
compName= "title";
codeType= " ";
nciDomainValue= " ";
compLabel= "&tableheader.";
Comment= "&tablelabel.";
output; 

compType= "metadata";
compName= "label";
codeType= " ";
nciDomainValue= " ";
compLabel= "&tablelabel.";
Comment= " ";
output; 

compType= "metadata";
compName= "wasDerivedFrom";
codeType= " ";
nciDomainValue= " ";
compLabel= "%lowcase(&tablename.).csv";
Comment= "Data source (obsFileName). Set this programmtically based on name of input file!";
output; 

compType= "metadata";
compName= "domainName";
codeType= " ";
nciDomainValue= " ";
compLabel= "%upcase(&tablename.)";
Comment= "The domain name, also part of the spreadsheet tab name";
output; 

compType= "metadata";
compName= "obsFileNameDirec";
codeType= " ";
nciDomainValue= " ";
compLabel= "!example";
Comment= "The directory containd the wasDerivedFrom file";
output; 

compType= "metadata";
compName= "dataCubeOutDirec";
codeType= " ";
nciDomainValue= " ";
compLabel= "!temporary";
Comment= " ";
output; 

/* This enables the experimental extension providing reference to the underlying data */
compType= "metadata";
compName= "extension.rrdfqbcrnd0";
codeType= " ";
nciDomainValue= " ";
compLabel= "TRUE";
Comment= " ";
output; 
    
run;

data skeletonSource;
    set skeletonSource1 skeletonSource2;
run;

proc export data=skeletonSource file=expcsvco replace dbms=csv;
run;



%put expcsvda: %sysfunc(pathname(expcsvda));
%put expcsvco: %sysfunc(pathname(expcsvco));
