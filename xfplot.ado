* Program: xfplot
* Very primary version, even no input options defined. (Need to talk next time)
* May need to define a temporary file (also set save option) for the result dta file
* Now two options: z-test or t-test


capture program drop xfplot

program xfplot

	 preserve // Preserve the 
	 tempfile marg ztest ttest // two possible temp files. TODO: convert name to input options
	
	 margins timepoint#treatment, predict(xb fixed) atmeans post // ASK Simo: do I need to take the margins of other than timepoint##treatment?
	
	 regsave using "`marg'", replace
	 
	 
	*** For Z-test
	    use "`marg'", clear

			*** generate indicators
			gen followup = regexs(0) if regexm(var, "^[0-9]")
			gen treatment = regexs(0) if regexm(var, "#[0-9].*\.treatment")
			replace treatment = regexs(0) if regexm(treatment, "[0-9]")
			
			***  compute  pvalues, lci & uci 
			gen z = coef/stderr
			gen pvalue = 2*(1-normal(abs(z)))
			gen lci = coef - invnormal(0.975)*stderr
			gen uci = coef + invnormal(0.975)*stderr
		
		save "`ztest'", replace
	
	*** For t-test (with mi)
		use "`marg'", clear
			 
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
	
		save "`ttest'", replace
	
end

