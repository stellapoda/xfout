xtmelogit cd_nonviol_f timepoint##treatment || cluster_id: || unique_child:, iter(1)
margins timepoint#treatment, predict(xb fixed) atmeans post

regsave 

*** For Z-test
*** generate indicators
gen followup = regexs(0) if regexm(var, "^[0-9]")
gen treatment = regexs(0) if regexm(var, "#[0-9].*\.treatment")
replace treatment = regexs(0) if regexm(treatment, "[0-9]")

***  compute  pvalues, lci & uci 
gen z = coef/stderr
gen pvalue = 2*(1-normal(abs(z)))
gen lci = coef - invnormal(0.975)*stderr
gen uci = coef + invnormal(0.975)*stderr


*** For t-test (with mi)
*** grab degrees of freedom
mat df = e(df_mi)
mat df = df'

*** generate indicators
gen followup = regexs(0) if regexm(var, "^[0-9]")
gen treatment = regexs(0) if regexm(var, "#[0-9].*\.treatment")
replace treatment = regexs(0) if regexm(treatment, "[0-9]")
gen community = regexs(0) if regexm(var, "#[0-9][bn]*\.id_community$")
replace community = regexs(0) if regexm(community, "[0-9]")

*** save the matrix of df's
svmat df

***  compute  pvalues, lci & uci 
gen pvalue = 2*ttail(df1, abs(coef/stderr))
gen lci = coef - invttail(df1, 0.025)*stderr
gen uci = coef + invttail(df1, 0.025)*stderr
