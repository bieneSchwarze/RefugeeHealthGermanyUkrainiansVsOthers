* REFUGEES M3-M6 CROSS-SECTION ANALYSIS 2022

set maxvar 120000

cd "I:\MA\amarchitto\SUARE\Ukr_Ref_CS_2022_23\Ref_2022"

* uploading all variable form different datasets (from Office: U:\complete\soep-core\soep.v38.1\consolidated14)
global ref_soep_core_v38_1 "U:\complete\soep-core\soep.v38.1\consolidated14"


use pid syear cid hid sex gebjahr gebmonat eintritt psample netto immiyear corigin migback arefback phrf using $ref_soep_core_v38_1\ppathl.dta, clear


keep if psample>=17 & psample<=19 | psample==24
tab psample

* merge with biol dataset
merge 1:1 pid syear using $ref_soep_core_v38_1\biol.dta, keep(master match) nogen


keep pid hid syear sex gebjahr eintritt psample netto immiyear corigin gebmonat migback arefback phrf lr3046 lr3031 lr3032 lr3033_h lr3033_v1 lr3084 lr3087 lr3085 lr3086 lr3094 lr3095 lm0016 lm0017 lm0018 lr3130 lr3131 lr3122 lr3123 lr3124 lr3125 lr3126 lr3127 lr3128 lr3129 lr3235 lr3236 lb0285 lr3193 lr3195 lr3198 lr3200 lr3204 lr3206 lr3208 lr3211

gen age=syear-gebjahr

* merge with pgen
merge 1:1 pid syear using $ref_soep_core_v38_1\pgen.dta, keep(master match) keepusing(pgmonth pgisced11 pgfamstd)nogen

* merging with pl with other variables
merge 1:1 pid syear using  $ref_soep_core_v38_1\pl.dta, keep(master match) keepusing(ple0008 plj0654_h plj0654_v1 plj0654_v2 plj0499_h plj0499_v1 plj0499_v2 plj0535 plj0071 plj0072 plj0073 plj0048_v1 plj0048_v2 plj0589 plj0680_h plj0680_v1 plj0680_v2 plj0626 pld0131_v1  pld0131_v2  pld0131_v3 plj0629 plj0627_v1 plj0627_v2 plj0630 plb0022_h plj0568 plj0569) nogen

*merging with hl for variable (hlj0005_h) Type of accomodation harmonized
merge m:1 hid syear using $ref_soep_core_v38_1\hl.dta, keep(master match) keepusing(hlj0005_h) nogen

**********************************************************************************



*create dummy date variable
gen day=15
 
*create STATA date variable for survey year
gen surveydate=mdy(pgmonth, day, syear)
format surveydate %td
label var surveydate "Date of survey"
 
*calculate months since arrival
*create STATA date for entry to Germany
gen entrydate=mdy(lr3131, day, lr3130)
format entrydate %td
label var entrydate "Date of arrival in Germany"
 
*fill entry date for all survey waves
by pid, sort: egen doe=max(entrydate)
format doe %td
br pid syear immiyear lr3131 entrydate doe surveydate 
br pid syear immiyear lr3131 entrydate doe surveydate if syear<=2016

 
*calculate days since arrival and categorise as months since arrival
gen arrivaldays=surveydate-doe
label var arrivaldays "Days since arrival at data collection"
hist arrivaldays, width(100)
replace arrivaldays=. if arrivaldays<0


* only interviewed within one year since day of arrival
tab arrivaldays
tab immiyear if arrivaldays<=365
tab corigin if arrivaldays<=365

* keep just adult population (n=1192) & arrivaldays<=365
keep if age>=18
keep if arrivaldays<=365

* merging data with PTS datasets
mvdecode lm0016, mv(-8/-1)
gen Year=lm0016

br pid syear Year
tab Year, m /// varaible with 97 missings (cannot be replaced by information from immiyear variable, because immiyear indicates the arriva year in Germany, while Year (or lm0016) indicates the year of leaving the country of origin)

gen country_new=corigin
label values country_new corigin
list corigin country_new in 1/100

joinby country_new Year using "I:\MA\amarchitto\SUARE\Ukr_Ref_CS_2022_23\Ref_2022\PTS_modified_ref.dta", unmatched(master)

br pid syear corigin country_new country Year lm0016 avg_pts

* excluding younger interviewed refugees (netto==29)
tab netto
keep if netto!=29


*________________________________________________________________________

* STEP 1: data cleaning

*	* Dependent Variable Y 

* General Health 2023 (binary)

mvdecode ple0008, mv(-8/-1)
recode ple0008 (1 2 3=0) (4 5=1), gen(health_bin)
label var health_bin "General health (self-rated)"
lab def health_bin 0 "good/satisf" 1 "bad"
lab values health_bin health_bin
tab health_bin

* General Health 2023 (binary), differently coded for sensitivity analysis
recode ple0008 (1 2=0) (3 4 5=1), gen(health_bin_sens)
label var health_bin_sens "General health  (self-rated)"
lab def health_bin_sens 0 "good" 1 "satisf/bad"
lab values health_bin_sens health_bin_sens
tab health_bin_sens

*   --  --  --  *

*	* Cross-Cutting Aspects

* Gender
mvdecode sex, mv(-8/-1) 
recode sex (1=1 "male") (2=2 "female"),gen(gender)
lab var gender "Gender"

* Age (alredy defined)
tab age, m
egen age_cut = cut(age), at(18,31,50,100) label
label var age_cut "Age group"
label drop age_cut
lab def age_cut 0 "18-30" 1 "31-49" 2 "50+"
lab val age_cut age_cut

* Country of origin (simplified)
recode corigin (4=4 "Afghanistan") (368=368 "Iraq") (760=760 "Syria") (else=900 "Other countries"), gen(corigin_simpl)
lab var corigin_simpl "Country of birth"

* Economic situation before flight

tab lr3046 syear
mvdecode lr3046, mv(-8/-1)
recode lr3046 (4 5=1) (3=2) (1 2=3), gen(economsit_bef)
lab var economsit_bef "Economic situation before flight"
lab def economsit_bef 1 "(well)below average" 2 "on average" 3 "(well)above average"
lab values economsit_bef economsit_bef
tab economsit_bef


* Education before flight 

mvdecode pgisced11, mv(-8/-1)

gen edu=pgisced11
replace edu=. if pgisced11<0
replace edu=0 if pgisced11==0 | pgisced11==1  | pgisced11==2
replace edu=1 if pgisced11==3 | pgisced11==4  | pgisced11==5
replace edu=2 if pgisced11>=6 
label def edu 0 "low" 1 "medium" 2 "high", modify
label values edu edu 
label var edu "level of education"
tab edu

*** new coding for education:
drop edu

gen edu=pgisced11
replace edu=. if pgisced11<0
replace edu=0 if pgisced11==0 | pgisced11==1  | pgisced11==2
replace edu=1 if pgisced11==3 | pgisced11==4
replace edu=2 if pgisced11>=5 
label def edu 0 "low" 1 "medium" 2 "high", modify
label values edu edu 
label var edu "level of education"
tab edu


* Occupational status before war

br pid syear lr3031 lr3032 lr3033_h
mvdecode lr3031, mv(-8/-1)

gen labfst_bef=.
replace labfst_bef=0 if lr3032==1 | lr3033_h==1
replace labfst_bef=1 if labfst_bef==. & lr3031!=.
lab var labfst_bef "Employed before flight"
lab def labfst_bef 0 "no" 1 "yes" 
lab values labfst_bef labfst_bef



*   --  --  --  *

*	* Pre-Migration Factors

	* preliminary variables

* date of leaving country of origin
tab Year
mvdecode lm0017, mv(-8/-1)

gen dateleaving=mdy(lm0017, day, Year)
format dateleaving %td
lab var dateleaving "Date of leaving country of origin"


* date of arrival in Germany

tab entrydate, m

* date of interview

tab surveydate, m 

* days since arrival 

tab arrivaldays, m


* Create PTS binary (low-high)
tab avg_pts, m
gen PTS=.
replace PTS=0 if avg_pts<=3
replace PTS=1 if avg_pts>3 
lab var PTS "PTS (avg)"
lab def PTS 0 "low (<=3)" 1 "high (>3)"
lab values PTS PTS



* Sexual abuses, imprisonment, kidnapping, natural disaster... (proxy using Gründe warum Sie Ihr herkunftsland verlassen haben: Vertreibung/Ausweisung; schlechte persönliche Lebensbedigungen; Verfolgung; Diskriminierung)
br pid syear lr3084 lr3085 lr3086 lr3087
mvdecode lr3084 lr3085 lr3086 lr3087, mv(-8/-1)

egen traum_exper_bef = anycount(lr3084 lr3085 lr3086 lr3087), values(1)

	* recoding 0 if none of reasons to leave were selected; 1=one or more reasons were named
recode traum_exper_bef (0=0) (1 2 3 4=1) (else=.), gen(traum_exp_bef_bin)
label var traum_exp_bef_bin "Traumatic experiences (reasons for leaving)"
lab def traum_exp_bef_bin 0 "no" 1 "one/more" 
lab values traum_exp_bef_bin traum_exp_bef_bin


*   --  --  --  *

*	* Peri-Migration Factors

* duration of flight (VAR= "entrydate" (date of entry in Germany) - "dateleaving" (date of living the country of birth))

gen duration=entrydate-dateleaving
replace duration=. if duration<0

egen duration_cut = cut(duration), at (0,31,183,366,20000) label
label var duration_cut "Duration of flight"
labe drop duration_cut
label define duration_cut 0 "within a month" 1 "2-6 months" 2 "7-12 months" 3 ">12 months"
label val duration_cut duration_cut
tab duration_cut

	* alternative comparable with Ukraininans (other variable used than for duration_cut !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!)
mvdecode lr3095, mv(-8/-1)
egen duration_cut_comparable = cut(lr3095), at(0,2,8,30,2000) label
label var duration_cut_comparable "Duration of flight"
labe drop duration_cut_comparable
label define duration_cut_comparable 0 "0-1 day" 1 "2-7 days" 2 "1-4 weeks" 3 "more than a month"
label val duration_cut_comparable duration_cut_comparable
tab duration_cut_comparable

	* duration of flight for sensitivity analysis (using "lr3095" if Refugee traveled directly to germany after having left their country of birth (if lm0018==1), and "lr3094" if they flew to Germany from one another countries than their country of birth (if lm0018==2)
mvdecode lm0018 lr3095 lr3094, mv(-8/-1)
gen duration_sens=.
replace duration_sens = lr3095 if lm0018==1 	
replace duration_sens = lr3094 if lm0018==2
tab duration_sens, m

egen duration_cut_sens = cut(duration_sens), at(0,8,31,183,20000) label
label var duration_cut_sens "Duration of flight"
labe drop duration_cut_sens
label define duration_cut_sens 0 "0-7 days" 1 "1-4 weeks" 2 "1-6 months" 3 ">6 months"
label val duration_cut_sens duration_cut_sens
tab duration_cut_sens, m
 	

* Traumatic experience during the flight (including: econ. betrayal/exploitaition, sexual harassment, physical attacks, shipwreck, robbery, blackmail, prison/ no traumatic experiences)

br pid syear lr3122 lr3123 lr3124 lr3125 lr3126 lr3127 lr3128 lr3129
mvdecode lr3122 lr3123 lr3124 lr3125 lr3126 lr3127 lr3128 lr3129, mv(-8/-1)

egen traum_count=anycount(lr3122 lr3123 lr3124 lr3125 lr3126 lr3127 lr3128), values(1)

gen tram_exper_during_sens=.
replace tram_exper_during_sens=0 if lr3129==1 | traum_count==0
replace tram_exper_during_sens=1 if traum_count>0
lab var tram_exper_during_sens "Traumatic experiences during flight"
lab def tram_exper_during_sens 0 "no" 1 "one/more"
lab values tram_exper_during_sens tram_exper_during_sens




*   --  --  --  *

*	* Post-Migration Factors
* days since arrival in Germany
tab arrivaldays, m /// (0, 365)

recode arrivaldays (0/182=0) (183/365=1) (else=.), gen(arrivalmonths)
lab var arrivalmonths "Time since arrival in Germany"
lab def arrivalmonths 0 "0-6 months" 1 "6-12 months"
lab values arrivalmonths arrivalmonths 

* language course/inegration course/professional course
/// integrationskurs (plj0654_h) / berufsbezogens Deutsch (plj0499_h) / andere Deutschsprachkurs (plj0535)

mvdecode plj0654_h plj0499_h plj0535, mv(-8/-1)
egen germ_course=anycount(plj0654_h plj0499_h plj0535), values(1)
gen germ_int_course=.
replace germ_int_course=0 if germ_course==0
replace germ_int_course=1 if germ_course>=1
lab var germ_int_course "Attended German language/integration/ESF-BAMF course"
lab def germ_int_course 0 "no" 1 "yes"
lab values germ_int_course germ_int_course


* language profiency

*German language proficiency
gen DEU_speak = plj0071
lab var DEU_speak "German speaking"
tab DEU_speak

gen DEU_writing = plj0072
lab var DEU_writing "German writing"
tab DEU_writing

gen DEU_reading = plj0073
lab var DEU_reading "German reading"
tab DEU_reading

label def language 4 "very good" 0 "not at all"

	foreach var of varlist DEU_speak DEU_writing DEU_reading {
		recode `var' (1=4) (2=3) (3=2) (4=1) (5=0) (-10/-1 = .) 
		lab val `var' language
		}

gen german_proficiency = DEU_speak + DEU_writing + DEU_reading
lab var german_proficiency "German language proficiency"
tab german_proficiency

*German language proficiency alternative
* GERMAN LANGUAGE PROFICIENCY categorical (refugees sample - year 2021)
mvdecode plj0071 plj0072 plj0073, mv(-8/-1)

vreverse plj0071, gen(DEU_speaking_rev)
vreverse plj0072, gen(DEU_writing_rev)
vreverse plj0073, gen(DEU_reading_rev)

*(Cronbach's alpha=0,92)
alpha DEU_speaking_rev DEU_writing_rev DEU_reading_rev


egen german_proficiency_avg = rowmean(DEU_speaking_rev DEU_writing_rev DEU_reading_rev)
egen german_proficiency_cut= cut(german_proficiency_avg), at(1,2,3,4,5,6)
tab german_proficiency_avg german_proficiency_cut

lab var german_proficiency_cut "German language proficiency"
lab def german_proficiency_cut 1 "none" 2 "poor" 3 "sufficient" 4 "good" 5 "excellent"
lab values german_proficiency_cut german_proficiency_cut

recode german_proficiency_cut (1 2=1 "none/poor") (3=2 "sufficient") (4 5=3 "good/excellent"), gen(german_proficiency_cut_new)



* Perceived discrimination
mvdecode plj0048_v1 plj0048_v2, mv(-8/-1)
gen discr=.
replace discr=plj0048_v1 if syear==2017
replace discr=plj0048_v2 if syear==2016 | syear>=2018
recode discr (3=0) (1 2=1), gen(discr_bin)
lab var discr_bin "Perceived discrimination"
lab def  discr_bin 0 "never" 1 "seldomly/often"
lab values discr_bin discr_bin
tab discr_bin

* Social isolation 
mvdecode plj0589, mv(-8/-1)
recode plj0589 (3 4 5=0) (1 2=1), gen(soc_isolation)
lab var soc_isolation "Feeling socially isolated"
lab def soc_isolation 0 "never/sometimes" 1 "(very)often"
lab values soc_isolation soc_isolation



* family Situation/separation

	* Family Status
mvdecode plj0626 plj0629, mv(-8/-1)
gen partner=.
replace partner=1 if plj0626==2 | plj0629==1
replace partner=0 if plj0629==2 & plj0626!=2
	
gen famstat = .
replace famstat=1 if partner==1
replace famstat=2 if partner==0 & plj0626==1
replace famstat=3 if partner==0 & plj0626==4
replace famstat=4 if partner==0 & plj0626==6
label var famstat "Family status/situation"
lab def famstat 1 "married/partner" 2 "single" 3 "divorced" 4 "widowed"
lab values famstat famstat


* Living land of partner
mvdecode plj0627_v1 pgfamstd plj0630, mv(-8/-1)
gen land_partner=0 if partner==0
replace land_partner=1 if partner==1 & (inlist(plj0627_v1,1,2,3) | inlist(plj0630,1,2,3))
replace land_partner=2 if partner==1 & (inlist(plj0627_v1,4,5) | inlist(plj0630,4,5))
lab var land_partner "Partner's living place"
lab def land_partner 0 "no partner" 1 "Germany" 2 "country of origin/abroad"
lab values land_partner land_partner
tab land_partner

* children
tab lb0285
mvdecode lb0285, mv(-5, -1)
recode lb0285 (-2=0) (1/15=1), gen(children)
lab var children "Children"
lab def children 0 "no child" 1 "one/more"
lab values children children

* living land of children (first 3. children)
mvdecode lr3193 lr3195 lr3198, mv(-8/-1)

recode lr3193 (1 2 3=1) (4 5 6=0), gen(child_1)
recode lr3195 (1 2 3=1) (4 5 6=0), gen(child_2)
recode lr3198 (1 2 3=1) (4 5 6=0), gen(child_3)
egen child_all = anycount(child_1 child_2 child_3), values(1)

* Best alternative!!!!!!

egen child_abroad = anycount(child_1 child_2 child_3), values(0)

gen children_germ=.
replace children_germ=0 if children==0
replace children_germ=1 if children==1 & child_abroad==0
replace children_germ=2 if children==1 & child_abroad==1
replace children_germ=3 if children==1 & child_abroad==2
replace children_germ=4 if children==1 & child_abroad==3 
lab var children_germ "Children living place"
lab def children_germ 0 "no child" 1 "all in Germany" 2 "one abroad/died" 3 "two abroad/died" 4 "all abroad/decesead"
lab values children_germ children_germ

 * children abroad simplified
recode children_germ (0=0) (1=1) (2 3 4=2), gen(children_germ_simplified)
tab children_germ children_germ_simplified
lab var children_germ_simplified "Children living place"
lab def children_germ_simplified 0 "no child" 1 "one/all in Germany" 2 "one/all abroad/died"
lab values children_germ_simplified children_germ_simplified

* residence permit/status
mvdecode plj0680_h, mv(-8/-1)
recode plj0680_h (1=1 "no/awaiting outcome") (5 7=2 "other residence permit/'Duldung'") (2 3 4 6=3 "residence permit (temporary/permanent"), gen(residence_status)
lab var residence_status "Residence/asylum status"

 
* accomodation (362 missings)
tab lr3235 lr3236
recode lr3236 (1 2=1 "shared accommodation for refugees") (3 4=2 "private apartment/house") (5=3 "other accommodation") (else=.), gen(accomodation)
lab var accomodation "Type of accommodation"

* accomodation alternative
tab hlj0005_h, m
recode lr3236 (1 2=1 "shared accom. for refugees") (3 4=2 "private apartment/house") (5=3 "other accommodation") (else=.), gen(lr3236_new)
recode hlj0005_h (1=1 "shared accom. for refugees") (2=2 "private apartment/house") (else=.), gen(hlj0005_h_new)
gen accomodation_new=lr3236_new if lr3235==2
replace accomodation_new=hlj0005_h_new if accomodation_new==.
lab var accomodation_new "Type of accommodation"
lab values accomodation_new lr3236_new


* Occupational status now
tab plb0022_h syear, m
recode plb0022_h (1=1) (2 4=2) (10=3) (9=4), gen(labfst_now) 
lab var labfst_now "Labor force status (now)"
lab def labfst_now 1 "fully employed" 2 "part-time/marginally employed" 3 "apprenticeship" 4 "unemployed"
lab values labfst_now labfst_now


* social connectedness: with Germans, with same country of origin non-relative
mvdecode plj0568 plj0569, mv(-8/-1)
* with persons with same country of origin
recode plj0568 (5 6=0) (3 4=1) (1 2=2), gen(contact_same_country)
lab var contact_same_country "Contact with same country of origin persons (non-relative)"
lab def contact_same_country 0 "no/seldomly" 1 "often" 2 "very often"
lab values contact_same_country contact_same_country 

* with Germans
recode plj0569 (5 6=0) (3 4=1) (1 2=2), gen(contact_germans)
lab var contact_germans "Contact with Germans"
lab def contact_germans 0 "no/seldomly" 1 "often" 2 "very often"
lab values contact_germans contact_germans 


******* 
* save dataset final
save ref_2023_final_JAN_neu.dta, replace

*   --  --  --  *


