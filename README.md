# RefugeeHealthGermanyUkrainiansVsOthers
Repository for source code of statistical analysis for the manuscript "Pre- and post-migration determinants of self-rated health among Ukrainian refugees in Germany: a cross-sectional comparative analysis with recently arrived refugees from other countries of origi

This repository contains the Stata source code for the analyses conduted in the above manuscript by Louise Biddle, Andrea Marchitto, Sabine Zinn.

Used data: SOEP v38.1 SUF (sample: IAB-BAMF-SOEP sample; M3-6 and M9)

Source Files Stata v18:
<p>
<strong>A. Analysis for Ukrainian refugee sample (folder Ukr-sample):</strong><br>
(1) Create ACLED data for analyses: <em>ACLED_data_importing_and_cleaning-APR_24.do</em><br>
(2) Data loading, cleaning, generation, and main analysis (complete cases): <em>Ukraine-sample_2023_JUN_24.do</em><br>
(3) Data loading, cleaning, generation, and main analysis (with multiple imputation): <em>MULTIPLE_IMPUTATION_UKR.do</em><br>
(4) Sensitivity checks: <em>MULTIPLE_IMPUTATION_UKR_extra_sensitivity_analyses.do</em>
</p>

<p>
<strong>B. Analysis for non-Ukrainian refugee sample (folder Ref-sample):</strong><br>
(1) Prepare PTS data for analyses: <em>PTS_preparing_do_file.do</em><br>
(2) Data loading, cleaning, generation, and main analysis (complete cases): <em>Refugee-sample_2021_JAN.do</em><br>
(3) Data loading, cleaning, generation, and main analysis (with multiple imputation): <em>MULTIPLE_IMPUTATION_REF.do</em><br>
(4) Sensitivity checks: <em>MULTIPLE_IMPUTATION_REF_extra_sensitivity_analyses.do</em>
</p>
