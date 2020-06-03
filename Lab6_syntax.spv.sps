﻿* Encoding: UTF-8.
DESCRIPTIVES VARIABLES=ar1 ar2 ar3 ar4 ar5 ar6 ar7 ar8 ar9 ar10 ar11 ar12 ar13 ar14 ar14 ar15 ar16 ar17 ar18 ar19 ar20 ar21 ar22 ar23 ar24 ar25 ar26 ar27 ar28 sex party liberal 
/STATISTICS=MEAN STDDEV MIN MAX.
EXAMINE VARIABLES=ar1 ar2 ar3 ar4 ar5 ar6 ar7 ar8 ar9 ar10 ar11 ar12 ar13 ar14 ar14 ar15 ar16 ar17 ar18 ar19 ar20 ar21 ar22 ar23 ar24 ar25 ar26 ar27 ar28 sex party liberal 
/PLOT BOXPLOT STEMLEAF HISTOGRAM
/COMPARE GROUPS
/STATISTICS DESCRIPTIVES
/CINTERVAL 95
/MISSING LISTWISE
/NOTOTAL.

CORRELATIONS
/VARIABLES=ar1 ar2 ar3 ar4 ar5 ar6 ar7 ar8 ar9 ar10 ar11 ar12 ar13 ar14 ar14 ar15 ar16 ar17 ar18 ar19 ar20 ar21 ar22 ar23 ar24 ar25 ar26 ar27 ar28 liberal 
/PRINT=TWOTAIL NOSIG
/MISSING=PAIRWISE

FACTOR
/VARIABLES ar1 ar2 ar3 ar4 ar5 ar6 ar7 ar8 ar9 ar10 ar11 ar12 ar13 ar14 ar14 ar15 ar16 ar17 ar18 ar19 ar20 ar21 ar22 ar23 ar24 ar25 ar26 ar27 ar28 
/ANALYSIS ar1 ar2 ar3 ar4 ar5 ar6 ar7 ar8 ar9 ar10 ar11 ar12 ar13 ar14 ar14 ar15 ar16 ar17 ar18 ar19 ar20 ar21 ar22 ar23 ar24 ar25 ar26 ar27 ar28
/PRINT INITIAL EXTRACTION
/PLOT EIGEN
/CRITERIA MINEIGEN(1) ITERATE(25)
/EXTRACTION PC
/ROTATION NOROTATE
/METHOD=CORRELATION.


DATASET ACTIVATE DataSet1.
FACTOR
  /VARIABLES ar1 ar2 ar3 ar4 ar5 ar6 ar7 ar8 ar9 ar10 ar11 ar12 ar13 ar14 ar15 ar16 ar17 ar18 ar19 
    ar20 ar21 ar22 ar23 ar24 ar25 ar26 ar27 ar28
  /MISSING LISTWISE 
  /ANALYSIS ar1 ar2 ar3 ar4 ar5 ar6 ar7 ar8 ar9 ar10 ar11 ar12 ar13 ar14 ar15 ar16 ar17 ar18 ar19 
    ar20 ar21 ar22 ar23 ar24 ar25 ar26 ar27 ar28
  /PRINT KMO EXTRACTION
  /CRITERIA MINEIGEN(1) ITERATE(25)
  /EXTRACTION PC
  /ROTATION NOROTATE
  /METHOD=CORRELATION.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT liberal
  /METHOD=ENTER ar1 ar2 ar3 ar4 ar5 ar6 ar7 ar8 ar9 ar10 ar11 ar12 ar13 ar14 ar15 ar16 ar17 ar18 
    ar19 ar20 ar21 ar22 ar23 ar24 ar25 ar26 ar27 ar28
  /SAVE MAHAL.

COMPUTE pval=($CASENUM-0.5)/154.
EXECUTE.

COMPUTE CHISQ=IDF.CHISQ(PVAL,28).
EXECUTE.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=MAH_1 CHISQ MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=YES.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: MAH_1=col(source(s), name("MAH_1"))
  DATA: CHISQ=col(source(s), name("CHISQ"))
  GUIDE: axis(dim(1), label("Mahalanobis Distance"))
  GUIDE: axis(dim(2), label("CHISQ"))
  GUIDE: text.title(label("Simple Scatter with Fit Line of CHISQ by Mahalanobis Distance"))
  ELEMENT: point(position(MAH_1*CHISQ))
END GPL.


set mxloops=9000 printback=off width=80  seed = 1953125.
matrix.

GET raw / FILE = * / missing=omit / VAR = ar2 to ar28.

compute ndatsets = 1000.

compute percent  = 95.

compute kind = 2 .

compute randtype = 2.


****************** End of user specifications. ******************

compute ncases   = nrow(raw). 
compute nvars    = ncol(raw).


do if (kind = 1 and randtype = 1).
compute nm1 = 1 / (ncases-1).
compute vcv = nm1 * (sscp(raw) - ((t(csum(raw))*csum(raw))/ncases)).
compute d = inv(mdiag(sqrt(diag(vcv)))).
compute realeval = eval(d * vcv * d).
compute evals = make(nvars,ndatsets,-9999).
loop #nds = 1 to ndatsets.
compute x = sqrt(2 * (ln(uniform(ncases,nvars)) * -1) ) &*
            cos(6.283185 * uniform(ncases,nvars) ).
compute vcv = nm1 * (sscp(x) - ((t(csum(x))*csum(x))/ncases)).
compute d = inv(mdiag(sqrt(diag(vcv)))).
compute evals(:,#nds) = eval(d * vcv * d).
end loop.
end if.


do if (kind = 1 and randtype = 2).
compute nm1 = 1 / (ncases-1).
compute vcv = nm1 * (sscp(raw) - ((t(csum(raw))*csum(raw))/ncases)).
compute d = inv(mdiag(sqrt(diag(vcv)))).
compute realeval = eval(d * vcv * d).
compute evals = make(nvars,ndatsets,-9999).
loop #nds = 1 to ndatsets.
compute x = raw.
loop #c = 1 to nvars.
loop #r = 1 to (ncases -1).
compute k = trunc( (ncases - #r + 1) * uniform(1,1) + 1 )  + #r - 1.
compute d = x(#r,#c).
compute x(#r,#c) = x(k,#c).
compute x(k,#c) = d.
end loop.
end loop.
compute vcv = nm1 * (sscp(x) - ((t(csum(x))*csum(x))/ncases)).
compute d = inv(mdiag(sqrt(diag(vcv)))).
compute evals(:,#nds) = eval(d * vcv * d).
end loop.
end if.


do if (kind = 2 and randtype = 1).
compute nm1 = 1 / (ncases-1).
compute vcv = nm1 * (sscp(raw) - ((t(csum(raw))*csum(raw))/ncases)).
compute d = inv(mdiag(sqrt(diag(vcv)))).
compute cr = (d * vcv * d).
compute smc = 1 - (1 &/ diag(inv(cr)) ).
call setdiag(cr,smc).
compute realeval = eval(cr).
compute evals = make(nvars,ndatsets,-9999).
compute nm1 = 1 / (ncases-1).
loop #nds = 1 to ndatsets.
compute x = sqrt(2 * (ln(uniform(ncases,nvars)) * -1) ) &*
            cos(6.283185 * uniform(ncases,nvars) ).
compute vcv = nm1 * (sscp(x) - ((t(csum(x))*csum(x))/ncases)).
compute d = inv(mdiag(sqrt(diag(vcv)))).
compute r = d * vcv * d.
compute smc = 1 - (1 &/ diag(inv(r)) ).
call setdiag(r,smc).
compute evals(:,#nds) = eval(r).
end loop.
end if.


do if (kind = 2 and randtype = 2).
compute nm1 = 1 / (ncases-1).
compute vcv = nm1 * (sscp(raw) - ((t(csum(raw))*csum(raw))/ncases)).
compute d = inv(mdiag(sqrt(diag(vcv)))).
compute cr = (d * vcv * d).
compute smc = 1 - (1 &/ diag(inv(cr)) ).
call setdiag(cr,smc).
compute realeval = eval(cr).
compute evals = make(nvars,ndatsets,-9999).
compute nm1 = 1 / (ncases-1).
loop #nds = 1 to ndatsets.
compute x = raw.
loop #c = 1 to nvars.
loop #r = 1 to (ncases -1).
compute k = trunc( (ncases - #r + 1) * uniform(1,1) + 1 )  + #r - 1.
compute d = x(#r,#c).
compute x(#r,#c) = x(k,#c).
compute x(k,#c) = d.
end loop.
end loop.
compute vcv = nm1 * (sscp(x) - ((t(csum(x))*csum(x))/ncases)).
compute d = inv(mdiag(sqrt(diag(vcv)))).
compute r = d * vcv * d.
compute smc = 1 - (1 &/ diag(inv(r)) ).
call setdiag(r,smc).
compute evals(:,#nds) = eval(r).
end loop.
end if.

compute num = rnd((percent*ndatsets)/100).
compute results = { t(1:nvars), realeval, t(1:nvars), t(1:nvars) }.
loop #root = 1 to nvars.
compute ranks = rnkorder(evals(#root,:)).
loop #col = 1 to ndatsets.
do if (ranks(1,#col) = num).
compute results(#root,4) = evals(#root,#col).
break.
end if.
end loop.
end loop.
compute results(:,3) = rsum(evals) / ndatsets.

print /title="PARALLEL ANALYSIS:".
do if (kind = 1 and randtype = 1).
print /title="Principal Components & Random Normal Data Generation".
else if (kind = 1 and randtype = 2).
print /title="Principal Components & Raw Data Permutation".
else if (kind = 2 and randtype = 1).
print /title="PAF/Common Factor Analysis & Random Normal Data Generation".
else if (kind = 2 and randtype = 2).
print /title="PAF/Common Factor Analysis & Raw Data Permutation".
end if.
compute specifs = {ncases; nvars; ndatsets; percent}.
print specifs /title="Specifications for this Run:"
 /rlabels="Ncases" "Nvars" "Ndatsets" "Percent".
print results 
 /title="Raw Data Eigenvalues, & Mean & Percentile Random Data Eigenvalues"
 /clabels="Root" "Raw Data" "Means" "Prcntyle"  /format "f12.6".

do if   (kind = 2).
print / space = 1.
print /title="Warning: Parallel analyses of adjusted correlation matrices".
print /title="eg, with SMCs on the diagonal, tend to indicate more factors".
print /title="than warranted (Buja, A., & Eyuboglu, N., 1992, Remarks on parallel".
print /title="analysis. Multivariate Behavioral Research, 27, 509-540.).".
print /title="The eigenvalues for trivial, negligible factors in the real".
print /title="data commonly surpass corresponding random data eigenvalues".
print /title="for the same roots. The eigenvalues from parallel analyses".
print /title="can be used to determine the real data eigenvalues that are".
print /title="beyond chance, but additional procedures should then be used".
print /title="to trim trivial factors.".
print / space = 2.
print /title="Principal components eigenvalues are often used to determine".
print /title="the number of common factors. This is the default in most".
print /title="statistical software packages, and it is the primary practice".
print /title="in the literature. It is also the method used by many factor".
print /title="analysis experts, including Cattell, who often examined".
print /title="principal components eigenvalues in his scree plots to determine".
print /title="the number of common factors. But others believe this common".
print /title="practice is wrong. Principal components eigenvalues are based".
print /title="on all of the variance in correlation matrices, including both".
print /title="the variance that is shared among variables and the variances".
print /title="that are unique to the variables. In contrast, principal".
print /title="axis eigenvalues are based solely on the shared variance".
print /title="among the variables. The two procedures are qualitatively".
print /title="different. Some therefore claim that the eigenvalues from one".
print /title="extraction method should not be used to determine".
print /title="the number of factors for the other extraction method.".
print /title="The issue remains neglected and unsettled.".
end if.

compute root      = results(:,1).
compute rawdata = results(:,2).
compute percntyl = results(:,4).

save results /outfile= 'C:\Users\bte14dyo\documents\screedata.sav' / var=root rawdata means percntyl .

end matrix.

* plots the eigenvalues, by root, for the real/raw data and for the random data.
GET file= 'C:\Users\bte14dyo\documents\screedata.sav'.
TSPLOT VARIABLES= rawdata means percntyl /ID= root /NOLOG.


FACTOR
  /VARIABLES ar1 ar2 ar3 ar4 ar5 ar6 ar7 ar8 ar9 ar10 ar11 ar12 ar13 ar14 ar15 ar16 ar17 ar18 ar19 
    ar20 ar21 ar22 ar23 ar24 ar25 ar26 ar27 ar28
  /MISSING LISTWISE 
  /ANALYSIS ar1 ar2 ar3 ar4 ar5 ar6 ar7 ar8 ar9 ar10 ar11 ar12 ar13 ar14 ar15 ar16 ar17 ar18 ar19 
    ar20 ar21 ar22 ar23 ar24 ar25 ar26 ar27 ar28
  /PRINT EXTRACTION
  /PLOT EIGEN
  /CRITERIA FACTORS(7) ITERATE(25)
  /EXTRACTION ML
  /ROTATION NOROTATE.


REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT liberal
  /METHOD=ENTER ar1 ar2 ar3 ar4 ar5 ar6 ar7 ar8 ar9 ar10 ar11 ar12 ar13 ar14 ar15 ar16 ar17 ar18 
    ar19 ar20 ar21 ar22 ar23 ar24 ar25 ar26 ar27 ar28
  /SAVE MAHAL.


FACTOR
  /VARIABLES ar1 ar2 ar3 ar4 ar5 ar6 ar7 ar8 ar9 ar10 ar11 ar12 ar13 ar14 ar15 ar16 ar17 ar18 ar19 
    ar20 ar21 ar22 ar23 ar24 ar25 ar26 ar27 ar28
  /MISSING LISTWISE 
  /ANALYSIS ar1 ar2 ar3 ar4 ar5 ar6 ar7 ar8 ar9 ar10 ar11 ar12 ar13 ar14 ar15 ar16 ar17 ar18 ar19 
    ar20 ar21 ar22 ar23 ar24 ar25 ar26 ar27 ar28
  /PRINT UNIVARIATE INITIAL KMO EXTRACTION
  /PLOT EIGEN
  /CRITERIA FACTORS(3) ITERATE(25)
  /EXTRACTION PAF
  /ROTATION NOROTATE
  /SAVE REG(ALL)
  /METHOD=CORRELATION.

FACTOR
  /VARIABLES ar1 ar2 ar3 ar4 ar5 ar6 ar7 ar8 ar9 ar10 ar11 ar12 ar13 ar14 ar15 ar17 ar18 ar20 ar22 
    ar23 ar25 ar26 ar27 ar16_recode art19_recode ar21_recode ar24_recode ar28_recode
  /MISSING LISTWISE 
  /ANALYSIS ar1 ar2 ar3 ar4 ar5 ar6 ar7 ar8 ar9 ar10 ar11 ar12 ar13 ar14 ar15 ar17 ar18 ar20 ar22 
    ar23 ar25 ar26 ar27 ar16_recode art19_recode ar21_recode ar24_recode ar28_recode
  /PRINT INITIAL EXTRACTION ROTATION
  /FORMAT SORT
  /PLOT EIGEN
  /CRITERIA FACTORS(3) ITERATE(25)
  /EXTRACTION PAF
  /CRITERIA ITERATE(25)
  /ROTATION VARIMAX
  /SAVE REG(ALL)
  /METHOD=CORRELATION.

DATASET ACTIVATE DataSet1.
FACTOR
  /VARIABLES ar2 ar4 ar5 ar21_recode ar24_recode ar6 
    ar7 ar9 ar10 ar13  ar15 ar17 ar18 ar20 ar22 ar23 ar26 ar27
  /MISSING LISTWISE 
  /ANALYSIS ar2 ar4 ar5 ar21_recode ar24_recode ar6 
    ar7 ar9 ar10 ar13  ar15 ar17 ar18 ar20 ar22 ar23 ar26 ar27
  /PRINT INITIAL KMO EXTRACTION ROTATION
  /FORMAT SORT
  /PLOT EIGEN
  /CRITERIA FACTORS(2) ITERATE(25)
  /EXTRACTION PAF
  /CRITERIA ITERATE(25)
  /ROTATION VARIMAX
  /SAVE REG(ALL)
  /METHOD=CORRELATION.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT liberal
  /METHOD=ENTER Animal_rights_gen Animal_experiments
