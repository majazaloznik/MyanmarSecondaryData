* Encoding: UTF-8.
GET
  FILE='D:\one percent.sav'.
DATASET NAME onePercent WINDOW=FRONT.

DATASET ACTIVATE onePercent.

* REMOVE INSTITUTIONS - formtype = 2

USE ALL.
SELECT IF (form_type  = 1).
exe.

* NEW VARS: 

* HOUSEHOLD SIZED BOUNDED AT 15

recode number_of_people (missing = copy) (lo thru 14= copy) (15 thru hi = 15 )(else=sysmis) into number_of_people_bound.
variable labels number_of_people_bound  'Household size (Bounded)'.
formats number_of_people_bound (F2.0).
value labels number_of_people_bound  15 '15 or more'.
exe.

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
/break barcode
/unique_generations = max(rrelatio).
VARIABLE LABELS unique_generations 'Number of generations in HH'.
* GENDER OF HEAD OF HOUSEHOLD 
*  p03_relationship == 1 what is p04_sex?
* sorted by relationship in each household, then you can use aggregate first() 

SORT CASES  BY HH_ID p03_relationship.

aggregate outfile * mode = addvariables
/break HH_ID
/sex_head = first(p04_sex).
VARIABLE LABELS sex_head 'Sex of Head of HH'.
* AGE OF HEAD OF HOUSEHOLD
*  p03_relationship == 1 what is p05_age?

aggregate outfile * mode = addvariables
/break HH_ID
/age_head = first(p05_age).
VARIABLE LABELS age_head 'Age of Head of HH'.

* MARITAL STATUS OF HEAD OF HOUSEHOLD
*  p03_relationship == 1 what is p06_marital_status?

aggregate outfile * mode = addvariables
/break HH_ID
/marital_status_head = first(p06_marital_status).

* AGE group OF HEAD OF HOUSEHOLD

RECODE  age_head (MISSING=COPY) (LO THRU 15=1) (LO THRU 20=2) (LO THRU 25=3) (LO THRU 30=4) (LO 
    THRU 35=5) (LO THRU 40=6) (LO THRU 45=7) (LO THRU 50=8) (LO THRU 55=9) (LO THRU 60=10) (LO THRU 
    65=11) (LO THRU 70=12) (LO THRU 75=13) (LO THRU 80=14) (LO THRU 85=15) (LO THRU 90=16) (LO THRU 
    95=17) (LO THRU HI=18) (ELSE=SYSMIS) INTO age_head_binned_5.
VARIABLE LABELS  age_head_binned_5 'Age (Binned)'.
FORMATS  age_head_binned_5 (F5.0).
VALUE LABELS  age_head_binned_5 1 '<= 15' 2 '16 - 20' 3 '21 - 25' 4 '26 - 30' 5 '31 - 35' 6 '36 - 40' 
    7 '41 - 45' 8 '46 - 50' 9 '51 - 55' 10 '56 - 60' 11 '61 - 65' 12 '66 - 70' 13 '71 - 75' 14 '76 - '+
    '80' 15 '81 - 85' 16 '86 - 90' 17 '91 - 95' 18 '96+'.
VARIABLE LEVEL  age_head_binned_5 (ORDINAL).

RECODE  age_head (MISSING=COPY) (LO THRU 20=1) (LO THRU 30=2) (LO THRU 40=3) (LO THRU 50=4) (LO 
    THRU 60=5) (LO THRU 70=6) (LO THRU 80=7) (LO THRU 90=8) (LO THRU HI=9) (ELSE=SYSMIS) INTO 
    age_head_binned_10.
VARIABLE LABELS age_head_binned_10 'Age (Binned)'.
FORMATS  age_head_binned_10 (F5.0).
VALUE LABELS  age_head_binned_10 1 '<= 20' 2 '21 - 30' 3 '31 - 40' 4 '41 - 50' 5 '51 - 60' 6 '61 - 70' 7 
    '71 - 80' 8 '81 - 90' 9 '91+'.
VARIABLE LEVEL  age_head_binned_10 (ORDINAL).
EXECUTE.

* Dichotomous p11_birth_township: born here or away

recode p11_birth_township (missing = copy) (0 = 0) (lo through 999 = 1)(else=sysmis) into p11_birth_township_c2.
variable labels p11_birth_township_c2 'Born here or away'.
formats p11_birth_township_c2 (F2.0).
value labels p11_birth_township_c2  0 'Born here' 1 'Born elsewhere'.
exe.

* BINNED p15_duration_of_residence

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

* value labels p16_reason_for_movement 9 'same township' = not given? i.e. missing. but looks like they have all 
moved within the same township..

* Dichotomous p17_prev_township: born here or away

recode p17_prev_res_township (missing = copy) (0 = 0) (lo through 999 = 1)(else=sysmis) into p17_prev_res_township_c2.
variable labels p17_prev_res_township  'Previous residence'.
formats p17_prev_res_township_c2 (F2.0).
value labels p17_prev_res_township_c2  0 'This towhnship' 1 'other township'.
exe.

* CROSSTABS FOR GL - PART ONE
* select only heads of househodls 

DATASET COPY  onePercentHeads.
DATASET ACTIVATE  onePercentHeads.
USE ALL.
SELECT IF (p03_relationship = 1).
EXECUTE.

DATASET ACTIVATE onePercentHeads.

* DISABILITY SEEING

CROSSTABS
  /TABLES= p09a_disability_seeing BY age_head_binned_5 age_head_binned_10 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

* DISABILITY HEARING

CROSSTABS
  /TABLES= p09b_disability_hearing BY age_head_binned_5 age_head_binned_10 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

*DISABILITY WALKING

CROSSTABS
  /TABLES= p09c_disability_walking BY age_head_binned_5 age_head_binned_10 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

* DISABILITY REMEMBERING

CROSSTABS
  /TABLES= p09d_disability_remembering BY age_head_binned_5 age_head_binned_10 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

* BORN HERE OR OTHER TOWNSHIP

CROSSTABS
  /TABLES= p11_birth_township_c2 BY age_head_binned_5 age_head_binned_10 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

* Born Urban or Rural

CROSSTABS
  /TABLES= p12_birth_ur BY age_head_binned_5 age_head_binned_10 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

* duration of residence binned - only if p_16 is not 6 - they have moved

COMPUTE filter_$=(p16_reason_for_movement ne 6).
FILTER BY filter_$.
exe.

CROSSTABS
  /TABLES= p15_duration_of_residence_5 BY age_head_binned_5 age_head_binned_10 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

FILTER OFF.
USE ALL.
delete variables filter_$.
EXECUTE.


* reason for movement

CROSSTABS
  /TABLES= p16_reason_for_movement BY age_head_binned_5 age_head_binned_10 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

* PREVIOUS TOWNSHIP HERE OR NOT - ONLY FOR THOSE THAT  p_16 is not 6 - they have moved

COMPUTE filter_$=(p16_reason_for_movement ne 6).
FILTER BY filter_$.
exe.

CROSSTABS
  /TABLES= p17_prev_res_township_c2 BY age_head_binned_5 age_head_binned_10 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

* PREVIOUS residence  urban or rural - only if p_16 is not 6 - they have moved

CROSSTABS
  /TABLES= p18_prev_res_ur BY age_head_binned_5 age_head_binned_10 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

FILTER OFF.
USE ALL.
delete variables filter_$.
EXECUTE.

* TYPE OF RESIDENCE

CROSSTABS
  /TABLES= h32_type_residence BY age_head_binned_5 age_head_binned_10 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

* TYPE OF OWNERSHIP

CROSSTABS
  /TABLES= h33_type_ownership BY age_head_binned_5 age_head_binned_10 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

* TYPE OF LIGHTING 

CROSSTABS
  /TABLES= h34_lighting BY age_head_binned_5 age_head_binned_10 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

* drinking water - first add missing labels from non drinking water

APPLY DICTIONARY
  /FROM *
  /SOURCE VARIABLES=h35b_non_drinking_water
  /TARGET VARIABLES=h35a_drinking_water
  /FILEINFO
  /VARINFO VALLABELS=REPLACE.

CROSSTABS
  /TABLES= h35a_drinking_water BY age_head_binned_5 age_head_binned_10 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

* non-drinking water

CROSSTABS
  /TABLES= h35b_non_drinking_water BY age_head_binned_5 age_head_binned_10 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

* cooking fuel

CROSSTABS
  /TABLES= h36_cooking_fuel BY age_head_binned_5 age_head_binned_10 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

* toilet

CROSSTABS
  /TABLES= h37_toilet BY age_head_binned_5 age_head_binned_10 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

* ROOF

CROSSTABS
  /TABLES= h38a_roof BY age_head_binned_5 age_head_binned_10 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

* walls

CROSSTABS
  /TABLES= h38b_walls BY age_head_binned_5 age_head_binned_10 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

* floor

CROSSTABS
  /TABLES= h38c_floor BY age_head_binned_5 age_head_binned_10 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.


* radio 

CROSSTABS
  /TABLES= h39a_radio BY age_head_binned_5 age_head_binned_10 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

* television

CROSSTABS
  /TABLES= h39b_television BY age_head_binned_5 age_head_binned_10 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

* land line phone

CROSSTABS
  /TABLES= h39c_land_line_phone BY age_head_binned_5 age_head_binned_10 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.


* MOBILE

CROSSTABS
  /TABLES= h39d_mobile_phone BY age_head_binned_5 age_head_binned_10 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

* COMPUTER 

CROSSTABS
  /TABLES= h39e_computer BY age_head_binned_5 age_head_binned_10 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.


* internet

CROSSTABS
  /TABLES= h39f_internet_at_home BY age_head_binned_5 age_head_binned_10 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

* car-truck-van

CROSSTABS
  /TABLES= h39g_car_truck_van BY age_head_binned_5 age_head_binned_10 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.


* motorcycle-moepd-tuktuk


CROSSTABS
  /TABLES= h39h_motorcycle_moped BY age_head_binned_5 age_head_binned_10 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.


* BICYCLE 

CROSSTABS
  /TABLES= h39i_bicycle BY age_head_binned_5 age_head_binned_10 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.


* 4 WHEEL TRACTOR 

CROSSTABS
  /TABLES= h39j_4_wheel_tractor BY age_head_binned_5 age_head_binned_10 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.


* canoe boat 

CROSSTABS
  /TABLES= h39k_canoe_boat BY age_head_binned_5 age_head_binned_10 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.


* motor_boat 

CROSSTABS
  /TABLES= h39l_motor_boat BY age_head_binned_5 age_head_binned_10 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.


* cart bullock 

CROSSTABS
  /TABLES= h39m_cart_bullock BY age_head_binned_5 age_head_binned_10 sex_head marital_status_head
   number_of_people_bound unique_generations p21_highest_grade p22_activity_status batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN row
  /COUNT ROUND CELL.

