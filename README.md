# RefugeeHealthGermanyUkrainiansVsOthers
Repository for source code of statistical analysis for the manuscript "Pre- and post-migration determinants of self-rated health among Ukrainian refugees in Germany: a cross-sectional comparative analysis with recently arrived refugees from other countries of origi

This repository contains the Stata source code for the analyses conduted in the above manuscript by Louise Biddle, Andrea Marchitto, Sabine Zinn.

Used data: SOEP v38.1 SUF (sample: IAB-BAMF-SOEP sample; M3-6 and M9)

Source Files Stata v18:
A. Analysis for Ukrainian refugee sample:
(1) Create ALCED data for analyses: ACLED data_importing and cleaning - APR_24.do
(2) Data loading, cleaning, generation, and main analysis (complete cases): Ukraine-sample_2023_JUN_24.do
(3) Data loading, cleaning, generation, and main analysis (with multiple imputation): MULTIPLE_IMPUTATION_UKR.do
(4) Sensitivity checks: MULTIPLE_IMPUTATION_UKR_extra_sensitivity_analyses.do
B. Analysis for non-Ukrainian refugee sample:
(1) Prepare PTS data for analyses: PTS_preparing_do _file.do
(2) Data loading, cleaning, generation, and main analysis (complete cases): Refugee-sample_2021_JAN.do
(3) Data loading, cleaning, generation, and main analysis (with multiple imputation): MULTIPLE_IMPUTATION_REF.do
(4) Sensitivity checks: MULTIPLE_IMPUTATION_REF_extra_sensitivity_analyses.do
