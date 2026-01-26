---
title: "From features to annotated gene lists"
teaching: 15
source: Rmd
exercises: 15
questions: 
- "Can you use both methods to extract annotation information?"
- "Why might some columns not be good key types?"
objectives:
- "Be able to use AnnotationDb methods to association annotations with platform data." 

keypoints: 
- "BioConductor has a rich annotation infrastructure, with different data type being stored in different annotation packages."
- "The `select()` function allows us to efficiently query annotation databases."
- "Using `topTable()` in conjunction with `rownames()` allows us to retrieve all the probes which are differentially expressed between our experimental conditions." 
---



## Preparation

To make sure we are doing things right, let's get the identifiers for 10 probesets.

> ## Try it: Get a limited number of probesets
>
> Let's work with a limited number of probesets (say, 10) from our differential expression analysis.
> `topTable()` gives us 10 in a data.frame, so we can easily create a character vector of the top 10
> probesets using methods from the last episode.
>
> > ## Solution
> >
> > 
> > ~~~
> > ps <- rownames(topTable(fitted.ebayes))
> > ~~~
> > {: .language-r}
> > 
> > 
> > 
> > ~~~
> > Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'rownames': object 'fitted.ebayes' not found
> > ~~~
> > {: .error}
> > 
> > 
> > 
> > ~~~
> > ps
> > ~~~
> > {: .language-r}
> > 
> > 
> > 
> > ~~~
> > Error: object 'ps' not found
> > ~~~
> > {: .error}
> {: .solution}
{: .challenge} 

## Annotation of genomic data in AnnotationDb

Using our linear model, we have identified differentially expressed probesets between
our two experimental condition. However, the results from `topTable()` only shows the
probeset IDs, rather than the gene names. We need to map these
IDs to gene symbols, which can then be further analyzed downstream. Fortunately, R has a
wide range of *annotation packages* that allows us to do this.

To do so, we will use the annotation package *hgu133plus2.db*, where *hgu133plus2* is the
array name. Intuitively, different arrays will have different annotation packages, but
they will all end with *.db*.

> ## Different AnnotationDB packages
>
> Besides platform-specific annotation packages, there are
> also sequence annotation packages (the *BSgenome* packages) as well as UCSC transcript
> packages (the *UCSC.knownGenes* packages) and the organism annotation packages (the *org*)
> packages. Feel free to look up the different annotation packages available on BioConductor
> under the annotations tab.
{: .callout}

Let's take a look at what's in the package:


~~~
library(hgu133plus2.db)
ls('package:hgu133plus2.db')
~~~
{: .language-r}



~~~
 [1] "hgu133plus2"              "hgu133plus2_dbconn"      
 [3] "hgu133plus2_dbfile"       "hgu133plus2_dbInfo"      
 [5] "hgu133plus2_dbschema"     "hgu133plus2.db"          
 [7] "hgu133plus2ACCNUM"        "hgu133plus2ALIAS2PROBE"  
 [9] "hgu133plus2CHR"           "hgu133plus2CHRLENGTHS"   
[11] "hgu133plus2CHRLOC"        "hgu133plus2CHRLOCEND"    
[13] "hgu133plus2ENSEMBL"       "hgu133plus2ENSEMBL2PROBE"
[15] "hgu133plus2ENTREZID"      "hgu133plus2ENZYME"       
[17] "hgu133plus2ENZYME2PROBE"  "hgu133plus2GENENAME"     
[19] "hgu133plus2GO"            "hgu133plus2GO2ALLPROBES" 
[21] "hgu133plus2GO2PROBE"      "hgu133plus2MAP"          
[23] "hgu133plus2MAPCOUNTS"     "hgu133plus2OMIM"         
[25] "hgu133plus2ORGANISM"      "hgu133plus2ORGPKG"       
[27] "hgu133plus2PATH"          "hgu133plus2PATH2PROBE"   
[29] "hgu133plus2PFAM"          "hgu133plus2PMID"         
[31] "hgu133plus2PMID2PROBE"    "hgu133plus2PROSITE"      
[33] "hgu133plus2REFSEQ"        "hgu133plus2SYMBOL"       
[35] "hgu133plus2UNIPROT"      
~~~
{: .output}

This version of `ls()` allows us to quickly list the contents of any package. What we see are a
bunch of *maps* from the hgu133plus2 probeset identifiers (which we have) to other identifiers
(which we don't). We need to provide the probe identifiers of interest and then retrieve the other
identifiers of interest.

## Method 1: reaching into the databases

Now that we have the probesets in a character vector, let's use what we have. Each of the objects in `ls('package:hgu133plus2')` is an *environment*, which is a special kind of list. The way to extract the values we want is to use the function `mget()` with the probsets as an argument. If we want the result to be a vector, we need to `unlist()` it.  Here's an example.


~~~
## get the symbols for our probesets
unlist(mget(ps,hgu133plus2SYMBOL))
~~~
{: .language-r}



~~~
Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'mget': object 'ps' not found
~~~
{: .error}

This method works on all such annotation data packages, but is a bit cumbersome. Very often we want more than one piece of information, and unlisting might be dangerous if the mapping is not one-to-one.

Let's try a better method.

## Method 2: The AnnotationDbi interface

A lot of Annotation data packages use a common interface through the AnnotationDbi package (see the [vignette][AnnotationDbi]).  There are four key functions:

`select()`
: run a query for selected columns with selected keys

`columns()` 
: identify what columns are available for a database

`keytypes()`
: some, but occasionally not all, of the columns can be used as keys for a query

`keys`()
: list the keys


Let's first look at the available columns for our chip


~~~
columns(hgu133plus2.db)
~~~
{: .language-r}



~~~
 [1] "ACCNUM"       "ALIAS"        "ENSEMBL"      "ENSEMBLPROT"  "ENSEMBLTRANS"
 [6] "ENTREZID"     "ENZYME"       "EVIDENCE"     "EVIDENCEALL"  "GENENAME"    
[11] "GENETYPE"     "GO"           "GOALL"        "IPI"          "MAP"         
[16] "OMIM"         "ONTOLOGY"     "ONTOLOGYALL"  "PATH"         "PFAM"        
[21] "PMID"         "PROBEID"      "PROSITE"      "REFSEQ"       "SYMBOL"      
[26] "UCSCKG"       "UNIPROT"     
~~~
{: .output}
We have a lot of columns to choose from. How about which can be used as keys


~~~
keytypes(hgu133plus2.db)
~~~
{: .language-r}



~~~
 [1] "ACCNUM"       "ALIAS"        "ENSEMBL"      "ENSEMBLPROT"  "ENSEMBLTRANS"
 [6] "ENTREZID"     "ENZYME"       "EVIDENCE"     "EVIDENCEALL"  "GENENAME"    
[11] "GENETYPE"     "GO"           "GOALL"        "IPI"          "MAP"         
[16] "OMIM"         "ONTOLOGY"     "ONTOLOGYALL"  "PATH"         "PFAM"        
[21] "PMID"         "PROBEID"      "PROSITE"      "REFSEQ"       "SYMBOL"      
[26] "UCSCKG"       "UNIPROT"     
~~~
{: .output}
It looks like all the columns can be used as keys. One of the key types is "PROBEID".  That looks right.


~~~
head(keys(hgu133plus2.db,keytype="PROBEID"))
~~~
{: .language-r}



~~~
[1] "1007_s_at" "1053_at"   "117_at"    "121_at"    "1255_g_at" "1294_at"  
~~~
{: .output}
If we want to extract the symbols, gene identifiers, and gene names, it's as simple as using the
`select()` function from AnnotationDbi with the probesets as our identifiers:


~~~
AnnotationDbi::select(hgu133plus2.db,ps,c("SYMBOL","ENTREZID","GENENAME"),keytype="PROBEID")
~~~
{: .language-r}



~~~
Error: object 'ps' not found
~~~
{: .error}
>## Try it!
> 
> Using the given information, use `topTable()` to retrieve all genes that are
> differentially expressed with a adjusted p-value of less than 0.05, with at fold change of at least two (log fold change at least one). 
> Restrict yourself to *upregulated* genes.
> 
> > ## Solution
> >
> > 
> > ~~~
> > ps2 <- topTable(fitted.ebayes,number=Inf,p.value = 0.05,lfc=1)
> > ~~~
> > {: .language-r}
> > 
> > 
> > 
> > ~~~
> > Error: object 'fitted.ebayes' not found
> > ~~~
> > {: .error}
> > 
> > 
> > 
> > ~~~
> > ps2_up <- rownames(ps2[ps2$logFC > 0,])
> > ~~~
> > {: .language-r}
> > 
> > 
> > 
> > ~~~
> > Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'rownames': object 'ps2' not found
> > ~~~
> > {: .error}
> > 
> > 
> > 
> > ~~~
> > df <- AnnotationDbi::select(hgu133plus2.db,ps2_up,c("SYMBOL","ENTREZID","GENENAME"),keytype="PROBEID")
> > ~~~
> > {: .language-r}
> > 
> > 
> > 
> > ~~~
> > Error: object 'ps2_up' not found
> > ~~~
> > {: .error}
> > 
> > 
> > 
> > ~~~
> > dplyr::mutate(df,GENENAME=stringr::str_trunc(GENENAME,30))
> > ~~~
> > {: .language-r}
> > 
> > 
> > 
> > ~~~
> > Error in UseMethod("mutate"): no applicable method for 'mutate' applied to an object of class "function"
> > ~~~
> > {: .error}
> {: .solution}
{: .challenge}




{% include links.md %}

[AnnotationDbi]: https://bioconductor.org/packages/release/bioc/vignettes/AnnotationDbi/inst/doc/IntroToAnnotationPackages.pdf
