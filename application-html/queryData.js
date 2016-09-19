function queryData( data ) {
    var numberOfCrit= data.results.bindings.length+1;

    //  Where Rselectionoperator is == and not 	    
    // ?rrdfqbcrnd0Rcolumnname != 'procedure' && ?rrdfqbcrnd0Rcolumnname != 'factor'",
    //      "	   && ?Rselectionoperator = '==' 	
    //  ?record  D2RQPropertyBridge  Rselectionvalue .
    // When ?rrdfqbcrnd0Rcolumnname == 'factor'" use the R-selectionvalue for variable name,
    // change to uppercase - and match on D2RQPropertyBridge
    var rqquerylines= [ 
	"prefix qb: <http://purl.org/linked-data/cube#> ",
	"prefix rrdfqbcrnd0: <http://www.example.org/rrdfqbcrnd0/> ",
	"select * where {",
    ];

    // Pattern	
    // select ?record ?TRT01A ?SEX ?AGE 
    // where {
    
    //   ?record <http://www.example.org/datasets/vocab/ADSL_TRT01A> ?TRT01A .
    //   ?record <http://www.example.org/datasets/vocab/ADSL_SEX> ?SEX .
    //   ?record <http://www.example.org/datasets/vocab/ADSL_AGE> ?AGE .
    //   values (?TRT01A ?SEX) {
    //     ( "Placebo"  "F" )
    //   }
    // }

    // issue: code list binding to more than one D2RQPropertyBridge - as SAFFL appears in both ADAE and ADSL
    // solution: make an approach where the underlying dataset is also refered to ...
    // issue: ADSL_PROPORTION should not exist
    var rqqueryvaluesdef=["values", "(" ];
    var rqqueryvaluespart=[ "{", "(" ];
    var rqquerylinesatend= [ " "];
    for (var i = 0; i < data.results.bindings.length; i++ ){
	var rrdfqbcrnd0Rcolumnname= data.results.bindings[i]["rrdfqbcrnd0Rcolumnname"].value;
	console.log(rrdfqbcrnd0Rcolumnname );
	console.log(data.results.bindings[i]["Rselectionoperator"] );
	console.log(data.results.bindings[i]["D2RQPropertyBridgeContVar"]);
	console.log(data.results.bindings[i]["Rselectionvalue"]);
	
	if (rrdfqbcrnd0Rcolumnname != 'procedure' &
	    rrdfqbcrnd0Rcolumnname != 'factor' 
	   ) {
	    var vn="?" +rrdfqbcrnd0Rcolumnname;

	    rqquerylines.push(" ?record "+ "<"+data.results.bindings[i]["D2RQPropertyBridge"].value+">" + " " +
			      vn + " ." );

	    if (data.results.bindings[i]["Rselectionoperator"] &&
		data.results.bindings[i]["Rselectionoperator"].value == '==' ) {

		rqqueryvaluesdef.push(vn);
		
		rqqueryvaluespart.push( '"'+data.results.bindings[i]["Rselectionvalue"].value+'"');

		if (data.results.bindings[i]["D2RQPropertyBridgeContVar"]){
		    var vn="?" + data.results.bindings[i]["Rselectionvalue"].value;
		    rqquerylinesatend.push(" ?record "+ "<"+
					   data.results.bindings[i]["D2RQPropertyBridgeContVar"].value+">" + " " +
					   vn + " ." );
		}
	    }
	}
    }

    rqqueryvaluesdef.push( ")");
    rqqueryvaluespart.push(")");

    rqquerylines.push( rqquerylinesatend.join(" ") );
    rqquerylines.push( rqqueryvaluesdef.join(" ") );
    rqquerylines.push( rqqueryvaluespart.join(" ") );
    rqquerylines.push("}");
    rqquerylines.push("}");

    var rqquery2=rqquerylines.join("\n");

    var pre= document.createElement("pre");
    var txt= document.createTextNode(rqquery2);
    pre.appendChild(txt);

    var show2 = document.getElementById("ShowResult2");
    show2.appendChild(pre);


    //	var sparqlURI="http://localhost:8890/sparql?default-graph-uri=&query="+encodeURIComponent(rqquery2)+"&format=text%2Fhtml&timeout=0&debug=on";
    var sparqlURI=SparqlEndpointQueryStem+encodeURIComponent(rqquery2)+"&format="+encodeURIComponent("text/plain");

    console.log(" --> query:\n", rqquery2, "\n" );
    console.log(" --> Open:\n", sparqlURI, "\n" );
    setsrc(sparqlURI);

    /*
      var promise2= $.ajax({
      dataType: "json",
      url:  endpoint,
      data: {
      "query": rqquery2,
      "output": "json"
      }
      });

      promise2.then( function(data) {
      }
    */    
}
