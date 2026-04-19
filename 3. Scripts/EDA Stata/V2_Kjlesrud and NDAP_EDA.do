capture log close
clear

cd "/Users/vidhi/college baby/sem 6/Topics in EconRes/FinalPaperMaterial"
log using V2_EDA.log, replace


**Data Exploration Breakdown**

**Nrega.dta**
use "Data for Political Competition Over Life and Death - Social Provision and Infant Mortality in India/ReplicationPackage/Datafiles/nrega.dta", clear

****Basic structure******
describe

tab year

tab state

//Unique GPs
egen gp_unique = tag(gp_id)
count if gp_unique == 1

//Unique pre vs post delimitation constituencies
* Count unique pre-delimitation constituencies
egen pre_tag = tag(pc_id_pre)
count if pre_tag == 1

* Count unique post-delimitation constituencies
egen post_tag = tag(pc_id_post)
count if post_tag == 1

* Average number of GPs per post-delimitation constituency
* First count GPs per constituency (using one year only to avoid triple counting)
bysort pc_id_post year: gen gp_count = _N
bysort pc_id_post: keep if year == 2011
summarize gp_count, detail

**Redistricting variable**
tab change_pc //share of redistricted GPs: 26.92% -> approx 1/4th of rural population --> shows amount of identifying variation available


**Political competition variable (fragmentation_2004_past)**
summarize fragmentation_2004_past, detail //report mean (should be around 0.62), standard deviation, min, max, and 25th/75th percentiles

histogram fragmentation_2004_past //describe the shape of the distribution, noting whether it is roughly bell-shaped or skewed
//slightly skewed to left


count if fragmentation_2004_past == . //report how many GPs lack a competition measure and whether this is a concern

*SC/ST population share controls*
summarize share_sc_past share_st_past, detail //report mean and standard deviation of SC and ST population shares at the constituency level
summarize cell_share_sc cell_share_st, detail //report the same at the cell level and compare — note whether cell-level variation is wider than constituency-level, which would indicate meaningful within-constituency heterogeneity


*Existing outcome variables (postbank and demand)*
summarize postbank, detail //report mean, standard deviation, and note extreme skewness; the mean should be around 775,559 rupees per the original paper
// hints at extreme skewness to the right as difference between standard deviation and mean is a lot

count if postbank == 0 //report what share of GP-years have zero disbursements, as this is a data quality issue worth flagging

summarize demand, detail //report the distribution of registered demand for work; this will be your placebo outcome variable



**District-Level MGNREGA Data**
clear all

import delimited using "MGNREGA Data/ZIP/6026/6026_source_data.csv", clear


*Basic structure*
**Report total number of observations, number of unique districts, number of states covered, and years available
d
duplicates report srcyear srcstatename srcdistrictname
distinct srcstatename

tab srcyear //report how observations are distributed across years
tab srcstatename //report state coverage and note whether it matches the 15 states in Nrega.dta or is broader/narrower

*Constructing and inspecting the outcome variable*
//Generate SC/ST employment share: 
gen scst_share = (totalpersondaysworkedscheduledca + totalpersondaysworkedscheduledtr) / totalpersondays

summarize scst_share, detail //report mean, standard deviation, min and max
count if scst_share > 1 | scst_share < 0 //check for impossible values indicating data errors, report how many and whether you drop them
 
histogram scst_share //describe the distribution shape; note whether it is roughly uniform or concentrated at particular values
//bysort srcstatename: summarize scst_share //report variation in SC/ST employment share across states, noting which states have the highest and lowest shares and whether this is consistent with known patterns of SC/ST population distribution

//right skewed with a spike at 1, making 1 the second highest frequency bin after soewhere near 0.3

*Constructing alternative outcome variables*
//Generate SC/ST job card share: 
gen scst_jobcard_share = (jobcardsissuedforscheduledcaste + jobcardsissuedforscheduledtribes) / jobcardsissued

summ scst_jobcard_share, detail
count if scst_jobcard_share > 1 | scst_jobcard_share < 0

*Checking data quality*
summ totalpersondays
count if totalpersondays == 0 //report share of district-years with zero total person-days; these are potential data quality issues
count if missing(scst_share) //report missing values in the outcome variable

//Check for districts that appear in some years but not others: if the panel is unbalanced, report which states or years have gaps
* 1. Count how many rows (years) exist for each State-District combo
bysort srcstatename srcdistrictname: gen year_count = _N

* 2. List the names where the count is NOT 10
* We use 'tag' so we only see each district name once in the results
egen district_tag = tag(srcstatename srcdistrictname)

list srcstatename srcdistrictname year_count if district_tag == 1 & year_count != 10

drop district_tag
drop year_count



**Key Numbers to Report in Your Write-Up**

//Compile these into a summary statistics table covering both datasets side by side where possible: number of observations, number of unique units, years covered, mean and standard deviation of the SC/ST employment share (district level), mean and standard deviation of political competition, mean SC/ST population share, share of redistricted GPs (Nrega.dta only), share of GP-years with zero disbursements, and match rate between datasets if you attempt any merging. This table gives your reader a complete picture of what data you are working with before you present any regression results.





log close
