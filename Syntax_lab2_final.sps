* Encoding: UTF-8.
* Recoding sex to dummy with female as reference [ female = 1 , male=  0 ] 

DATASET ACTIVATE DataSet2.
RECODE sex ('female'=1) (ELSE=0) INTO sex_dummy.
VARIABLE LABELS  sex_dummy 'Female as reference'.
EXECUTE.

* running the regression with both our models in a hieracrchial manor, asking for a few diagnostical outputs as well. 

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) BCOV R ANOVA COLLIN TOL CHANGE selection 
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT pain
  /METHOD=ENTER sex_dummy age
  /METHOD=ENTER STAI_trait pain_cat cortisol_serum cortisol_saliva mindfulness
  /SCATTERPLOT=(*ZPRED ,*ZRESID)
  /RESIDUALS HISTOGRAM(ZRESID) NORMPROB(ZRESID)
  /SAVE PRED COOK RESID.

* Plotting Cooks distance 

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=ID COO_1 MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=YES.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: ID=col(source(s), name("ID"), unit.category())
  DATA: COO_1=col(source(s), name("COO_1"))
  GUIDE: axis(dim(1), label("ID"))
  GUIDE: axis(dim(2), label("Cook's Distance"))
  GUIDE: text.title(label("Simple Scatter with Fit Line of Cook's Distance by ID"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: point(position(ID*COO_1))
END GPL.

* removing the cortisol_saliva after detecting some multicolinearity (VIF> 5) for cortisol_saliva and cortisol_serum and running the regression again
* also removing ID_145 since it seemed to be  an outlier. 

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) BCOV R ANOVA COLLIN TOL CHANGE selection 
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT pain
  /METHOD=ENTER sex_dummy age
  /METHOD=ENTER STAI_trait pain_cat cortisol_serum mindfulness
  /SCATTERPLOT=(*ZPRED ,*ZRESID)
  /RESIDUALS HISTOGRAM(ZRESID) NORMPROB(ZRESID)
  /SAVE PRED COOK RESID.

* plotting the residuals showed that the assumption of heterscedasity was not met. Below we try to fix it and keeping the original scale of our dependent variable. 

GENLIN pain WITH  sex_dummy age 
/MODEL sex_dummy age INTERCEPT=YES 
DISTRIBUTION=NORMAL LINK=IDENTITY 
/CRITERIA SCALE=MLE COVB=ROBUST PCONVERGE=1E-006(ABSOLUTE) 
SINGULAR=1E-012 ANALYSISTYPE=3(WALD) 
CILEVEL=95 CITYPE=WALD LIKELIHOOD=FULL 
/MISSING CLASSMISSING=EXCLUDE 
/PRINT CPS DESCRIPTIVES MODELINFO FIT SUMMARY SOLUTION.



GENLIN pain WITH  sex_dummy age STAI_trait pain_cat cortisol_serum mindfulness
/MODEL sex_dummy age STAI_trait pain_cat cortisol_serum mindfulness INTERCEPT=YES 
DISTRIBUTION=NORMAL LINK=IDENTITY 
/CRITERIA SCALE=MLE COVB=ROBUST PCONVERGE=1E-006(ABSOLUTE) 
SINGULAR=1E-012 ANALYSISTYPE=3(WALD) 
CILEVEL=95 CITYPE=WALD LIKELIHOOD=FULL 
/MISSING CLASSMISSING=EXCLUDE 
/PRINT CPS DESCRIPTIVES MODELINFO FIT SUMMARY SOLUTION.

* GETTING THE AIC 


REGRESSION
  /MISSING LISTWISE
  /STATISTICS R ANOVA CHANGE SELECTION 
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT pain
  /METHOD=ENTER sex_dummy age
  /METHOD=ENTER STAI_trait pain_cat cortisol_serum cortisol_saliva mindfulness
 




