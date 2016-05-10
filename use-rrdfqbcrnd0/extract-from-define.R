library(rrdf)
define.fn<- "../../any-snippet/define-xml-processing/define-as-rdf.xml"

define.xml<- load.rdf(define.fn,format="TURTLE")


prefix.rq<- '
prefix rdfs:  <http://www.w3.org/2000/01/rdf-schema#>
prefix ns:    <http://www.iro.umontreal.ca/lapalme/ns#> 
prefix owl:   <http://www.w3.org/2002/07/owl#> 
prefix xsd:   <http://www.w3.org/2001/XMLSchema#> 
prefix rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
'

sparql.rq<- '
select ?OID ?leafID ?DisplayIdentifier ?DisplayLabel 
where {
 [ ns:ResultDisplay
 [ ns:DisplayIdentifier ?DisplayIdentifier;
   ns:DisplayLabel      ?DisplayLabel ;
   ns:OID      ?OID ;
   ns:leafID   ?leafID 
 ]
 ] 
}
order by ?OID
'

# cat(paste0( prefix.rq, sparql.rq, sep="\n" ))
sq<- NULL
sq<- sparql.rdf( define.xml, paste0( prefix.rq, sparql.rq, sep="\n" ) )
print(sq)

