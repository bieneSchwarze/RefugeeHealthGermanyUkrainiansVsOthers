* Multiple imputation. Ref Extra Sensitivity Analyses

* Setting work direct and uplaoding data 

cd "Y:\abt-sop\MA\amarchitto\SUARE\Ukr_Ref_CS_2022_23\Ref_2022"

capture log close


* 1) Interactions 

* use already imputed stored data


use ref_imputed_data.dta, clear

mi estimate, or post: logistic health_bin i.gender##i.(soc_isolation discr_bin german_proficiency_cut_new) i.age_cut##i.(soc_isolation discr_bin german_proficiency_cut_new) i.economsit_bef i.edu i.labfst_bef i.corigin_simpl_2 i.PTS i.traum_exp_bef_bin i.arrivalmonths i.accomodation_new i.residence_status i.land_partner i.children_germ_simplified i.germ_int_course i.contact_same_country i.contact_germans
mi estimate, vartable nocitable
estimates store M4_imputed_interactions





esttab M4_imputed_interactions using REF_RESULTS_IMPUTED_new_interactions.rtf, ///
	ci pr2 aic bic baselevel label ///
	refcat(1.gender "Gender" ///
	0.age_cut "Age group" ///
	1.economsit_bef "Economic situation before flight" ///
	0.edu "Level of education" ///
	0.labfst_bef "Employed before flight" ///
	1.corigin_simpl_2 "Country of birth" ///
	0.PTS "PTS" ///
	0.traum_exp_bef_bin "Traumatic experiences before flight" ///
	0.arrivalmonths "Time in Germany since arrival" ///
	1.accomodation_new "Type of accommodation" ///
	1.residence_status "Residence/asylum status" ///
	0.land_partner "Partner's living place" ///
	0.children_germ_simplified "Children living place" ///
	0.discr_bin "Perceived discrimination" ///
	0.germ_int_course "Attended German language/integration/ESF-BAMF course" ///
	1.german_proficiency_cut_new "German language proficiency" ///
	0.soc_isolation "Feeling socially isolated" ///
	0.contact_same_country "Contact with persons with same country of origin (non-relative)" ///
	0.contact_germans "Contact with Germans", nolabel) eform compress replace 

	
	* alternative

mi estimate, or post: logistic health_bin i.gender i.age_cut i.economsit_bef i.edu i.labfst_bef i.corigin_simpl_2 i.PTS i.traum_exp_bef_bin i.arrivalmonths i.accomodation_new i.residence_status i.land_partner i.children_germ_simplified i.discr_bin i.germ_int_course i.german_proficiency_cut_new i.soc_isolation i.contact_same_country i.contact_germans i.gender#i.(soc_isolation discr_bin german_proficiency_cut_new) i.age_cut#i.(soc_isolation discr_bin german_proficiency_cut_new)
mi estimate, vartable nocitable
estimates store M4_imputed_interactions

esttab M4_imputed_interactions using REF_RESULTS_IMPUTED_new_interactions.rtf, ///
	ci pr2 aic bic baselevel label ///
	refcat(1.gender "Gender" ///
	0.age_cut "Age group" ///
	1.economsit_bef "Economic situation before flight" ///
	0.edu "Level of education" ///
	0.labfst_bef "Employed before flight" ///
	1.corigin_simpl_2 "Country of birth" ///
	0.PTS "PTS" ///
	0.traum_exp_bef_bin "Traumatic experiences before flight" ///
	0.arrivalmonths "Time in Germany since arrival" ///
	1.accomodation_new "Type of accommodation" ///
	1.residence_status "Residence/asylum status" ///
	0.land_partner "Partner's living place" ///
	0.children_germ_simplified "Children living place" ///
	0.discr_bin "Perceived discrimination" ///
	0.germ_int_course "Attended German language/integration/ESF-BAMF course" ///
	1.german_proficiency_cut_new "German language proficiency" ///
	0.soc_isolation "Feeling socially isolated" ///
	0.contact_same_country "Contact with persons with same country of origin (non-relative)" ///
	0.contact_germans "Contact with Germans", nolabel) eform compress replace 

	
	
* 2) Interactionseffects

use ref_2023_final_JAN_neu.dta, replace

*recoding country of origin
recode corigin_simpl (760=1 "Syria") (4=2 "Afghanistan") (368=3 "Iraq") (900=4 "Other countries"), gen(corigin_simpl_2)
tab corigin_simpl corigin_simpl_2
lab var corigin_simpl_2 "Country of birth"
tab corigin_simpl_2, m

* manually create INTERACTION terms

	* gender * scoial isolation --> 4 caegories [in mi impute chianed: mlogit]
egen gender_isolation = group(gender soc_isolation)
lab var gender_isolation "Gender # Feeling socially isolated"
lab def gender_isolation 1 "male - does not apply(at all)/neutral pos." 2 "male - applies(fully)" 3 "female - does not apply(at all)/neutral pos." 4 "female - applies(fully)"
lab values gender_isolation gender_isolation

	* gender * discrimination --> 4 caegories [in mi impute chianed: mlogit]
egen gender_discrimination = group(gender discr_bin)
lab var gender_discrimination "Gender # Perceived discrimination"
lab def gender_discrimination 1 "male - never" 2 "male - seldomly/often" 3 "female - never" 4 "female - seldomly/often"
lab values gender_discrimination gender_discrimination

	* gender * german proficiency --> 6 caegories [in mi impute chianed: mlogit]
egen gender_german = group(gender german_proficiency_cut_new)
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


* taking only variables included into analysis
keep health_bin gender age_cut economsit_bef edu labfst_bef corigin_simpl_2 PTS traum_exp_bef_bin arrivalmonths accomodation_new residence_status land_partner children_germ_simplified discr_bin germ_int_course german_proficiency_cut_new soc_isolation contact_same_country contact_germans gender_isolation gender_discrimination gender_german age_isolation age_discrimination age_german

* erase missigng obs by the DV
drop if health_bin==.
		// n=1,192


* Imputing data

/* imputation only of covariates

ice health_bin gender age_cut economsit_bef edu labfst_bef corigin_simpl_2 PTS traum_exp_bef_bin arrivalmonths accomodation_new residence_status land_partner children_germ_simplified discr_bin germ_int_course german_proficiency_cut_new soc_isolation contact_same_country contact_germans, saving(icedata) m(5) seed(1234) replace

use icedata, clear

mi import ice, automatic

mi describe

*/




* Imputation data. with 5, 20 and 30 "add"

/*

mi set flong

mi xtset, clear

misstable summ gender age_cut economsit_bef edu labfst_bef corigin_simpl_2 PTS traum_exp_bef_bin arrivalmonths accomodation_new residence_status land_partner children_germ_simplified discr_bin germ_int_course german_proficiency_cut_new soc_isolation contact_same_country contact_germans gender_isolation gender_discrimination gender_german age_isolation age_discrimination age_german

mi register imputed economsit_bef  labfst_bef accomodation_new residence_status land_partner children_germ_simplified discr_bin  soc_isolation contact_same_country contact_germans gender_isolation gender_discrimination  age_isolation age_discrimination 

mi register regular gender age_cut edu corigin_simpl_2 PTS traum_exp_bef_bin arrivalmonths germ_int_course german_proficiency_cut_new gender_german age_german



mi impute chained (logit) labfst_bef discr_bin soc_isolation  ///
(ologit) economsit_bef contact_same_country contact_germans ///
(mlogit) land_partner children_germ_simplified residence_status accomodation_new gender_isolation gender_discrimination age_isolation age_discrimination = gender age_cut edu corigin_simpl_2 PTS traum_exp_bef_bin arrivalmonths germ_int_course german_proficiency_cut_new age_german gender_german, add(30) rseed(1234) augment showcommand noisily 

*/






mi set flong

mi xtset, clear

misstable summ gender age_cut economsit_bef edu labfst_bef corigin_simpl_2 PTS traum_exp_bef_bin arrivalmonths accomodation_new residence_status land_partner children_germ_simplified discr_bin germ_int_course german_proficiency_cut_new soc_isolation contact_same_country contact_germans gender_isolation gender_discrimination gender_german age_isolation age_discrimination age_german

mi register imputed gender age_cut economsit_bef edu labfst_bef corigin_simpl_2 PTS traum_exp_bef_bin arrivalmonths accomodation_new residence_status land_partner children_germ_simplified discr_bin germ_int_course german_proficiency_cut_new soc_isolation contact_same_country contact_germans gender_isolation gender_discrimination gender_german age_isolation age_discrimination age_german


mi impute chained (logit) gender labfst_bef PTS traum_exp_bef_bin arrivalmonths germ_int_course discr_bin soc_isolation /// 
(ologit) age_cut economsit_bef edu german_proficiency_cut_new contact_same_country contact_germans ///
(mlogit) land_partner children_germ_simplified residence_status accomodation_new corigin_simpl_2 gender_isolation gender_discrimination gender_german age_isolation age_discrimination age_german, add(30) rseed(1234) augment

		// convergence not achieved

* saving imputed data in wd
save ref_imputed_data_interactions.dta, replace

* ##############

use ref_imputed_data_interactions.dta, clear

* M1
mi estimate, or post: logistic health_bin i.gender i.age_cut i.economsit_bef i.edu i.labfst_bef i.corigin_simpl_2
mi estimate, vartable nocitable
estimates store M1_imputed

*M2
mi estimate, or post: logistic health_bin i.gender i.age_cut i.economsit_bef i.edu i.labfst_bef i.corigin_simpl_2 i.PTS i.traum_exp_bef_bin
mi estimate, vartable nocitable
estimates store M2_imputed

*M3
mi estimate, or post: logistic health_bin i.gender i.age_cut i.economsit_bef i.edu i.labfst_bef i.corigin_simpl_2 i.arrivalmonths i.accomodation_new i.residence_status i.land_partner i.children_germ_simplified i.discr_bin i.germ_int_course i.german_proficiency_cut_new i.soc_isolation i.contact_same_country i.contact_germans
mi estimate, vartable nocitable
estimates store M3_imputed

*M4
mi estimate, or post: logistic health_bin i.gender i.age_cut i.economsit_bef i.edu i.labfst_bef i.corigin_simpl_2 i.PTS i.traum_exp_bef_bin i.arrivalmonths i.accomodation_new i.residence_status i.land_partner i.children_germ_simplified i.discr_bin i.germ_int_course i.german_proficiency_cut_new i.soc_isolation i.contact_same_country i.contact_germans
mi estimate, vartable nocitable
estimates store M4_imputed

*Analysis
esttab M1_imputed M2_imputed M3_imputed M4_imputed, ci pr2 aic bic noomitted nobaselevel eform label compress



esttab M1_imputed M2_imputed M3_imputed M4_imputed using REF_RESULTS_IMPUTED_new.rtf, ///
	ci pr2 aic bic baselevel label ///
	refcat(1.gender "Gender" ///
	0.age_cut "Age group" ///
	1.economsit_bef "Economic situation before flight" ///
	0.edu "Level of education" ///
	0.labfst_bef "Employed before flight" ///
	1.corigin_simpl_2 "Country of birth" ///
	0.PTS "PTS" ///
	0.traum_exp_bef_bin "Traumatic experiences before flight" ///
	0.arrivalmonths "Time in Germany since arrival" ///
	1.accomodation_new "Type of accommodation" ///
	1.residence_status "Residence/asylum status" ///
	0.land_partner "Partner's living place" ///
	0.children_germ_simplified "Children living place" ///
	0.discr_bin "Perceived discrimination" ///
	0.germ_int_course "Attended German language/integration/ESF-BAMF course" ///
	1.german_proficiency_cut_new "German language proficiency" ///
	0.soc_isolation "Feeling socially isolated" ///
	0.contact_same_country "Contact with persons with same country of origin (non-relative)" ///
	0.contact_germans "Contact with Germans", nolabel) eform compress replace 
	
	
	
	
	
	
* 2) Interactioneffects - 3rd trying

cd "Y:\abt-sop\MA\amarchitto\SUARE\Ukr_Ref_CS_2022_23\Ref_2022"

capture log close


* Uploading data

use ref_2023_final_JAN_neu.dta, replace


*recoding country of origin
recode corigin_simpl (760=1 "Syria") (4=2 "Afghanistan") (368=3 "Iraq") (900=4 "Other countries"), gen(corigin_simpl_2)
tab corigin_simpl corigin_simpl_2
lab var corigin_simpl_2 "Country of birth"
tab corigin_simpl_2, m



* taking only variables included into analysis
keep health_bin gender age_cut economsit_bef edu labfst_bef corigin_simpl_2 PTS traum_exp_bef_bin arrivalmonths accomodation_new residence_status land_partner children_germ_simplified discr_bin germ_int_course german_proficiency_cut_new soc_isolation contact_same_country contact_germans 

* erase missigng obs by the DV
drop if health_bin==.
		// n=1,192


mi set mlong

mi xtset, clear

misstable summ gender age_cut economsit_bef edu labfst_bef corigin_simpl_2 PTS traum_exp_bef_bin arrivalmonths accomodation_new residence_status land_partner children_germ_simplified discr_bin germ_int_course german_proficiency_cut_new soc_isolation contact_same_country contact_germans

mi register imputed gender age_cut economsit_bef edu labfst_bef corigin_simpl_2 PTS traum_exp_bef_bin arrivalmonths accomodation_new residence_status land_partner children_germ_simplified discr_bin germ_int_course german_proficiency_cut_new soc_isolation contact_same_country contact_germans


mi impute chained (logit) i.gender##i.(soc_isolation discr_bin german_proficiency_cut_new) labfst_bef PTS traum_exp_bef_bin arrivalmonths germ_int_course /// 
(ologit) i.age_cut##i.(soc_isolation discr_bin german_proficiency_cut_new) economsit_bef edu contact_same_country contact_germans ///
(mlogit) land_partner children_germ_simplified residence_status accomodation_new corigin_simpl_2, add(30) rseed(1234) augment noisily showcommand

	
	
***** 


*  STRATIFICATION BY EDUCATION LEVEL


use ref_2023_final_JAN_neu.dta, replace

*recoding country of origin
recode corigin_simpl (760=1 "Syria") (4=2 "Afghanistan") (368=3 "Iraq") (900=4 "Other countries"), gen(corigin_simpl_2)
tab corigin_simpl corigin_simpl_2
lab var corigin_simpl_2 "Country of birth"
tab corigin_simpl_2, m	
	
	
* taking only variables included into analysis
keep health_bin gender age_cut economsit_bef edu labfst_bef corigin_simpl_2 PTS traum_exp_bef_bin arrivalmonths accomodation_new residence_status land_partner children_germ_simplified discr_bin germ_int_course german_proficiency_cut_new soc_isolation contact_same_country contact_germans 

* erase missigng obs by the DV
drop if health_bin==.
		// n=1,192


* Imputing data

mi set flong

mi xtset, clear

misstable summ gender age_cut economsit_bef edu labfst_bef corigin_simpl_2 PTS traum_exp_bef_bin arrivalmonths accomodation_new residence_status land_partner children_germ_simplified discr_bin germ_int_course german_proficiency_cut_new soc_isolation contact_same_country contact_germans

mi register imputed gender age_cut economsit_bef labfst_bef corigin_simpl_2 PTS traum_exp_bef_bin arrivalmonths accomodation_new residence_status land_partner children_germ_simplified discr_bin germ_int_course german_proficiency_cut_new soc_isolation contact_same_country contact_germans


mi impute chained (logit) gender labfst_bef PTS traum_exp_bef_bin arrivalmonths germ_int_course discr_bin soc_isolation /// 
(ologit) age_cut economsit_bef german_proficiency_cut_new contact_same_country contact_germans ///
(mlogit) land_partner children_germ_simplified residence_status accomodation_new corigin_simpl_2, add(30) rseed(1234) by(edu) augment

* saving imputed data in wd
save ref_imputed_data_stratification_edu.dta, replace	



mi estimate, or post: logistic health_bin i.gender i.age_cut i.economsit_bef i.labfst_bef i.corigin_simpl_2 i.PTS i.traum_exp_bef_bin i.arrivalmonths i.accomodation_new i.residence_status i.land_partner i.children_germ_simplified i.discr_bin i.germ_int_course i.german_proficiency_cut_new i.soc_isolation i.contact_same_country i.contact_germans if edu==0
mi estimate, vartable nocitable
estimates store M4_imputed_low

mi estimate, or post: logistic health_bin i.gender i.age_cut i.economsit_bef i.labfst_bef i.corigin_simpl_2 i.PTS i.traum_exp_bef_bin i.arrivalmonths i.accomodation_new i.residence_status i.land_partner i.children_germ_simplified i.discr_bin i.germ_int_course i.german_proficiency_cut_new i.soc_isolation i.contact_same_country i.contact_germans if edu==1
mi estimate, vartable nocitable
estimates store M4_imputed_medium

mi estimate, or post: logistic health_bin i.gender i.age_cut i.economsit_bef i.labfst_bef i.corigin_simpl_2 i.PTS i.traum_exp_bef_bin i.arrivalmonths i.accomodation_new i.residence_status i.land_partner i.children_germ_simplified i.discr_bin i.germ_int_course i.german_proficiency_cut_new i.soc_isolation i.contact_same_country i.contact_germans if edu==2
mi estimate, vartable nocitable
estimates store M4_imputed_high


esttab M4_imputed_low M4_imputed_medium M4_imputed_high, ci pr2 aic bic noomitted nobaselevel eform label compress

esttab M4_imputed_low M4_imputed_medium M4_imputed_high, ci pr2 aic bic baselevel eform nolabel compress

esttab M4_imputed_low M4_imputed_medium M4_imputed_high using REF_RESULTS_IMPUTED_new_stratification_edu.rtf, ///
	ci pr2 aic bic baselevel label ///
	refcat(1.gender "Gender" ///
	0.age_cut "Age group" ///
	1.economsit_bef "Economic situation before flight" ///
	0.labfst_bef "Employed before flight" ///
	1.corigin_simpl_2 "Country of birth" ///
	0.PTS "PTS" ///
	0.traum_exp_bef_bin "Traumatic experiences before flight" ///
	0.arrivalmonths "Time in Germany since arrival" ///
	1.accomodation_new "Type of accommodation" ///
	1.residence_status "Residence/asylum status" ///
	0.land_partner "Partner's living place" ///
	0.children_germ_simplified "Children living place" ///
	0.discr_bin "Perceived discrimination" ///
	0.germ_int_course "Attended German language/integration/ESF-BAMF course" ///
	1.german_proficiency_cut_new "German language proficiency" ///
	0.soc_isolation "Feeling socially isolated" ///
	0.contact_same_country "Contact with persons with same country of origin (non-relative)" ///
	0.contact_germans "Contact with Germans", nolabel) eform compress replace 

