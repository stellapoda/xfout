* Task: convert xfout.ado to program
* Info: xfout written by Simo Goshev
* Date Created: 05/23

clear 
set seed 77777
set more off
cd "/Users/zitongliu/Dropbox/2019/xfout"
do "xfplot.ado"


 use "simu_dataset_xfout.dta", clear
 
xtmelogit bi_outcome1 timepoint##treatment##i.cluster_id || community_id: || unique_child:, matsqrt


* xi: xtmelogit bi_outcome1 i.timepoint*i.treatment*i.community_id || community_id: || cluster_id: , matsqrt

exit

 xfplot, savem("mytiral", replace) within(cluster_id)


/*

* I.  SIMULATION: 

set obs 300
gen unique_child = _n if _n <= 100
replace unique_child = _n - 100 if (_n > 100) & (_n<= 200)
replace unique_child = _n - 200 if (_n > 200)
sort unique_child

* create timepoint: 
generate timepoint = mod(_n, 3) + 1
sort unique_child timepoint

* generate random treatment: 0 1 2
generate treatment = floor((3)*runiform()) if timepoint == 1
bys unique_child: replace treatment = treatment[1] 
 
* Create examplary outcome variable: outcome1, outcome2, outcome3
* now we make it related with treatment and timepoint
* treatment and timepoint are not correlated. 
* outcome1: + treatment (0.5) and + time (0.4)
* outcome2: + treatment (0.5) and - time (-0.4)
* outcome3: 0 treatment and + time (0.4)
* outcome4: - treatment (-0.5) and 0 time

egen zs_treat = std(treatment) // Convert to zscore
egen zs_time = std(timepoint)

gen e = rnormal(0, 1)

* outcome1:  
scalar a = sqrt(1-0.4^2 - 0.5^2)
gen outcome1 = 0.5 * zs_treat + 0.4 *zs_time + scalar(a)* e

* outcome2: 
gen outcome2 = 0.5 * zs_treat - 0.4 *zs_time + scalar(a)* e

* outcome3
scalar b = sqrt(1 - 0.4^2)
gen outcome3 = 0.4 *zs_time +scalar(b) * e

* outcome4
scalar c = sqrt(1 - 0.5^2)
gen outcome4 = - 0.5*zs_treat + scalar(c) * e

* standadize them into binary variable
foreach out of varlist outcome* {
gen bi_`out' = (`out' > 0)
}

* community_id, suppose there are 10 communities, from 1 to 10
generate community_id = round((9)* uniform()+1) if timepoint == 1
bys unique_child: replace community_id = community_id[1]

* cluster_id: integer, suppose there are 5 clusters， from 1 to 5
generate cluster_id = 1 if community_id <= 3
replace cluster_id = 3 if community_id >= 6
replace cluster_id = 2 if cluster_id == . 


drop zs_treat zs_time e


save "simu_dataset_xfout.dta", replace

********************************************************************************




* II. ESTIMATION
/*
forval i = 1/4 {
xtmelogit bi_outcome`i' timepoint##treatment || cluster_id: || unique_child:, matsqrt
margins timepoint#treatment, predict(xb fixed) atmeans post

regsave using "result_`i'", replace
}
*/
