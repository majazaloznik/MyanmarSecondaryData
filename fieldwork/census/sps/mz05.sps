* Encoding: UTF-8.
************************************************************************************
************************************************************************************
GET
  FILE='D:\one percent.sav'.
DATASET NAME MainFile WINDOW=FRONT.

DATASET ACTIVATE MainFile.

* REMOVE INSTITUTIONS - formtype = 2

USE ALL.
SELECT IF (form_type  = 1).
exe.

************************************************************************************
************************************************************************************
* NEW VARS: 
************************************************************************************
************************************************************************************

* HOUSEHOLD SIZE BOUNDED AT 15

recode number_of_people (missing = copy) (lo thru 14= copy) (15 thru hi = 15 )(else=sysmis) into number_of_people_bound.
variable labels number_of_people_bound  'Household size (Bounded)'.
formats number_of_people_bound (F2.0).
value labels number_of_people_bound  15 '15 or more'.
exe.

************************************************************************************
* UNIQUE HOUSEHOLDS

string id01(A2).
string id02(A2).
string id03(A2).
string id04(A3).
string id05(A3).
string id06(A4).
compute id01 = string(batch_state_region, F2.0).
compute id02= string(batch_district, F2.0).
compute id03= string(batch_township, F2.0).
compute id04= string(batch_ward, F3.0).
compute id05= string(batch_ea, F3.0).
compute id06= string(household_number, F4.0).
exe.
string HH_ID (a21).
compute HH_ID = concatenate(ltrim(id01),"-",ltrim(id02),"-",ltrim(id03), "-",ltrim(id04), "-",ltrim(id05), "-",ltrim(id06) ).
exe.

DELETE VARIABLES id01 id02 id03 id04 id05 id06.
exe.

************************************************************************************
* NUMBER OF GENERATIONS IN HOUSEHOLD:

* new categories,
0 == head, spouse and siblings (1,2,7), 
1 = children, ch in law and adopted children (3,4,10)
2 == grand children (5)
-1 = parents, parents in law(6)
-2 = grandparents (8)
all others sysmys
 
RECODE p03_relationship (1=0) (2=0) (7=0) (3=1) (4=1) (10=1) (5=2) (6=-1) (8=-2) (9=SYSMIS) 
    (11=SYSMIS) (SYSMIS=SYSMIS) (MISSING=SYSMIS) INTO relationship_generation.
EXECUTE.

* first split file into households - barcode used as the is the unique identifier

SORT CASES  BY HH_ID.
SPLIT FILE LAYERED BY HH_ID.

* rank by relationship generation within each household will get you the number of generations, even if one is skipped

rank relationship_generation (A) /RANK /TIES=CONDENSE.

split file off.

* then simply use max to get the total number in each household (break == barcode) 

aggregate outfile * mode = addvariables
/break HH_ID
/unique_generations = max(rrelatio).
VARIABLE LABELS unique_generations 'Number of generations in HH'.


************************************************************************************
* GENDER OF HEAD OF HOUSEHOLD 
* p03_relationship == 1 what is p04_sex?
* sorted by relationship in each household, then you can use aggregate first() 

SORT CASES  BY HH_ID p03_relationship.

aggregate outfile * mode = addvariables
/break HH_ID
/sex_head = first(p04_sex).
VARIABLE LABELS sex_head 'Sex of Head of HH'.

APPLY DICTIONARY
  /FROM *
  /SOURCE VARIABLES=p04_sex
  /TARGET VARIABLES=sex_head
  /FILEINFO
  /VARINFO VALLABELS=REPLACE.

************************************************************************************
* AGE OF HEAD OF HOUSEHOLD
*  p03_relationship == 1 what is p05_age?

aggregate outfile * mode = addvariables
/break HH_ID
/age_head = first(p05_age).
VARIABLE LABELS age_head 'Age of Head of HH'.

************************************************************************************
* MARITAL STATUS OF HEAD OF HOUSEHOLD
*  p03_relationship == 1 what is p06_marital_status?

aggregate outfile * mode = addvariables
/break HH_ID
/marital_status_head = first(p06_marital_status).

* copy over labels

APPLY DICTIONARY
  /FROM *
  /SOURCE VARIABLES=p06_marital_status
  /TARGET VARIABLES=marital_status_head
  /FILEINFO
  /VARINFO VALLABELS=REPLACE.

************************************************************************************
* AGE group 5 years

RECODE  p05_age (MISSING=COPY) (LO THRU 15=1) (LO THRU 20=2) (LO THRU 25=3) (LO THRU 30=4) (LO 
    THRU 35=5) (LO THRU 40=6) (LO THRU 45=7) (LO THRU 50=8) (LO THRU 55=9) (LO THRU 60=10) (LO THRU 
    65=11) (LO THRU 70=12) (LO THRU 75=13) (LO THRU 80=14) (LO THRU 85=15) (LO THRU 90=16) (LO THRU 
    95=17) (LO THRU HI=18) (ELSE=SYSMIS) INTO p05_age_binned_5.
VARIABLE LABELS  p05_age_binned_5 'Age (Binned 5)'.
FORMATS  p05_age_binned_5 (F5.0).
VALUE LABELS  p05_age_binned_5 1 '<= 15' 2 '16 - 20' 3 '21 - 25' 4 '26 - 30' 5 '31 - 35' 6 '36 - 40' 
    7 '41 - 45' 8 '46 - 50' 9 '51 - 55' 10 '56 - 60' 11 '61 - 65' 12 '66 - 70' 13 '71 - 75' 14 '76 - '+
    '80' 15 '81 - 85' 16 '86 - 90' 17 '91 - 95' 18 '96+'.
VARIABLE LEVEL  p05_age_binned_5 (ORDINAL).
exe.

************************************************************************************
* Dichotomous p11_birth_township: born here or away

recode p11_birth_township (missing = copy) (0 = 0) (lo through 999 = 1)(else=sysmis) into p11_birth_township_c2.
variable labels p11_birth_township_c2 'Born here or away'.
formats p11_birth_township_c2 (F2.0).
value labels p11_birth_township_c2  0 'Born here' 1 'Born elsewhere'.
exe.

************************************************************************************
* BINNED p15_duration_of_residence five years

RECODE  p15_duration_of_residence (MISSING=COPY) (LO THRU 5=1) (LO THRU 10=2) (LO THRU 15=3) (LO 
    THRU 20=4) (LO THRU 25=5) (LO THRU 30=6) (LO THRU 35=7) (LO THRU 40=8) (LO THRU 45=9) (LO THRU 
    50=10) (LO THRU 55=11) (LO THRU 60=12) (LO THRU 65=13) (LO THRU 70=14) (LO THRU 75=15) (LO THRU 
    80=16) (LO THRU 85=17) (LO THRU 90=18) (LO THRU 95=19) (LO THRU HI=20) (ELSE=SYSMIS) INTO 
    p15_duration_of_residence_5.
VARIABLE LABELS  p15_duration_of_residence_5 'Duration of residence (Binned)'.
FORMATS  p15_duration_of_residence_5 (F5.0).
VALUE LABELS  p15_duration_of_residence_5 1 '<= 5' 2 '6 - 10' 3 '11 - 15' 4 '16 - 20' 5 '21 - 25' 6 
    '26 - 30' 7 '31 - 35' 8 '36 - 40' 9 '41 - 45' 10 '46 - 50' 11 '51 - 55' 12 '56 - 60' 13 '61 - 65' 
    14 '66 - 70' 15 '71 - 75' 16 '76 - 80' 17 '81 - 85' 18 '86 - 90' 19 '91 - 95' 20 '96+'.
VARIABLE LEVEL  p15_duration_of_residence_5 (ORDINAL).
EXECUTE.

* reason for movement code 9? is it people moving within the same township?
* value labels p16_reason_for_movement 9 'same township' = not given? i.e. missing. but looks like they have all moved within the same township..

************************************************************************************
* Dichotomous p17_prev_township: born here or away

recode p17_prev_res_township (missing = copy) (0 = 0) (lo through 999 = 1)(else=sysmis) into p17_prev_res_township_c2.
variable labels p17_prev_res_township  'Previous residence'.
formats p17_prev_res_township_c2 (F2.0).
value labels p17_prev_res_township_c2  0 'This towhnship' 1 'other township'.
exe.

************************************************************************************
* children ever born, summed and capped

compute p25_children_born = p25a_children_born_male + p25b_children_born_female.
recode  p25_children_born (missing = copy) (lo through 10 = copy) (11 thru hi = 11) (else = sysmis) into p25_children_born_bound.
variable labels p25_children_born_bound  'Children ever born (bounded)'.
formats p25_children_born_bound (F2.0).
value labels p25_children_born_bound 11 'more than 10'.

************************************************************************************
* boys born capped

recode  p25a_children_born_male (missing = copy) (lo through 10 = copy) (11 thru hi = 11) (else = sysmis) into p25a_children_born_male_bound.
variable labels p25a_children_born_male_bound 'Children ever born- male (bounded)'.
formats p25a_children_born_male_bound (F2.0).
value labels p25a_children_born_male_bound 11 'more than 10'.

************************************************************************************
* girls born capped

recode  p25b_children_born_female (missing = copy) (lo through 10 = copy) (11 thru hi = 11) (else = sysmis) into p25b_children_born_female_bound.
variable labels p25b_children_born_female_bound 'Children ever born- female (bounded)'.
formats p25b_children_born_female_bound (F2.0).
value labels p25b_children_born_female_bound 11 'more than 10'.

************************************************************************************
* children in hh summed and capped
compute p26_children_in_hh = p26a_children_in_hh_male + p26b_children_in_hh_female.
recode  p26_children_in_hh (missing = copy) (lo through 10 = copy) (11 thru hi = 11) (else = sysmis) into p26_children_in_hh_bound.
variable labels p26_children_in_hh_bound  'Children still in hh (bounded)'.
formats p26_children_in_hh_bound (F2.0).
value labels p26_children_in_hh_bound 11 'more than 10'.

************************************************************************************
* boys in hh capped

recode  p26a_children_in_hh_male (missing = copy) (lo through 10 = copy) (11 thru hi = 11) (else = sysmis) into p26a_children_in_hh_male_bound.
variable labels p26a_children_in_hh_male_bound 'Children still in hh - male (bounded)'.
formats p26a_children_in_hh_male_bound (F2.0).
value labels p26a_children_in_hh_male_bound 11 'more than 10'.

************************************************************************************
* girls in hh capped
recode  p26b_children_in_hh_female (missing = copy) (lo through 10 = copy) (11 thru hi = 11) (else = sysmis) into p26b_children_in_hh_female_bound.
variable labels p26b_children_in_hh_female_bound 'Children still in hh- female (bounded)'.
formats p26b_children_in_hh_female_bound (F2.0).
value labels p26b_children_in_hh_female_bound 11 'more than 10'.
exe.

************************************************************************************
* children elsewhere summed and capped

compute p27_children_else = p27a_children_else_male + p27b_children_else_female.
recode  p27_children_else (missing = copy) (lo through 10 = copy) (11 thru hi = 11) (else = sysmis) into p27_children_else_bound.
variable labels p27_children_else_bound  'Children still in hh (bounded)'.
formats p27_children_else_bound (F2.0).
value labels p27_children_else_bound 11 'more than 10'.

************************************************************************************
*boys elsewhere capped

recode  p27a_children_else_male (missing = copy) (lo through 10 = copy) (11 thru hi = 11) (else = sysmis) into p27a_children_else_male_bound.
variable labels p27a_children_else_male_bound 'Children elsewhere - male (bounded)'.
formats p27a_children_else_male_bound (F2.0).
value labels p27a_children_else_male_bound 11 'more than 10'.

************************************************************************************
* girls elsewhere capped

recode  p27b_children_else_female (missing = copy) (lo through 10 = copy) (11 thru hi = 11) (else = sysmis) into p27b_children_else_female_bound.
variable labels p27b_children_else_female_bound 'Children elsewhere- female (bounded)'.
formats p27b_children_else_female_bound (F2.0).
value labels p27b_children_else_female_bound 11 'more than 10'.
exe.

************************************************************************************
* children died summed and capped

compute p28_children_died = p28a_children_died_male + p28b_children_died_female.
recode  p28_children_died (missing = copy) (lo through 10 = copy) (11 thru hi = 11) (else = sysmis) into p28_children_died_bound.
variable labels p28_children_died_bound  'Children died (bounded)'.
formats p28_children_died_bound (F2.0).
value labels p28_children_died_bound 11 'more than 10'.
exe.

************************************************************************************
* boys died capped

recode  p28a_children_died_male (missing = copy) (lo through 10 = copy) (11 thru hi = 11) (else = sysmis) into p28a_children_died_male_bound.
variable labels p28a_children_died_male_bound 'Children died - male (bounded)'.
formats p28a_children_died_male_bound (F2.0).
value labels p28a_children_died_male_bound 11 'more than 10'.

************************************************************************************
* girls died capped

recode  p28b_children_died_female (missing = copy) (lo through 10 = copy) (11 thru hi = 11) (else = sysmis) into p28b_children_died_female_bound.
variable labels p28b_children_died_female_bound 'Children died - female (bounded)'.
formats p28b_children_died_female_bound (F2.0).
value labels p28b_children_died_female_bound 11 'more than 10'.
exe.


************************************************************************************
* disability index variables

************************************************************************************
* sum all up to 12

compute p09_disablity_sum = sum(p09a_disability_seeing, p09b_disability_hearing, p09c_disability_walking, p09d_disability_remembering) -4.

************************************************************************************
* rescale and then sum up

recode p09a_disability_seeing (missing = copy) (1 = 0) (2 = 0.5) (3 = 1) (4 = 2) (else = sysmis) into  p09a_disability_seeing_rescaled.
recode p09b_disability_hearing (missing = copy) (1 = 0) (2 = 0.5) (3 = 1) (4 = 2) (else = sysmis) into  p09b_disability_hearing_rescaled.
recode p09c_disability_walking (missing = copy) (1 = 0) (2 = 0.5) (3 = 1) (4 = 2) (else = sysmis) into  p09c_disability_walking_rescaled.
recode p09d_disability_remembering  (missing = copy) (1 = 0) (2 = 0.5) (3 = 1) (4 = 2) (else = sysmis) into  p09d_disability_remembering_rescaled.
compute p09_disablity_rescaled_sum = sum(p09a_disability_seeing_rescaled,  p09b_disability_hearing_rescaled,
 p09c_disability_walking_rescaled, p09d_disability_remembering_rescaled) .
exe.
delete variables p09a_disability_seeing_rescaled  p09b_disability_hearing_rescaled  p09c_disability_walking_rescaled p09d_disability_remembering_rescaled.

************************************************************************************
* dummy and sum up 

recode p09a_disability_seeing (missing = copy) (1 = 0) (2 through 4 = 1) (else = sysmis) into  p09a_disability_seeing_dummy.
recode p09b_disability_hearing (missing = copy) (1 = 0) (2 through 4 = 1) (else = sysmis) into  p09b_disability_hearing_dummy.
recode p09c_disability_walking (missing = copy) (1 = 0) (2 through 4 = 1) (else = sysmis) into  p09c_disability_walking_dummy.
recode p09d_disability_remembering  (missing = copy) (1 = 0) (2 through 4 = 1) (else = sysmis) into  p09d_disability_remembering_dummy.
compute p09_disablity_dummy_sum = sum(p09a_disability_seeing_dummy,  p09b_disability_hearing_dummy,
 p09c_disability_walking_dummy, p09d_disability_remembering_dummy) .
exe.
delete variables p09a_disability_seeing_dummy p09b_disability_hearing_dummy p09c_disability_walking_dummy p09d_disability_remembering_dummy.
exe.

************************************************************************************
* recode education into 7 categories

recode  p21_highest_grade (missing = copy) (0 thru 4 = 0) (5 thru 8 = 1) (9 thru 10 = 2) (11 = 3) (12 thru 15 = 4) (16 thru 18 = 5) (19 = 6)  (else = sysmis) into p21_highest_grade_c7.
variable labels p21_highest_grade_c7 'Highest level of education completed (7 categories)'.
formats p21_highest_grade_c7 (F2.0).
value labels p21_highest_grade_c7 0 'None completed' 1 'Elementary completed' 2 'Middleschool completed' 3 'Highschool completed' 4 'undergraduate' 5 'postgraduate' 6 'other'.
exe.



************************************************************************************
************************************************************************************
* CROSSTABS FOR GL - PART ONE
* select only heads of househodls 

DATASET COPY  HeadsOfHH.
DATASET ACTIVATE  HeadsOfHH.
USE ALL.
SELECT IF (p03_relationship = 1).
EXECUTE.

output close *.

************************************************************************************
**HEADS OF HOUSEHOLD ONLY 
************************************************************************************
* DISABILITY SEEING

CROSSTABS
  /TABLES= p09a_disability_seeing BY p05_age_binned_5 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade_c7 p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

************************************************************************************
* DISABILITY HEARING

CROSSTABS
  /TABLES= p09b_disability_hearing BY p05_age_binned_5 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade_c7 p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

************************************************************************************
*DISABILITY WALKING

CROSSTABS
  /TABLES= p09c_disability_walking BY p05_age_binned_5  sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade_c7 p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

************************************************************************************
* DISABILITY REMEMBERING

CROSSTABS
  /TABLES= p09d_disability_remembering BY p05_age_binned_5 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade_c7 p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

************************************************************************************
* DISABILITY index(12)

CROSSTABS
  /TABLES= p09_disablity_sum BY p05_age_binned_5 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade_c7 p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

************************************************************************************
* DISABILITY index rescaled(8)

CROSSTABS
  /TABLES= p09_disablity_rescaled_sum BY p05_age_binned_5 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade_c7 p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

************************************************************************************
* DISABILITY index dummy(4)

CROSSTABS
  /TABLES= p09_disablity_dummy_sum BY p05_age_binned_5 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade_c7 p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.


************************************************************************************
* BORN HERE OR OTHER TOWNSHIP

CROSSTABS
  /TABLES= p11_birth_township_c2 BY p05_age_binned_5  sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade_c7 p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

************************************************************************************
* Born Urban or Rural

CROSSTABS
  /TABLES= p12_birth_ur BY p05_age_binned_5  sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade_c7 p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

************************************************************************************
* duration of residence binned 

*COMPUTE filter_$=(p16_reason_for_movement ne 6).
*FILTER BY filter_$.
*exe.

CROSSTABS
  /TABLES= p15_duration_of_residence_5 BY p05_age_binned_5  sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade_c7 p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

*FILTER OFF.
*USE ALL.
*delete variables filter_$.
*EXECUTE.

************************************************************************************
* reason for movement

CROSSTABS
  /TABLES= p16_reason_for_movement BY p05_age_binned_5 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade_c7 p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

************************************************************************************
* PREVIOUS TOWNSHIP HERE OR NOT 

*COMPUTE filter_$=(p16_reason_for_movement ne 6).
*FILTER BY filter_$.
*exe.

CROSSTABS
  /TABLES= p17_prev_res_township_c2 BY p05_age_binned_5 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade_c7 p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.


************************************************************************************
* PREVIOUS residence  urban or rural - only if p_16 is not 6 - they have moved

CROSSTABS
  /TABLES= p18_prev_res_ur BY p05_age_binned_5 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade_c7 p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

*FILTER OFF.
*USE ALL.
*delete variables filter_$.
*EXECUTE.


************************************************************************************
* TYPE OF RESIDENCE

CROSSTABS
  /TABLES= h32_type_residence BY p05_age_binned_5 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade_c7 p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.


************************************************************************************
* TYPE OF OWNERSHIP

CROSSTABS
  /TABLES= h33_type_ownership BY p05_age_binned_5 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade_c7 p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.


************************************************************************************
* TYPE OF LIGHTING 

CROSSTABS
  /TABLES= h34_lighting BY p05_age_binned_5 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade_c7 p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.


************************************************************************************
* drinking water - first add missing labels from non drinking water

APPLY DICTIONARY
  /FROM *
  /SOURCE VARIABLES=h35b_non_drinking_water
  /TARGET VARIABLES=h35a_drinking_water
  /FILEINFO
  /VARINFO VALLABELS=REPLACE.

CROSSTABS
  /TABLES= h35a_drinking_water BY p05_age_binned_5 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade_c7 p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

************************************************************************************
* non-drinking water

CROSSTABS
  /TABLES= h35b_non_drinking_water BY p05_age_binned_5 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade_c7 p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

************************************************************************************
* cooking fuel

CROSSTABS
  /TABLES= h36_cooking_fuel BY p05_age_binned_5 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade_c7 p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

************************************************************************************
* toilet

CROSSTABS
  /TABLES= h37_toilet BY p05_age_binned_5 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade_c7 p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

************************************************************************************
* ROOF

CROSSTABS
  /TABLES= h38a_roof BY p05_age_binned_5 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade_c7 p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

************************************************************************************
* walls

CROSSTABS
  /TABLES= h38b_walls BY p05_age_binned_5 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade_c7 p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

************************************************************************************
* floor

CROSSTABS
  /TABLES= h38c_floor BY p05_age_binned_5 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade_c7 p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

************************************************************************************
* radio 

CROSSTABS
  /TABLES= h39a_radio BY p05_age_binned_5 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade_c7 p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

************************************************************************************
* television

CROSSTABS
  /TABLES= h39b_television BY p05_age_binned_5 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade_c7 p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

************************************************************************************
* land line phone

CROSSTABS
  /TABLES= h39c_land_line_phone BY p05_age_binned_5 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade_c7 p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

************************************************************************************
* MOBILE

CROSSTABS
  /TABLES= h39d_mobile_phone BY p05_age_binned_5 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade_c7 p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

************************************************************************************
* COMPUTER 

CROSSTABS
  /TABLES= h39e_computer BY p05_age_binned_5 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade_c7 p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

************************************************************************************
* internet

CROSSTABS
  /TABLES= h39f_internet_at_home BY p05_age_binned_5 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade_c7 p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.


************************************************************************************
* car-truck-van

CROSSTABS
  /TABLES= h39g_car_truck_van BY p05_age_binned_5 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade_c7 p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

************************************************************************************
* motorcycle-moepd-tuktuk

CROSSTABS
  /TABLES= h39h_motorcycle_moped BY p05_age_binned_5 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade_c7 p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.


************************************************************************************
* BICYCLE 

CROSSTABS
  /TABLES= h39i_bicycle BY p05_age_binned_5 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade_c7 p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

************************************************************************************
* 4 WHEEL TRACTOR 

CROSSTABS
  /TABLES= h39j_4_wheel_tractor BY p05_age_binned_5 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade_c7 p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

************************************************************************************
* canoe boat 

CROSSTABS
  /TABLES= h39k_canoe_boat BY p05_age_binned_5 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade_c7 p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

************************************************************************************
* motor_boat 

CROSSTABS
  /TABLES= h39l_motor_boat BY p05_age_binned_5 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade_c7 p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

************************************************************************************
* cart bullock 

CROSSTABS
  /TABLES= h39m_cart_bullock BY p05_age_binned_5 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade_c7 p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.


************************************************************************************
************************************************************************************
* EXPORT
************************************************************************************

OUTPUT EXPORT 
  /CONTENTS  EXPORT=ALL LAYERS=ALL MODELVIEWS=ALL
  /REPORT  DOCUMENTFILE='C:\Users\Dell\Documents\MNMcensus-GL-Part1-1percent.htm'
     TITLE=FILENAME FORMAT=HTML RESTYLE=YES.

OUTPUT EXPORT
  /CONTENTS  EXPORT=ALL  LAYERS=PRINTSETTING  MODELVIEWS=PRINTSETTING
  /XLSX  DOCUMENTFILE=
    'C:\Users\Dell\Documents\IBM\SPSS\Statistics\MNMcensus-GL-Part1-1percent-v2.xlsx'
     OPERATION=CREATEFILE
     LOCATION=LASTCOLUMN  NOTESCAPTIONS=YES.

OUTPUT EXPORT
  /CONTENTS  EXPORT=ALL  LAYERS=PRINTSETTING  MODELVIEWS=PRINTSETTING
  /DOC  DOCUMENTFILE=
    'C:\Users\Dell\Documents\IBM\SPSS\Statistics\MNMcensus-GL-Part1-1percent-v2.doc'
     NOTESCAPTIONS=YES  WIDETABLES=SHRINK PAGEBREAKS=YES
     PAGESIZE=INCHES(8.5, 11.0)  TOPMARGIN=INCHES(1.0)  BOTTOMMARGIN=INCHES(1.0)
     LEFTMARGIN=INCHES(1.0)  RIGHTMARGIN=INCHES(1.0).

OUTPUT CLOSE *.

DATASET CLOSE HeadsOfHH.


************************************************************************************
************************************************************************************
* CROSSTABS FOR GL - PART TWO
* select only women ever married 
************************************************************************************

DATASET ACTIVATE MainFile.
USE ALL.

************************************************************************************
CROSSTABS
  /TABLES=  p25_children_born_bound BY p05_age_binned_5  p06_marital_status
   number_of_people_bound unique_generations p21_highest_grade_c7 p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

************************************************************************************
CROSSTABS
  /TABLES=  p25a_children_born_male_bound BY p05_age_binned_5  p06_marital_status
   number_of_people_bound unique_generations p21_highest_grade_c7 p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

************************************************************************************

CROSSTABS
  /TABLES=  p25b_children_born_female_bound BY p05_age_binned_5  p06_marital_status
   number_of_people_bound unique_generations p21_highest_grade_c7 p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

************************************************************************************

CROSSTABS
  /TABLES=  p26_children_in_hh_bound BY p05_age_binned_5  p06_marital_status
   number_of_people_bound unique_generations p21_highest_grade_c7 p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

************************************************************************************
CROSSTABS
  /TABLES=  p26a_children_in_hh_male_bound BY p05_age_binned_5  p06_marital_status
   number_of_people_bound unique_generations p21_highest_grade_c7 p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

************************************************************************************
CROSSTABS
  /TABLES=  p26b_children_in_hh_female_bound BY p05_age_binned_5  p06_marital_status
   number_of_people_bound unique_generations p21_highest_grade_c7 p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

************************************************************************************
CROSSTABS
  /TABLES=  p27_children_else_bound BY p05_age_binned_5  p06_marital_status
   number_of_people_bound unique_generations p21_highest_grade_c7 p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

************************************************************************************
CROSSTABS
  /TABLES=  p27a_children_else_male_bound BY p05_age_binned_5  p06_marital_status
   number_of_people_bound unique_generations p21_highest_grade_c7 p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

************************************************************************************
CROSSTABS
  /TABLES=  p27b_children_else_female_bound BY p05_age_binned_5  p06_marital_status
   number_of_people_bound unique_generations p21_highest_grade_c7 p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.


************************************************************************************
CROSSTABS
  /TABLES=  p28_children_died_bound BY p05_age_binned_5  p06_marital_status
   number_of_people_bound unique_generations p21_highest_grade_c7 p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

************************************************************************************
CROSSTABS
  /TABLES=  p28a_children_died_male_bound BY p05_age_binned_5  p06_marital_status
   number_of_people_bound unique_generations p21_highest_grade_c7 p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

************************************************************************************
CROSSTABS
  /TABLES=  p28b_children_died_female_bound BY p05_age_binned_5  p06_marital_status
   number_of_people_bound unique_generations p21_highest_grade_c7 p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.


************************************************************************************
************************************************************************************
* EXPORT
************************************************************************************

OUTPUT EXPORT 
  /CONTENTS  EXPORT=ALL LAYERS=ALL MODELVIEWS=ALL
  /REPORT  DOCUMENTFILE='C:\Users\Dell\Documents\MNMcensus-GL-Part2-1percent-v2.htm'
     TITLE=FILENAME FORMAT=HTML RESTYLE=YES.

OUTPUT EXPORT
  /CONTENTS  EXPORT=ALL  LAYERS=PRINTSETTING  MODELVIEWS=PRINTSETTING
  /XLSX  DOCUMENTFILE=
    'C:\Users\Dell\Documents\IBM\SPSS\Statistics\MNMcensus-GL-Part2-1percent-v2.xlsx'
     OPERATION=CREATEFILE
     LOCATION=LASTCOLUMN  NOTESCAPTIONS=YES.

OUTPUT EXPORT
  /CONTENTS  EXPORT=ALL  LAYERS=PRINTSETTING  MODELVIEWS=PRINTSETTING
  /DOC  DOCUMENTFILE=
    'C:\Users\Dell\Documents\IBM\SPSS\Statistics\MNMcensus-GL-Part2-1percent-v2.doc'
     NOTESCAPTIONS=YES  WIDETABLES=SHRINK PAGEBREAKS=YES
     PAGESIZE=INCHES(8.5, 11.0)  TOPMARGIN=INCHES(1.0)  BOTTOMMARGIN=INCHES(1.0)
     LEFTMARGIN=INCHES(1.0)  RIGHTMARGIN=INCHES(1.0).


OUTPUT CLOSE *.


************************************************************************************
************************************************************************************
* CROSSTABS FOR GL - PART THREE
************************************************************************************
* select only OVER 18

DATASET ACTIVATE  MainFile.
USE ALL.

dataset copy  Over18.
dataset activate Over18.
select if (p05_age >= 18).
exe.

************************************************************************************

CROSSTABS
  /TABLES= p09_disablity_dummy_sum  BY p04_sex p05_age_binned_5 p05_age_binned_10
   number_of_people_bound unique_generations p21_highest_grade_c7 p22_activity_status batch_urban_rural p26_children_in_hh_bound p26_children_in_hh_male_bound p26_children_in_hh_female_bound p27_children_else_bound p27_children_else_male_bound p27_children_else_female_bound h32_type_residence h33_type_ownership
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

************************************************************************************
CROSSTABS
  /TABLES= p09_disablity_sum  BY p04_sex p05_age_binned_5 p05_age_binned_10 p21_highest_grade_c7 p22_activity_status batch_urban_rural  p26_children_in_hh_bound p26_children_in_hh_male_bound p26_children_in_hh_female_bound p27_children_else_bound p27_children_else_male_bound p27_children_else_female_bound h32_type_residence h33_type_ownership
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

************************************************************************************
CROSSTABS
  /TABLES= p09_disablity_rescaled_sum  BY p04_sex p05_age_binned_5 p05_age_binned_10
   number_of_people_bound unique_generations p21_highest_grade_c7 p22_activity_status batch_urban_rural  p26_children_in_hh_bound p26_children_in_hh_male_bound p26_children_in_hh_female_bound p27_children_else_bound p27_children_else_male_bound p27_children_else_female_bound h32_type_residence h33_type_ownership
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

************************************************************************************
************************************************************************************
*EXPORT
************************************************************************************


OUTPUT EXPORT 
  /CONTENTS  EXPORT=ALL LAYERS=ALL MODELVIEWS=ALL
  /REPORT  DOCUMENTFILE='C:\Users\Dell\Documents\MNMcensus-GL-Part3-1percent.htm'
     TITLE=FILENAME FORMAT=HTML RESTYLE=YES.

OUTPUT EXPORT
  /CONTENTS  EXPORT=ALL  LAYERS=PRINTSETTING  MODELVIEWS=PRINTSETTING
  /XLSX  DOCUMENTFILE=
    'C:\Users\Dell\Documents\IBM\SPSS\Statistics\MNMcensus-GL-Part3-1percent-v2.xlsx'
     OPERATION=CREATEFILE
     LOCATION=LASTCOLUMN  NOTESCAPTIONS=YES.

OUTPUT EXPORT
  /CONTENTS  EXPORT=ALL  LAYERS=PRINTSETTING  MODELVIEWS=PRINTSETTING
  /DOC  DOCUMENTFILE=
    'C:\Users\Dell\Documents\IBM\SPSS\Statistics\MNMcensus-GL-Part3-1percent-v2.doc'
     NOTESCAPTIONS=YES  WIDETABLES=SHRINK PAGEBREAKS=YES
     PAGESIZE=INCHES(8.5, 11.0)  TOPMARGIN=INCHES(1.0)  BOTTOMMARGIN=INCHES(1.0)
     LEFTMARGIN=INCHES(1.0)  RIGHTMARGIN=INCHES(1.0).

output close *. 
