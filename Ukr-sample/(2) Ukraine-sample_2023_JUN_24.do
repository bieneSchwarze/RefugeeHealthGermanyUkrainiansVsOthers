* Set working directory
cd "I:\MA\amarchitto\SUARE\Ukr_Ref_CS_2022_23\Ukr 2023"

use pid syear mode end_date end_time start_date end_language valid using "G:\consolidated\soep-ukr\finaldata\ukr-instrumentation.dta", replace


*merging with pl + selecting all variables of interest (see Cross-Section Ukr-Ref Items.docx)

merge 1:1 pid syear using "G:\consolidated\soep-ukr\finaldata\ukr-pl.dta", keep(master match) keepusing(pukr77 pukr77_v1 pukr31 pukr30 pukr71 pukr53 pukr54_1 pukr54_2 pukr54_3 pukr54_4 pukr54_5 pukr54_6 pukr54_7 pukr54_8 pukr54_9 pukr54_10 pukr54_11 pukr54_12 pukr54_no pukr57 pukr6 pukr5 pukr82 pukr11_1 pukr11_5 pukr11_7 pukr4d pukr4m pukr4y pukr3d pukr3m pukr3y pukr84 pukr85 pukr86 pukr236 pukr263 pukr265_1 pukr78 pukr10 pukr19 pukr19_v1 pukr32 pukr33 pukr36 pukr39 pukr39no pukr284_1 pukr284_2 pukr284_3 pukr285_1 pukr285_2 pukr285_3 pukr62 pukr74 pukr75) nogen


tab valid
** dropping observation which are not valid "Ergebnis Gültigkeitsprüfung: ungültig"
drop if valid==2


*________________________________________________________________________

* STEP 1: data cleaning

*	* Dependent Variable Y 

* General Health 2023 (binary)

mvdecode pukr77_v1, mv(-8/-1)
recode pukr77_v1 (1 2 3=0) (4 5=1), gen(health_bin)
label var health_bin "General health (self-rated)"
lab def health_bin 0 "good/satisf" 1 "bad"
lab values health_bin health_bin
tab health_bin

* General Health 2023 (binary), differently coded for sensitivity analysis
recode pukr77_v1 (1 2=0) (3 4 5=1), gen(health_bin_sens)
label var health_bin_sens "General health  (self-rated)"
lab def health_bin_sens 0 "good" 1 "satisf/bad"
lab values health_bin_sens health_bin_sens
tab health_bin_sens


*   --  --  --  *

*	* Cross-Cutting Aspects

* Gender
 
// (replacing non-missing values for puk31 (2022) for follow-up repondents (ex. pid==10027469 / list pid syear pukr31 if pid==10027469)
sort pid syear
br pid syear pukr31
mvdecode pukr31, mv(-8/-1)
gen gender=.
bysort pid (syear): replace gender=pukr31[_n-1] if missing(pukr31)
mvdecode gender, mv(-8/-1, 3)
lab var gender "Gender"
lab def gender 1 "male" 2 "female"
lab val gender gender

tab gender pukr31, m


* Age

mvdecode pukr30, mv (-8/-1)
gen age = syear-pukr30
egen age_cut = cut(age), at(18,31,50,100) label
label var age_cut "Age group"
label drop age_cut
lab def age_cut 0 "18-30" 1 "31-49" 2 "50+"
lab val age_cut age_cut

* Economic situation before flight

tab pukr71 syear
mvdecode pukr71, mv(-8/-1)
gen ecosit_bef=.
bysort pid (syear): replace ecosit_bef=pukr71[_n-1] if missing(pukr71)
list pid syear pukr71 ecosit_bef in 1/100
lab values ecosit_bef pukr71
tab ecosit_bef

recode ecosit_bef (4 5=1) (3=2) (1 2=3), gen(economsit_bef)
lab var economsit_bef "Economic situation before war"
lab def economsit_bef 1 "(well)below average" 2 "on average" 3 "(well)above average"
lab values economsit_bef economsit_bef
tab economsit_bef


* Education before flight 

mvdecode pukr53 pukr54_1 pukr54_2 pukr54_3 pukr54_4 pukr54_5 pukr54_6 pukr54_7 pukr54_8 pukr54_9 pukr54_10 pukr54_11 pukr54_12 pukr54_no, mv(-8/-1)

gen edu_low_1=.
bysort pid (syear): replace edu_low_1 = pukr54_1[_n-1] if missing(pukr54_1)
gen edu_low_2=.
bysort pid (syear): replace edu_low_2 = pukr54_2[_n-1] if missing(pukr54_2)
gen edu_med_3=.
bysort pid (syear): replace edu_med_3  = pukr54_3[_n-1] if missing(pukr54_3)
gen edu_med_4=.
bysort pid (syear): replace edu_med_4 = pukr54_4[_n-1] if missing(pukr54_4)
gen edu_med_5=.
bysort pid (syear): replace edu_med_5 = pukr54_5[_n-1] if missing(pukr54_5)
gen edu_med_6=.
bysort pid (syear): replace edu_med_6 = pukr54_6[_n-1] if missing(pukr54_6)
gen edu_hig_7=.
bysort pid (syear): replace edu_hig_7 = pukr54_7[_n-1] if missing(pukr54_7)
gen edu_hig_8=.
bysort pid (syear): replace edu_hig_8 = pukr54_8[_n-1] if missing(pukr54_8)
gen edu_hig_9=.
bysort pid (syear): replace edu_hig_9 = pukr54_9[_n-1] if missing(pukr54_9)
gen edu_hig_10=.
bysort pid (syear): replace edu_hig_10 = pukr54_10[_n-1] if missing(pukr54_10)
gen edu_hig_11=.
bysort pid (syear): replace edu_hig_11 = pukr54_11[_n-1] if missing(pukr54_11)
gen edu_hig_12=.
bysort pid (syear): replace edu_hig_12 = pukr54_12[_n-1] if missing(pukr54_12)
gen edu_no=.
bysort pid (syear): replace edu_no = pukr54_no[_n-1] if missing(pukr54_no)

egen any_title = anycount(edu_low_1 edu_low_2 edu_med_3 edu_med_4 edu_med_5 edu_med_6 edu_hig_7 edu_hig_8 edu_hig_9 edu_hig_10 edu_hig_11 edu_hig_12), values(1)

egen edu_high = anycount(edu_hig_7 edu_hig_8 edu_hig_9 edu_hig_10 edu_hig_11 edu_hig_12), values(1)

egen edu_medium = anycount(edu_med_3 edu_med_4 edu_med_5 edu_med_6), values(1)

egen edu_low = anycount(edu_low_1 edu_low_2), values(1)

* school
recode pukr53 (80410003=1) (80410004=2) (80410006=3) (80410007=4) ( 80410008=5) (80410010=6) (80410011=7) (80410012=8), gen(school_t0)
gen school=.
bysort pid (syear): replace school = school_t0[_n-1] if missing(school_t0)


gen edu=. 
replace edu=2 if edu_high>0
replace edu=1 if edu_medium>0 & edu_high==0
replace edu=0 if edu_low>0 & edu_medium==0 & edu_high==0
replace edu=0 if edu==. & any_title==0
lab var edu "Education before flight (level)"
lab def edu 0 "low" 1 "medium" 2 "high"
lab values edu edu


#####
RECODING OF EDUCATION:
* drop existing education
drop edu

* recoding school
tab school
recode school (1 2 3 4 5 6=0 "low") (7 8=1 "medium-high"), gen(school_NEW)

drop any_title edu_high edu_medium edu_low

rename edu_med_5 edu_high_5
rename edu_med_6 edu_high_6

egen any_title = anycount(edu_low_1 edu_low_2 edu_med_3 edu_med_4 edu_high_5 edu_high_6 edu_hig_7 edu_hig_8 edu_hig_9 edu_hig_10 edu_hig_11 edu_hig_12), values(1)

egen edu_high = anycount(edu_high_5 edu_high_6 edu_hig_7 edu_hig_8 edu_hig_9 edu_hig_10 edu_hig_11 edu_hig_12), values(1)

egen edu_medium = anycount(edu_med_3 edu_med_4), values(1)

egen edu_low = anycount(edu_low_1 edu_low_2), values(1)


gen edu=. 
replace edu=2 if edu_high>0 // n=4349/5934
replace edu=1 if edu_medium>0 & edu_high==0  
replace edu=0 if edu_low>0 & edu_medium==0 & edu_high==0
replace edu=0 if edu_no==1
lab var edu "Education before flight (level)"
lab def edu 0 "low" 1 "medium" 2 "high"
lab values edu edu


* Occupational status before war

tab pukr57
mvdecode pukr57, mv(-8/-1)
gen labfst_bef=.
bysort pid (syear): replace labfst_bef=pukr57[_n-1] if missing(pukr57)
list pid syear pukr57 labfst_bef in 1/100
recode labfst_bef (1=1) (2=0) (else=.)
lab var labfst_bef "Employed before flight"
lab def labfst_bef 0 "no" 1 "yes" 
lab values labfst_bef labfst_bef


*   --  --  --  *

*	* Pre-Migration Factors

	* preliminary variables

* date of leaving Ukraine

mvdecode pukr3d pukr3m pukr3y, mv(-8/-1)
gen day_l=.
bysort pid (syear): replace day_l=pukr3d[_n-1] if missing(pukr3d)

gen month_l=.
bysort pid (syear): replace month_l=pukr3m[_n-1] if missing(pukr3m)

gen year_l=.
bysort pid (syear): replace year_l=pukr3y[_n-1] if missing(pukr3y)

gen dateleaving=mdy(month_l, day_l, year_l)
format dateleaving %td

lab var dateleaving "Date of leaving Ukraine"


* date of arrival in Germany
mvdecode pukr4d pukr4m pukr4y, mv(-8/-1)
gen day_a=.
bysort pid (syear): replace day_a=pukr4d[_n-1] if missing(pukr4d)

gen month_a=.
bysort pid (syear): replace month_a=pukr4m[_n-1] if missing(pukr4m)

gen year_a=.
bysort pid (syear): replace year_a=pukr4y[_n-1] if missing(pukr4y)

gen datearrival=mdy(month_a, day_a, year_a)
format datearrival %td

lab var datearrival "Date of arrival in Germany"

* date of interview
tostring end_date, gen(end_date2)
tab end_date2
gen end_date_fin = date(end_date2, "YMD")
tab end_date_fin
format end_date_fin %td

gen survey_arrival= end_date_fin-datearrival
lab var survey_arrival "Days since arrival at data collection"

br pid syear datearrival end_date_fin survey_arrival if syear==2023


* don`t forget: keep if survey_arrival<=365 | dataUkr==. !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!



* appending the Political terror Scale Dataset if (Country==Ukraine | Country==Russia-Occupied Areas (Ukraine)) & Year>=2014 
 
gen dataUkr = 1

append using "I:\MA\amarchitto\SUARE\Ukr_Ref_CS_2022_23\PTS-2023.dta" 


keep if ((Country=="Ukraine" | Country=="Russia-Occupied Areas (Ukraine)") & Year>=2014) | dataUkr==1 



*pre-war/after-war

* using political terror scale data, gen av values of the indicator (if present) Amnesty International, Human Right Watch; US Department
egen avg_pts = rowmean(PTS_A PTS_H PTS_S)

gen dateleaving_war =. 
replace dateleaving_war=1 if dateleaving<=mdy(2,24,2022)
replace dateleaving_war=2 if dateleaving>mdy(2,24,2022) & dateleaving<mdy(4,6,2022)
replace dateleaving_war=3 if dateleaving>=mdy(4,6,2022) & dateleaving<=mdy(9,10,2022)
replace dateleaving_war=4 if dateleaving>mdy(9,10,2022)

mvdecode pukr6, mv(-8/-1)
gen ukr_reg=.
bysort pid (syear): replace ukr_reg=pukr6[_n-1] if missing(pukr6)
lab values ukr_reg pukr6



gen ukr_russ_occupied= .
replace ukr_russ_occupied= 0 if inlist(ukr_reg,2,3,4,5,7,8,9,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26) & dateleaving_war==1
replace ukr_russ_occupied= 1 if inlist(ukr_reg,1,6,10,27) & dateleaving_war==1

replace ukr_russ_occupied= 0 if inlist(ukr_reg,4,5,7,9,11,12,13,14,15,19,20,21,23,24,25,26) & dateleaving_war==2
replace ukr_russ_occupied= 1 if inlist(ukr_reg,1,2,3,6,8,10,16,17,18,22,27) & dateleaving_war==2

replace ukr_russ_occupied= 0 if inlist(ukr_reg,4,5,7,8,9,11,13,14,15,17,18,19,20,21,22,23,24,25,26) & dateleaving_war==3
replace ukr_russ_occupied= 1 if inlist(ukr_reg,1,2,3,6,10,12,16,27) & dateleaving_war==3

replace ukr_russ_occupied= 0 if inlist(ukr_reg,2,4,5,7,8,9,11,12,13,14,15,17,18,19,20,21,22,23,24,25,26) & dateleaving_war==4
replace ukr_russ_occupied= 1 if inlist(ukr_reg,1,3,6,10,16,27) & dateleaving_war==4

* generating variables of pts for each country and each year

gen PTS_Russ_Occ_2022 = 5
gen PTS_Ukr_2014 = 3.666667
gen PTS_Ukr_2015 = 4.333333
gen PTS_Ukr_2016 = 3.666667
gen PTS_Ukr_2017 = 3.666667
gen PTS_Ukr_2018 = 4
gen PTS_Ukr_2019 = 3
gen PTS_Ukr_2020 = 3
gen PTS_Ukr_2021 = 3
gen PTS_Ukr_2022 = 2.666667
  

gen PTS_U_R =.
replace PTS_U_R=PTS_Russ_Occ_2022 if ukr_russ_occupied==1 & dateleaving>=mdy(1,1,2022)
replace PTS_U_R=PTS_Ukr_2022 if ukr_russ_occupied==0 & dateleaving>=mdy(1,1,2022)
replace PTS_U_R=PTS_Ukr_2021 if ukr_russ_occupied==0 & dateleaving>=mdy(1,1,2021) & dateleaving<mdy(1,1,2022)
replace PTS_U_R=PTS_Ukr_2020 if ukr_russ_occupied==0 & dateleaving>=mdy(1,1,2020) & dateleaving<mdy(1,1,2021)
replace PTS_U_R=PTS_Ukr_2019 if ukr_russ_occupied==0 & dateleaving>=mdy(1,1,2019) & dateleaving<mdy(1,1,2020)
replace PTS_U_R=PTS_Ukr_2018 if ukr_russ_occupied==0 & dateleaving>=mdy(1,1,2018) & dateleaving<mdy(1,1,2019)
replace PTS_U_R=PTS_Ukr_2017 if ukr_russ_occupied==0 & dateleaving>=mdy(1,1,2017) & dateleaving<mdy(1,1,2018)
replace PTS_U_R=PTS_Ukr_2016 if ukr_russ_occupied==0 & dateleaving>=mdy(1,1,2016) & dateleaving<mdy(1,1,2017)
replace PTS_U_R=PTS_Ukr_2015 if ukr_russ_occupied==0 & dateleaving>=mdy(1,1,2015) & dateleaving<mdy(1,1,2016)
replace PTS_U_R=PTS_Ukr_2014 if ukr_russ_occupied==0 & dateleaving>=mdy(1,1,2014) & dateleaving<mdy(1,1,2015)


br dateleaving dateleaving_war ukr_russ_occupied PTS_Russ_Occ_2022 PTS_U_R PTS_Ukr_2014 PTS_Ukr_2015 PTS_Ukr_2016 PTS_Ukr_2017 PTS_Ukr_2018 PTS_Ukr_2019 PTS_Ukr_2020 PTS_Ukr_2021 PTS_Ukr_2022

* Create PTS binary (low-high)

gen PTS=.
replace PTS=0 if PTS_U_R<=3
replace PTS=1 if PTS_U_R>3 
lab var PTS "PTS"
lab def PTS 0 "low (<=3)" 1 "high (>3)"
lab values PTS PTS


* Values with political Terror Scale/ Region of Ukraine/dateof leaving



* Sexual abuses, imprisonment, kidnapping, natural disaster... (proxy using Gründe warum Sie Ihr herkunftsland verlassen haben: Krieg/Konflikte; schlechte persönliche Lebensbedigungen; Verfolgung/Diskriminierung)
mvdecode pukr11_1 pukr11_5 pukr11_7, mv(-8/-1)
gen war_conflict=.
bysort pid (syear): replace war_conflict=pukr11_1[_n-1] if missing(pukr11_1)

gen bad_cond=.
bysort pid (syear): replace bad_cond=pukr11_5[_n-1] if missing(pukr11_5)

gen persec_discrim=.
bysort pid (syear): replace persec_discrim=pukr11_7[_n-1] if missing(pukr11_7)


egen traum_exper_bef = anycount(war_conflict bad_cond persec_discrim), values(1)

	* recoding 0 if none of reasons to leave were selected; 1=one or more reasons were named
recode traum_exper_bef (0=0) (1 2 3=1) (else=.), gen(traum_exp_bef_bin)
label var traum_exp_bef_bin "Traumatic experiences (reasons for leaving)"
lab def traum_exp_bef_bin 0 "none" 1 "one/more" 
lab values traum_exp_bef_bin traum_exp_bef_bin


*   --  --  --  *

*	* Peri-Migration Factors

* duration of flight
gen duration=datearrival-dateleaving
replace duration=. if duration<0


egen duration_cut_sens = cut(duration), at(0,2,8,30,2000) label
label var duration_cut_sens "Duration of flight"
labe drop duration_cut_sens
label def duration_cut_sens 0 "0-1 day" 1 "2-7 days" 2 "1-4 weeks" 3 "more than a month" 
lab val duration_cut_sens duration_cut_sens


* Traumatic experience during the flight???? (NOT AVAILABLE FOR UKR SURVEY)


*   --  --  --  *

*	* Post-Migration Factors
* date of interview
recode survey_arrival (0/182=0) (183/365=1) (else=.), gen(arrivalmonths)
lab var arrivalmonths "Time in Germany since arrival"
lab def arrivalmonths 0 "0-6 months" 1 "6-12 months"
lab values arrivalmonths arrivalmonths 

* language course/integration courses
tab pukr263
tab pukr265_1
mvdecode pukr263 pukr265_1, mv(-8/-1)
gen germ_course=.
replace germ_course=1 if pukr263==1 | pukr265_1==1
replace germ_course=0 if pukr263==2 & pukr265_1!=1
replace germ_course=0 if pukr263!=1 & pukr265_1==0
lab var germ_course "Attended German language/integration course"
lab def germ_course 0 "no" 1 "yes"
lab values germ_course germ_course

* language profiency (Ukraininan refugees sample - year 2022)
mvdecode pukr84 pukr85 pukr86, mv(-8/-1)
vreverse pukr84, gen(DEU_speaking_rev)
vreverse pukr85, gen(DEU_writing_rev)
vreverse pukr86, gen(DEU_reading_rev)
alpha DEU_speaking_rev DEU_writing_rev DEU_reading_rev

egen german_proficiency_avg = rowmean(DEU_speaking_rev DEU_writing_rev DEU_reading_rev)
egen german_proficiency_cut= cut(german_proficiency_avg), at(1,2,3,4,5,6)
tab german_proficiency_avg german_proficiency_cut

lab var german_proficiency_cut "German language proficiency"
lab def german_proficiency_cut 1 "none" 2 "poor" 3 "sufficient" 4 "good" 5 "excellent"
lab values german_proficiency_cut german_proficiency_cut

recode german_proficiency_cut (1 2=1 "none/poor") (3=2 "sufficient") (4 5=3 "good/excellent"), gen(german_proficiency_cut_new)


/* Louise-fpr comparison
gen neu_speak=pukr84
recode neu_speak .=. 1=5 2=4 3=3 4=2 5=1

gen neu_writ=pukr85
recode neu_writ .=. 1=5 2=4 3=3 4=2 5=1

gen neu_read=pukr86
recode neu_read .=. 1=5 2=4 3=3 4=2 5=1

egen L_german_proficiency_avg = rowmean(neu_speak neu_writ neu_read)
egen L_german_proficiency_cut= cut(L_german_proficiency_avg), at(1,2,3,4,5,6)
tab L_german_proficiency_avg L_german_proficiency_cut

lab var L_german_proficiency_cut "German language proficiency"
lab def L_german_proficiency_cut 1 "none" 2 "poor" 3 "sufficient" 4 "good" 5 "excellent"
lab values L_german_proficiency_cut L_german_proficiency_cut

recode L_german_proficiency_cut (1 2=1 "none/poor") (3=2 "sufficient") (4 5=3 "good/excellent"), gen(L_german_proficiency_cut_new)

*/
******



* Perceived discrimination
mvdecode pukr236, mv(-8/-1)
recode pukr236 (3=0) (1 2=1), gen(discr_bin)
lab var discr_bin "Perceived discrimination"
lab def  discr_bin 0 "never" 1 "seldomly/often"
lab values discr_bin discr_bin
tab discr_bin

* Social isolation (feeling alone as proxy)
recode pukr78 (1 2 3=0) (4 5=1) (else=.), gen(soc_isolation)
lab var soc_isolation "Social isolation (statement of 'feeling alone')"
lab def soc_isolation 0 "do not apply (at all)/neutral position" 1 "applies (fully)"
lab values soc_isolation soc_isolation

* family Situation/separation

	* Family Status
mvdecode pukr32 pukr33, mv(-8/-1)
gen partner=.
replace partner=1 if pukr32==1 | pukr33==1
replace partner=0 if pukr33==2 & pukr32!=1
	
gen famstat = .
replace famstat=1 if partner==1
replace famstat=2 if partner==0 & pukr32==2
replace famstat=3 if partner==0 & pukr32==3
replace famstat=4 if partner==0 & pukr32==4
label var famstat "Family status"
lab def famstat 1 "married/partner" 2 "single" 3 "divorced" 4 "widowed"
lab values famstat famstat


* Living land of partner
mvdecode pukr36, mv(-8/-1)
recode pukr36 (1=1) (2 3 4=2), gen(land_partner)
replace land_partner=0 if partner==0
lab var land_partner "Partner's living place"
lab def land_partner 0 "no partner" 1 "Germany" 2 "Ukraine/abroad"
lab values land_partner land_partner

* children
mvdecode pukr39 pukr39no, mv(-8/-1)
gen children=.
replace children= 0 if pukr39no==1
replace children=1 if pukr39>=1 & pukr39no!=1
lab var children "Children"
lab def children 0 "no child" 1 "one/more"
lab values children children

* living land of children (first 3. children)
mvdecode pukr285_1 pukr285_2 pukr285_3, mv(-8/-1)

recode pukr285_1 (1=1) (2 3=0), gen(child_1)
recode pukr285_2 (1=1) (2 3=0), gen(child_2)
recode pukr285_3 (1=1) (2 3=0), gen(child_3)
egen child_all = anycount(child_1 child_2 child_3), values(1)


gen children_Germ=.
replace children_Germ=0 if children==0
replace children_Germ=1 if children==1 & child_all==3
replace children_Germ=2 if children==1 & (child_all==2 | child_all==1)
replace children_Germ=3 if children==1 & child_all==0
lab var children_Germ "Children living place"
lab def children_Germ 0 "no child" 1 "all children in Germany" 2 "some in Germany/some abroad/Ukraine" 3 "all children abroad/Ukraine"
lab values children_Germ children_Germ

* Alternative?
gen children_Germ2=.
replace children_Germ2=0 if children==0
replace children_Germ2=1 if children==1 & child_all==3
replace children_Germ2=2 if children==1 & child_all<=2 
lab var children_Germ2 "Children living place"
lab def children_Germ2 0 "no child" 1 "all children in Germany" 2 "all/some abroad/Ukraine"
lab values children_Germ2 children_Germ2

* Best alternative!!!!!!

egen child_abroad = anycount(child_1 child_2 child_3), values(0)

gen children_germ=.
replace children_germ=0 if children==0
replace children_germ=1 if children==1 & child_abroad==0
replace children_germ=2 if children==1 & child_abroad==1
replace children_germ=3 if children==1 & child_abroad==2
replace children_germ=4 if children==1 & child_abroad==3 
lab var children_germ "Children living place"
lab def children_germ 0 "no child" 1 "all in Germany" 2 "one abroad" 3 "two abroad" 4 "all abroad"
lab values children_germ children_germ

 * children abroad simplified
recode children_germ (0=0) (1=1) (2 3 4=2), gen(children_germ_simplified_1)
tab children_germ children_germ_simplified_1


* children living in the same haushold of respondents (first 3 kids)
mvdecode pukr284_1 pukr284_2 pukr284_3, mv(-8/-1)
recode pukr284_1 (1=1) (2=0), gen(child_house_1)
recode pukr284_2 (1=1) (2=0), gen(child_house_2)
recode pukr284_3 (1=1) (2=0), gen(child_house_3)

egen child_house = anycount(child_house_1 child_house_2 child_house_3), values(1)
egen child_house_no = anycount(child_house_1 child_house_2 child_house_3), values(0)

sort pid syear
br pid pukr39 children child_house_1 child_house_2 child_house_3 child_house child_house_no child_1 child_2 child_3 child_abroad children_germ_simplified_1 if syear==2023

* VERY FINAL CHILDREN PLACE VARIABLE
gen children_germ_simplified=.
replace children_germ_simplified=0 if children==0
replace children_germ_simplified=1 if child_house>0
replace children_germ_simplified=1 if child_house_no>0 & children_germ_simplified_1==1
replace children_germ_simplified=2 if child_house_no>0 & children_germ_simplified_1==2
lab var children_germ_simplified "Children living place"
lab def children_germ_simplified 0 "no child" 1 "one/all in Germany" 2 "one/all in Ukraine/abroad"
lab values children_germ_simplified children_germ_simplified

br pid pukr39 children child_house child_house_no child_abroad children_germ_simplified_1 children_germ_simplified if syear==2023


* residence permit/status
mvdecode pukr10, mv(-8/-1)
recode pukr10 (1 6=1) (2 5=2) (3 4=3), gen(residence_status)
lab var residence_status "Residence status"
lab def residence_status 1 "no/unclear" 2 "other resid. permits" 3 "resid. permit(TPD, §24 AsylbLG)"
lab values residence_status residence_status
 
* accomodation = directly reporting non-missing values (2023) from variables pukr19 and pukr19_v1 / reporting time-invariant non-missing values from pukr19 (2022) if missing by follow-up 
mvdecode pukr19 pukr19_v1, mv(-8/-1)
gen accomodation=.
replace accomodation=pukr19
replace accomodation=pukr19_v1 if pukr19_v1!=.
bysort pid (syear): replace accomodation=pukr19[_n-1] if missing(pukr19)
lab var accomodation "Type of accommodation"
lab def accomodation 1 "shared accom. for refugees" 2 "private apartment/house" 3 "other accommodation"
lab values accomodation accomodation 


* Occupational status now
tab pukr62
recode pukr62 (1=1) (2 4=2) (5 6=3) (7=4) (else=.), gen(labfst_now)
lab var labfst_now "Labor force status (now)"
lab def labfst_now 1 "fully employed" 2 "part-time/marginally employed" 3 "apprenticenship" 4 "unemployed"
lab values labfst_now labfst_now

* Occupational status_ALTERNATIVE
recode labfst_now (1 3=1 "fully employed/apprenticenship") (2=2 "part-time/marginally employed") (4=3 "unemployed"), gen(labfst_now_new)
lab var labfst_now_new "Labor force status (now)"

* social connectedness: with Germans, with Ukrainians non-relative
mvdecode pukr74 pukr75, mv(-8/-1)
* with Ukrainians
recode pukr74 (5 6=0) (3 4=1) (1 2=2), gen(contact_ukrainians)
lab var contact_ukrainians "Contact with Ukrainians (non-relative)"
lab def contact_ukrainians 0 "no/seldomly" 1 "often" 2 "very often"
lab values contact_ukrainians contact_ukrainians 

* with Germans
recode pukr75 (5 6=0) (3 4=1) (1 2=2), gen(contact_germans)
lab var contact_germans "Contact with Germans"
lab def contact_germans 0 "no/seldomly" 1 "often" 2 "very often"
lab values contact_germans contact_germans 

* selecting all surveyed within one year
keep if survey_arrival<=365

*****************************************************************************
* MERGING/JOYINING DATA WITH ACLED - DATA

* reshaping var "ukr_reg" changin
tab ukr_reg 

recode ukr_reg (1 27=1 "Autonomous Republic of Crimea + Sevastopol") ///
(2=2 "Kharkiv Oblast") ///
(3=3 "Kherson Oblast") ///
(4=4 "Khmelnytskyi Oblast") ///
(5=5 "Dnipropetrovsk Oblast") ///
(6=6 "Donetsk Oblast") ///
(7=7 "Ivano-Frankivsk Oblast") ///
(8=8 "Kyiv Oblast") ///
(9=9 "Kirovohrad Oblast") ///
(10=10 "Luhansk Oblast") ///
(11=11 "Lviv Oblast") ///
(12=12 "Mykolaiv Oblast") ///
(13=13 "Odesa Oblast") ///
(14=14 "Poltava Oblast") ///
(15=15 "Rivne Oblast") ///
(16=16 "Zaporizhzhia Oblast") ///
(17=17 "Zhytomyr Oblast") ///
(18=18 "Sumy Oblast") ///
(19=19 "Ternopil Oblast") ///
(20=20 "Zakarpattia Oblast") ///
(21=21 "Cherkasy Oblast") ///
(22=22 "Chernihiv Oblast") ///
(23=23 "Chernivtsi Oblast") ///
(24=24 "Vinnytsia Oblast") ///
(25=25 "Volyn Oblast") ///
(26=26 "Kyiv") (else=.), gen(ukr_reg_match) 
lab var ukr_reg_match "Ukrainian regions"


*****************************************************************************

**** merging with ACLED Dataset (multiplication of all pairwise combnation of datasets: n=11,221,203)
joinby ukr_reg_match using "I:\MA\amarchitto\SUARE\Ukr_Ref_CS_2022_23\ACLED_modified_ukr_APR_24_final.dta", unmatched(master) _merge(_merge)

*\ matching of dataset generated each pid and each region (Ukrainian) multiple observation according to var "event_date_new"

br pid ukr_reg_match dateleaving end_date_fin event_date_new fatalities_new
br pid ukr_reg_match dateleaving event_date_new fatalities_new
sort pid event_date_new
br pid ukr_reg_match dateleaving  event_date_new fatalities_new


************************************************************
*** Fatalities pre-migration

* counting all fatalities by pid and region previously happened before date of leaving
bysort pid (event_date_new): egen fatalities_cum = total(fatalities_new[_n-1]) if event_date_new<=dateleaving

br pid ukr_reg_match dateleaving end_date_fin event_date_new fatalities_new fatalities_cum if pid==10000005
br pid ukr_reg_match dateleaving end_date_fin event_date_new fatalities_new fatalities_cum if pid==10000442

* reporting this value for all observation by pid by using egen: max() function
bys pid: egen fatalities_cum_1 = max(fatalities_cum)

lab var fatalities_cum_1 "Fatalities before leaving UKR (cum)"
	* check:
br pid ukr_reg_match dateleaving end_date_fin event_date_new fatalities_new fatalities_cum fatalities_cum_1 if pid==10000005

* counting all fatalities by pid and region happened between the day the war started (24feb2022) and dateleaving
bysort pid (event_date_new): egen fatalities_cum_since_war = total(fatalities_new[_n-1]) if event_date_new<=dateleaving & event_date_new>=mdy(2,24,2022)
bys pid: egen fatalities_cum_since_war_1 = max(fatalities_cum_since_war)
lab var fatalities_cum_since_war_1 "Fatalities btw leaving UKR and war's start (cum)"
	* check:
br pid ukr_reg_match dateleaving end_date_fin event_date_new fatalities_new fatalities_cum fatalities_cum_since_war fatalities_cum_since_war_1 if pid==10000005


* splitting fatalities_cum into quintiles
xtile quintile_fatalities_cum= fatalities_cum, n(5)

tab fatalities_cum quintile_fatalities_cum
bys pid: egen quintile_fatalities_cum_1 = max(quintile_fatalities_cum)

lab var quintile_fatalities_cum_1 "Fatalities before leaving UKR (quintile)"
lab def quintile_fatalities_cum_1 1 "1Q: 0-4 fatalities" 2 "2Q: 6-30 fatalities" 3 "3Q: 32-70 fatalities" 4 "4Q: 72-244 fatalities" 5 "5Q: 246-2614 fatalities"
lab values quintile_fatalities_cum_1 quintile_fatalities_cum_1     
tab quintile_fatalities_cum_1

* splitting fatalities_cum_since_war into quintiles
xtile quintile_fatalities_cum_sw= fatalities_cum_since_war, n(5)

tab fatalities_cum_since_war quintile_fatalities_cum_sw
bys pid: egen quintile_fatalities_cum_sw_1 = max(quintile_fatalities_cum_sw)

lab var quintile_fatalities_cum_sw_1 "Fatalities btw leaving UKR and war's start (quintile)"
lab def quintile_fatalities_cum_sw_1 1 "1Q: 0-10 fatalities" 2 "2Q: 12-54 fatalities" 3 "3Q: 58-160 fatalities" 4 "4Q: 162-720 fatalities" 5 "5Q: 722-2532 fatalities"
lab values quintile_fatalities_cum_sw_1 quintile_fatalities_cum_sw_1
tab quintile_fatalities_cum_sw_1


*** Fatalities post-migration

* counting fatalities happend since the day of interview and till 7 days before by pid and region

bysort pid (event_date_new): gen fatalities_cum_7days = fatalities_new + fatalities_new[_n-1] + fatalities_new[_n-2] + fatalities_new[_n-3] + fatalities_new[_n-4] + fatalities_new[_n-5] + fatalities_new[_n-6] + fatalities_new[_n-7] if event_date_new<=end_date_fin & event_date_new>=end_date_fin[_n-7]
	// it generetas one single obs each pid with the cumulative numeber of fatalities since 7 days before day of data collection/interview (n=5943)
lab var fatalities_cum_7days "Fatalities 7 days before day of interview (cum)"	
	
* quintile fatalities_cum_post
xtile tertile_fatalities_cum_7days= fatalities_cum_7days, n(3)
lab var tertile_fatalities_cum_7days "Fatalities 7 days before day of interview (tertile)"
lab def tertile_fatalities_cum_7days 1 "1Q: 0 fatality" 2 "2Q: 2-4fatalities" 3 "3Q: 6-94 fatalities"
lab values tertile_fatalities_cum_7days tertile_fatalities_cum_7days
tab tertile_fatalities_cum_7days
	

	
	
	
*******
******
*****
****
***
**
*

* to return to original numbero of pid observations of ukr sample: n=5943
bys pid: keep if tertile_fatalities_cum_7days!=.
 

* save dataset final
save uks_2023_final_JUN_24.dta, replace