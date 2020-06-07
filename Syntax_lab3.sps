﻿* Encoding: UTF-8.

DATASET ACTIVATE DataSet1.
FREQUENCIES VARIABLES=Survived Pclass Sex SibSp Parch gender
  /STATISTICS=VARIANCE MEAN SKEWNESS SESKEW KURTOSIS SEKURT
  /HISTOGRAM
  /ORDER=ANALYSIS.

DESCRIPTIVES VARIABLES=Survived Pclass Age SibSp gender
  /STATISTICS=MEAN STDDEV MIN MAX KURTOSIS SKEWNESS.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Pclass MEAN(Fare)[name="MEAN_Fare"] MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Pclass=col(source(s), name("Pclass"), unit.category())
  DATA: MEAN_Fare=col(source(s), name("MEAN_Fare"))
  GUIDE: axis(dim(1), label("Pclass"))
  GUIDE: axis(dim(2), label("Mean Fare"))
  GUIDE: text.title(label("Simple Bar Mean of Fare by Pclass"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: interval(position(Pclass*MEAN_Fare), shape.interior(shape.square))
END GPL.


CROSSTABS
  /TABLES=Survived BY Sex
  /FORMAT=AVALUE TABLES
  /STATISTICS=CORR 
  /CELLS=COUNT
  /COUNT ROUND CELL.

CROSSTABS
  /TABLES=Survived BY Pclass
  /FORMAT=AVALUE TABLES
  /STATISTICS=CORR 
  /CELLS=COUNT
  /COUNT ROUND CELL.

CROSSTABS
  /TABLES=Survived BY SibSp
  /FORMAT=AVALUE TABLES
  /STATISTICS=CORR 
  /CELLS=COUNT
  /COUNT ROUND CELL.


DATASET ACTIVATE DataSet2.
CROSSTABS
  /TABLES=Embarked BY Pclass
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.


RECODE Sex ('female'=1) ('male'=0) INTO Gender.
EXECUTE.

LOGISTIC REGRESSION VARIABLES Survived
  /METHOD=ENTER Pclass Age_1 family_size gender
  /PRINT=CI(95)
  /CRITERIA=PIN(0.05) POUT(0.10) ITERATE(20) CUT(0.5).


NOMREG Survived (BASE=FIRST ORDER=ASCENDING) BY gender  WITH Pclass family_size Age_1
  /CRITERIA CIN(95) DELTA(0) MXITER(100) MXSTEP(5) CHKSEP(20) LCONVERGE(0) PCONVERGE(0.000001) 
    SINGULAR(0.00000001)
  /MODEL
  /STEPWISE=PIN(.05) POUT(0.1) MINEFFECT(0) RULE(SINGLE) ENTRYMETHOD(LR) REMOVALMETHOD(LR)
  /INTERCEPT=INCLUDE
  /PRINT=CLASSTABLE PARAMETER SUMMARY LRT CPS STEP MFI IC.




