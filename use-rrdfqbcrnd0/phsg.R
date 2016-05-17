# Scan for .yml files and store the results in a triple store
# Export triple store to turtle

# This is where I have stored the git clone of phuse-scripts
# --> start change here 
dirpath<- ".."
# --> end change here 


library(yaml)
library(rrdf)

process<- function( yl, subjectURI, RDFstore) {
    print(yl);
    for (name in names(yl)) {
        cat(" ", name, "\n")
        ## shoudl checkk for vector, and then store as collection
        ## http://stackoverflow.com/questions/29001433/how-rdfbag-rdfseq-and-rdfalt-is-different-while-using-them
        ## https://www.w3.org/TR/rdf-schema/#ch_seq
        if (is.character( yl[[name]] ) ) {
      cat("in is.char\n")
      add.data.triple( RDFstore, subjectURI, paste0(phsgprefix, name), yl[[name]])
    }
    else {
      cat("in else\n")
      objectURI<- paste0(subjectURI,"/", name)
      print(objectURI)
      add.triple( RDFstore, subjectURI, paste0(phsgprefix, name), objectURI)
      process( yl[[name]], objectURI, RDFstore)
    }
  }
}

RDFstore<- new.rdf(ontology=FALSE)
phsgprefix<- "http://www.example.org/phsg/"
add.prefix(RDFstore, prefix="phsg", namespace=phsgprefix)

ymlfiles.all<- list.files(path=dirpath, pattern="^.*\\.yml$", recursive=TRUE)
ymlfiles<- grep("/packrat/",ymlfiles.all,invert=TRUE,value=TRUE)

seqno<-0
for (fnpart in ymlfiles) {
seqno<- seqno+1
# fn<- "./whitepapers/scriptathons/demographics/demo_summary_sas.yml"
fn<- file.path( dirpath, fnpart)
cat("Reading ", fn,"\n")

ym<-try(yaml.load_file(fn))
if (class(ym)!="try-error") {
subjectURI<-  paste0(phsgprefix,"fn", seqno)
cat("For ", fn," defined URI: ",subjectURI, "\n")

add.data.triple(RDFstore, subjectURI, paste0(phsgprefix,"filename"), fn)
               
process(ym, subjectURI, RDFstore)
} else {
  cat(class(ym),"\n")
}
}

getttlfn<- save.rdf(RDFstore,"ghyaml.ttl","TURTLE")

# rr<-sparql.rdf(RDFstore, "select * where {?s ?p ?o}")
# knitr::kable(rr)

# rr2<-sparql.rdf(RDFstore, paste(paste0("prefix ", "phsg:", "<", phsgprefix, ">"), "select * where {?s ?p ?o}", sep="\n"))
# knitr::kable(rr2)

