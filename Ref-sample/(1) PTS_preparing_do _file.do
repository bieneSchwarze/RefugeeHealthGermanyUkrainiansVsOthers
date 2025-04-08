* political terror scale, preparation and cleaning for merging with Soep data

use "I:\MA\amarchitto\SUARE\Ukr_Ref_CS_2022_23\PTS-2023.dta"

keep Country Year PTS_A PTS_H PTS_S
rename Country country
* NO rename Year syear
fre country, all
fre Year, all
keep if Year>=1976 & Year<=2021
fre country, all


encode country, gen(country_n)


recode country_n (1=4 "[4] Afghanistan") (2=8 "[8] Albanien") (3=12 "[12] Algerien") (5=24 "[24] Angola") (11=31 "[31] Aserbaidschan") (14=50 "[50] Bangladesch") (8=51 "[51] Armenien") (22=70 "[70] Bosnia and Herzegovina") (129=104 "[104] Myanmar") (31=120 "[120] Kamerun") (178=144 "[144] Sri Lanka") (41=188 "[188] Costa Rica") (60=231 "[231] Äthiopien") (57=232 "[232] Eritrea") (68=268 "[268] Georgien") (66=270 "[270] Gambia") (143=275 "[275] Palästina") (76=324 "[324] Guinea") (85=364 "[364] Iran") (86=368 "[368] Irak") (42=384 "[384] Côte d'Ivoire") (96=404 "[404] Kenia") (101=414 "[414] Kuwait") (105=422 "[422] Libanon") (108=434 "[434] Libyen") (116=466 "[466] Mali") (127=504 "[504] Marokko") (136=562 "[562] Niger") (137=566 "[566] Nigeria") (141=586 "[586] Pakistan") (153=642 "[642] Rumänien") (155=643 "[643] Russische Föderation") (163=682 "[682] Saudi-Arabien") (165=688 "[688] Serbien") (205=704 "[704] Vietnam") (172=706 "[706] Somalia") (179=729 "[729] Sudan") (183=760 "[760] Syrien") (185=762 "[762] Tadschikistan") (193=729 "[792] Türkei") (138=807 "[807] Nordmazedonien") (202=860 "[860] Usbekistan") (100=900 "[900] Kosovo") (else=.), gen(country_new)


egen avg_pts = rowmean(PTS_A PTS_H PTS_S)

sort country Year
br country country_new Year PTS_A PTS_H PTS_S avg_pts
drop if country_new==.
br country country_new Year PTS_A PTS_H PTS_S avg_pts
sort country_new Year 
order country_new Year

save PTS_modified_ref.dta, replace






