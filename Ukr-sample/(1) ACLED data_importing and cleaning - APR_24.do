* ACLED DATASET

* setting working directory
cd "I:\MA\amarchitto\SUARE\Ukr_Ref_CS_2022_23"

* Importing from cvs format
import delimited "I:\MA\amarchitto\SUARE\Ukr_Ref_CS_2022_23\2017-01-01-2023-12-31-Eastern_Africa-Europe-Middle_East-North_America-Northern_Africa-Southern_Africa-Western_Africa.csv", clear

* saving dataset as dta format
save acled_data_2017_2023.dta, replace

clear all
cls

********************************************************************************

* uploading dataset
use acled_data_2017_2023.dta, replace

* Changing date format to be the same format of Ukr-sample (SOEP data)
split event_date, parse(" ") gen(part)
rename part1 day
rename part2 month
rename part3 Year

encode month, gen(month_n)
fre month_n

recode month_n (5=1 "January") (4=2 "February") (8=3 "March") (1=4 "April") (9=5 "May") (7=6 "June") (6=7 "July") (2=8 "August") (12=9 "September") (11=10 "October") (10=11 "November") (3=12 "December"), gen(month_n_n)
tab month month_n_n

destring day, replace

destring Year, replace

gen event_date_2=mdy(month_n_n, day, Year)
format event_date_2 %td
tab event_date_2

br event_date event_date_2
drop event_date

keep if country=="Ukraine"
drop country 

keep if civilian_targeting=="Civilian targeting"
keep if time_precision==1 

* reshaping var admin1 ("Ukrainian region", so that it can be matched with var of master dataset)

encode admin1, gen(ACLED_ukr_reg)


* recoding exaclty like var in main dataset for matching "ukr_reg_match"

recode ACLED_ukr_reg (4=1 "Autonomous Republic of Crimea + Sevastopol") ///
(8=2 "Kharkiv Oblast") ///
(9=3 "Kherson Oblast") ///
(10=4 "Khmelnytskyi Oblast") ///
(5=5 "Dnipropetrovsk Oblast") ///
(6=6 "Donetsk Oblast") ///
(7=7 "Ivano-Frankivsk Oblast") ///
(12=8 "Kyiv Oblast") ///
(11=9 "Kirovohrad Oblast") ///
(14=10 "Luhansk Oblast") ///
(15=11 "Lviv Oblast") ///
(16=12 "Mykolaiv Oblast") ///
(17=13 "Odesa Oblast") ///
(18=14 "Poltava Oblast") ///
(19=15 "Rivne Oblast") ///
(25=16 "Zaporizhzhia Oblast") ///
(26=17 "Zhytomyr Oblast") ///
(20=18 "Sumy Oblast") ///
(21=19 "Ternopil Oblast") ///
(24=20 "Zakarpattia Oblast") ///
(1=21 "Cherkasy Oblast") ///
(2=22 "Chernihiv Oblast") ///
(3=23 "Chernivtsi Oblast") ///
(22=24 "Vinnytsia Oblast") ///
(23=25 "Volyn Oblast") ///
(13=26 "Kyiv") (else=.), gen(ukr_reg_match) 
lab var ukr_reg_match "Ukrainian regions"



* N= 11530


*****************************************************************************************************************************
****** new dataset
collapse (sum) fatalities, by(event_date_2 ukr_reg_match)
br
sort ukr_reg_match event_date_2

* N=3172

****************************************************************************************************************************

save ACLED_modified_ukr_APR_24.dta, replace

clear all


***********************************************
* GENERATING A DATASET WITH DATES FORM 1.1.2018 to 6.3.2023 (day of last reported interview of UKR respondents)
* setting working directory
cd "I:\MA\amarchitto\SUARE\Ukr_Ref_CS_2022_23"
di mdy(12,31,2017)
di mdy(3,6,2023)
di mdy(3,6,2023) - mdy(12,31,2017)
set obs 1891
gen event_date_new = mdy(12,31,2017) + _n

format event_date_new %td

list in 1
list in L 

save date_continuous.dta, replace

clear all

****
use date_continuous.dta, replace

* combining all pairwise combination of date_continuous dataset (N=1891) X ACLED_modified_ukr_APR_24 dataset (N=3172): N_fin = 5,998,252 obs
cross using "I:\MA\amarchitto\SUARE\Ukr_Ref_CS_2022_23\ACLED_modified_ukr_APR_24.dta"

br
gen fatalities_new=.
replace fatalities_new=fatalities if event_date_2==event_date_new

sort ukr_reg_match event_date_new event_date_2
br event_date_new event_date_2 ukr_reg_match fatalities_new if ukr_reg_match==1 & fatalities_new!=.

* this is working!
collapse (sum) fatalities_new, by(event_date_new ukr_reg_match)
sort ukr_reg_match event_date_new

drop if ukr_reg_match==.

* new dataset: N=49,166 (one observation of fatalities each day from 1jan2018 to 6mar2023 (n=1891) by Ukr-region (n=26))

save ACLED_modified_ukr_APR_24_final.dta, replace


*************************************************
*************************************************
*****************   END   ***********************
*************************************************
*************************************************

