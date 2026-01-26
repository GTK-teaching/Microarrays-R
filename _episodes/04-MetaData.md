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

















