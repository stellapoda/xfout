* Program: xfplot
* Very primary version, even no input options about plotting defined. (Need to talk next time)
* Now two options: z-test or t-test
* Savemargin: save margin result
* Test: if not specified, will do t-test. 2 choices: ztest and ttest. 

* 1. estimate margin: options here - varlist, margin option
* 2. export the margins: to excel
* 3. plotting: my past code. 

* capture mar
*  if _rc

* TODO list by Zitiong:
* 1. need to allow within() --- DONE!
* 2. factor varlist: -- TODO
* 3. export table : not yet started.
* 4. plotting: wait for SIMO. 


capture program drop xfplot

program xfplot
	 syntax varlist(fv), [Test(string) SAVEMargin(string) within(varname)] 
	 
	 tokenize "`savemargin'", parse(",")
	 
	 local sav `1'
	 local rep `3'

	 
	 if "`test'" != "ztest" &  "`test'" != "ttest" & "`test'" != ""  {
	 disp as error `"Test option should be either "ztest" or "ttest"! "'
	 exit 198
	 }
	 
	 if "`test'" == "" {
	 disp as input `"Test option not specified, will do the default t-test. "'
	 local test "ttest"
	 }
	 
	 
	 preserve // Preserve the original dataset

	 tempfile marg ztest ttest // two possible temp files. TODO: convert name to input options
	 
	 
	 **** IM here!!! 
	 local fvops = "`s(fvops)'" == "true" | _caller() >= 11
if `fvops' {
	// within this loop, you can expand the factor variable list,
	// create a local for version control and perform any other
	// steps needed for factor operated varlists
}
	
	if "`within'" == "" {
	 margins timepoint, predict(xb fixed) atmeans post 
	}
	else {
	margins timepoint, predict(xb fixed) atmeans post within(`within')
	}
	 regsave using "`marg'", replace
	 
	 if "`sav'" != "" {
	 if "`rep'" == "replace" {
	 regsave using "`sav'", replace
	 }
	 else{
	 regsave using "`sav'"
	 }
	 }

	 if "`test'" == "ztest" {
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
	 }
	 
	 if "`test'" == "ttest" {
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
	 }
	 
end

