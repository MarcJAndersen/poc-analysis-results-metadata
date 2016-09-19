function ActionData(ev) {
    ev.preventDefault();
    if ( event.target.className == "droptarget" ) {
        event.target.style.border = "";
    }

    var URIobs=ev.dataTransfer.getData("Text");
    console.log("URIobs: ", URIobs);
    //    var endpoint = "http://localhost:8890/sparql";

    var endpoint='http://localhost:3030/arm'; /* http://stackoverflow.com/questions/28547288/no-access-control-allow-origin-header-is-present-on-the-requested-resource-err */
    
    // in the cube also ?D2RQPropertyBridge on the ?dimvalue - eg also on the individual codelist value
    // This would make the identification of D2RQ-PropertyBridge for factor much simpler ...
    
    // get the parts needed for building a SPARQL query for retrievning the data
    var rqquery= [
	"prefix qb: <http://purl.org/linked-data/cube#> ",
	"prefix rrdfqbcrnd0: <http://www.example.org/rrdfqbcrnd0/> ",
	"  select ?obs ?codelist ?dimvalue ?propdim ?D2RQPropertyBridgeContVar ?D2RQPropertyBridge ?rrdfqbcrnd0Rcolumnname ?Rselectionoperator ?Rselectionvalue",
	"where {",
	"       ?obs ?propdim ?dimvalue .",
	"  ?propdim a qb:DimensionProperty .",
	"  ?propdim qb:codeList ?codelist .",
	"  optional { ?dimvalue rrdfqbcrnd0:R-selectionoperator ?Rselectionoperator } . ",
	"  optional { ?dimvalue rrdfqbcrnd0:D2RQ-PropertyBridge ?D2RQPropertyBridgeContVar . }",
	"  optional { ?dimvalue rrdfqbcrnd0:R-selectionvalue  ?Rselectionvalue . } ",
	"  optional { ?codelist rrdfqbcrnd0:codeType ?rrdfqbcrnd0codeType . }",
	"  optional { ?codelist rrdfqbcrnd0:R-columnname ?rrdfqbcrnd0Rcolumnname . }",
	"  optional { ?obs qb:dataSet ?qbdataSet .",
        "              ?qbdataSet rrdfqbcrnd0:D2RQ-DataSetName ?D2RQdsname .",
        "              ?codelist  rrdfqbcrnd0:DataSetRefD2RQ ?reference .",
        "              ?reference rrdfqbcrnd0:D2RQ-DataSetName ?D2RQdsname .",
        "              ?reference rrdfqbcrnd0:D2RQ-PropertyBridge ?D2RQPropertyBridge . }",
	"  optional { ?obs qb:dataSet ?qbdataSet .",
        "              ?qbdataSet rrdfqbcrnd0:D2RQ-DataSetName ?D2RQdsname .",
        "              ?dimvalue rrdfqbcrnd0:DataSetRefD2RQ ?reference .",
        "              ?reference rrdfqbcrnd0:D2RQ-DataSetName ?D2RQdsname .",
        "              ?reference rrdfqbcrnd0:D2RQ-PropertyBridge ?D2RQPropertyBridgeContVar . }",
	"values ( ?obs ) {",
	"(<"+URIobs+">)",
	"}",
	"}",
    ].join("\n")			       
    ;
    console.log("SPARQL query\n"+rqquery );

    console.log("Before promise 1")
    
    var promise1= $.ajax({
	dataType: "json",
	url:  endpoint,
	data: {
	    "query": rqquery,
	    "output": "json"
	}
    });

    console.log("After promise 1")
    promise1.then( function(data) {
	
	var table = document.createElement('table');
	console.log( "data.head.vars.length: ", data.head.vars.length );
	console.log( "data.head.vars: ", data.head.vars );
	var tr = document.createElement('tr');   
	for (var j=0; j < data.head.vars.length; j++) {
	    var th = document.createElement('th');
	    console.log("Header cell: "+data.head.vars[j]);
	    var cell= document.createTextNode(data.head.vars[j]);
	    th.appendChild(cell);
	    tr.appendChild(th);
	}
	table.appendChild(tr);
	console.log("End header row");
	
	console.log( "data.results.bindings.length: ", data.results.bindings.length );
	for (var i = 0; i < data.results.bindings.length; i++ ){
	    var tr = document.createElement('tr');   
	    for (var j=0; j <data.head.vars.length; j++) {
		if (data.results.bindings[i][data.head.vars[j]]) {
		    console.log("data.results.bindings[i][data.head.vars[j]].value",
				data.results.bindings[i][data.head.vars[j]].value);
		}
	    }
	    for (var j=0; j < data.head.vars.length; j++) {
		
		var td = document.createElement('td');
		if (data.results.bindings[i][data.head.vars[j]]) {
		    var item=data.results.bindings[i][data.head.vars[j]];
		    if (item.type=="uri") {
			var cell= document.createElement("div");
			var att=document.createAttribute("class");
			att.value="clickuri";
			cell.setAttributeNode(att); 

			//    var att2=document.createAttribute("onclick"); 
			//    att2.value="myLookupsubject(this)";
			//    cell.setAttributeNode(att2);  

			cell.appendChild( document.createTextNode(item.value) );
		    } else if  (item.type=="typed-literal") {
			var cell= document.createTextNode(item.value);
		    }
		    else {
			var cell = document.createTextNode(item.value);
		    }
		} else {
		    var cell= document.createTextNode(" ");
		}
		td.appendChild(cell);
		tr.appendChild(td);
		console.log("End cell");
	    }
	    table.appendChild(tr);
	    console.log("End row");
	}
	console.log("End table");
        var tablearea = document.getElementById("ShowResult");
        tablearea.appendChild(table);

	queryData( data )
	// build the sparql query to get the data
	// invoke the next query
    } );

    
    // Still need to transpose the data - this will be mapping specific
    // Not clever 

    

    //    var sparqlURI="http://localhost:8890/sparql?default-graph-uri=&query="+encodeURIComponent(rqquery)+"&format=text%2Fhtml&timeout=0&debug=on";
    //    console.log(" --> Open: ", sparqlURI);
    //    setsrc(sparqlURI);

}

