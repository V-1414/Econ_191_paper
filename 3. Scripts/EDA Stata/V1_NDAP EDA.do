clear

cd "/Users/vidhi/college baby/sem 6/Topics in EconRes/FinalPaperMaterial/MGNREGA Data"


//loading the data
import delimited using "ZIP/6026/6026_source_data.csv", clear


**************************
*Checking Key identifiers*
**************************

*** does total number of rows = state x district x year? ***

	* 1. Get total number of observations
	count
	local total_obs = r(N)

	* 2. Get the number of values that appear exactly once
	quietly duplicates report srcyear srcstatename srcdistrictname
	local unique_obs = r(unique_value)

	* 3. Compare
	if `total_obs' == `unique_obs' {
		display "This is the unique key. N_unique_obs: `unique_obs' "
	}

*** Are there any district names that are the same for two diff states? Or could we directly use district for unique key? ***
	duplicates report srcyear srcdistrictname
	return list

	/*  
	there's 6288 districts that appear only once in a year, and 80 observations for districts that appear 2 times in a year.
	So 80/2 = 40 districts appear twice in a year. 
	Total (in this case unique) rows are 6368, and total unique districts are 6288 + (80/2 = 40) = 6328. 
	This suggests some district names probably overlap across states.
	*/

* Listing only the 40 district names that are repeated:
	duplicates list srcyear srcdistrictname if srcyear == "2011-12"

* Checking which states share these districts

	* 1. Create a tag for any combination that appears more than once
	duplicates tag srcyear srcdistrictname, gen(is_dup)

	* 2. List the variables only for the specific year AND where a duplicate exists
	list srcyear srcstatename srcdistrictname if is_dup > 0 & srcyear == "2011-12", ///
		sepby(srcdistrictname) noobs
		
	* 3. Clean up
	drop is_dup
	
	/* 
	So, UP shares BALRAMPUR and HAMIRPUR,Chhattisgarh shares BALRAMPUR and BILASPUR, 
	Himachal shares BILASPUR, and Rajasthan shares Pratapgarh.
	Effectively we have 4 states that share 4 districts in total (because there are two states that share two districts)
	*/

****************************
*Checking Year availability*
****************************

duplicates report srcstatename srcdistrictname



*********REVISE **********

* 1. Count how many rows (years) exist for each State-District combo
bysort srcstatename srcdistrictname: gen year_count = _N

* 2. List the names where the count is NOT 10
* We use 'tag' so we only see each district name once in the results
egen district_tag = tag(srcstatename srcdistrictname)

list srcstatename srcdistrictname year_count if district_tag == 1 & year_count != 10

drop district_tag
drop year_count







************************************************************
* MGNREGA DATA EXPLORATION
* Organized by exploration category
************************************************************

************************************************************
* 0. SETUP: CONSTRUCT KEY VARIABLES
************************************************************

* Construct SC/ST person-days and employment share
gen persondays_scst = totalpersondaysworkedscheduledca + totalpersondaysworkedscheduledtr
gen scst_share = persondays_scst / totalpersondays

* Flag extreme values
gen share_zero = (scst_share == 0)
gen share_one  = (scst_share == 1)

* Numeric year for time series plotting
gen year_num = yearcode

************************************************************
* 1. OUTCOME VARIABLE QUALITY
************************************************************

* --- Distribution of SC/ST employment share ---
sum scst_share, detail
hist scst_share, bin(40) title("Distribution of SC/ST Employment Share") ///
    xtitle("SC/ST Share of Person-Days") freq
	
//left skewed, with a weird spike at 1

* --- Zeros and ones ---
tab share_zero
tab share_one

* List extreme cases
list srcstatename srcdistrictname srcyear scst_share ///
    if share_zero == 1 | share_one == 1

* --- Compare employment share to job card share (proxy for population share) ---
* Job card share as rough proxy for SC/ST population presence in the district
gen scst_jobcard_share = (jobcardsissuedforscheduledcaste + jobcardsissuedforscheduledtribes) / jobcardsissued

* Scatter: employment share vs job card share
scatter scst_share scst_jobcard_share, ///
    title("SC/ST Employment Share vs Job Card Share") ///
    xtitle("SC/ST Job Card Share") ytitle("SC/ST Employment Share") ///
    msize(small) mlcolor(none) mfcolor(navy%40)

* Flag implausible cases: employment share >> job card share
gen implausible = (scst_share > scst_jobcard_share + 0.2) & !missing(scst_share)
tab implausible
list srcstatename srcdistrictname srcyear scst_share scst_jobcard_share ///
    if implausible == 1, sep(0)

* --- Missing values across all 44 variables ---
* Count missings per variable
foreach v of varlist * {
    qui count if missing(`v')
    if r(N) > 0 di "Missing in `v': " r(N)
}

* Are missings concentrated in particular states or years?
egen nmiss = rowmiss(scst_share totalpersondays persondays_scst)
tab srcstatename if nmiss > 0
tab srcyear if nmiss > 0

************************************************************
* 2. TEMPORAL PATTERNS
************************************************************

* --- Average SC/ST share over time ---
preserve
    collapse (mean) scst_share (sd) sd_scst=scst_share, by(year_num)
    twoway (connected scst_share year_num) ///
        (rcap scst_share sd_scst year_num, lcolor(gs10)), ///
        title("Mean SC/ST Employment Share Over Time") ///
        xtitle("Year") ytitle("Mean SC/ST Share") ///
        legend(order(1 "Mean" 2 "±1 SD"))
restore

* --- Check J&K missing years ---
list srcstatename srcdistrictname srcyear yearcode ///
    if srcstatename == "Jammu And Kashmir" | srcstatename == "Ladakh", sep(0)

* Are J&K districts systematically different in baseline (pre-2019)?
gen jk = (srcstatename == "Jammu And Kashmir" | srcstatename == "Ladakh")
ttest scst_share if yearcode <= 2019, by(jk)

************************************************************
* 3. CROSS-SECTIONAL & WITHIN VARIATION
************************************************************

* --- Overall variance decomposition: within vs between ---
* Install xtsum if needed: ssc install xtsum
encode srcdistrictname, gen(dist_id)  // create numeric district ID

* Create a unique district ID that accounts for state (since names repeat)
egen dist_state_id = group(srcstatename srcdistrictname)
xtset dist_state_id year_num
xtsum scst_share   // reports overall, between, and within SD

* --- State-level averages: which states have highest/lowest SC/ST share ---
preserve
    collapse (mean) scst_share, by(srcstatename)
    gsort -scst_share
    list srcstatename scst_share, sep(0) noobs
restore

* --- Bar chart of state means ---
preserve
    collapse (mean) scst_share, by(srcstatename)
    graph hbar scst_share, over(srcstatename, sort(1) label(labsize(tiny))) ///
        title("Mean SC/ST Employment Share by State") ///
        ytitle("Mean SC/ST Share")
restore

************************************************************
* 4. PROGRAM-LEVEL SANITY CHECKS
************************************************************

* --- Total person-days over time (is program growing/shrinking?) ---
preserve
    collapse (sum) totalpersondays persondays_scst, by(year_num)
    twoway (connected totalpersondays year_num) ///
           (connected persondays_scst year_num), ///
        title("Total vs SC/ST Person-Days Over Time") ///
        xtitle("Year") ytitle("Person-Days (sum across districts)") ///
        legend(order(1 "Total" 2 "SC/ST"))
restore

* --- Rising SC/ST share while total employment collapses? ---
* Year-on-year change in total person-days
xtset dist_state_id year_num
gen d_totaldays = D.totalpersondays
gen d_scst_share = D.scst_share

* Are changes in share correlated with level changes in total employment?
pwcorr d_scst_share d_totaldays, sig

* Flag districts where share rose but total employment fell significantly
gen diverge = (d_scst_share > 0.05) & (d_totaldays < -100000)
tab diverge
list srcstatename srcdistrictname srcyear d_scst_share d_totaldays ///
    if diverge == 1, sep(0)

* --- Verify we have BOTH numerator and denominator ---
* Confirm no obs where total person days = 0 but SC/ST days > 0
count if totalpersondays == 0 & persondays_scst > 0
count if totalpersondays == 0
count if persondays_scst == 0 & totalpersondays > 0

************************************************************
* 5. NON-UNIQUE DISTRICT NAMES (KEY IDENTIFIER CHECK)
************************************************************

* Identify which district names appear in multiple states
preserve
    keep srcstatename srcdistrictname
    duplicates drop
    bysort srcdistrictname: gen n_states = _N
    keep if n_states > 1
    sort srcdistrictname srcstatename
    list, sep(0) noobs
restore

* Confirm dist_state_id is truly unique at district level
* (should equal number of unique districts)
distinct dist_state_id
distinct srcdistrictname   // will be lower if names repeat across states

************************************************************
* 6. BALANCE CHECK: PANEL COMPLETENESS
************************************************************

* How many year-observations per district?
bysort dist_state_id: gen obs_count = _N
tab obs_count

* Which districts have fewer than 10 observations?
preserve
    bysort dist_state_id: keep if _n == 1
    list srcstatename srcdistrictname obs_count if obs_count < 10, sep(0) noobs
restore

* Confirm total N
count   // should be 6,368
distinct dist_state_id   // number of unique districts

************************************************************
* 7. SUMMARY STATISTICS TABLE (for write-up)
************************************************************

* Key variables to report in paper
local keyvars scst_share scst_jobcard_share totalpersondays ///
              persondays_scst totalpersonda~a totalpersonda~r

estpost sum `keyvars', detail
esttab using summary_stats.csv, cells("mean sd min p25 p50 p75 max count") ///
    replace label title("Summary Statistics")
