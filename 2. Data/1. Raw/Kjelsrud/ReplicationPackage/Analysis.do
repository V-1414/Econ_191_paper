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
global table2=1
global table3=1
global table4=1
global table5=1
global table6=1
global table7=1


***************************************************
* Table 2: Summary statistics
***************************************************
if $table2 ==1 {
	qui {
use "$dir/datafiles/mortality.dta", clear
keep if main_sample==1
qui statsmat postneonatal,stat(n mean sd) mat(row1)
duplicates drop pc_id_post, force
qui statsmat gini_pre66_past, stat(n mean sd) mat(row4)
qui statsmat fragmentation_2004_past, stat(n mean sd) mat(row5)
qui statsmat mean_pre66_past, stat(n mean sd) mat(row6)

use "$dir/datafiles/healthcare.dta",clear
keep if main_sample==1
qui statsmat health_index,stat(n mean sd) mat(row2)

use "$dir/datafiles/nrega.dta",clear
qui statsmat postbank,stat(n mean sd) mat(row3)
mat define table2=row1 \ row2 \ row3 \ row4 \ row5 \ row6
}
}


***************************************************
* Table 3: Balance table
***************************************************
if $table3  == 1 {
qui {
	matrix table3=J(36,3,.)
	global help_var=0
	
forvalues  col=1/3 {
	global help_var= $help_var +1
	
if $help_var == 1 { 
	use "$dir/datafiles/mortality.dta", clear
	keep if main_sample==1
	xtset pc_dist_y
	global controls = "$cov_area $cov_ind"
}	
if $help_var == 2 {
	use "$dir/datafiles/healthcare.dta",clear
	keep if main_sample==1
	xtset pc_dist
	global controls = "$cov_area"
}	
if $help_var == 3 {
	use "$dir/datafiles/nrega.dta",clear
	xtset pc_dist
	global controls = "$cov_area"
	duplicates drop gp_id,force
}
capture drop change_pc
gen change_pc = pc_id_post!=matched_pc_post
global a=-1
foreach var in $controls {
	global a=$a +2 
	xtreg  `var' change_pc ,fe cluster($cluster ) 
	matrix table3[$a,`col']=_b[change_pc]
	matrix table3[$a +1,`col']=_se[change_pc]

}

sum change_pc
matrix table3[35,`col']=r(mean)
matrix table3[36,`col']=r(N)
xtreg change_pc $controls ,fe cluster($cluster ) 
global F`col'= e(F) 
}
}	
}



***************************************************
* Table 4: Main results
***************************************************
if $table4 ==1 {
qui {

***Postneonatal mortality, Cols 1-2
	use "$dir/datafiles/mortality.dta", clear
	keep if main_sample==1
	xtset pc_dist_y
	egen exp	   = std(log_mean_pre66_past) 
	egen ineq	   = std(gini_pre66_past) 
	egen pol_comp  = std(fragmentation_2004_past) 
	gen  inter     = ineq * pol_comp		
	
	eststo col1Tab1: xtreg postneonatal ineq pol_comp inter exp, fe cluster($cluster) 
	eststo col2Tab1: xtreg postneonatal ineq pol_comp inter exp $cov_area $cov_ind, fe cluster($cluster) 

***Health care index, Cols 3-4
	use "$dir/datafiles/healthcare.dta",clear
	keep if main_sample==1
	xtset pc_dist
	egen exp	   = std(log_mean_pre66_past) 
	egen ineq	   = std(gini_pre66_past) 
	egen pol_comp  = std(fragmentation_2004_past) 
	gen  inter     = ineq * pol_comp		
	 
	eststo col3Tab1: xtreg health_index ineq pol_comp inter exp , fe cluster($cluster) 
	eststo col4Tab1: xtreg health_index ineq pol_comp inter exp $cov_area, fe cluster($cluster) 

***NREGA, Cols 5-6
	use "$dir/datafiles/nrega.dta",clear
	xtset pc_dist_y
	egen exp	   = std(log_mean_pre66_past) 
	egen ineq	   = std(gini_pre66_past) 
	egen pol_comp  = std(fragmentation_2004_past) 
	gen  inter     = ineq * pol_comp		

	eststo col5Tab1: xtreg sPostbank  ineq pol_comp inter exp , fe cluster($cluster) 
	eststo col6Tab1: xtreg sPostbank ineq pol_comp inter exp $cov_area, fe cluster($cluster) 

label var ineq  "Inequality" 
label var pol_comp  "Political competition" 
label var inter  "Inequality X Political competition" 
}
}
	
	
	
***************************************************
* Table 5: Placebo regressions
***************************************************	
if $table5 == 1 {
qui {

***Postneonatal mortality, Col 1 
	use "$dir/datafiles/mortality.dta", clear
	keep if placebo_sample==1
	xtset pc_dist2001_y
	egen exp	   = std(log_mean_pre61_past) 
	egen ineq	   = std(gini_pre61_past) 
	egen pol_comp  = std(fragmentation_1999_past) 
	gen  inter     = ineq * pol_comp	

	eststo col1Tab5: xtreg postneonatal ineq pol_comp inter exp $cov_area_2001 $cov_ind, fe cluster($cluster2001) 

***Health care index, Col 2
	use "$dir/datafiles/healthcare.dta",clear
	keep if placebo_sample==1
	xtset pc_dist2001
	egen exp	   = std(log_mean_pre61_past) 
	egen ineq	   = std(gini_pre61_past) 
	egen pol_comp  = std(fragmentation_1999_past) 
	gen  inter     = ineq * pol_comp
	
	eststo col2Tab5: xtreg index_health_placebo ineq pol_comp inter exp $cov_area_2001, fe cluster($cluster2001) 

***NREGA, Col 3
	use "$dir/datafiles/nrega.dta",clear
	xtset pc_dist_y 
	egen exp	   = std(log_mean_pre66_past) 
	egen ineq	   = std(gini_pre66_past) 
	egen pol_comp  = std(fragmentation_2004_past) 
	gen  inter     = ineq * pol_comp	

	eststo col3Tab5: xtreg sDemand ineq pol_comp inter exp $cov_area, fe cluster($cluster) 	
	
label var ineq  "Inequality" 
label var pol_comp  "Political competition" 
label var inter  "Inequality X Political competition" 	
}
}




***************************************************
* Table 6: Horse race regressions
***************************************************

if $table6 ==1 {
	qui {
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

	
* additional interactions - expenditures
	gen int1_exp = exp * ineq
	gen int2_exp = exp * pol_comp
	
* additional interactions - area characteristics
	foreach Y in  primary phc phs tap power paved share_sc share_st share_l6 share_lit   {
	egen `Y'_pastSTD=std(`Y'_past)
	egen cell_`Y'STD=std(cell_`Y')
	gen int1PC_`Y' = `Y'_pastSTD * ineq
	gen int2PC_`Y' = `Y'_pastSTD * pol_comp	
	gen int1_cell_`Y' = cell_`Y'STD * ineq
	gen int2_cell_`Y' = cell_`Y'STD * pol_comp	
	}
	
	*foreach Y in   poverty_pre66 urbanization population  caste_frac  religion_frac lit {
	foreach Y in   poverty_pre66 urbanization population  caste_frac  religion_frac {		
	egen `Y'_pastSTD=std(`Y'_past)
	gen int1PC_`Y' = `Y'_pastSTD * ineq
	gen int2PC_`Y' = `Y'_pastSTD * pol_comp	
	}
	
	if $help_var == 1 {
	* additional interactions - child characteristics
	foreach Y in female twin hindu muslim christian sikh buddhist{
	gen int1_`Y' = `Y' * ineq
	gen int2_`Y' = `Y' * pol_comp	
	}
	}
	
	global int_cov_area		int1_cell_share_sc int1_cell_share_st int1_cell_share_l6 int1_cell_share_lit int1_cell_primary int1_cell_phc int1_cell_phs int1_cell_tap int1_cell_power int1_cell_paved int2_cell_share_sc int2_cell_share_st int2_cell_share_l6 int2_cell_share_lit int2_cell_primary int2_cell_phc int2_cell_phs int2_cell_tap int2_cell_power int2_cell_paved
	global int_cov_ind   	int1_female int1_twin int1_hindu int1_muslim int1_christian int1_sikh int1_buddhist int2_female int2_twin int2_hindu int2_muslim int2_christian int2_sikh int2_buddhist
	
	gen INT1=.
	gen INT2=.
	gen level=.
	
	*col 1
	global c=1
	replace INT1=int1_exp
	replace INT2=int2_exp
	replace level=exp
	eststo col1Tab6_`col': xtreg yvar ineq pol_comp inter level  INT1 INT2 $controls , fe cluster($cluster) 
	eststo col1

	*col 2-7
	
	*foreach v in poverty_pre66 urbanization population  sc st religion_frac_pre66 {
	foreach v in poverty_pre66 urbanization population  caste_frac  religion_frac share_lit{
	global c=$c +1
	replace INT1=int1PC_`v'
	replace INT2=int2PC_`v'
	replace level=`v'_pastSTD
	eststo col${c}Tab6_`col': xtreg  yvar ineq pol_comp inter exp  INT1 INT2  level  $controls, fe cluster($cluster)  
	}


	*Col 8
	global c=$c +1
	eststo col${c}Tab6_`col':  xtreg yvar ineq pol_comp inter exp  $controls ///
	int1_exp int2_exp ///
	int1PC_urbanization int2PC_urbanization urbanization_pastSTD ///
	int1PC_population int2PC_population  population_pastSTD  ///
	int1PC_caste_frac int2PC_caste_frac caste_frac_pastSTD ///
	int1PC_share_lit int2PC_share_lit share_lit_pastSTD ///
	int1PC_poverty_pre66 int2PC_poverty_pre66 poverty_pre66_pastSTD ///
	int1PC_religion_frac int2PC_religion_frac religion_frac_pastSTD ///
	 , fe cluster($cluster) 

	 *Col 9
	if $help_var == 1 {
	global c=$c +1
	eststo col${c}Tab6_`col': xtreg  yvar ineq pol_comp inter exp $controls $int_cov_area $int_cov_ind  , fe cluster($cluster) 
	}
	
	*Col 9
	if $help_var != 1 {
	global c=$c +1
	eststo col${c}Tab6_`col': xtreg  yvar ineq pol_comp inter exp $controls $int_cov_area , fe cluster($cluster) 
	}
	
	
}

label var ineq  "Inequality" 
label var pol_comp  "Political competition" 
label var inter  "Inequality X Political competition" 

}
}


	 
***************************************************
* Table 7: Alternative measures of inequality and political competition
***************************************************		

if $table7  == 1 {
qui {
	local ineq1="palma_pre66_past"
	local ineq2="meanlog_pre66_past"
	local ineq3="theil_pre66_past"
	local pol_comp1="min_vote_share_2004_past"
	local pol_comp2="min_margin_2004_past"
	local pol_comp3="effective_parties_2004_past"
	

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

	egen ineq1 = std(`ineq1') 
	egen ineq2 = std(`ineq2') 
	egen ineq3 = std(`ineq3') 
	egen pol_comp1 = std(`pol_comp1') 
	egen pol_comp2 = std(`pol_comp2') 
	egen pol_comp3 = std(`pol_comp3')
	
	gen pol_comp_help=pol_comp
	gen ineq_help=ineq
	forvalues p=1/3 {
	replace inter=ineq`p' * pol_comp
	replace ineq_help=ineq`p'
	eststo coli`p'Tab7_`col':  xtreg yvar ineq_help pol_comp_help inter exp $controls , fe cluster($cluster) 
	}
	
	replace ineq_help=ineq
	forvalues p=1/3 {
	replace inter=ineq * pol_comp`p'
	replace pol_comp_help=pol_comp`p'
	eststo colp`p'Tab7_`col': xtreg yvar ineq_help pol_comp_help inter exp $controls  , fe cluster($cluster) 
	}
}

label var ineq_help "Inequality" 
label var pol_comp_help  "Political competition" 
label var inter  "Inequality X Political competition" 
}

}








***************************************************
* DISPLAY TABLES
***************************************************

****
if $table2 ==1 {
*Table 2: Summary statistics
 mat list table2
}
	 
if $table3 ==1 {
*Table 3: Balance table
mat list table3
disp $F1
disp $F2
disp $F3	
} 

if $table4 ==1 {
* Table 4: Main results
noisily esttab  col1Tab1 col2Tab1 col3Tab1 col4Tab1 col5Tab1 col6Tab1,keep(ineq pol_comp inter) order(ineq pol_comp inter) se stats(N r2,fmt(%9.0fc %9.3f)) label nomtitles starlevels(* 0.10 ** 0.05 *** 0.01)  b(%8.4f)
}


if $table5 == 1 {
* Table 5: Placebo regressions
noisily esttab  col1Tab5 col2Tab5 col3Tab5 ,keep(ineq pol_comp inter) order(ineq pol_comp inter) se stats(N r2,fmt(%9.0fc %9.3f)) label nomtitles starlevels(* 0.10 ** 0.05 *** 0.01)  b(%8.4f)
}

if $table6 ==1 {
* Table 6: Horse race regressions
*Panel A
noisily esttab  col1Tab6_1 col2Tab6_1 col3Tab6_1 col4Tab6_1 col5Tab6_1 col6Tab6_1 col7Tab6_1 col8Tab6_1 col9Tab6_1,keep(ineq pol_comp inter) order(ineq pol_comp inter) se stats(N r2,fmt(%9.0fc %9.3f)) label nomtitles starlevels(* 0.10 ** 0.05 *** 0.01)  b(%8.4f)

*Panel B
noisily esttab  col1Tab6_2 col2Tab6_2 col3Tab6_2 col4Tab6_2 col5Tab6_2 col6Tab6_2 col7Tab6_2 col8Tab6_2 col9Tab6_2,keep(ineq pol_comp inter) order(ineq pol_comp inter) se stats(N r2,fmt(%9.0fc %9.3f)) label nomtitles starlevels(* 0.10 ** 0.05 *** 0.01)  b(%8.4f)

*Panel C
noisily esttab  col1Tab6_3 col2Tab6_3 col3Tab6_3 col4Tab6_3 col5Tab6_3 col6Tab6_3 col7Tab6_3 col8Tab6_3 col9Tab6_3,keep(ineq pol_comp inter) order(ineq pol_comp inter) se stats(N r2,fmt(%9.0fc %9.3f)) label nomtitles starlevels(* 0.10 ** 0.05 *** 0.01)  b(%8.4f)
}

if $table7  == 1 {
* Table 7: Alternative measures of inequality and political competition
*Panel A
noisily esttab  coli1Tab7_1 coli2Tab7_1 coli3Tab7_1  colp1Tab7_1 colp2Tab7_1 colp3Tab7_1,keep(ineq_help pol_comp_help inter) order(ineq_help pol_comp_help inter) se stats(N r2,fmt(%9.0fc %9.3f)) label nomtitles starlevels(* 0.10 ** 0.05 *** 0.01)  b(%8.4f)

*Panel B
noisily esttab  coli1Tab7_2 coli2Tab7_2 coli3Tab7_2  colp1Tab7_2 colp2Tab7_2 colp3Tab7_2,keep(ineq_help pol_comp_help inter) order(ineq_help pol_comp_help inter) se stats(N r2,fmt(%9.0fc %9.3f)) label nomtitles starlevels(* 0.10 ** 0.05 *** 0.01)  b(%8.4f)

*Panel C
noisily esttab  coli1Tab7_3 coli2Tab7_3 coli3Tab7_3  colp1Tab7_3 colp2Tab7_3 colp3Tab7_3,keep(ineq_help pol_comp_help inter) order(ineq_help pol_comp_help inter) se stats(N r2,fmt(%9.0fc %9.3f)) label nomtitles starlevels(* 0.10 ** 0.05 *** 0.01)  b(%8.4f)
}
