* ============================================================
* GP-Level Analysis: Political Competition and SC/ST Targeting
* in MGNREGA
*
* Replication of GP_level_analysis.ipynb (analysis sections only).
* Requires: gp_analysis_dataset.csv  (saved from Section 15 of notebook)
*
* FE strategy:  pc_dist (pre-delimitation PC x district, ~1,260 levels)
* SE:           clustered at pc_dist level
* Treatment:    fragmentation_std  (political competition, 1-SD standardised)
*
* Requires reghdfe and ftools:
*   ssc install reghdfe
*   ssc install ftools
* ============================================================

clear all
set more off

* ── Set path to the analysis dataset ─────────────────────────────────────────
* Edit DATA_PATH to point to wherever you saved gp_analysis_dataset.csv
global DATA_PATH "/Users/vidhi/VSCODE/Econ_191_paper/FinalPaperMaterial copy/2. Data/3. Processed/gp_analysis_dataset.csv"

* ── Load data ─────────────────────────────────────────────────────────────────
import delimited using "${DATA_PATH}", clear

* ── Variable labels ───────────────────────────────────────────────────────────
label variable ln_sc_targeting      "Log SC Targeting Ratio (winsorised)"
label variable ln_st_targeting      "Log ST Targeting Ratio (winsorised)"
label variable ln_scst_targeting    "Log SC+ST Targeting Ratio (winsorised)"
label variable fragmentation_std    "Political Competition (standardised)"
label variable fragmentation_std_sq "Political Competition Squared (EC^2)"
label variable pc_dist              "Pre-delim PC x District FE cell"
label variable change_pc            "Reshuffled by 2008 Delimitation (=1)"
label variable in_st_sample         "ST sub-sample: ST pop share >= 5% (=1)"
label variable has_sc_outcome       "SC log outcome non-missing (=1)"
label variable share_l6_past        "Children under-6 share"
label variable share_lit_past       "Literacy rate"
label variable poverty_pre66_past   "Poverty headcount"
label variable ln_population        "Log rural population"
label variable urbanization_past    "Urbanisation rate"
label variable primary_past         "Primary school available (=1)"
label variable phc_past             "PHC available (=1)"
label variable paved_past           "Paved road available (=1)"
label variable power_past           "Electricity available (=1)"

* ── Describe sample ───────────────────────────────────────────────────────────
di "Total GPs in dataset: " _N
count if has_sc_outcome == 1
di "GPs with SC outcome:  " r(N)
count if in_st_sample == 1
di "GPs in ST sub-sample: " r(N)

* ── Controls local macro ──────────────────────────────────────────────────────
local controls share_l6_past share_lit_past poverty_pre66_past  ///
               ln_population urbanization_past                  ///
               primary_past phc_past paved_past power_past

* ============================================================
* SECTION 11: Main Regressions  (with controls)
* ============================================================

* (1) SC targeting ratio
di _newline "=== (1) SC Targeting ==="
reghdfe ln_sc_targeting fragmentation_std `controls', ///
    absorb(pc_dist) vce(cluster pc_dist)

* (2) ST targeting ratio  — ST sub-sample only (ST pop share >= 5%)
di _newline "=== (2) ST Targeting (ST pop >= 5%) ==="
reghdfe ln_st_targeting fragmentation_std `controls' ///
    if in_st_sample == 1, absorb(pc_dist) vce(cluster pc_dist)

* (3) SC+ST targeting ratio
di _newline "=== (3) SC+ST Targeting ==="
reghdfe ln_scst_targeting fragmentation_std `controls', ///
    absorb(pc_dist) vce(cluster pc_dist)

* ============================================================
* SECTION 11c: Quadratic Specification — ST Targeting
* Y = b0 + b1*EC + b2*EC^2 + controls + FE
* Turning point: EC_std* = -b1 / (2*b2)
* ============================================================

di _newline "=== (4) ST Targeting — Quadratic in EC ==="
reghdfe ln_st_targeting fragmentation_std fragmentation_std_sq `controls' ///
    if in_st_sample == 1, absorb(pc_dist) vce(cluster pc_dist)

* Report turning point
local b1 = _b[fragmentation_std]
local b2 = _b[fragmentation_std_sq]
if abs(`b2') > 1e-10 {
    local tp = -`b1' / (2 * `b2')
    di "Turning point  EC_std* = " %6.3f `tp'
}

* ============================================================
* SECTION 14: Robustness — No Controls
* ============================================================

di _newline "=== (5) SC Targeting — No Controls ==="
reghdfe ln_sc_targeting fragmentation_std, ///
    absorb(pc_dist) vce(cluster pc_dist)

di _newline "=== (6) ST Targeting — No Controls (ST pop >= 5%) ==="
reghdfe ln_st_targeting fragmentation_std ///
    if in_st_sample == 1, absorb(pc_dist) vce(cluster pc_dist)

di _newline "=== (7) SC+ST Targeting — No Controls ==="
reghdfe ln_scst_targeting fragmentation_std, ///
    absorb(pc_dist) vce(cluster pc_dist)

* ============================================================
* OPTIONAL: Export results table with estout
* (uncomment if estout is installed: ssc install estout)
* ============================================================

/*
eststo clear
quietly reghdfe ln_sc_targeting fragmentation_std `controls', ///
    absorb(pc_dist) vce(cluster pc_dist)
eststo m1

quietly reghdfe ln_st_targeting fragmentation_std `controls' ///
    if in_st_sample == 1, absorb(pc_dist) vce(cluster pc_dist)
eststo m2

quietly reghdfe ln_scst_targeting fragmentation_std `controls', ///
    absorb(pc_dist) vce(cluster pc_dist)
eststo m3

esttab m1 m2 m3 using "gp_regression_results.rtf", replace   ///
    keep(fragmentation_std)                                   ///
    b(3) se(3) star(* 0.1 ** 0.05 *** 0.01)                  ///
    title("Effect of Political Competition on SC/ST MGNREGA Targeting") ///
    mtitles("SC" "ST (pop>=5%)" "SC+ST")                     ///
    addnotes("FE: pc_dist (pre-delim PC x district)" ///
             "SE clustered at pc_dist level")
*/
