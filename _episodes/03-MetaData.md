---
title: Working with experimental metadata
teaching: 10
exercises: 5
source: Rmd
objectives:
- Be able to use metadata from GEO objects to construct useful R data objects
- Be able to use read.celfiles in combination with your own pData object to ensure data integrity
questions:
- "If an experiment were more complicated, and included several independent variables, would you be able to create a phenoData object from the GSE?"
keypoints: 
- GEO metadata can be cast into R data objects for analysis. The details are up to the user.
- Using proper phenoData to describe an experiment helps to ensure reproducibility and avoid reading in files out of order
---



We have successfully read CEL files into an R object, but we
haven't provided any information about the experimental design, which would
normally be provided in a phenoData object.  In the case of our two
experiments, the experimental designs are pretty simple. Let's see if
we can find the information we need from the metadata.

## What you should have

If you have been following this tutorial, you should have the following objects:

- An _ExpressionSet_ object for GSE33146 (the processed data). Let's assume this is called `gse33146`.
- An _ExpressionSet_ object for GSE66417  (the processed data). Let's assume this is called `gse66417`.
- An _ExpressionFeatureSet_ object for GSE33146 (the raw data). Let's assume this is called `gse33146_celdata`. 
- A _GeneFeatureSet_ object for GSE66417 (the raw data). Let's assume this is called `gse66417_celdata`. 
 
> ## Why do the raw data for the two experiments appear to be different classes? 
>
> The GSE33146 raw data is of class ExpressionFeatureSet, but the
> GSE66417 data is of class GeneFeatureSet. Raw Affymetrix data is all
> some form of "FeatureSet" data, but different array designs are
> _extensions_ of the abstract FeatureSet class. The first series is
> from a 3′-biased array design, and the second is from a gene-based
> design. The classes represent those different design types.
{: .callout}

## GSE33146

In the simple case, we already have an ExpressionSet object, and we can use the pData from it. 


~~~
library(tidyverse)
varLabels(gse33146)
~~~
{: .language-r}



~~~
 [1] "title"                   "geo_accession"          
 [3] "status"                  "submission_date"        
 [5] "last_update_date"        "type"                   
 [7] "channel_count"           "source_name_ch1"        
 [9] "organism_ch1"            "characteristics_ch1"    
[11] "characteristics_ch1.1"   "treatment_protocol_ch1" 
[13] "growth_protocol_ch1"     "molecule_ch1"           
[15] "extract_protocol_ch1"    "label_ch1"              
[17] "label_protocol_ch1"      "taxid_ch1"              
[19] "hyb_protocol"            "scan_protocol"          
[21] "description"             "description.1"          
[23] "data_processing"         "platform_id"            
[25] "contact_name"            "contact_laboratory"     
[27] "contact_department"      "contact_institute"      
[29] "contact_address"         "contact_city"           
[31] "contact_state"           "contact_zip/postal_code"
[33] "contact_country"         "supplementary_file"     
[35] "data_row_count"          "cell line:ch1"          
[37] "culture medium:ch1"     
~~~
{: .output}



~~~
# It looks like the variables of interest are "cell line:ch1" and "treatment:ch1", and the sample accessions are in "geo_accession"
gse33146$supplementary_file
~~~
{: .language-r}



~~~
[1] "ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM820nnn/GSM820817/suppl/GSM820817.CEL.gz"
[2] "ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM820nnn/GSM820818/suppl/GSM820818.CEL.gz"
[3] "ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM820nnn/GSM820819/suppl/GSM820819.CEL.gz"
[4] "ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM820nnn/GSM820820/suppl/GSM820820.CEL.gz"
[5] "ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM820nnn/GSM820821/suppl/GSM820821.CEL.gz"
[6] "ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM820nnn/GSM820822/suppl/GSM820822.CEL.gz"
~~~
{: .output}



~~~
pd <- pData(gse33146)
pd['cel_file'] <- str_split(pd$supplementary_file,"/") %>% map_chr(tail,1)
~~~
{: .language-r}

With this simple trick, we now can re-read out CEL files, and _guarantee_ that they are in the correct order as the experimental data we have from getGEO.


~~~
gse33146_celdata <- read.celfiles(paste0('GSE33146/',pd$cel_file),phenoData=phenoData(gse33146))
~~~
{: .language-r}



~~~
Reading in : GSE33146/GSM820817.CEL.gz
Reading in : GSE33146/GSM820818.CEL.gz
Reading in : GSE33146/GSM820819.CEL.gz
Reading in : GSE33146/GSM820820.CEL.gz
Reading in : GSE33146/GSM820821.CEL.gz
Reading in : GSE33146/GSM820822.CEL.gz
~~~
{: .output}



~~~
Warning in read.celfiles(paste0("GSE33146/", pd$cel_file), phenoData =
phenoData(gse33146)): 'channel' automatically added to varMetadata in phenoData.
~~~
{: .error}
We get a warning because some extra information about detection channels is added, but no matter: we have already gotten the treatment conditions attached to our data!


~~~
pData(gse33146_celdata)[,c("geo_accession","cell line:ch1","culture medium:ch1")]
~~~
{: .language-r}



~~~
          geo_accession                              cell line:ch1
GSM820817     GSM820817 Human breast cancer-derived cell line DKAT
GSM820818     GSM820818 Human breast cancer-derived cell line DKAT
GSM820819     GSM820819 Human breast cancer-derived cell line DKAT
GSM820820     GSM820820 Human breast cancer-derived cell line DKAT
GSM820821     GSM820821 Human breast cancer-derived cell line DKAT
GSM820822     GSM820822 Human breast cancer-derived cell line DKAT
          culture medium:ch1
GSM820817               MEGM
GSM820818               MEGM
GSM820819               MEGM
GSM820820               SCGM
GSM820821               SCGM
GSM820822               SCGM
~~~
{: .output}

## GSE66417

We can do the same thing with our second data set, but we can see that the experimental  layout is more complicated


~~~
library(tidyverse)
varLabels(gse66417)
~~~
{: .language-r}



~~~
 [1] "title"                   "geo_accession"          
 [3] "status"                  "submission_date"        
 [5] "last_update_date"        "type"                   
 [7] "channel_count"           "source_name_ch1"        
 [9] "organism_ch1"            "characteristics_ch1"    
[11] "characteristics_ch1.1"   "treatment_protocol_ch1" 
[13] "growth_protocol_ch1"     "molecule_ch1"           
[15] "extract_protocol_ch1"    "label_ch1"              
[17] "label_protocol_ch1"      "taxid_ch1"              
[19] "hyb_protocol"            "scan_protocol"          
[21] "description"             "data_processing"        
[23] "platform_id"             "contact_name"           
[25] "contact_email"           "contact_institute"      
[27] "contact_address"         "contact_city"           
[29] "contact_state"           "contact_zip/postal_code"
[31] "contact_country"         "supplementary_file"     
[33] "data_row_count"          "cell type:ch1"          
[35] "treatment:ch1"          
~~~
{: .output}



~~~
# It looks like the variables of interest are "cell type:ch1" and "treatment:ch1", and the sample accessions are in "geo_accession"
pd <- pData(gse66417)
pd['cel_file'] <- str_split(pd$supplementary_file,"/") %>% map_chr(tail,1)
~~~
{: .language-r}

We can repeat our simple trick to guarantee our cel files and our metadata are aligned.


~~~
gse66417_celdata <- read.celfiles(paste0('GSE66417/',pd$cel_file),phenoData=phenoData(gse66417))
~~~
{: .language-r}



~~~
Reading in : GSE66417/GSM1622170_Jurkat-Ctrl-RD1_HuGene-2_0-st_.CEL.gz
Reading in : GSE66417/GSM1622189_Jurkat-Ctrl-RD2_HuGene-2_0-st_.CEL.gz
Reading in : GSE66417/GSM1622191_Jurkat-Ctrl-RD3_HuGene-2_0-st_.CEL.gz
Reading in : GSE66417/GSM1622194_Jurkat-Ixazomib-RD4_HuGene-2_0-st_.CEL.gz
Reading in : GSE66417/GSM1622196_Jurkat-Ixazomib-RD5_HuGene-2_0-st_.CEL.gz
Reading in : GSE66417/GSM1622198_Jurkat-Ixazomib-RD6_HuGene-2_0-st_.CEL.gz
Reading in : GSE66417/GSM1622200_L540-Ctrl-RD7_HuGene-2_0-st_.CEL.gz
Reading in : GSE66417/GSM1622202_L540-Ctrl-RD8_HuGene-2_0-st_.CEL.gz
Reading in : GSE66417/GSM1622204_L540-Ctrl-RD9_HuGene-2_0-st_.CEL.gz
Reading in : GSE66417/GSM1622206_L540-Ixazomib-RD10_HuGene-2_0-st_.CEL.gz
Reading in : GSE66417/GSM1622209_L540-Ixazomib-RD11_HuGene-2_0-st_.CEL.gz
Reading in : GSE66417/GSM1622211_L540-Ixazomib-RD12_HuGene-2_0-st_.CEL.gz
~~~
{: .output}



~~~
Warning in read.celfiles(paste0("GSE66417/", pd$cel_file), phenoData =
phenoData(gse66417)): 'channel' automatically added to varMetadata in phenoData.
~~~
{: .error}


~~~
pData(gse66417_celdata)[,c("geo_accession","cell type:ch1","treatment:ch1")]
~~~
{: .language-r}



~~~
           geo_accession    cell type:ch1                 treatment:ch1
GSM1622170    GSM1622170  T-Cell Lymphoma                       Control
GSM1622189    GSM1622189  T-Cell Lymphoma                       Control
GSM1622191    GSM1622191  T-Cell Lymphoma                       Control
GSM1622194    GSM1622194  T-Cell Lymphoma 25nM of Ixazomib for 24 Hours
GSM1622196    GSM1622196  T-Cell Lymphoma 25nM of Ixazomib for 24 Hours
GSM1622198    GSM1622198  T-Cell Lymphoma 25nM of Ixazomib for 24 Hours
GSM1622200    GSM1622200 Hodgkin Lymphoma                       Control
GSM1622202    GSM1622202 Hodgkin Lymphoma                       Control
GSM1622204    GSM1622204 Hodgkin Lymphoma                       Control
GSM1622206    GSM1622206 Hodgkin Lymphoma 25nM of Ixazomib for 24 Hours
GSM1622209    GSM1622209 Hodgkin Lymphoma 25nM of Ixazomib for 24 Hours
GSM1622211    GSM1622211 Hodgkin Lymphoma 25nM of Ixazomib for 24 Hours
~~~
{: .output}
In this experiment, two coviariates are modified: cell type and treatment!



{% include site-links.md %} 
{% include links.md %} 
