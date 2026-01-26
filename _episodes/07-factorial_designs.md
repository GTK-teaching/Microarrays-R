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
~~~
{: .language-r}



~~~
Error in h(simpleError(msg, call)): error in evaluating the argument 'object' in selecting a method for function 'pData': object 'gse66417_eset' not found
~~~
{: .error}



~~~
pd <- rename(pd,cell_type="cell type:ch1",treatment="treatment:ch1")
~~~
{: .language-r}



~~~
Error: object 'pd' not found
~~~
{: .error}



~~~
pd$treatment <- as.factor(pd$treatment)
~~~
{: .language-r}



~~~
Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'as.factor': object 'pd' not found
~~~
{: .error}



~~~
levels(pd$treatment) <- c("Ixazomib","Control")
~~~
{: .language-r}



~~~
Error in eval(ei, envir): object 'pd' not found
~~~
{: .error}



~~~
pd$group <- as.factor(paste(pd$cell_type,pd$treatment))
~~~
{: .language-r}



~~~
Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'as.factor': object 'pd' not found
~~~
{: .error}



~~~
levels(pd$group) <- c("Hodgkins.Control","Hodgkins.Ixazomib","TCL.Control","TCL.Ixazomib")
~~~
{: .language-r}



~~~
Error in eval(ei, envir): object 'pd' not found
~~~
{: .error}


~~~
Error: object 'pd' not found
~~~
{: .error}

Now we can create a design representing the different groups


~~~
design <- model.matrix(~ 0 + pd$group)
~~~
{: .language-r}



~~~
Error in eval(predvars, data, env): object 'pd' not found
~~~
{: .error}



~~~
colnames(design) <- levels(pd$group)
~~~
{: .language-r}



~~~
Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'levels': object 'pd' not found
~~~
{: .error}



~~~
design
~~~
{: .language-r}



~~~
standardGeneric for "design" defined from package "BiocGenerics"

function (object, ...) 
standardGeneric("design")
<bytecode: 0x55d96c431e08>
<environment: 0x55d96c4324d0>
Methods may be defined for arguments: object
Use  showMethods(design)  for currently available ones.
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
Error in if (levels[1] == "(Intercept)") {: argument is of length zero
~~~
{: .error}


~~~
kable(contrasts_matrix)
~~~
{: .language-r}



~~~
Error: object 'contrasts_matrix' not found
~~~
{: .error}

Now we can run the fit as usual


~~~
gse66417_fit <- lmFit(gse66417_eset,design)
~~~
{: .language-r}



~~~
Error: object 'gse66417_eset' not found
~~~
{: .error}



~~~
gse66417_fit2 <- contrasts.fit(gse66417_fit,contrasts=contrasts_matrix)
~~~
{: .language-r}



~~~
Error: object 'contrasts_matrix' not found
~~~
{: .error}



~~~
gse66417_fit2 <- eBayes(gse66417_fit2)
~~~
{: .language-r}



~~~
Error: object 'gse66417_fit2' not found
~~~
{: .error}



~~~
summary(decideTests(gse66417_fit2,lfc=1))
~~~
{: .language-r}



~~~
Error in h(simpleError(msg, call)): error in evaluating the argument 'object' in selecting a method for function 'summary': object 'gse66417_fit2' not found
~~~
{: .error}




