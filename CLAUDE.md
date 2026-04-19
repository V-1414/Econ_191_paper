# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an economics research project examining **political competition's effect on MGNREGA (India's rural employment guarantee) outcomes**, with attention to equity for Scheduled Castes (SCs) and Scheduled Tribes (STs). The primary empirical strategy leverages constituency delimitation changes as a source of variation in political competition.

## Tools

- **Stata 17+** — main statistical analysis (`.do` files in `3. Scripts/EDA Stata/`)
- **Python (pandas, matplotlib, seaborn)** — data cleaning and EDA (Jupyter notebooks in `3. Scripts/`)
- **VS Code workspace** — open `3. Scripts/FinalPaperMaterial.code-workspace` to get a two-folder view (`FinalPaperMaterial/` and `2. Data/1. Raw/`)

## Repository Layout

```
1. Literature/        — reference papers
2. Data/
   1. Raw/            — source datasets (never modify)
   2. Interim/        — intermediate cleaned files (outputs of cleaning scripts)
   3. Processed/      — analysis-ready datasets
   4. Scraped/
3. Scripts/
   EDA Stata/         — Stata .do files
   *.ipynb            — Python notebooks for cleaning and EDA
4. Outputs/           — tables, figures
```

## Key Datasets

| File | Source | Unit | N | Notes |
|------|--------|------|---|-------|
| `nrega.dta` | Kjelsrud replication | Gram Panchayat × year | 451,231 | 15 states, 2011–2017; contains `fragmentation_2004_past` (political competition) and `change_ac` (delimitation flag) |
| `mortality.dta` | Kjelsrud / NFHS 2015-16 | Infant | 204,893 | Parliamentary Constituency–level political controls |
| `healthcare.dta` | Kjelsrud / DLHS 2012-13 | Primary Health Centre | 11,381 | |
| `Employment Generated.csv` | India Data Portal | GP × year | 2,642,550 | 2014–2024; has duplicate GP-year rows — resolve with `max()` aggregation |
| `Category Wise Workers.csv` | India Data Portal | GP × year | ~265k/yr | Caste- and gender-disaggregated job card data |
| `6026_source_data.csv` | NDAP | District × year | — | 10 years per state-district combination expected |
| `TCPD_GE_All_States_2026-3-20.csv` | TCPD | Election | — | State assembly and general election results |
| Mittal files | Mittal | Panchayat / district | — | SC/ST equity and inequity indices; cross-walk via `panchayat_ID_MIS_index_mapping.csv` |

## Running Stata Scripts

To replicate Kjelsrud et al. tables/figures exactly:
```stata
do "2. Data/1. Raw/Kjelsrud/ReplicationPackage/Analysis.do"
```

EDA scripts (run in order):
```stata
do "3. Scripts/EDA Stata/V1_NDAP EDA.do"
do "3. Scripts/EDA Stata/V2_Kjlesrud and NDAP_EDA.do"
```

## Key Data Quirks

- **`Employment Generated.csv` duplicates:** GP-year combinations can have multiple rows, some with zero values. The cleaning logic drops zero-value rows first, then aggregates with `max()` for remaining conflicts.
- **`nrega.dta` flag mismatch:** ~294 observations have `change_ac == 1` but no actual constituency change — flag inconsistency to investigate before using as instrument.
- **District name collisions in NDAP:** 40 district names appear in multiple states; always merge on `state × district`, never district alone.
- **Mittal cross-walk coverage:** Only 115,223 of 217,930 panchayats in the mapping file have a non-null MIS index — expect ~47% missing when joining to MIS-based data.
- **Outcome variable `postbank`:** MGNREGA person-days in rupees; highly right-skewed — consider log transformation.

## Identification Strategy

The paper exploits **constituency delimitation (2008 Delimitation Act)** as a source of exogenous variation in political competition. `change_ac` in `nrega.dta` flags GPs whose parliamentary constituency boundary changed. `fragmentation_2004_past` measures pre-delimitation political fragmentation and is the key independent variable.
