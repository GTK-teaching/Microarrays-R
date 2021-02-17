---
title:  "Identifying differentially expressed genes using linear models (part 2, factorial designs)"
source: Rmd
teaching: 20
exercises: 20
questions:
  - "How do we identify genes that are differentially expressed in a statistically rigorous manner?"
objectives:
  - "Be able to use `limma` to identify differentially expressed genes."
  - "Understand the formula class of objects in R, and use it to specify the appropriate model for linear modeling." 
keypoints:
  - "The `formula` class of objects in R enables us to represent a wide range of models to identify differentially expressed genes."
---



## Experimental designs with more than one covariate

GSE66417 is an example of a _factorial_ experimental design, in which two covariates are varied in a single experiment. In this case, the cell type is (Lymphoma or CTL cells) and the treatment is varied (control or Ixozamib). This is called a 2x2 factorial design.

In order to model the expression of each gene, we can model the _group_ mean expression under each condition. We have four conditions, so the model is something like

$$
Y = \beta_1 X_1 + \beta_2 X_2 + \beta_3 X_3 + \beta_4 X_4 + \epsilon
$$

where each value $\beta$ represents a particular condition. We would like to identify genes where othe contrasts represent changes between different groups, i.e., the effect of drug treatment in each cell type. In order to do that, we need to specify contrasts explicitly.  One way to do this is to create a "dummy" variable that represents the four groups.


~~~
library(dplyr)
pd <- pData(gse66417_eset)
pd <- rename(pd,cell_type="cell type:ch1",treatment="treatment:ch1")
pd$treatment <- as.factor(pd$treatment)
levels(pd$treatment) <- c("Ixazomib","Control")
pd$group <- as.factor(paste(pd$cell_type,pd$treatment))
levels(pd$group) <- c("Hodgkins.Control","Hodgkins.Ixazomib","TCL.Control","TCL.Ixazomib")
~~~
{: .language-r}


|           |cell_type        |treatment |group             |
|:----------|:----------------|:---------|:-----------------|
|GSM1622170 |T-Cell Lymphoma  |Control   |TCL.Control       |
|GSM1622189 |T-Cell Lymphoma  |Control   |TCL.Control       |
|GSM1622191 |T-Cell Lymphoma  |Control   |TCL.Control       |
|GSM1622194 |T-Cell Lymphoma  |Ixazomib  |TCL.Ixazomib      |
|GSM1622196 |T-Cell Lymphoma  |Ixazomib  |TCL.Ixazomib      |
|GSM1622198 |T-Cell Lymphoma  |Ixazomib  |TCL.Ixazomib      |
|GSM1622200 |Hodgkin Lymphoma |Control   |Hodgkins.Control  |
|GSM1622202 |Hodgkin Lymphoma |Control   |Hodgkins.Control  |
|GSM1622204 |Hodgkin Lymphoma |Control   |Hodgkins.Control  |
|GSM1622206 |Hodgkin Lymphoma |Ixazomib  |Hodgkins.Ixazomib |
|GSM1622209 |Hodgkin Lymphoma |Ixazomib  |Hodgkins.Ixazomib |
|GSM1622211 |Hodgkin Lymphoma |Ixazomib  |Hodgkins.Ixazomib |

Now we can create a design representing the different groups


~~~
design <- model.matrix(~ 0 + pd$group)
colnames(design) <- levels(pd$group)
design
~~~
{: .language-r}



~~~
   Hodgkins.Control Hodgkins.Ixazomib TCL.Control TCL.Ixazomib
1                 0                 0           1            0
2                 0                 0           1            0
3                 0                 0           1            0
4                 0                 0           0            1
5                 0                 0           0            1
6                 0                 0           0            1
7                 1                 0           0            0
8                 1                 0           0            0
9                 1                 0           0            0
10                0                 1           0            0
11                0                 1           0            0
12                0                 1           0            0
attr(,"assign")
[1] 1 1 1 1
attr(,"contrasts")
attr(,"contrasts")$`pd$group`
[1] "contr.treatment"
~~~
{: .output}

Our contrasts can be formed by the usual `makeContrasts()` function, but we can easily specify five contrasts that might be interesting.


~~~
contrasts_matrix <- makeContrasts(drug_in_hodgkins=Hodgkins.Ixazomib - Hodgkins.Control,
              drug_in_TCL=TCL.Ixazomib - TCL.Control,
              cell_in_control=Hodgkins.Control - TCL.Control,
              cell_w_drug=Hodgkins.Ixazomib - TCL.Ixazomib,
              interaction=(Hodgkins.Control - TCL.Control) - (Hodgkins.Ixazomib - TCL.Ixazomib),
              levels=design)
~~~
{: .language-r}


~~~
kable(contrasts_matrix)
~~~
{: .language-r}



|                  | drug_in_hodgkins| drug_in_TCL| cell_in_control| cell_w_drug| interaction|
|:-----------------|----------------:|-----------:|---------------:|-----------:|-----------:|
|Hodgkins.Control  |               -1|           0|               1|           0|           1|
|Hodgkins.Ixazomib |                1|           0|               0|           1|          -1|
|TCL.Control       |                0|          -1|              -1|           0|          -1|
|TCL.Ixazomib      |                0|           1|               0|          -1|           1|

Now we can run the fit as usual


~~~
gse66417_fit <- lmFit(gse66417_eset,design)
gse66417_fit2 <- contrasts.fit(gse66417_fit,contrasts=contrasts_matrix)
gse66417_fit2 <- eBayes(gse66417_fit2)
summary(decideTests(gse66417_fit2,lfc=1))
~~~
{: .language-r}



~~~
       drug_in_hodgkins drug_in_TCL cell_in_control cell_w_drug interaction
Down                451           2            2330        2769         380
NotSig            52649       53531           49312       48453       52888
Up                  517          84            1975        2395         349
~~~
{: .output}


