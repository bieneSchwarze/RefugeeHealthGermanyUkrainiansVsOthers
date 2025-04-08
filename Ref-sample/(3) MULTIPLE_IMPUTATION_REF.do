* Multiple imputation. Ref

* Setting work direct and uplaoding data 

cd "I:\MA\amarchitto\SUARE\Ukr_Ref_CS_2022_23\Ref_2022"

capture log close
log using REF_analysis_multiple_imputation.log, replace

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

/* imputation only of covariates

ice health_bin gender age_cut economsit_bef edu labfst_bef corigin_simpl_2 PTS traum_exp_bef_bin arrivalmonths accomodation_new residence_status land_partner children_germ_simplified discr_bin germ_int_course german_proficiency_cut_new soc_isolation contact_same_country contact_germans, saving(icedata) m(5) seed(1234) replace

use icedata, clear

mi import ice, automatic

mi describe

*/


* Imputation data. with 5, 20 and 30 "add"

mi set flong

mi xtset, clear

misstable summ gender age_cut economsit_bef edu labfst_bef corigin_simpl_2 PTS traum_exp_bef_bin arrivalmonths accomodation_new residence_status land_partner children_germ_simplified discr_bin germ_int_course german_proficiency_cut_new soc_isolation contact_same_country contact_germans

mi register imputed gender age_cut economsit_bef edu labfst_bef corigin_simpl_2 PTS traum_exp_bef_bin arrivalmonths accomodation_new residence_status land_partner children_germ_simplified discr_bin germ_int_course german_proficiency_cut_new soc_isolation contact_same_country contact_germans


mi impute chained (logit) gender labfst_bef PTS traum_exp_bef_bin arrivalmonths germ_int_course discr_bin soc_isolation /// 
(ologit) age_cut economsit_bef edu german_proficiency_cut_new contact_same_country contact_germans ///
(mlogit) land_partner children_germ_simplified residence_status accomodation_new corigin_simpl_2, add(30) rseed(1234) augment

* saving imputed data in wd
save ref_imputed_data.dta, replace

* ##############

use ref_imputed_data.dta, clear

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

	
* coefplot M4_imputed

* saving same coefplot inyto a graph folder (with all coefplots of the study)
global Graphs "I:\MA\amarchitto\SUARE\Ukr_Ref_CS_2022_23\Graphs-UKR-REF"

coefplot M4_imputed, bylabel(fully adjusted model M4) eform xline(1) xscale(log) legend(pos(6)) ms(oh) groups(*.gender *.age_cut *.economsit_bef *.edu *.labfst_bef *.corigin_simpl_2 = "SOCIO-DEMOGRAPHIC" *.PTS *.traum_exp_bef_bin = "PRE-MIGRATION FACTORS" *.arrivalmonths *.accomodation_new *.residence_status *.land_partner *.children_germ_simplified i.discr_bin *.germ_int_course *.german_proficiency_cut_new *.soc_isolation *.contact_same_country *.contact_germans = "POST-MIGRATION FACTORS")  mlabel(cond(@pval<.001, "***", cond(@pval<.01, "**", cond(@pval<.05, "*", "")))) baselevel mlabel(cond(@pval<.001, "***", cond(@pval<.01, "**", cond(@pval<.05, "*", "")))) drop(_cons) coeflabels(, notick labsize(tiny)) headings(1.gender = "{bf:Gender}" 0.age_cut = "{bf:Age group}" 1.economsit_bef ="{bf:Economic situation before flight}" 0.edu = "{bf:Level of education}" 0.labfst_bef = "{bf:Employed before flight}" 1.corigin_simpl_2 = "{bf: Country of birth}" 0.PTS = "{bf:PTS}" 0.traum_exp_bef_bin = "{bf:Traumatic experiences before flight}" 0.arrivalmonths = "{bf:Time in Germany since arrival}" 1.accomodation_new = "{bf:Type of accommodation}" 1.residence_status = "{bf:Residence/asylum status}" 0.land_partner = "{bf:Partner's living place}" 0.children_germ_simplified = "{bf:Children living place}" 0.discr_bin = "{bf:Perceived discrimination}" 0.germ_int_course = "{bf:Attended German language/integration course}" 1.german_proficiency_cut_new = "{bf:German language proficiency}" 0.soc_isolation = "{bf:Feeling socially isolated}" 0.contact_same_country = "{bf:Contact with persons with same country of origin (non-relative)}" 0.contact_germans = "{bf:Contact with Germans}", labsize(tiny)) play("ref_coef_M4_imputed_edit") name(Ref_M4_coefplot_imputed, replace)	

graph save $Graph\Ref_M4_coefplot_imputed, replace



* NEW GRAPH (Louise)
**REFUGEE SAMPLE

coefplot M4_imputed, eform xline(1) xscale(log) drop(_cons) ysize(15) baselevel ylab(, labsize(small)) xlabel(0.5 1 2 4 6) mcolor(black) ciopts(lcolor(black)) ///
	headings(1.gender = "{bf:Gender}" 0.age_cut = "{bf:Age group}" 1.economsit_bef =	"{bf:Economic situation before war}" 0.edu = "{bf:Education}" 0.labfst_bef = "{bf:Employed before flight}" 1.corigin_simpl_2 = "{bf: Country of birth}" 0.PTS = "{bf:Political Terror Scale}" 0.traum_exp_bef_bin = "{bf:Traumatic experiences}" 0.arrivalmonths = "{bf:Time since arrival}" 1.accomodation_new = "{bf:Type of accommodation}" 1.residence_status = "{bf:Residence/asylum status}" 0.land_partner = "{bf:Partner's living place}" 0.children_germ_simplified = "{bf:Children's living place}" 0.discr_bin = "{bf:Perceived discrimination}" 0.germ_int_course = "{bf:Attended language course}" 1.german_proficiency_cut_new = "{bf:German language proficiency}" 0.soc_isolation = "{bf:Social isolation}" 0.contact_same_country = "{bf:Contact: country of origin}" 0.contact_germans = "{bf:Contact: Germans}", gap labsize(small)) ///
	coeflabels (2.residence_status= "other/'Duldung'" 3.residence_status="temporary/ permament status") ///
	groups(*.gender *.age_cut *.economsit_bef *.edu *.labfst_bef *.corigin_simpl_2 = "{bf:Sociodemographics}" *.PTS *.traum_exp_bef_bin = "{bf:Pre-migration factors}" *.arrivalmonths *.accomodation_new *.residence_status *.land_partner *.children_germ_simplified i.discr_bin *.germ_int_course *.german_proficiency_cut_new *.soc_isolation *.contact_same_country *.contact_germans = "{bf:Post-migration factors}", angle(vertical) labsize(small))

graph save $Graphs\Ref_M4_coefplot_imp_NEW, replace

		
* TEST MULTICOLLINEARITY
mi estimate, or post: logistic health_bin i.gender i.age_cut i.economsit_bef i.edu i.labfst_bef i.corigin_simpl_2 i.PTS i.traum_exp_bef_bin i.arrivalmonths i.accomodation_new i.residence_status i.land_partner i.children_germ_simplified i.discr_bin i.germ_int_course i.german_proficiency_cut_new i.soc_isolation i.contact_same_country i.contact_germans

estimates store M4_imputed

collin gender age_cut economsit_bef edu labfst_bef corigin_simpl_2 PTS traum_exp_bef_bin arrivalmonths accomodation_new residence_status land_partner children_germ_simplified discr_bin germ_int_course german_proficiency_cut_new soc_isolation contact_same_country contact_germans


*###############################################################################


* uploading data for sensitivity analysis

use ref_2023_final_JAN_neu.dta, replace

*recoding country of origin
recode corigin_simpl (760=1 "Syria") (4=2 "Afghanistan") (368=3 "Iraq") (900=4 "Other countries"), gen(corigin_simpl_2)
tab corigin_simpl corigin_simpl_2
lab var corigin_simpl_2 "Country of birth"
tab corigin_simpl_2, m


* taking only useful vars for sensitivity analysis (full model M4)
keep health_bin_sens gender age_cut economsit_bef edu labfst_bef corigin_simpl_2 PTS traum_exp_bef_bin arrivalmonths accomodation_new residence_status land_partner children_germ_simplified discr_bin germ_int_course german_proficiency_cut_new soc_isolation contact_same_country contact_germans

* drop missing of DV
drop if health_bin_sens==.
		// n=1,192


* Imputation data. with 5, 20 and 30 "add" - SENS

mi set flong

mi xtset, clear

misstable summ gender age_cut economsit_bef edu labfst_bef corigin_simpl_2 PTS traum_exp_bef_bin arrivalmonths accomodation_new residence_status land_partner children_germ_simplified discr_bin germ_int_course german_proficiency_cut_new soc_isolation contact_same_country contact_germans

mi register imputed gender age_cut economsit_bef edu labfst_bef corigin_simpl_2 PTS traum_exp_bef_bin arrivalmonths accomodation_new residence_status land_partner children_germ_simplified discr_bin germ_int_course german_proficiency_cut_new soc_isolation contact_same_country contact_germans

mi impute chained (logit) gender labfst_bef PTS traum_exp_bef_bin arrivalmonths germ_int_course discr_bin soc_isolation /// 
(ologit) age_cut economsit_bef edu german_proficiency_cut_new contact_same_country contact_germans ///
(mlogit) land_partner children_germ_simplified residence_status accomodation_new corigin_simpl_2, add(30) rseed(1234) augment

* save imputed data
save ref_imputed_data_sens.dta, replace

* S_ref_sensitivity
mi estimate, or post: logistic health_bin_sens i.gender i.age_cut i.economsit_bef i.edu i.labfst_bef i.corigin_simpl_2 i.PTS i.traum_exp_bef_bin i.arrivalmonths i.accomodation_new i.residence_status i.land_partner i.children_germ_simplified i.discr_bin i.germ_int_course i.german_proficiency_cut_new i.soc_isolation i.contact_same_country i.contact_germans
mi estimate, vartable nocitable
estimates store SA_D_ref_imputed


* S_syrians_sensitivity
mi estimate, or post: logistic health_bin_sens i.gender i.age_cut i.economsit_bef i.edu i.labfst_bef i.PTS i.traum_exp_bef_bin i.arrivalmonths i.accomodation_new i.residence_status i.land_partner i.children_germ_simplified i.discr_bin i.germ_int_course i.german_proficiency_cut_new i.soc_isolation i.contact_same_country i.contact_germans if corigin_simpl_2==1
mi estimate, vartable nocitable
estimates store SA_E_syr_imputed


esttab SA_D_ref_imputed SA_E_syr_imputed using RESULTS_REF_SENS_IMPUTED_new.rtf, ///
	ci pr2 aic bic baselevel label ///
	refcat(1.gender "Gender" ///
	0.age_cut "Age group" ///
	1.economsit_bef "Economic situation before flight" ///
	0.edu "Level of education" ///
	0.labfst_bef "Employed before flight" ///
	1.corigin_simpl_2 "Country of birth (only ref)" ///
	0.PTS "PTS" ///
	0.traum_exp_bef_bin "Traumatic experiences before flight" ///
	0.arrivalmonths "Time in Germany since arrival" ///
	1.accomodation_new "Type of accomodation (ref)" ///
	1.residence_status "Residence/asylum status" ///
	0.land_partner "Partner's living place" ///
	0.children_germ_simplified "Children living place" ///
	0.discr_bin "Perceived discrimination" ///
	0.germ_int_course "Attended German language/integration/ESF-BAMF course (ref)" ///
	1.german_proficiency_cut_new "German language proficiency" ///
	0.soc_isolation "Feeling socially isolated" ///
	0.contact_same_country "Contact with persons of same country of origin (non-relative - ref)" ///
	0.contact_germans "Contact with Germans", nolabel) eform compress replace 

	
capture log close	


* final dataset, not imputed

use ref_2023_final_JAN_neu.dta, replace


* TO DO: changing the coding of var "corigin_simpl". 
recode corigin_simpl (760=1 "Syria") (4=2 "Afghanistan") (368=3 "Iraq") (900=4 "Other countries"), gen(corigin_simpl_2)
tab corigin_simpl corigin_simpl_2
lab var corigin_simpl_2 "Country of birth"
tab corigin_simpl_2, m

* Model 4 (full model, sensitivity analysis: changing the DV categories)
 
logistic health_bin i.gender i.age_cut i.economsit_bef i.edu i.labfst_bef i.corigin_simpl_2 i.PTS i.traum_exp_bef_bin i.arrivalmonths i.accomodation_new i.residence_status i.land_partner i.children_germ_simplified i.discr_bin i.germ_int_course i.german_proficiency_cut_new i.soc_isolation i.contact_same_country i.contact_germans
estimates store M4


*#####
* Estab final
esttab SA_D_ref_imputed SA_E_syr_imputed M4 using FINAL_RESULTS_REF_PAPER.rtf, ///
	ci pr2 baselevel label ///
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


