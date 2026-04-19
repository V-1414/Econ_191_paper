
******************************************************************************************************
******************************************************************************************************
* APPENDIX B
******************************************************************************************************
******************************************************************************************************

*Set paths
global dir				"/users/anders/Dropbox/Health, inequality and political competition/replicationpackage"
global local_temp 		"/users/anders/desktop/temp"


*Globals
global controls="s_* mpre_electors_2004 mpre_electors_2004_2 pre_share_sc pre_share_st  pre_urbanization pre_share_lit pre_share_males"
global variables="com_incument cab_minister state_minister align_stategovern"

*Decide which table to produce (1=yes)
global tableB1=1
global tableB2=1
global tableB3=1


********************************************************
* Table B1: Changes in Parliamentary constituencies
********************************************************
if $tableB1  == 1 {
qui {
use "$dir/datafiles/sample_appendixB.dta",clear
duplicates drop state2001,force
statsmat count_pcs,by(state_name) stat(mean) mat(col1)
statsmat mean_pop,by(state_name) stat(mean) mat(col2)
statsmat mean_change,by(state_name) stat(mean) mat(col3)

gen n=_n
keep if n==1
statsmat count_pcsALL, stat(mean) mat(col1ALL)
statsmat mean_popALL, stat(mean) mat(col2ALL)
statsmat mean_changeALL, stat(mean) mat(col3ALL)

mat define COL1=col1 \ col1ALL
mat define COL2=col2 \ col2ALL
mat define COL3=col3 \ col3ALL
mat define tableB1=COL1, COL2, COL3
}
mat list tableB1
}

********************************************************
* Table B2: Absolute population changes and initial population
********************************************************
if $tableB2  == 1 {
qui {
use "$dir/datafiles/sample_appendixB.dta",clear
qui tab state2001,gen(s_)
	eststo b2a:reg abs_population_change mpre_electors_2004 mpre_electors_2004_2 pre_share_st pre_share_sc, robust
	eststo b2b: reg abs_population_change mpre_electors_2004 mpre_electors_2004_2 pre_share_st pre_share_sc s_*, robust	
	label var mpre_electors_2004 "Eligible voters pre-delimitation"
	label var mpre_electors_2004_2  "Eligible voters pre-delimitation squared"
}

	noisily esttab  b2a b2b,keep(mpre_electors_2004  mpre_electors_2004_2) order(mpre_electors_2004  mpre_electors_2004_2 )  stats(N r2,fmt(%9.0fc %9.3f)) label nomtitles starlevels(* 0.10 ** 0.05 *** 0.01)  b(%8.3f)
}	


********************************************************
* Table B3: Redistricting and electoral prospects (2004)
********************************************************
if $tableB3  == 1 {
qui {
use "$dir/datafiles/sample_appendixB.dta",clear
qui tab state2001,gen(s_)
	eststo a3a: reg population_increase s_* $controls $variables , robust
	test $variables
	local f=round(r(p),.001)
	estadd local ftest `f'
	eststo a3b: reg share_old_voters s_* $controls $variables  , robust
	test $variables
	local f=round(r(p),.001)
	estadd local ftest `f'
	eststo a3c: reg mpre_res_post_sc s_* $controls $variables , robust
	test $variables
	local f=round(r(p),.001)
	estadd local ftest `f'
	eststo a3d: reg mpre_res_post_st s_* $controls $variables , robust
	test $variables
	local f=round(r(p),.001)
	estadd local ftest `f'
	eststo a3e: reg demographic_index s_* $controls $variables , robust
	test $variables
	local f=round(r(p),.001)
	estadd local ftest `f'

	label var com_incument "Member of Delimitation Commission"
	label var cab_minister  "Cabinet Minister"
	label var state_minister "State Minister"
	label var align_stategovern "From same party as state government"
}

		noisily esttab  a3a a3b a3c a3d a3e,keep(com_incument cab_minister state_minister align_stategovern) order(com_incument cab_minister state_minister align_stategovern )  stats(N r2,fmt(%9.0fc %9.3f)) label nomtitles starlevels(* 0.10 ** 0.05 *** 0.01)  b(%8.3f)
}	
	