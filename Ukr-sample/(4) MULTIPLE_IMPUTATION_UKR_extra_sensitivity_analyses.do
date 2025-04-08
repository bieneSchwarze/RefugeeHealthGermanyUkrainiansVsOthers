* * Multiple imputation. Ukr extra sensitivity analyses

* Setting work direct and uplaoding data 


cd "Y:\abt-sop\MA\amarchitto\SUARE\Ukr_Ref_CS_2022_23\Ukr 2023"

*****************************
*****************************

*****************************
*****************************

*****************************
*****************************
*  ADDITIONAL SENSITIVITY ANALYSIS


* 1) adding arriving cohorts



use uks_2023_final_JUN_24.dta, replace


tab datearrival
* migration cohort pre 31 May 2022 and post 31 may 2022
gen migr_cohorts = .
replace migr_cohorts = 0 if datearrival <= mdy(5,31,2022)
replace migr_cohorts = 1 if datearrival > mdy(5,31,2022)
lab var migr_cohorts "Migration cohorts"
lab def migr_cohorts  0 "arrived until 31May2022" 1 "arrived after 31May2022"


* taking only vars included into analysis
keep health_bin gender age_cut economsit_bef edu labfst_bef PTS traum_exp_bef_bin arrivalmonths accomodation residence_status land_partner children_germ_simplified labfst_now_new discr_bin germ_course german_proficiency_cut_new soc_isolation contact_ukrainians contact_germans migr_cohorts

* erase missing obs by the DV
drop if health_bin==.
		// n= 5,932


* * Imputing data

* Imputation data. with 5, 20 and 30 "add"

		// recoding gender --> binary (0,1)
		recode gender (1=0 "male") (2=1 "female"), gen(gender_1)


mi set flong

misstable summ gender_1 age_cut economsit_bef edu labfst_bef PTS traum_exp_bef_bin arrivalmonths accomodation residence_status land_partner children_germ_simplified discr_bin germ_course german_proficiency_cut_new soc_isolation contact_ukrainians contact_germans migr_cohorts

mi register imputed gender_1 age_cut economsit_bef edu labfst_bef PTS traum_exp_bef_bin arrivalmonths accomodation residence_status land_partner children_germ_simplified discr_bin germ_course german_proficiency_cut_new soc_isolation contact_ukrainians contact_germans migr_cohorts

mi impute chained (logit) gender_1 labfst_bef PTS traum_exp_bef_bin arrivalmonths germ_course discr_bin soc_isolation migr_cohorts /// 
(ologit) age_cut economsit_bef edu german_proficiency_cut_new contact_ukrainians contact_germans ///
(mlogit) land_partner children_germ_simplified residence_status accomodation, add(30) rseed(1234) augment		

* saving imputed data in wd
save ukr_imputed_data_kohort.dta, replace


* ##############

use ukr_imputed_data_kohort.dta, clear


* Model 4 (full model + kohort)
mi estimate, or post: logistic health_bin i.gender_1 i.age_cut i.economsit_bef i.edu i.labfst_bef i.PTS i.traum_exp_bef_bin i.arrivalmonths i.accomodation i.residence_status i.land_partner i.children_germ_simplified i.discr_bin i.germ_course i.german_proficiency_cut_new i.soc_isolation i.contact_ukrainians i.contact_germans i.migr_cohorts
mi estimate, vartable nocitable
estimates store M4_imputed

esttab M4_imputed, ci pr2 aic bic noomitted nobaselevel eform label compress

esttab M4_imputed, ci pr2 aic bic baselevel eform nolabel compress

esttab M4_imputed using UKR_RESULTS_IMPUTED_KOHORT.rtf, ///
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
	0.contact_germans "Contact with Germans" ///
	0.migr_cohorts "Migration cohorts", nolabel) eform compress replace 

*******


* 2) Interaction terms 


	* 1. option - uploading already imputed stored data main model m4 
	
use ukr_imputed_data.dta, clear	

mi estimate, or post: logistic health_bin i.gender_1 i.age_cut i.economsit_bef i.edu i.labfst_bef i.PTS i.traum_exp_bef_bin i.arrivalmonths i.accomodation i.residence_status i.land_partner i.children_germ_simplified i.discr_bin i.germ_course i.german_proficiency_cut_new i.soc_isolation i.contact_ukrainians i.contact_germans i.gender_1#i.(soc_isolation discr_bin german_proficiency_cut_new) i.age_cut#i.(soc_isolation discr_bin german_proficiency_cut_new)
mi estimate, vartable nocitable
estimates store M4_imputed_interactions_alternative
	// r(459) estimation sample varies between m=1 and m=2; click here for details
	
	
		* --> 1. omitting interaction gender * german proficiency
mi estimate, or post: logistic health_bin i.gender_1 i.age_cut i.economsit_bef i.edu i.labfst_bef i.PTS i.traum_exp_bef_bin i.arrivalmonths i.accomodation i.residence_status i.land_partner i.children_germ_simplified i.discr_bin i.germ_course i.german_proficiency_cut_new i.soc_isolation i.contact_ukrainians i.contact_germans i.gender_1#i.(soc_isolation discr_bin) i.age_cut#i.(soc_isolation discr_bin german_proficiency_cut_new)
mi estimate, vartable nocitable
estimates store M4_imputed_interactions_alternative	
	// r(459) estimation sample varies between m=1 and m=2; click here for details

	
		* --> 2. omitting interaction gender * german proficiency and age_cut * german proficiency     OK
mi estimate, or post: logistic health_bin i.gender_1 i.age_cut i.economsit_bef i.edu i.labfst_bef i.PTS i.traum_exp_bef_bin i.arrivalmonths i.accomodation i.residence_status i.land_partner i.children_germ_simplified i.discr_bin i.germ_course i.german_proficiency_cut_new i.soc_isolation i.contact_ukrainians i.contact_germans i.gender_1#i.(soc_isolation discr_bin) i.age_cut#i.(soc_isolation discr_bin)
mi estimate, vartable nocitable
estimates store M4_imputed_interactions
	
esttab M4_imputed_interactions using UKR_RESULTS_IMPUTED_new_interactions.rtf, ///
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
	

* counting frequencies imputed data

	* gender language proficiency (imputed data)
	asdoc tab gender_1 german_proficiency_cut_new, replace
	asdoc tab gender_1 german_proficiency_cut_new, m replace
	
	* by gender: health and language proficiency (imputed data)
	asdoc bys gender_1: tab health_bin german_proficiency_cut_new, replace
	asdoc bys gender_1: tab health_bin german_proficiency_cut_new, m replace
	
* --- *	
	
	* age group language proficiency (imputed data)
	asdoc tab age_cut german_proficiency_cut_new, replace
	asdoc tab age_cut german_proficiency_cut_new, m replace
	
	* by age group: health and language proficiency (imputed data)
	asdoc bys age_cut: tab health_bin german_proficiency_cut_new, replace
	asdoc bys age_cut: tab health_bin german_proficiency_cut_new, m replace
	

* counting frequencies not imputed data	

cd "Y:\abt-sop\MA\amarchitto\SUARE\Ukr_Ref_CS_2022_23\Ukr 2023"

use uks_2023_final_JUN_24.dta, replace

drop if health_bin==.
	
	* gender language proficiency (not imputed data)
	asdoc tab gender german_proficiency_cut_new, m replace
	
	* by gender: health and language proficiency (not imputed data)
	asdoc bys gender: tab health_bin german_proficiency_cut_new, m replace
	
* --- *	
	
	* age group language proficiency (not imputed data)
	asdoc tab age_cut german_proficiency_cut_new, m replace
	
	* by age group: health and language proficiency (not imputed data)
	asdoc bys age_cut: tab health_bin german_proficiency_cut_new, m replace	


	
	


	/*

	* 2. option - imputing data 
	
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

mi xtset, clear

misstable summ gender_1 age_cut economsit_bef edu labfst_bef PTS traum_exp_bef_bin arrivalmonths accomodation residence_status land_partner children_germ_simplified discr_bin germ_course german_proficiency_cut_new soc_isolation contact_ukrainians contact_germans

mi register imputed gender_1 age_cut economsit_bef edu labfst_bef PTS traum_exp_bef_bin arrivalmonths accomodation residence_status land_partner children_germ_simplified discr_bin germ_course german_proficiency_cut_new soc_isolation contact_ukrainians contact_germans

mi impute chained (logit) gender_1 labfst_bef PTS traum_exp_bef_bin arrivalmonths germ_course discr_bin soc_isolation /// 
(ologit) age_cut economsit_bef edu german_proficiency_cut_new contact_ukrainians contact_germans ///
(mlogit) land_partner children_germ_simplified residence_status accomodation, add(30) rseed(1234) augment		


mi estimate, or post: logistic health_bin i.gender_1 i.age_cut i.economsit_bef i.edu i.labfst_bef i.PTS i.traum_exp_bef_bin i.arrivalmonths i.accomodation i.residence_status i.land_partner i.children_germ_simplified i.discr_bin i.germ_course i.german_proficiency_cut_new i.soc_isolation i.contact_ukrainians i.contact_germans i.gender_1#i.(soc_isolation discr_bin german_proficiency_cut_new) i.age_cut#i.(soc_isolation discr_bin german_proficiency_cut_new)
mi estimate, vartable nocitable
estimates store M4_imputed_interactions_alternative

esttab M4_imputed_interactions_alternative, ci pr2 aic bic noomitted nobaselevel eform label compress

esttab M4_imputed_interactions_alternative, ci pr2 aic bic baselevel eform nolabel compress

esttab M4_imputed_interactions_alternative using UKR_RESULTS_IMPUTED_interactions_alternative.rtf, ///
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
	


* 2) adding interactions terms ##### NOT WORKING

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

	* age * german proficiency --> 9 caegories [in mi impute chianed: ologit]
egen age_german = group(age_cut german_proficiency_cut_new)
lab var age_german "Age group # German language proficiency"
lab def age_german 1 "18-30 - none/poor" 2 "18-30 - sufficient" 3 "18-30 - good/excellent" 4 "31-49 - none/poor" 5 "31-49 - sufficient" 6 "31-49 - good/excellent" 7 "50+ - none/poor" 8 "50+ - sufficient" 9 "50+ - good/excellent"
lab values age_german age_german

mi set flong

misstable summ gender_1 age_cut economsit_bef edu labfst_bef PTS traum_exp_bef_bin arrivalmonths accomodation residence_status land_partner children_germ_simplified discr_bin germ_course german_proficiency_cut_new soc_isolation contact_ukrainians contact_germans gender_isolation gender_discrimination gender_german age_isolation age_discrimination age_german

	// variable with nomissing to registered as regular

mi register imputed gender_1 age_cut economsit_bef edu labfst_bef accomodation residence_status land_partner children_germ_simplified discr_bin germ_course german_proficiency_cut_new soc_isolation contact_ukrainians contact_germans gender_isolation gender_discrimination gender_german age_isolation age_discrimination age_german PTS traum_exp_bef_bin arrivalmonths


mi impute chained (logit) gender_1 labfst_bef germ_course discr_bin soc_isolation PTS traum_exp_bef_bin arrivalmonths ///
(ologit) age_cut economsit_bef edu german_proficiency_cut_new contact_ukrainians contact_germans age_discrimination age_german ///
(mlogit) land_partner children_germ_simplified residence_status accomodation gender_isolation gender_discrimination gender_german, add(30) rseed(1234) augment noisily force

	// convergence not achieved
	
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

keep health_bin gender age_cut economsit_bef edu labfst_bef PTS traum_exp_bef_bin arrivalmonths accomodation residence_status land_partner children_germ_simplified labfst_now_new discr_bin germ_course german_proficiency_cut_new soc_isolation contact_ukrainians contact_germans 

* erase missing obs by the DV
drop if health_bin==.
		// n= 5,932


* * Imputing data

* Imputation data. with 5, 20 and 30 "add"

		// recoding gender --> binary (0,1)
		recode gender (1=0 "male") (2=1 "female"), gen(gender_1)	

* imputing data
		
mi set mlong

misstable summ gender_1 age_cut economsit_bef edu labfst_bef PTS traum_exp_bef_bin arrivalmonths accomodation residence_status land_partner children_germ_simplified discr_bin germ_course german_proficiency_cut_new soc_isolation contact_ukrainians contact_germans

mi register imputed gender_1 age_cut economsit_bef edu labfst_bef accomodation residence_status land_partner children_germ_simplified discr_bin germ_course german_proficiency_cut_new soc_isolation contact_ukrainians contact_germans

mi register regular PTS traum_exp_bef_bin arrivalmonths

mi impute chained (logit) gender_1 labfst_bef germ_course discr_bin soc_isolation /// 
(ologit) economsit_bef age_cut  edu german_proficiency_cut_new contact_ukrainians contact_germans i.age_cut#i.(soc_isolation discr_bin german_proficiency_cut_new) = PTS traum_exp_bef_bin arrivalmonths ///
(mlogit) land_partner children_germ_simplified residence_status accomodation i.gender_1#i.(soc_isolation discr_bin german_proficiency_cut_new) = PTS traum_exp_bef_bin arrivalmonths, add(30) rseed(1234) augment noisily		



* new
mi impute chained (logit) gender_1 labfst_bef PTS traum_exp_bef_bin arrivalmonths germ_course discr_bin soc_isolation /// 
(ologit, include(age_cut * soc_isolation)) age_cut economsit_bef edu german_proficiency_cut_new contact_ukrainians contact_germans /// 
(mlogit) land_partner children_germ_simplified residence_status accomodation i.gender_1#i.(soc_isolation discr_bin german_proficiency_cut_new), add(30) rseed(1234) augment		


*/


* 3) stratification by level of education
	
* STRATIFICATION BY EDUCATION LEVEL
cd "Y:\abt-sop\MA\amarchitto\SUARE\Ukr_Ref_CS_2022_23\Ukr 2023"

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

mi xtset, clear

misstable summ gender_1 age_cut economsit_bef edu labfst_bef PTS traum_exp_bef_bin arrivalmonths accomodation residence_status land_partner children_germ_simplified discr_bin germ_course german_proficiency_cut_new soc_isolation contact_ukrainians contact_germans

mi register imputed gender_1 age_cut economsit_bef labfst_bef PTS traum_exp_bef_bin arrivalmonths accomodation residence_status land_partner children_germ_simplified discr_bin germ_course german_proficiency_cut_new soc_isolation contact_ukrainians contact_germans

mi impute chained (logit) gender_1 labfst_bef PTS traum_exp_bef_bin arrivalmonths germ_course discr_bin soc_isolation /// 
(ologit) age_cut economsit_bef german_proficiency_cut_new contact_ukrainians contact_germans ///
(mlogit) land_partner children_germ_simplified residence_status accomodation, add(30) rseed(1234) by(edu) augment

save ukr_imputed_data_stratification_edu.dta, replace

mi estimate, or post: logistic health_bin i.gender_1 i.age_cut i.economsit_bef i.labfst_bef i.PTS i.traum_exp_bef_bin i.arrivalmonths i.accomodation i.residence_status i.land_partner i.children_germ_simplified i.discr_bin i.germ_course i.german_proficiency_cut_new i.soc_isolation i.contact_ukrainians i.contact_germans if edu==0
mi estimate, vartable nocitable
estimates store M4_imputed_low

/*
mi estimate, or noisily: logistic health_bin i.gender_1 i.age_cut i.economsit_bef i.labfst_bef i.PTS i.traum_exp_bef_bin i.arrivalmonths i.accomodation i.residence_status i.land_partner i.children_germ_simplified i.discr_bin i.germ_course i.german_proficiency_cut_new i.soc_isolation i.contact_ukrainians i.contact_germans if edu==1
mi estimate, vartable nocitable
estimates store M4_imputed_medium

		 
		mi estimate: omitted terms vary
			The set of omitted variables or categories is not consistent between m=1 and m=3; this is not allowed.  To
			identify varying sets, you can use mi xeq to run the command on individual imputations or you can reissue the
			command with mi estimate, noisily
			r(498)

		*/
		
* without german langiage proficiency		
mi estimate, or post: logistic health_bin i.gender_1 i.age_cut i.economsit_bef i.labfst_bef i.PTS i.traum_exp_bef_bin i.arrivalmonths i.accomodation i.residence_status i.land_partner i.children_germ_simplified i.discr_bin i.germ_course i.soc_isolation i.contact_ukrainians i.contact_germans if edu==1
mi estimate, vartable nocitable		
estimates store M4_imputed_medium		

mi estimate, or post: logistic health_bin i.gender_1 i.age_cut i.economsit_bef i.labfst_bef i.PTS i.traum_exp_bef_bin i.arrivalmonths i.accomodation i.residence_status i.land_partner i.children_germ_simplified i.discr_bin i.germ_course i.german_proficiency_cut_new i.soc_isolation i.contact_ukrainians i.contact_germans if edu==2
mi estimate, vartable nocitable
estimates store M4_imputed_high


esttab M4_imputed_low M4_imputed_medium M4_imputed_high, ci pr2 aic bic noomitted nobaselevel eform label compress

esttab M4_imputed_low M4_imputed_medium M4_imputed_high using UKR_RESULTS_IMPUTED_stratification_edu.rtf, ///
	ci pr2 aic bic baselevel label ///
	refcat(0.gender_1 "Gender" ///
	0.age_cut "Age group" ///
	1.economsit_bef "Economic situation before flight" ///
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
	

	
	
* counting frequencies imputed data

	* gender language proficiency (imputed data)
	asdoc tab edu german_proficiency_cut_new, replace
	asdoc tab edu german_proficiency_cut_new, m replace
	
	* by education: health and language proficiency (imputed data)
	asdoc bys edu: tab health_bin german_proficiency_cut_new, replace
	asdoc bys edu: tab health_bin german_proficiency_cut_new, m replace
	

	

* counting frequencies not imputed data	

cd "Y:\abt-sop\MA\amarchitto\SUARE\Ukr_Ref_CS_2022_23\Ukr 2023"

use uks_2023_final_JUN_24.dta, replace

drop if health_bin==.
	
	* education language proficiency (not imputed data)
	asdoc tab edu german_proficiency_cut_new, m replace
	
	* by education: health and language proficiency (not imputed data)
	asdoc bys edu: tab health_bin german_proficiency_cut_new, m replace
	
