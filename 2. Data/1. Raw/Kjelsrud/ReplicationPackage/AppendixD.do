
set more off

*Set paths
global dir				"/users/anders/Dropbox/Health, inequality and political competition/replicationpackage"
global local_temp 		"/users/anders/desktop/temp"

*Set globals
global cov_area cell_share_sc cell_share_st cell_share_l6 cell_share_lit cell_primary cell_phc cell_phs cell_tap cell_power cell_paved
global cov_ind  female twin hindu muslim christian sikh buddhist
global cluster  pc_dist	
global cov_area_2001 cell2001_share_sc cell2001_share_st cell2001_share_l6 cell2001_share_lit cell2001_primary cell2001_phc cell2001_phs cell2001_tap cell2001_power cell2001_paved
global cluster2001  pc_dist2001	

*Decide which table to produce (1=yes)
global tableD1=1
global tableD2=1
global tableD3=1
global tableD4=1
global tableD5=1

global figureD1=1

***************************************************
* Table D1: Balance table, alternative
***************************************************
if $tableD1  == 1 {
qui {
	matrix tableB1=J(34,9,.)
	global help_var=0
	
forvalues  col=1/3 {
	global help_var= $help_var +1
	
if $help_var == 1 { 
use "$dir/datafiles/mortality.dta", clear
keep if main_sample==1
	xtset pc_dist_y
	egen exp	   = std(log_mean_pre66_past) 
	egen ineq	   = std(gini_pre66_past) 
	egen pol_comp  = std(fragmentation_2004_past) 
	gen  inter     = ineq * pol_comp	
	global controls = "$cov_area $cov_ind"
}	
if $help_var == 2 {
use "$dir/datafiles/healthcare.dta",clear
keep if main_sample==1	
	xtset pc_dist
	egen exp	   = std(log_mean_pre66_past) 
	egen ineq	   = std(gini_pre66_past) 
	egen pol_comp  = std(fragmentation_2004_past) 
	gen  inter     = ineq * pol_comp	
	global controls = "$cov_area"
}	
if $help_var == 3 {
use "$dir/datafiles/nrega.dta",clear
	xtset pc_dist
	egen exp	   = std(log_mean_pre66_past) 
	egen ineq	   = std(gini_pre66_past) 
	egen pol_comp  = std(fragmentation_2004_past) 
	gen  inter     = ineq * pol_comp
	global controls = "$cov_area"
}

global a=-1
global b=1
if `col'==2 {
	global b=4
}
if `col'==3 {
	global b=7
}
foreach var in $controls {
	global a=$a +2 
	xtreg  `var' ineq pol_comp inter ,fe cluster($cluster ) 
	matrix tableB1[$a, $b ]=_b[ineq ]
	matrix tableB1[$a +1,$b ]=_se[ineq ]
	matrix tableB1[$a,$b +1]=_b[pol_comp]
	matrix tableB1[$a +1,$b +1]=_se[pol_comp]
	matrix tableB1[$a,$b +2 ]=_b[inter ]
	matrix tableB1[$a +1,$b +2]=_se[inter ]
}
}
}
mat list tableB1
}

***************************************************
* Table D2: Neonatal
***************************************************
if $tableD2 ==1 {
qui {

***neonatal mortality, Cols 1-2
use "$dir/datafiles/mortality.dta", clear
keep if neonatal_sample==1
	xtset pc_dist_y
	egen exp	   = std(log_mean_pre66_past) 
	egen ineq	   = std(gini_pre66_past) 
	egen pol_comp  = std(fragmentation_2004_past) 
	gen  inter     = ineq * pol_comp		
	
	eststo col1TabB2: xtreg neonatal ineq pol_comp inter exp, fe cluster($cluster) 
	eststo col2TabB2: xtreg neonatal ineq pol_comp inter exp $cov_area $cov_ind, fe cluster($cluster) 

label var ineq  "Inequality" 
label var pol_comp  "Political competition" 
label var inter  "Inequality X Political competition" 
}

noisily esttab  col1TabB2 col2TabB2,keep(ineq pol_comp inter) order(ineq pol_comp inter) se stats(N r2,fmt(%9.0fc %9.3f)) label nomtitles starlevels(* 0.10 ** 0.05 *** 0.01)  b(%8.4f)
}
	

**************************************************
* Table D3 Regressions on separate PHC variables
***************************************************
if $tableD3 ==1 {
qui {
use "$dir/datafiles/healthcare.dta",clear
keep if main_sample==1	
	xtset pc_dist
	egen exp	   = std(log_mean_pre66_past) 
	egen ineq	   = std(gini_pre66_past) 
	egen pol_comp  = std(fragmentation_2004_past) 
	gen  inter     = ineq * pol_comp	
	 
	matrix tableD3=J(18,5,.)
	global c=-1
	foreach var in doctor nurse visitor antenatal  deliveries diarrhoea pneumonia vaccines  school    {
	global c=$c +2
	sum `var'
	matrix tableD3[$c ,4 ]= r(mean)
	xtreg `var' ineq pol_comp inter exp $cov_area, fe cluster($cluster) 
	matrix tableD3[$c ,5 ]= e(N)
	matrix tableD3[$c ,1 ]= _b[ineq]
	matrix tableD3[$c +1,1 ]= _se[ineq]
	matrix tableD3[$c ,2 ]= _b[pol_comp]
	matrix tableD3[$c +1,2 ]= _se[pol_comp]
	matrix tableD3[$c ,3 ]= _b[inter]
	matrix tableD3[$c +1,3 ]= _se[inter]
	 }
}
mat list tableD3	
}
		
	
***************************************************
* Table D4: Demand for health care at primary health centers
***************************************************

if $tableD4 == 1 {
	qui {
* Col 1
	use "$dir/datafiles/mortality.dta", clear
	keep if migr==0 & obs_missing==0 

	* Keep one observation per household
	foreach Y in hindu muslim christian sikh buddhist{
	rename `Y' `Y'_temp 
	bysort id: egen `Y'=mode(`Y'_temp), minmode
	drop `Y'_temp
	}
	duplicates drop id cell_share_sc cell_share_st cell_share_l6 cell_share_lit cell_primary cell_phc cell_phs cell_tap cell_power cell_paved hindu muslim christian sikh buddhist gov_health, force

	xtset pc_dist
	egen exp	   = std(log_mean_pre66_past) 
	egen ineq	   = std(gini_pre66_past) 
	egen pol_comp  = std(fragmentation_2004_past) 
	gen  inter     = ineq * pol_comp		

	eststo col1TabB4: xtreg gov_health ineq pol_comp inter exp $cov_area hindu muslim christian sikh buddhist, fe cluster($cluster) 
	su gov_health, d
	estadd scalar Mean_control = `r(mean)'
	
*Col 2
use "$dir/datafiles/appendixD_D4.dta",clear
	xtset pc_dist2001
	egen exp	   = std(log_mean_pre61_past) 
	egen ineq	   = std(gini_pre61_past) 
	egen pol_comp  = std(fragmentation_1999_past) 
	gen  inter     = ineq * pol_comp

	eststo col2TabB4:  xtreg gov_health ineq pol_comp inter exp $cov_area_2001 hindu muslim christian sikh buddhist , fe cluster(pc_dist2001) 
	su gov_health, d
	estadd scalar Mean_control = `r(mean)'
}	
	noisily esttab   col1TabB4  col2TabB4,keep(ineq pol_comp inter) order(ineq pol_comp inter) se stats(N Mean_control,fmt(%9.0fc %9.3f)) label nomtitles starlevels(* 0.10 ** 0.05 *** 0.01)  b(%8.4f)
}			


***************************************************
* Table D5: Employment, firms and night-time light
***************************************************
if $tableD5 == 1 {
qui {
use "$dir/datafiles/appendixD_D5a.dta",clear
xtset pc_dist
	global a=0
	foreach var in ec13_emp_all log_ec13_emp_all firms  log_firms  {
	global a=$a +1

	xtreg  `var'pc log_mean_pre66_past gini_pre66_past fragmentation_2004_past , fe cluster($cluster) 
	egen exp	   = std(log_mean_pre66_past) if e(sample)
	egen ineq	   = std(gini_pre66_past)  if e(sample)
	egen pol_comp  = std(fragmentation_2004_past)  if e(sample)
	gen  inter     = ineq * pol_comp	

	eststo col${a}TabA8: xtreg  `var'pc   $cov_area exp ineq pol_comp inter, fe cluster($cluster) 
	sum `var'pc if e(sample)
	qui drop exp ineq pol_comp inter 
		}

use "$dir/datafiles/appendixD_D5b.dta",clear
xtset pc_dist_y
	foreach var in average_ntl  average_ntl2 log_average_ntl2 {
	global a=$a +1

	qui xtreg `var' log_mean_pre66_past gini_pre66_past fragmentation_2004_past, fe cluster($cluster) 
	egen exp	   = std(log_mean_pre66_past) if e(sample)
	egen ineq	   = std(gini_pre66_past)  if e(sample)
	egen pol_comp  = std(fragmentation_2004_past)  if e(sample)
	gen  inter     = ineq * pol_comp		
	eststo col${a}TabA8: xtreg `var' $cov_area exp ineq pol_comp inter, fe cluster($cluster) 
	sum `var' if e(sample)
	drop exp ineq pol_comp inter

	}
	
}
	noisily esttab  col1TabA8 col2TabA8 col3TabA8 col4TabA8 col5TabA8 col6TabA8 col7TabA8  ,keep(ineq pol_comp inter) order(ineq pol_comp inter) se stats(N r2,fmt(%9.0fc %9.3f)) label nomtitles starlevels(* 0.10 ** 0.05 *** 0.01)  b(%8.4f)	
	 
}
	
***************************************************
* Figure D1
***************************************************
if $figureD1  == 1 {
set scheme s1mono	
use "$dir/datafiles/mortality.dta", clear
	duplicates drop pc_id_post,force
	pwcorr  fragmentation_2004_past fragmentation_2009
	twoway sc fragmentation_2009 fragmentation_2004_past , xtitle("Political competition in 2004 (pre-delimitation)") ytitle("Political competition in 2009 (post-delimitation)") ylabel(0.3(.1).9) xlabel(0.3(.1).9) text(.85 .38 "corr=.502", placement(south))
}
