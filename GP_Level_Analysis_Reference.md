# GP-Level Analysis: Political Competition and SC/ST Targeting in MGNREGA
## Complete Reference Document

---

## 1. Research Question

**Does higher political competition lead to more equitable targeting of MGNREGA benefits towards Scheduled Castes (SCs) and Scheduled Tribes (STs)?**

The outcome of interest is the **targeting ratio** — the ratio of a group's share of MGNREGA person-days to its share of the rural population. A ratio > 1 means the group receives more than its population-proportionate share (over-represented); < 1 means under-representation. Three versions are estimated: SC-only, ST-only, and combined SC+ST.

---

## 2. Identification Strategy

### 2.1 Background: Kjelsrud et al. (2024)

This analysis piggybacks directly on the identification strategy of Kjelsrud, Moene and Vandewalle (2024), *"Political Competition Over Life and Death: Social Provision and Infant Mortality in India"*.

Their core insight is that the **2008 Delimitation Act** — which redrew India's 543 parliamentary constituency boundaries — provides a quasi-natural experiment. Before delimitation, a set of Gram Panchayats (GPs) all belonged to the same parliamentary constituency. After delimitation, some of those GPs were reassigned to new constituencies while others stayed. Because the new constituency a GP ended up in was determined by a mechanical boundary-drawing process (not by the GP's own characteristics), the level of political competition in the post-delimitation constituency is plausibly exogenous to local outcomes.

The key identifying comparison is therefore:

> *Among GPs that were previously in the same pre-delimitation constituency (and same district), compare outcomes between those that ended up in more politically competitive post-delimitation constituencies versus those that ended up in less competitive ones.*

This controls for all pre-delimitation constituency-level confounders through fixed effects, leaving only the post-delimitation variation in political competition to identify the effect.

### 2.2 Kjelsrud's MGNREGA Specification (Equation 3)

$$E_{j,l,k,t} = \alpha_0 + \beta_1 \text{Ineq}_l + \beta_2 \text{EC}_l + \beta_3 (\text{Ineq}_l \times \text{EC}_l) + \beta_4 \bar{y}_l + \gamma_{k \times d, t} + \Gamma X_{j,l,k} + \varepsilon_{j,l,k,t}$$

**Subscripts:** j = GP, l = post-delimitation PC, k = pre-delimitation PC, d = district, t = fiscal year.

| Symbol | Meaning |
|---|---|
| $E_{j,l,k,t}$ | MGNREGA disbursement (rupees) in GP j, year t |
| $\text{Ineq}_l$ | Gini coefficient of post-delim PC l (2009-10 NSS) |
| $\text{EC}_l$ | Political competition of post-delim PC l: 1 − HHI of 2004 vote shares |
| $\bar{y}_l$ | Mean expenditure in post-delim PC l |
| $\gamma_{k \times d, t}$ | **Pre-delim PC × district × year fixed effects** (column `pc_dist` in nrega.dta, interacted with year) |
| $X_{j,l,k}$ | GP-level area controls from Census 2001: literacy, SC/ST shares, children-under-6, amenities |

SEs are clustered at the **district × pre-delimitation PC** (`pc_dist`) level.

His main interest is β₃ (the interaction between inequality and competition). His two treatment variables are inequality and political competition and their interaction.

### 2.3 This Paper's Adaptation

Three changes from Kjelsrud's MGNREGA specification:

1. **Outcome changes**: from total MGNREGA disbursement → log SC/ST targeting ratio
2. **Treatment simplifies**: drop inequality (Gini) and its interaction with EC, keep only political competition `EC_l`
3. **Time dimension drops**: Mittal's person-day data is time-averaged (no year t), so the year dimension in the FE is removed — the analysis is cross-sectional across GPs

Everything else — the FE structure, the control set, the clustering, the sample — follows Kjelsrud directly.

### 2.4 Critical Clarification on Fixed Effects

The FE must be the **pre-delimitation PC** (or pre-delim PC × district), **not** a joint (pre-delim PC, post-delim PC) cell.

**Why:** Political competition `EC_l` is a property of the post-delimitation PC l. Every GP within the same (pre-delim PC, post-delim PC) pair shares the exact same value of `EC_l` — so a joint (pre-delim, post-delim) FE would be perfectly collinear with `EC_l` and kill all identification. The variation that identifies β comes from GPs in the same *pre*-delim PC that were assigned to *different* post-delim PCs with *different* competition levels. This requires the FE to be at the pre-delim PC level only.

Kjelsrud interacts the pre-delim PC FE with district (because districts are the key administrative unit for MGNREGA implementation). This `pc_dist` variable is pre-computed in `nrega.dta` and should be used directly as the FE.

**In nrega.dta:** `pc_dist` = pre-delimitation PC × district cell (1,260 unique values across the 14-state sample).

---

## 3. Regression Specification

$$\ln\!\left(\text{TargetingRatio}_j\right) = \alpha + \beta \cdot \text{EC}_l + \Gamma X_j + \gamma_{\texttt{pc\_dist}} + \varepsilon_j$$

Estimated separately for three outcomes: SC targeting ratio, ST targeting ratio, SC+ST targeting ratio.

### 3.1 Outcome Variable Construction

**Targeting ratio for group G in GP j:**

$$\text{TargetingRatio}_{G,j} = \frac{\text{Person-days worked by G in GP j} \,/\, \text{Total person-days in GP j}}{\text{Population of G in GP j} \,/\, \text{Total rural population in GP j}}$$

- **= 1**: group receives exactly its population-proportionate share  
- **> 1**: over-represented (better-than-proportionate targeting)  
- **< 1**: under-represented

The ratio is **winsorised at the 1st and 99th percentiles** before log-transforming to limit the influence of outliers and data entry errors. After log-transforming, any remaining −∞ values (from log(0) when the winsorise floor is zero for ST in districts with near-zero ST population) are replaced with NaN.

**For the ST-only ratio:** Restrict to GPs where the ST rural population share ≥ 5%. In GPs with near-zero ST population, a tiny fluctuation in person-days produces enormous ratio swings; those observations are noise rather than signal.

### 3.2 Treatment Variable

**`fragmentation_2004_past`** from `nrega.dta`: political competition of the post-delimitation parliamentary constituency that GP j belongs to, measured as 1 − HHI of candidate vote shares in the April-May 2004 general election. Higher values = more competitive.

This is **standardised** (subtract mean, divide by SD) before entering the regression, following Kjelsrud, so the coefficient is interpretable as the effect of a one-standard-deviation increase in political competition.

The 2004 election is used (not a later election) because:
- It pre-dates the Commission's work (which started July 2004), so it could not have been influenced by anticipation of delimitation
- Kjelsrud demonstrates competition is persistent across electoral cycles

### 3.3 Fixed Effects

`pc_dist` (pre-delimitation PC × district), already computed in `nrega.dta` as a categorical identifier. Absorbed using within-transformation (demeaning) or dummy variables. This is a 1,260-level categorical FE.

### 3.4 Controls

All controls come from `nrega.dta` directly (Census-based, no additional data needed). They capture within-`pc_dist`-cell GP-level variation in characteristics that independently affect MGNREGA utilisation by SCs/STs:

| Variable in nrega.dta | Meaning | Rationale |
|---|---|---|
| `share_l6_past` | Share of children under 6 | Proxy for household labour supply and MGNREGA demand |
| `share_lit_past` | Literacy rate | Awareness of rights; ability to navigate application process |
| `poverty_pre66_past` | Poverty headcount | Structural demand for the programme |
| `ln(population_past)` | Log rural population | GP size affects absolute and per-capita allocation |
| `urbanization_past` | Urbanisation rate | Programme utilisation differs even within rural sample |
| `primary_past` | Primary school availability (binary) | Baseline amenity access = state capacity |
| `phc_past` | PHC availability (binary) | Baseline health/admin infrastructure |
| `paved_past` | Paved road availability (binary) | Physical access to worksites |
| `power_past` | Electricity availability (binary) | Proxy for general infrastructure development |

**Do NOT include `share_sc_past` or `share_st_past` as controls.** SC/ST population share is already in the denominator of the targeting ratio. Including it as a regressor would mechanically partial out the denominator and distort the coefficient on political competition.

### 3.5 Standard Errors

Clustered at the `pc_dist` (pre-delimitation PC × district) level — the level of the fixed effect and the unit at which the treatment varies. This follows Kjelsrud exactly.

---

## 4. Data Sources and Linkage

### 4.1 Overview

Five files are needed. The linking key is `gp_id` (Kjelsrud's internal GP identifier, 1–151,660):

```
nrega.dta                           gp_id_names.dta
[gp_id, pc_dist, EC, controls]  +   [gp_id → gpname, state, district, block]
        |                                       |
        └───────────────┬───────────────────────┘
                        │ gp_id (exact)
                        ▼
              Working GP-level panel
                        │
                        │ name match on (state, district, gp_name)
                        ▼
        Mittal mis_avg_sc_st_data.csv           panchayat_category.csv
        [person-days SC/ST/other per GP]    +   [SC/ST/total population per GP]
              (numerator of ratio)               (denominator of ratio)
```

### 4.2 File Details

| File | Path | Key columns | Role |
|---|---|---|---|
| `nrega.dta` | `Kjelsrud/ReplicationPackage/Datafiles/nrega.dta` | `gp_id`, `state`, `district2011`, `pc_id_pre`, `pc_id_post`, `pc_dist`, `fragmentation_2004_past`, `change_pc`, `share_l6_past`, `share_lit_past`, `poverty_pre66_past`, `population_past`, `urbanization_past`, `primary_past`, `phc_past`, `paved_past`, `power_past` | Treatment, FE, and all controls |
| `gp_id_names.dta` | `Kjelsrud/gp_id_names.dta` | `gp_id`, `gpname`, `state2011`, `district2011`, `cdblock2011` | Bridge from gp_id to GP name for name-matching |
| `mis_avg_sc_st_data.csv` | `Mittal/mis_avg_sc_st_data.csv` | `state`, `district`, `block`, `panchayat`, `emp_provided_persondays_sc`, `emp_provided_persondays_st`, `emp_provided_persondays_oth` | **Numerator** of targeting ratio (averaged person-days by caste group) |
| `panchayat_category.csv` | `Mittal/panchayat_category.csv` | `State`, `District`, `Subdistrict`, `Panchayat`, `SC population`, `ST population`, `Total population` | **Denominator** of targeting ratio (rural population by caste group) |
| SHRUG `shrid_loc_names.csv` + `pc11r_shrid_key.csv` | `SHRUG/shrug-shrid-keys-csv/` and `SHRUG/shrug-pc-keys-csv/` | `pc11_state_id`, `pc11_district_id`, `state_name`, `district_name` | Crosswalk from numeric `state2011`/`district2011` codes in gp_id_names → human-readable names for Mittal matching |

### 4.3 Step-by-Step Linkage

**Step 1 — Build name crosswalk from numeric codes**  
`gp_id_names.dta` has numeric `state2011` and `district2011` (Census 2011 national codes). Mittal uses string names. Use SHRUG's `pc11r_shrid_key.csv` + `shrid_loc_names.csv` to build a lookup table mapping each `(state2011, district2011)` → `(state_name, district_name)`. Merge onto `gp_id_names` to get `(gp_id, state_name, district_name, gpname)` with all strings lowercased and stripped.

**Step 2 — Match Mittal mis_avg to gp_id**  
Merge `gp_id_names` (with string names) to `mis_avg_sc_st_data.csv` on `(state_name, district_name, gp_name)` — exact string match after lowercasing. Expected match rate: ~78.4% of gp_ids (118,919 / 151,660). Handle duplicate matches (10,659 gp_ids match to more than one Mittal row) by also requiring block name match: add `cdblock2011` → block name mapping if available, otherwise resolve duplicates by taking the row with the highest total person-days (most complete record).

**Step 3 — Match panchayat_category to gp_id**  
Same procedure: match `panchayat_category.csv` to `gp_id_names` on `(state_name, district_name, gp_name)`. This gives SC/ST population counts for the targeting ratio denominator.

**Step 4 — Merge everything onto nrega.dta**  
`nrega.dta` is a GP × year panel (3 years). Since the outcome is time-averaged, collapse nrega.dta to one row per gp_id (taking the mean of time-varying variables or keeping the single value of time-invariant ones). Then merge Steps 2 and 3 onto this collapsed GP-level frame by `gp_id`.

**Step 5 — Construct targeting ratios**  
```
sc_pd_share   = emp_provided_persondays_sc / (sc + st + oth person-days)
st_pd_share   = emp_provided_persondays_st / (sc + st + oth person-days)
scst_pd_share = (sc + st) / (sc + st + oth person-days)

sc_pop_share   = SC population / Total population
st_pop_share   = ST population / Total population
scst_pop_share = (SC + ST population) / Total population

sc_targeting_ratio   = sc_pd_share / sc_pop_share
st_targeting_ratio   = st_pd_share / st_pop_share
scst_targeting_ratio = scst_pd_share / scst_pop_share
```
Winsorise at 1st–99th percentile; log-transform; replace log(0) = −∞ with NaN.

**Step 6 — Standardise treatment**  
```
fragmentation_std = (fragmentation_2004_past − mean) / SD
```

### 4.4 About `cdblock2011`

The `cdblock2011` column in `gp_id_names.dta` is **Kjelsrud's internal sequential block numbering** (1–1,098), not the national Census LGD block code. It cannot be directly joined to any external dataset. It is only useful for resolving duplicate gp_id → Mittal matches when two GPs in the same district have the same name but are in different blocks (requires mapping Mittal's `block` column to Kjelsrud's internal block numbering — feasible if block names in Mittal match the block names in the original MGNREGA scrape that Kjelsrud used).

---

## 5. Sample Restrictions

Following Kjelsrud:
- **14 states** (Census 2011 state codes: 3, 6, 9, 10, 19, 21, 22, 23, 24, 27, 28, 29, 32, 33): Punjab, Haryana, Uttar Pradesh, Bihar, West Bengal, Odisha, Chhattisgarh, Madhya Pradesh, Gujarat, Maharashtra, Andhra Pradesh, Karnataka, Kerala, Tamil Nadu
- **Rural areas only** (MGNREGA is a rural programme; Mittal population data is for rural panchayats)
- **ST analysis only**: Restrict to GPs where ST rural population share ≥ 5% (removes ~60% of GPs where near-zero ST denominator makes the ratio uninformative)
- **Matched GPs only**: GPs where both person-day data (Mittal mis_avg) and population data (panchayat_category) were successfully name-matched (~78% coverage; check that unmatched GPs are not systematically different on `change_pc` or `fragmentation`)

---

## 6. Expected Identification and Interpretation

### 6.1 Main identifying assumption

Conditional on the `pc_dist` fixed effect (pre-delimitation PC × district), the assignment of a GP to a post-delimitation PC with a particular level of political competition is unrelated to unobserved determinants of SC/ST targeting in that GP. Kjelsrud validates this with two balance tests: (i) GPs that changed constituency do not differ significantly from those that did not on a wide range of Census observables; (ii) pre-Delimitation placebo outcomes are unpredicted by post-Delimitation competition.

### 6.2 Interpreting β

The coefficient β on `fragmentation_std` is approximately a percentage change (log outcome, standardised treatment): a one-SD increase in political competition is associated with a β × 100% change in the targeting ratio.

- **β > 0**: more competitive constituencies → higher SC/ST targeting ratio (over-representation). Consistent with mobilisation theory: competitive politicians target SC/ST voters to turn out their base.
- **β < 0**: more competitive constituencies → lower targeting ratio. Consistent with swing-voter theory: tight races incentivise broad-based provision rather than targeted redistribution to marginalised groups.
- **β ≈ 0**: no detectable relationship between political competition and SC/ST targeting equity after conditioning on pre-delimitation PC characteristics.

### 6.3 Why this is not fully causal

The Delimitation IV as originally designed identifies the effect of **political competition** through the quasi-random reallocation of GPs to constituencies. In this adaptation, that interpretation holds with one caveat: because the Mittal person-day data is time-averaged over an unspecified window (likely ~2009–2015), we cannot rule out that the average captures some pre-delimitation dynamics. The cleanest causal claim is that the results reflect the post-2008 political equilibrium.

---

## 7. Key Variables Summary Table

| Variable | Source column | File | Type | Notes |
|---|---|---|---|---|
| `ln_sc_targeting` | Constructed | — | Outcome | Log of winsorised SC targeting ratio |
| `ln_st_targeting` | Constructed | — | Outcome | Log of winsorised ST targeting ratio; ST pop ≥ 5% only |
| `ln_scst_targeting` | Constructed | — | Outcome | Log of winsorised SC+ST targeting ratio |
| `fragmentation_std` | `fragmentation_2004_past` | nrega.dta | Treatment | Standardised; from post-delim PC's 2004 election |
| `pc_dist` | `pc_dist` | nrega.dta | FE | Pre-delim PC × district cell; 1,260 unique values |
| `change_pc` | `change_pc` | nrega.dta | Diagnostic | = 1 if GP changed constituency in 2008 Delimitation |
| `pc_id_pre` | `pc_id_pre` | nrega.dta | Identifier | Pre-delimitation parliamentary constituency ID |
| `pc_id_post` | `pc_id_post` | nrega.dta | Identifier | Post-delimitation parliamentary constituency ID |
| `share_l6_past` | `share_l6_past` | nrega.dta | Control | Share of children under 6 |
| `share_lit_past` | `share_lit_past` | nrega.dta | Control | Literacy rate |
| `poverty_pre66_past` | `poverty_pre66_past` | nrega.dta | Control | Poverty headcount |
| `ln_population` | `population_past` (log) | nrega.dta | Control | Log rural population |
| `urbanization_past` | `urbanization_past` | nrega.dta | Control | Urbanisation rate |
| `primary_past` | `primary_past` | nrega.dta | Control | Primary school availability |
| `phc_past` | `phc_past` | nrega.dta | Control | PHC availability |
| `paved_past` | `paved_past` | nrega.dta | Control | Paved road availability |
| `power_past` | `power_past` | nrega.dta | Control | Electricity availability |
| `emp_provided_persondays_sc` | same | mis_avg_sc_st_data.csv | Raw | SC person-days (averaged across years) |
| `emp_provided_persondays_st` | same | mis_avg_sc_st_data.csv | Raw | ST person-days (averaged across years) |
| `emp_provided_persondays_oth` | same | mis_avg_sc_st_data.csv | Raw | Other person-days (averaged across years) |
| `SC population` | same | panchayat_category.csv | Raw | GP-level SC rural population |
| `ST population` | same | panchayat_category.csv | Raw | GP-level ST rural population |
| `Total population` | same | panchayat_category.csv | Raw | GP-level total rural population |

---

## 8. Limitations to Flag

1. **Time-averaged outcome**: Mittal's person-days are averaged across an unconfirmed window. Cannot run a panel regression or include year FEs. Cannot run Kjelsrud's placebo test (pre-Delimitation outcomes) for MGNREGA.

2. **Name-matching noise**: ~22% of gp_ids are unmatched. If unmatched GPs are systematically less competitive or more SC/ST-concentrated, estimates will be biased. Report a balance table comparing matched vs. unmatched GPs on `fragmentation_std`, `change_pc`, `share_sc_past`, `share_st_past`.

3. **Numerator vs. denominator data vintage mismatch**: Mittal person-days are post-2008 (approximately); panchayat population is from Census 2011. Minor mismatch but both are appropriate for measuring the post-Delimitation period.

4. **No person-days for 2011–2013**: Unlike Kjelsrud's outcome (disbursement 2011–2014), the Mittal data covers a longer averaged window. Results should be interpreted as long-run average targeting equity in the post-Delimitation period, not as a specific year-on-year treatment effect.

5. **Cross-sectional identification only**: Without time variation, cannot use within-GP changes as an additional source of identification. The estimate of β relies entirely on cross-GP within-`pc_dist` variation.
