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
global tableC1=1
global tableC2=1
global tableC3=1
global tableC4=1
global tableC5=1

***************************************************
* Table C1: Post-Neonatal, Excluding muslims
***************************************************
if $tableC1 ==1 {
	qui {
use "$dir/datafiles/mortality.dta", clear
keep if main_sample==1
	xtset pc_dist_y
	egen exp	   = std(log_mean_pre66_past) 
	egen ineq	   = std(gini_pre66_past) 
	egen pol_comp  = std(fragmentation_2004_past) 
	gen  inter     = ineq * pol_comp		

	eststo col1TabC1: xtreg postneonatal ineq pol_comp inter exp, fe cluster($cluster) 
	eststo col2TabC1: xtreg postneonatal ineq pol_comp inter exp $cov_area $cov_ind, fe cluster($cluster) 	
}

	noisily esttab  col1TabC1 col2TabC1  ,keep(ineq pol_comp inter) order(ineq pol_comp inter) se stats(N r2,fmt(%9.0fc %9.3f)) label nomtitles starlevels(* 0.10 ** 0.05 *** 0.01)  b(%8.4f)	
}

***************************************************
* Table C2: Additional robustness checks
***************************************************
if $tableC2  == 1 {
qui {
global help_var =0
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
	gen yvar=postneonatal
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
	gen yvar=health_index
	global controls = "$cov_area"
}	
if $help_var == 3 {
use "$dir/datafiles/nrega.dta",clear
	xtset pc_dist_y
	egen exp	   = std(log_mean_pre66_past) 
	egen ineq	   = std(gini_pre66_past) 
	egen pol_comp  = std(fragmentation_2004_past) 
	gen  inter     = ineq * pol_comp
	gen yvar=sPostbank
	global controls = "$cov_area"
}

	* reg 1
	qui tab party_2009,gen(par_)
	gen inc=party_2009=="INC"
	gen bjp=party_2009=="BJP"
	gen sp=party_2009=="SP"
	gen jdu=party_2009=="JD(U)"
	gen bsp=party_2009=="BSP"
	
	foreach var in inc bjp sp jdu bsp {
		gen `var'_ineq=`var'*ineq
		gen `var'_pol=`var'*pol_comp
	}
	eststo col1TabC2_`col': xtreg yvar ineq pol_comp inter exp  inc bjp sp jdu bsp  $controls , fe cluster($cluster ) 
	eststo col2TabC2_`col': xtreg yvar ineq pol_comp inter exp  inc inc_ineq inc_pol bjp bjp_ineq bjp_pol sp sp_ineq sp_pol jdu jdu_pol jdu_ineq bsp bsp_ineq bsp_pol $controls , fe cluster($cluster ) 
		
		
	* reg 2
	gen res_st=reservation_post=="ST"
	gen res_sc=reservation_post=="SC"
	
	foreach var in res_st res_sc {
		gen `var'_ineq=`var'*ineq
		gen `var'_pol=`var'*pol_comp
	}
	
	eststo col3TabC2_`col': xtreg  yvar  ineq pol_comp inter exp res_st res_sc  $controls , fe cluster($cluster ) 
	eststo col4TabC2_`col': xtreg  yvar  ineq pol_comp inter exp  res_st res_st_ineq res_st_pol res_sc res_sc_ineq res_sc_pol $controls , fe cluster($cluster ) 
}

label var ineq  "Inequality" 
label var pol_comp  "Political competition" 
label var inter  "Inequality X Political competition" 
}

*Panel A: Postneonatal
noisily esttab  col1TabC2_1 col2TabC2_1 col3TabC2_1 col4TabC2_1,keep(ineq pol_comp inter) order(ineq pol_comp inter) se stats(N r2,fmt(%9.0fc %9.3f)) label nomtitles starlevels(* 0.10 ** 0.05 *** 0.01)  b(%8.4f)
*Panel B: Health care
noisily esttab  col1TabC2_2 col2TabC2_2 col3TabC2_2 col4TabC2_2,keep(ineq pol_comp inter) order(ineq pol_comp inter) se stats(N r2,fmt(%9.0fc %9.3f)) label nomtitles starlevels(* 0.10 ** 0.05 *** 0.01)  b(%8.4f)
*Panel C: MGNREGA
noisily esttab  col1TabC2_3 col2TabC2_3 col3TabC2_3 col4TabC2_3,keep(ineq pol_comp inter) order(ineq pol_comp inter) se stats(N r2,fmt(%9.0fc %9.3f)) label nomtitles starlevels(* 0.10 ** 0.05 *** 0.01)  b(%8.4f)
}

************************************************************
**Table C3: Table Distance, main estimates
************************************************************
if $tableC3  == 1 {
qui {
use "$dir/datafiles/mortality.dta", clear
keep if main_sample==1
xtset pc_dist_y	
global a=0
foreach d in 40 20 {
global a=$a +1
preserve

	keep if distance_km<=`d' 
	egen exp	   = std(log_mean_pre66_past) 
	egen ineq	   = std(gini_pre66_past) 
	egen pol_comp  = std(fragmentation_2004_past) 
	gen  inter     = ineq * pol_comp		
	
	eststo col${a}TabC3: xtreg postneonatal $cov_area $cov_ind exp ineq pol_comp inter  , fe cluster($cluster) 
restore
	}

foreach d in 5{
global a=$a +1
preserve
	keep if distance_km>`d' 
	egen exp	   = std(log_mean_pre66_past) 
	egen ineq	   = std(gini_pre66_past) 
	egen pol_comp  = std(fragmentation_2004_past) 
	gen  inter     = ineq * pol_comp		

	eststo col${a}TabC3: xtreg postneonatal $cov_area $cov_ind exp ineq pol_comp inter  , fe cluster($cluster) 
restore
}

use "$dir/datafiles/healthcare.dta",clear
keep if main_sample==1
	xtset pc_dist
	foreach d in 40 20 {
	global a=$a +1
	preserve
	keep if distance_km<=`d'
	egen exp	   = std(log_mean_pre66_past) 
	egen ineq	   = std(gini_pre66_past) 
	egen pol_comp  = std(fragmentation_2004_past) 
	gen  inter     = ineq * pol_comp		
	eststo col${a}TabC3: xtreg health_index   $cov_area exp ineq pol_comp inter, fe cluster($cluster) 
	restore
	}
	
	foreach d in 5{
	global a=$a +1
	preserve
	keep if distance_km>`d'
	egen exp	   = std(log_mean_pre66_past) 
	egen ineq	   = std(gini_pre66_past) 
	egen pol_comp  = std(fragmentation_2004_past) 
	gen  inter     = ineq * pol_comp		
	eststo col${a}TabC3: xtreg health_index   $cov_area exp ineq pol_comp inter, fe cluster($cluster) 
	restore
	}
	
use "$dir/datafiles/nrega.dta",clear
xtset pc_dist_y
	foreach d in 40 20 {
	global a=$a +1
	preserve
	keep if distance_km<=`d'
	egen exp	   = std(log_mean_pre66_past) 
	egen ineq	   = std(gini_pre66_past) 
	egen pol_comp  = std(fragmentation_2004_past) 
	gen  inter     = ineq * pol_comp		
	eststo col${a}TabC3: xtreg sPostbank   $cov_area exp ineq pol_comp inter, fe cluster($cluster) 
	restore
	}	

	foreach d in 5 {
	global a=$a +1
	preserve
	keep if distance_km>`d'
	egen exp	   = std(log_mean_pre66_past) 
	egen ineq	   = std(gini_pre66_past) 
	egen pol_comp  = std(fragmentation_2004_past) 
	gen  inter     = ineq * pol_comp		
	eststo col${a}TabC3: xtreg sPostbank   $cov_area exp ineq pol_comp inter, fe cluster($cluster) 
	restore
	}	

clear
set obs 1
gen ineq=0
gen pol_comp=0
gen inter=0
label var ineq "Inequality" 
label var pol_comp  "Political competition" 
label var inter  "Inequality X Political competition" 

}
noisily esttab col1TabC3 col2TabC3 col3TabC3  col4TabC3 col5TabC3  col7TabC3 col8TabC3    ,keep(ineq pol_comp inter) order(ineq pol_comp inter) se stats(N r2,fmt(%9.0fc %9.3f)) label nomtitles starlevels(* 0.10 ** 0.05 *** 0.01)  b(%8.4f) 
}

***************************************************
* Table C4: Additional balancing checks
***************************************************

if $tableC4  == 1 {
qui {
	global help_var=0
forvalues  col=1/3 {
	global help_var= $help_var +1
	
if $help_var == 1 { 
use "$dir/datafiles/mortality.dta", clear
keep if main_sample==1
	xtset pc_dist_y
}	
if $help_var == 2 {
use "$dir/datafiles/healthcare.dta",clear
keep if main_sample==1
	xtset pc_dist
}	
if $help_var == 3 {
use "$dir/datafiles/nrega.dta",clear
	xtset pc_dist
	duplicates drop gp_id,force
}
*capture drop change_pc
*gen change_pc = pc_id_post!=matched_pc_post
	egen exp	   = std(log_mean_pre66_past) if  mean_share_acW!=.
	egen ineq	   = std(gini_pre66_past)  if  mean_share_acW!=.
	egen pol_comp  = std(fragmentation_2004_past)  if  mean_share_acW!=.
	gen  inter     = ineq * pol_comp if  mean_share_acW!=.

eststo col1TabC4_${help_var }: xtreg  mean_share_acW change_pc ,fe cluster($cluster ) 
eststo col2TabC4_${help_var }: xtreg  mean_share_acW ineq pol_comp inter ,fe cluster($cluster ) 

drop exp ineq pol_comp inter
	egen exp	   = std(log_mean_pre66_past) if   share_blocksplit!=.
	egen ineq	   = std(gini_pre66_past)  if   share_blocksplit!=.
	egen pol_comp  = std(fragmentation_2004_past)  if   share_blocksplit!=.
	gen  inter     = ineq * pol_comp if   share_blocksplit!=.
	
eststo col3TabC4_${help_var }: xtreg   share_blocksplit change_pc ,fe cluster($cluster ) 
eststo col4TabC4_${help_var }: xtreg   share_blocksplit ineq pol_comp inter,fe cluster($cluster ) 

}
label var change_pc "Redistricted at the PC-level" 
label var ineq "Inequality" 
label var pol_comp  "Political competition" 
label var inter  "Inequality X Political competition" 
}

*Panel A: Postneonatal
noisily esttab col1TabC4_1 col2TabC4_1 col3TabC4_1  col4TabC4_1    ,keep(change_pc ineq pol_comp inter) order(change_pc ineq pol_comp inter) se stats(N r2,fmt(%9.0fc %9.3f)) label nomtitles starlevels(* 0.10 ** 0.05 *** 0.01)  b(%8.4f) 

*Panel B: Health care
noisily esttab col1TabC4_2 col2TabC4_2 col3TabC4_2  col4TabC4_2    ,keep(change_pc ineq pol_comp inter) order(change_pc ineq pol_comp inter) se stats(N r2,fmt(%9.0fc %9.3f)) label nomtitles starlevels(* 0.10 ** 0.05 *** 0.01)  b(%8.4f) 

*Panel C: MGNREGA
noisily esttab col1TabC4_3 col2TabC4_3 col3TabC4_3  col4TabC4_3    ,keep(change_pc ineq pol_comp inter) order(change_pc ineq pol_comp inter) se stats(N r2,fmt(%9.0fc %9.3f)) label nomtitles starlevels(* 0.10 ** 0.05 *** 0.01)  b(%8.4f) 

}

***************************************************
* Table C5:  Regressions to extra balancing
***************************************************

if $tableC5 == 1 {
	qui {
***Postneonatal mortality, Cols 1-2
use "$dir/datafiles/mortality.dta", clear
keep if main_sample==1
drop if change_ac==1
	xtset pc_dist_y
	egen exp	   = std(log_mean_pre66_past) 
	egen ineq	   = std(gini_pre66_past) 
	egen pol_comp  = std(fragmentation_2004_past) 
	gen  inter     = ineq * pol_comp		
	eststo col1: xtreg postneonatal ineq pol_comp inter exp $cov_area $cov_ind , fe cluster($cluster)

use "$dir/datafiles/mortality.dta", clear
keep if main_sample==1
drop if split_block==1
	xtset pc_dist_y
	egen exp	   = std(log_mean_pre66_past) 
	egen ineq	   = std(gini_pre66_past) 
	egen pol_comp  = std(fragmentation_2004_past) 
	gen  inter     = ineq * pol_comp		
	eststo col2: xtreg postneonatal ineq pol_comp inter exp $cov_area $cov_ind , fe cluster($cluster)	

***Health care index, Cols 3-4
use "$dir/datafiles/healthcare.dta",clear
keep if main_sample==1
drop if change_ac==1
	xtset pc_dist	
	egen exp	   = std(log_mean_pre66_past) 
	egen ineq	   = std(gini_pre66_past) 
	egen pol_comp  = std(fragmentation_2004_past) 
	gen  inter     = ineq * pol_comp		
	eststo col3: xtreg health_index ineq pol_comp inter exp $cov_area , fe cluster($cluster) 
	
use "$dir/datafiles/healthcare.dta",clear
keep if main_sample==1
drop if split_block==1
	xtset pc_dist
	egen exp	   = std(log_mean_pre66_past) 
	egen ineq	   = std(gini_pre66_past) 
	egen pol_comp  = std(fragmentation_2004_past) 
	gen  inter     = ineq * pol_comp		
	eststo col4: xtreg health_index ineq pol_comp inter exp $cov_area , fe cluster($cluster) 
	
***NREGA, Cols 5-6
use "$dir/datafiles/nrega.dta",clear
drop if change_ac==1
	xtset pc_dist_y
	egen exp	   = std(log_mean_pre66_past) 
	egen ineq	   = std(gini_pre66_past) 
	egen pol_comp  = std(fragmentation_2004_past) 
	gen  inter     = ineq * pol_comp		
	eststo col5: xtreg sPostbank ineq pol_comp inter exp $cov_area, fe cluster($cluster) 

use "$dir/datafiles/nrega.dta",clear
drop if split_block==1
	xtset pc_dist_y
	egen exp	   = std(log_mean_pre66_past) 
	egen ineq	   = std(gini_pre66_past) 
	egen pol_comp  = std(fragmentation_2004_past) 
	gen  inter     = ineq * pol_comp		
	eststo col6: xtreg sPostbank ineq pol_comp inter exp $cov_area, fe cluster($cluster) 
label var ineq  "Inequality" 
label var pol_comp  "Political competition" 
label var inter  "Inequality X Political competition" 
}

*Table
noisily esttab  col1 col2 col3 col4 col5 col6,keep(ineq pol_comp inter) order(ineq pol_comp inter) se stats(N r2,fmt(%9.0fc %9.3f)) label nomtitles starlevels(* 0.10 ** 0.05 *** 0.01)  b(%8.4f)
}  
