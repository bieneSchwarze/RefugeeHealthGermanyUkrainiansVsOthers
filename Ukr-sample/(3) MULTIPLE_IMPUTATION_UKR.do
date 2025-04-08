* * Multiple imputation. Ukr

* Setting work direct and uplaoding data 


cd "Y:\abt-sop\MA\amarchitto\SUARE\Ukr_Ref_CS_2022_23\Ukr 2023"
capture log close
log using UKR_analysis_multiple_imputation.log, replace

use uks_2023_final_JUN_24.dta, replace

* taking only vars included into analysis
keep health_bin gender age_cut economsit_bef edu labfst_bef PTS traum_exp_bef_bin arrivalmonths accomodation residence_status land_partner children_germ_simplified labfst_now_new discr_bin germ_course german_proficiency_cut_new soc_isolation contact_ukrainians contact_germans 

* erase missing obs by the DV
drop if health_bin==.
		// n= 5,932


* * Imputing data

* Imputation data. with 5, 20 and 30 "add"

		// recoding gender --> binary (0,1)
		recode gender (1=0 "male") (2=1 "female"), gen(gender_1)


mi set flong

misstable summ gender_1 age_cut economsit_bef edu labfst_bef PTS traum_exp_bef_bin arrivalmonths accomodation residence_status land_partner children_germ_simplified discr_bin germ_course german_proficiency_cut_new soc_isolation contact_ukrainians contact_germans

mi register imputed gender_1 age_cut economsit_bef edu labfst_bef PTS traum_exp_bef_bin arrivalmonths accomodation residence_status land_partner children_germ_simplified discr_bin germ_course german_proficiency_cut_new soc_isolation contact_ukrainians contact_germans

mi impute chained (logit) gender_1 labfst_bef PTS traum_exp_bef_bin arrivalmonths germ_course discr_bin soc_isolation /// 
(ologit) age_cut economsit_bef edu german_proficiency_cut_new contact_ukrainians contact_germans ///
(mlogit) land_partner children_germ_simplified residence_status accomodation, add(30) rseed(1234) augment		

* saving imputed data in wd
save ukr_imputed_data.dta, replace


* ##############

use ukr_imputed_data.dta, clear

* M1_imputed
mi estimate, or post: logistic health_bin i.gender_1 i.age_cut i.economsit_bef i.edu i.labfst_bef
mi estimate, vartable nocitable
estimates store M1_imputed

* Model 2 (socio, ses, country of origin + pre-migration)
mi estimate, or post: logistic health_bin i.gender_1 i.age_cut i.economsit_bef i.edu i.labfst_bef i.PTS i.traum_exp_bef_bin
mi estimate, vartable nocitable
estimates store M2_imputed

* Model 3 (socio, ses, country of origin + post-migration)
mi estimate, or post: logistic health_bin i.gender_1 i.age_cut i.economsit_bef i.edu i.labfst_bef i.arrivalmonths i.accomodation i.residence_status i.land_partner i.children_germ_simplified i.discr_bin i.germ_course i.german_proficiency_cut_new i.soc_isolation i.contact_ukrainians i.contact_germans
mi estimate, vartable nocitable
estimates store M3_imputed

* Model 4 (full model)
mi estimate, or post: logistic health_bin i.gender_1 i.age_cut i.economsit_bef i.edu i.labfst_bef i.PTS i.traum_exp_bef_bin i.arrivalmonths i.accomodation i.residence_status i.land_partner i.children_germ_simplified i.discr_bin i.germ_course i.german_proficiency_cut_new i.soc_isolation i.contact_ukrainians i.contact_germans
mi estimate, vartable nocitable
estimates store M4_imputed

esttab M1_imputed M2_imputed M3_imputed M4_imputed, ci pr2 aic bic noomitted nobaselevel eform label compress

esttab M1_imputed M2_imputed M3_imputed M4_imputed, ci pr2 aic bic baselevel eform nolabel compress

esttab M1_imputed M2_imputed M3_imputed M4_imputed using UKR_RESULTS_IMPUTED.rtf, ///
	ci pr2 aic bic baselevel label ///
	refcat(0.gender_1 "Gender" ///
	0.age_cut "Age group" ///
	1.economsit_bef "Economic situation before flight" ///
	0.edu "Level of education" ///
	0.labfst_bef "Employed before flight" ///
	0.PTS "PTS" ///
	0.traum_exp_bef_bin "Traumatic experiences before flight" ///
	0.arrivalmonths "Time in Germany since arrival" ///
	1.accomodation "Type of accomodation" ///
	1.residence_status "Residence/asylum status" ///
	0.land_partner "Partner's living place" ///
	0.children_germ_simplified "Children living place" ///
	0.discr_bin "Perceived discrimination" ///
	0.germ_course "Attended German language/integration course" ///
	1.german_proficiency_cut_new "German language proficiency" ///
	0.soc_isolation "Feeling socially isolated" ///
	0.contact_ukrainians "Contact with Ukrainians(non-relative)" ///
	0.contact_germans "Contact with Germans", nolabel) eform compress replace 
	
* saving same coefplot inyto a graph folder (with all coefplots of the study)
global Graphs "I:\MA\amarchitto\SUARE\Ukr_Ref_CS_2022_23\Graphs-UKR-REF"

coefplot M4_imputed, bylabel(fully adjusted model M4) eform xline(1) xscale(log) legend(pos(6)) ms(oh) groups(*.gender *.age_cut *.economsit_bef *.edu *.labfst_bef = "SOCIO-DEMOGRAPHIC" *.PTS *.traum_exp_bef_bin = "PRE-MIGRATION FACTORS" *.arrivalmonths *.accomodation *.residence_status *.land_partner *.children_germ_simplified *.labfst_now_new *.discr_bin *.germ_course *.german_proficiency_cut_new *.soc_isolation *.contact_ukrainians *.contact_germans = "POST-MIGRATION FACTORS", labsize(tiny)) baselevel mlabel(cond(@pval<.001, "***", cond(@pval<.01, "**", cond(@pval<.05, "*", "")))) drop(_cons) coeflabels(, notick labsize(tiny)) headings(0.gender_1 = "{bf:Gender}" 0.age_cut = "{bf:Age group}" 1.economsit_bef ="{bf:Economic situation before flight}" 0.edu = "{bf:Level of education}" 0.labfst_bef = "{bf:Employed before flight}" 0.PTS = "{bf:PTS}" 0.traum_exp_bef_bin = "{bf:Traumatic experiences before flight}" 0.arrivalmonths = "{bf:Time in Germany since arrival}" 1.accomodation = "{bf:Type of accommodation}" 1.residence_status = "{bf:Residence/asylum status}" 0.land_partner = "{bf:Partner's living place}" 0.children_germ_simplified = "{bf:Children living place}" 0.discr_bin = "{bf:Perceived discrimination}" 0.germ_course = "{bf:Attended German language/integration course}" 1.german_proficiency_cut_new = "{bf:German language proficiency}" 0.soc_isolation = "{bf:Feeling socially isolated}" 0.contact_ukrainians = "{bf:Contact with Ukrainians(non-relative)}" 0.contact_germans = "{bf:Contact with Germans}", labsize(tiny)) play("ukr_coef_M4_imputed_edit") name(Ukr_M4_coefplot_imputed, replace)	

graph save $Graphs\Ukr_M4_coefplot_imputed, replace

* NEW GRAPH (Louise)

**UKRAINIAN SAMPLE
coefplot M4_imputed, eform xline(1) xscale(log) drop(_cons) ysize(15) baselevel ylab(, labsize(small)) xlabel(0.5 1 2 4 6) mcolor(black) ciopts(lcolor(black)) ///
	headings(0.gender_1 = "{bf:Gender}" 0.age_cut = "{bf:Age group}" 1.economsit_bef ="{bf:Economic situation before war}" 0.edu = "{bf:Education}" 0.labfst_bef = "{bf:Employed before flight}" 0.PTS = "{bf:PTS}" 0.traum_exp_bef_bin = "{bf:Traumatic experiences}" 0.arrivalmonths = "{bf:Time since arrival}" 1.accomodation = "{bf:Type of accommodation}" 1.residence_status = "{bf:Residence status}" 0.land_partner = "{bf:Partner's living place}" 0.children_germ_simplified = "{bf:Children's living place}" 0.discr_bin = "{bf:Perceived discrimination}" 0.germ_course = "{bf:German language course}" 1.german_proficiency_cut_new = "{bf:German language proficiency}" 0.soc_isolation = "{bf:Feeling alone}" 0.contact_ukrainians = "{bf:Contact: Ukrainians}" 0.contact_germans = "{bf:Contact: Germans}", labsize(small)) ///
	coeflabels (0.soc_isolation="no/ neutral" 1.soc_isolation="yes" 3.residence_status="permit according to TPD") ///
	groups(*.gender *.age_cut *.economsit_bef *.edu *.labfst_bef = "{bf: Sociodemographics}" *.PTS *.traum_exp_bef_bin = "{bf:Pre-migration factors}" *.arrivalmonths *.accomodation *.residence_status *.land_partner *.children_germ_simplified *.labfst_now_new *.discr_bin *.germ_course *.german_proficiency_cut_new *.soc_isolation *.contact_ukrainians *.contact_germans = "{bf:Post-migration factors}", angle(vertical) labsize(small))

graph save $Graphs\Ukr_M4_coefplot_imp_NEW, replace
		

		
* TEST MULTICOLLINEARITY
mi estimate, or post: logistic health_bin i.gender_1 i.age_cut i.economsit_bef i.edu i.labfst_bef i.PTS i.traum_exp_bef_bin i.arrivalmonths i.accomodation i.residence_status i.land_partner i.children_germ_simplified i.discr_bin i.germ_course i.german_proficiency_cut_new i.soc_isolation i.contact_ukrainians i.contact_germans

estimates store M4_imputed

collin gender_1 age_cut economsit_bef edu labfst_bef PTS traum_exp_bef_bin arrivalmonths accomodation residence_status land_partner children_germ_simplified discr_bin germ_course german_proficiency_cut_new soc_isolation contact_ukrainians contact_germans 

	
*###############################################################################


* uploading data for sensitivity analysis

clear all

cd "I:\MA\amarchitto\SUARE\Ukr_Ref_CS_2022_23\Ukr 2023"
	
use uks_2023_final_JUN_24.dta, clear

drop if health_bin==.
		// n = 5,932
 

 
* * Imputing data

* Imputation data. with 5, 20 and 30 "add"

		// recoding gender --> binary (0,1)
		recode gender (1=0 "male") (2=1 "female"), gen(gender_1)


mi set flong

misstable summ gender_1 age_cut economsit_bef edu labfst_bef PTS quintile_fatalities_cum_sw_1 traum_exp_bef_bin tertile_fatalities_cum_7days arrivalmonths accomodation residence_status land_partner children_germ_simplified discr_bin germ_course german_proficiency_cut_new soc_isolation contact_ukrainians contact_germans

mi register imputed gender_1 age_cut economsit_bef edu labfst_bef PTS quintile_fatalities_cum_sw_1 traum_exp_bef_bin tertile_fatalities_cum_7days arrivalmonths accomodation residence_status land_partner children_germ_simplified discr_bin germ_course german_proficiency_cut_new soc_isolation contact_ukrainians contact_germans

mi impute chained (logit) gender_1 labfst_bef PTS traum_exp_bef_bin arrivalmonths germ_course discr_bin soc_isolation /// 
(ologit) age_cut economsit_bef edu german_proficiency_cut_new contact_ukrainians contact_germans quintile_fatalities_cum_sw_1 tertile_fatalities_cum_7days ///
(mlogit) land_partner children_germ_simplified residence_status accomodation, add(30) rseed(1234) augment	

save ukr_imputed_data_sens_1.dta, replace

******** SENTIVITY ANALYSES - FINAL *********

use ukr_imputed_data_sens_1.dta, clear

* - 1 - ***** SA A --> main model M4 with replacement of ACLED fatalities in Quintile to PTS as pre-migration factor determining health 
mi estimate, or post: logistic health_bin i.gender_1 i.age_cut i.economsit_bef i.edu i.labfst_bef i.quintile_fatalities_cum_sw_1 i.traum_exp_bef_bin i.arrivalmonths i.accomodation i.residence_status i.land_partner i.children_germ_simplified i.discr_bin i.germ_course i.german_proficiency_cut_new i.soc_isolation i.contact_ukrainians i.contact_germans
mi estimate, vartable nocitable
estimates store SA_A_ukr_imputed

* - 2 - ***** SA B --> main model M4 with addition of ACLED fatalities post-migration (PTS as pre-migration factors)
mi estimate, or post: logistic health_bin i.gender_1 i.age_cut i.economsit_bef i.edu i.labfst_bef i.PTS i.traum_exp_bef_bin i.tertile_fatalities_cum_7days i.arrivalmonths i.accomodation i.residence_status i.land_partner i.children_germ_simplified i.discr_bin i.germ_course i.german_proficiency_cut_new i.soc_isolation i.contact_ukrainians i.contact_germans
mi estimate, vartable nocitable
estimates store SA_B_ukr_imputed

* - 4 - ***** SA D (UKR) --> main model M4 with new recoded self-rated health variable "health_bin_sens"
			* SA D Ukr
mi estimate, or post: logistic health_bin_sens i.gender_1 i.age_cut i.economsit_bef i.edu i.labfst_bef i.PTS i.traum_exp_bef_bin i.arrivalmonths i.accomodation i.residence_status i.land_partner i.children_germ_simplified i.discr_bin i.germ_course i.german_proficiency_cut_new i.soc_isolation i.contact_ukrainians i.contact_germans
mi estimate, vartable nocitable
estimates store SA_D_ukr_imputed

* ESTAB

esttab SA_A_ukr_imputed SA_B_ukr_imputed SA_D_ukr_imputed, ci pr2 aic bic  baselevel eform nolabel compress

esttab SA_A_ukr_imputed SA_B_ukr_imputed SA_D_ukr_imputed using FINAL_RESULTS_UKR_IMPUTED.rtf, ///
	ci pr2 aic bic baselevel label ///
	refcat(0.gender_1 "Gender" ///
	0.age_cut "Age group" ///
	1.economsit_bef "Economic situation before flight" ///
	0.edu "Level of education" ///
	0.labfst_bef "Employed before flight" ///
	0.PTS "PTS" ///
	1.quintile_fatalities_cum_sw_1 "Fatalities btw leaving UKR and war's start (quintile - only ukr)" ///
	0.traum_exp_bef_bin "Traumatic experiences before flight" ///
	1.tertile_fatalities_cum_7days "Fatalities 7 days before day of interview (tertile - only ukr)" ///
	0.arrivalmonths "Time in Germany since arrival" ///
	1.accomodation "Type of accommodation (ukr)" ///
	1.residence_status "Residence/asylum status" ///
	0.land_partner "Partner's living place" ///
	0.children_germ_simplified "Children living place" ///
	1.labfst_now_new "Labor force status (now)" ///
	0.discr_bin "Perceived discrimination" ///
	0.germ_course "Attended German language/integration course (ukr)" ///
	1.german_proficiency_cut_new "German language proficiency" ///
	0.soc_isolation "Feeling socially isolated" ///
	0.contact_ukrainians "Contact with Ukrainians(non-relative)" ///
	0.contact_germans "Contact with Germans", nolabel) eform compress replace 
	

	
*##############################################################################


* new dependent vqariable: concerned about own health situation	
clear all

cd "I:\MA\amarchitto\SUARE\Ukr_Ref_CS_2022_23\Ukr 2023"
	
use uks_2023_final_JUN_24.dta, replace

	
* NEW SENSITIVITY ANALYSES for Ukrainians and Other refugees
	
					* preliminary adjument/addition/modifying of variables before analysis 
					
* sensitivity analysis with new outcome vars (Sorgen um Ihre Gesundheit): var in ukr sample "pukr89_2"
drop _merge

merge 1:1 pid syear using "G:\consolidated\soep-ukr\finaldata\ukr-pl.dta", keepusing(pukr89_2)
keep if _merge==3
drop _merge

* create new outocme variable: "Concerned of health situation"
tab pukr89_2
mvdecode pukr89_2, mv(-8/-1)
fre pukr89_2
recode pukr89_2 (1=1 "very concerned") (2 3=0 "little concerned/not at all"), gen(health_concerned_bin)
lab var health_concerned_bin "Being concerned of my health situation"	


tab health_concerned_bin, m
	// missings= 14
	
drop if health_concerned_bin==.

* * Imputing data

* Imputation data. with 5, 20 and 30 "add"

		// recoding gender --> binary (0,1)
		recode gender (1=0 "male") (2=1 "female"), gen(gender_1)


mi set flong

misstable summ gender_1 age_cut economsit_bef edu labfst_bef PTS traum_exp_bef_bin arrivalmonths accomodation residence_status land_partner children_germ_simplified discr_bin germ_course german_proficiency_cut_new soc_isolation contact_ukrainians contact_germans

mi register imputed gender_1 age_cut economsit_bef edu labfst_bef PTS traum_exp_bef_bin arrivalmonths accomodation residence_status land_partner children_germ_simplified discr_bin germ_course german_proficiency_cut_new soc_isolation contact_ukrainians contact_germans

mi impute chained (logit) gender_1 labfst_bef PTS traum_exp_bef_bin arrivalmonths germ_course discr_bin soc_isolation /// 
(ologit) age_cut economsit_bef edu german_proficiency_cut_new contact_ukrainians contact_germans ///
(mlogit) land_partner children_germ_simplified residence_status accomodation, add(30) rseed(1234) augment	

* save
save ukr_imputed_data_sens_2, replace

******** SENTIVITY ANALYSES - FINAL concerned... *********

* - 3 - ***** SA C --> [source==0] main model M4 run with new outcome variable: concerend of my health-situation
mi estimate, or post: logistic health_concerned_bin i.gender_1 i.age_cut i.economsit_bef i.edu i.labfst_bef i.PTS i.traum_exp_bef_bin i.arrivalmonths i.accomodation i.residence_status i.land_partner i.children_germ_simplified i.discr_bin i.germ_course i.german_proficiency_cut_new i.soc_isolation i.contact_ukrainians i.contact_germans
mi estimate, vartable nocitable
estimates store SA_C_ukr_imputed	


esttab SA_C_ukr_imputed, ci pr2 aic bic  baselevel eform nolabel compress

esttab SA_C_ukr_imputed using FINAL_RESULTS_UKR_Concerned_IMPUTED.rtf, ///
	ci pr2 aic bic baselevel label ///
	refcat(0.gender_1 "Gender" ///
	0.age_cut "Age group" ///
	1.economsit_bef "Economic situation before flight" ///
	0.edu "Level of education" ///
	0.labfst_bef "Employed before flight" ///
	0.PTS "PTS" ///
	0.traum_exp_bef_bin "Traumatic experiences before flight" ///
	0.arrivalmonths "Time in Germany since arrival" ///
	1.accomodation "Type of accommodation (ukr)" ///
	1.residence_status "Residence/asylum status" ///
	0.land_partner "Partner's living place" ///
	0.children_germ_simplified "Children living place" ///
	0.discr_bin "Perceived discrimination" ///
	0.germ_course "Attended German language/integration course (ukr)" ///
	1.german_proficiency_cut_new "German language proficiency" ///
	0.soc_isolation "Feeling socially isolated" ///
	0.contact_ukrainians "Contact with Ukrainians(non-relative)" ///
	0.contact_germans "Contact with Germans", nolabel) eform compress replace 
	
	
capture log close




* final dataset, not imputed
use uks_2023_final_JUN_24.dta, replace

* model 4, not imputed
logistic health_bin i.gender i.age_cut i.economsit_bef i.edu i.labfst_bef i.PTS i.traum_exp_bef_bin i.arrivalmonths i.accomodation i.residence_status i.land_partner i.children_germ_simplified i.discr_bin i.germ_course i.german_proficiency_cut_new i.soc_isolation i.contact_ukrainians i.contact_germans
estimates store M4	

*##############################################################################
* estab final

esttab SA_A_ukr_imputed SA_B_ukr_imputed SA_C_ukr_imputed SA_D_ukr_imputed M4, ci pr2 aic bic  baselevel eform nolabel compress

esttab SA_A_ukr_imputed SA_B_ukr_imputed SA_C_ukr_imputed SA_D_ukr_imputed M4 using FINAL_RESULTS_UKR_PAPER.rtf, ///
	ci pr2 aic bic baselevel label ///
	refcat(0.gender_1 "Gender" ///
	1.gender "Gender" ///
	0.age_cut "Age group" ///
	1.economsit_bef "Economic situation before flight" ///
	0.edu "Level of education" ///
	0.labfst_bef "Employed before flight" ///
	0.PTS "PTS" ///
	1.quintile_fatalities_cum_sw_1 "Fatalities btw leaving UKR and war's start (quintile - only ukr)" ///	
	0.traum_exp_bef_bin "Traumatic experiences before flight" ///
	1.tertile_fatalities_cum_7days "Fatalities 7 days before day of interview (tertile - only ukr)" ///	
	0.arrivalmonths "Time in Germany since arrival" ///
	1.accomodation "Type of accommodation (ukr)" ///
	1.residence_status "Residence/asylum status" ///
	0.land_partner "Partner's living place" ///
	0.children_germ_simplified "Children living place" ///
	0.discr_bin "Perceived discrimination" ///
	0.germ_course "Attended German language/integration course (ukr)" ///
	1.german_proficiency_cut_new "German language proficiency" ///
	0.soc_isolation "Feeling socially isolated" ///
	0.contact_ukrainians "Contact with Ukrainians(non-relative)" ///
	0.contact_germans "Contact with Germans", nolabel) eform compress replace 
	
	
	
capture log close	



*****************************
*****************************

*****************************
*****************************

*****************************
*****************************
*  ADDITIONAL SENSITIVITY ANALYSIS --> on MULTIPLE_IMPUTATION_UKR_extra_sensitivity_analyses.do

use uks_2023_final_JUN_24.dta, clear

* taking only vars included into analysis and insert interactionsterms
	// gender_1  *  soc_isolation
	// age_cut   *  soc_isolation
	// gender_1  *  discr_bin
	// age_cut   *  discr_bin
	// gender_1  *  german_proficiency_cut_new
	// age_cut   *  german_proficiency_cut_new

keep health_bin gender age_cut economsit_bef edu labfst_bef PTS traum_exp_bef_bin arrivalmonths accomodation residence_status land_partner children_germ_simplified labfst_now_new discr_bin germ_course german_proficiency_cut_new soc_isolation contact_ukrainians contact_germans 

* erase missing obs by the DV
drop if health_bin==.
		// n= 5,932


* * Imputing data

* Imputation data. with 5, 20 and 30 "add"

		// recoding gender --> binary (0,1)
		recode gender (1=0 "male") (2=1 "female"), gen(gender_1)

* manually create interactions terms

	* gender * scoial isolation --> 4 caegories [in mi impute chianed: mlogit]
egen gender_isolation = group(gender_1 soc_isolation)
lab var gender_isolation "Gender # Feeling socially isolated"
lab def gender_isolation 1 "male - does not apply(at all)/neutral pos." 2 "male - applies(fully)" 3 "female - does not apply(at all)/neutral pos." 4 "female - applies(fully)"
lab values gender_isolation gender_isolation

	* gender * discrimination --> 4 caegories [in mi impute chianed: mlogit]
egen gender_discrimination = group(gender_1 discr_bin)
lab var gender_discrimination "Gender # Perceived discrimination"
lab def gender_discrimination 1 "male - never" 2 "male - seldomly/often" 3 "female - never" 4 "female - seldomly/often"
lab values gender_discrimination gender_discrimination

	* gender * german proficiency --> 6 caegories [in mi impute chianed: mlogit]
egen gender_german = group(gender_1 german_proficiency_cut_new)
lab var gender_german "Gender # German language proficiency"
lab def gender_german 1 "male - none/poor" 2 "male - sufficient" 3 "male - good/excellent" 4 "female - none/poor" 5 "female - sufficient" 6 "female - good/excellent"
lab values gender_german gender_german

	* age * sociale isolation --> 6 caegories [in mi impute chianed: ologit]
egen age_isolation = group(age_cut soc_isolation)
lab var age_isolation "Age group # Feeling socially isolated"
lab def age_isolation 1 "18-30 - does not apply(at all)/neutral pos." 2 "18-30 - applies(fully)" 3 "31-49 - does not apply(at all)/neutral pos." 4 "31-49 - applies(fully)" 5 "50+ - does not apply(at all)/neutral pos." 6 "50+ - applies(fully)"
lab values age_isolation age_isolation

	* age * discrimination --> 6 caegories [in mi impute chianed: ologit]
egen age_discrimination = group(age_cut discr_bin)
lab var age_discrimination "Age group # Perceived discrimination"
lab def age_discrimination 1 "18-30 - never" 2 "18-30 - seldomly/often" 3 "31-49 - never" 4 "31-49 - seldomly/often" 5 "50+ - never" 6 "50+ - seldomly/often"
lab values age_discrimination age_discrimination

	* age * german proficiency
egen age_german = group(age_cut german_proficiency_cut_new)
lab var age_german "Age group # German language proficiency"
lab def age_german 1 "18-30 - none/poor" 2 "18-30 - sufficient" 3 "18-30 - good/excellent" 4 "31-49 - none/poor" 5 "31-49 - sufficient" 6 "31-49 - good/excellent" 7 "50+ - none/poor" 8 "50+ - sufficient" 9 "50+ - good/excellent"
lab values age_german age_german

mi set mlong

misstable summ gender_1 age_cut economsit_bef edu labfst_bef PTS traum_exp_bef_bin arrivalmonths accomodation residence_status land_partner children_germ_simplified discr_bin germ_course german_proficiency_cut_new soc_isolation contact_ukrainians contact_germans gender_isolation gender_discrimination gender_german age_isolation age_discrimination age_german


mi register imputed gender_1 age_cut economsit_bef edu labfst_bef PTS traum_exp_bef_bin arrivalmonths accomodation residence_status land_partner children_germ_simplified discr_bin germ_course german_proficiency_cut_new soc_isolation contact_ukrainians contact_germans gender_isolation gender_discrimination gender_german age_isolation age_discrimination age_german


mi impute chained (logit) gender_1 labfst_bef PTS traum_exp_bef_bin arrivalmonths germ_course discr_bin soc_isolation /// 
(ologit) age_cut economsit_bef edu german_proficiency_cut_new contact_ukrainians contact_germans age_isolation age_discrimination age_german gender_isolation gender_discrimination gender_german ///
(mlogit) land_partner children_germ_simplified residence_status accomodation , add(30) rseed(1234) augment noisily	
* saving imputed data in wd
save ukr_imputed_data_interaction.dta, replace


use ukr_imputed_data_interaction.dta, clear


* Model 4 (full model) + interaction terms
mi estimate, or post: logistic health_bin i.gender_1 i.age_cut i.economsit_bef i.edu i.labfst_bef i.PTS i.traum_exp_bef_bin i.arrivalmonths i.accomodation i.residence_status i.land_partner i.children_germ_simplified i.discr_bin i.germ_course i.german_proficiency_cut_new i.soc_isolation i.contact_ukrainians i.contact_germans i.gender_isolation i.age_isolation i.gender_discrimination i.age_discrimination i.gender_german i.age_german 
mi estimate, vartable nocitable
estimates store M4_imputed_interaction

esttab M4_imputed_interaction, ci pr2 aic bic noomitted nobaselevel eform label compress

esttab M4_imputed_interaction, ci pr2 aic bic baselevel eform nolabel compress

esttab M4_imputed_interaction using UKR_RESULTS_IMPUTED_INTERACTIONS.rtf, ///
	ci pr2 aic bic baselevel label ///
	refcat(0.gender_1 "Gender" ///
	0.age_cut "Age group" ///
	1.economsit_bef "Economic situation before flight" ///
	0.edu "Level of education" ///
	0.labfst_bef "Employed before flight" ///
	0.PTS "PTS" ///
	0.traum_exp_bef_bin "Traumatic experiences before flight" ///
	0.arrivalmonths "Time in Germany since arrival" ///
	1.accomodation "Type of accomodation" ///
	1.residence_status "Residence/asylum status" ///
	0.land_partner "Partner's living place" ///
	0.children_germ_simplified "Children living place" ///
	0.discr_bin "Perceived discrimination" ///
	0.germ_course "Attended German language/integration course" ///
	1.german_proficiency_cut_new "German language proficiency" ///
	0.soc_isolation "Feeling socially isolated" ///
	0.contact_ukrainians "Contact with Ukrainians(non-relative)" ///
	0.contact_germans "Contact with Germans", nolabel) eform compress replace 

	
	
	
***** 


* ALTERNATIVE	

*  ADDITIONAL SENSITIVITY ANALYSIS

use uks_2023_final_JUN_24.dta, clear

* taking only vars included into analysis and insert interactionsterms
	// gender_1  *  soc_isolation
	// age_cut   *  soc_isolation
	// gender_1  *  discr_bin
	// age_cut   *  discr_bin
	// gender_1  *  german_proficiency_cut_new
	// age_cut   *  german_proficiency_cut_new

keep health_bin gender age_cut economsit_bef edu labfst_bef PTS traum_exp_bef_bin arrivalmonths accomodation residence_status land_partner children_germ_simplified labfst_now_new discr_bin germ_course german_proficiency_cut_new soc_isolation contact_ukrainians contact_germans 

* erase missing obs by the DV
drop if health_bin==.
		// n= 5,932


* * Imputing data

* Imputation data. with 5, 20 and 30 "add"

		// recoding gender --> binary (0,1)
		recode gender (1=0 "male") (2=1 "female"), gen(gender_1)	

* imputing data
		
mi set flong

misstable summ gender_1 age_cut economsit_bef edu labfst_bef PTS traum_exp_bef_bin arrivalmonths accomodation residence_status land_partner children_germ_simplified discr_bin germ_course german_proficiency_cut_new soc_isolation contact_ukrainians contact_germans

mi register imputed gender_1 age_cut economsit_bef edu labfst_bef PTS traum_exp_bef_bin arrivalmonths accomodation residence_status land_partner children_germ_simplified discr_bin germ_course german_proficiency_cut_new soc_isolation contact_ukrainians contact_germans

mi impute chained (logit) gender_1 labfst_bef PTS traum_exp_bef_bin arrivalmonths germ_course discr_bin soc_isolation /// 
(ologit) age_cut economsit_bef edu german_proficiency_cut_new contact_ukrainians contact_germans ///
(mlogit) land_partner children_germ_simplified residence_status accomodation, add(30) rseed(1234) augment		