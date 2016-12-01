
* Encoding: UTF-8.
************************************************************************************
************************************************************************************
* GET DATA - CHANGE FILE PATH!!!
* also replace all C:\Users\Dell\Documents\IBM\SPSS\Statistics\census\output\ with new output path
************************************************************************************

GET
  FILE='D:\one percent.sav'.
DATASET NAME MainFile WINDOW=FRONT.

DATASET ACTIVATE MainFile.

* REMOVE INSTITUTIONS - formtype = 2

USE ALL.
SELECT IF (form_type  = 1).
exe.
DATASET ACTIVATE MainFile.


************************************************************************************
************************************************************************************
* NEW VARS: 
************************************************************************************
************************************************************************************

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
* age in 5 year intervals 

RECODE  p05_age (MISSING=COPY) (LO THRU 14=1) (LO THRU 19=2) (LO THRU 24=3) (LO THRU 29=4) (LO THRU 
    34=5) (LO THRU 39=6) (LO THRU 44=7) (LO THRU 49=8) (LO THRU 54=9) (LO THRU 59=10) (LO THRU 64=11) 
    (LO THRU 69=12) (LO THRU 74=13) (LO THRU 79=14) (LO THRU 84=15) (LO THRU 89=16) (LO THRU 94=17) (LO 
    THRU HI=18) (ELSE=SYSMIS) INTO p05_age_binned.
VARIABLE LABELS  p05_age_binned 'Age (Binned)'.
FORMATS  p05_age_binned (F5.0).
VALUE LABELS  p05_age_binned 1 '<= 14' 2 '15 - 19' 3 '20 - 24' 4 '25 - 29' 5 '30 - 34' 6 '35 - 39' 
    7 '40 - 44' 8 '45 - 49' 9 '50 - 54' 10 '55 - 59' 11 '60 - 64' 12 '65 - 69' 13 '70 - 74' 14 '75 - '+
    '79' 15 '80 - 84' 16 '85 - 89' 17 '90 - 94' 18 '95+'.
VARIABLE LEVEL  p05_age_binned (ORDINAL).
EXECUTE.

************************************************************************************
* children ever born, summed and capped

compute p25_children_born = p25a_children_born_male + p25b_children_born_female.
recode  p25_children_born (missing = copy) (lo through 10 = copy) (11 thru hi = 11) (else = sysmis) into p25_children_born_bound.
variable labels p25_children_born_bound  'Children ever born (bounded)'.
formats p25_children_born_bound (F2.0).
value labels p25_children_born_bound 11 'more than 10'.
exe.

************************************************************************************
* disability index
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

VARIABLE LABELS p09_disablity_dummy_sum 'Disabilites dummy sum (4)'.

************************************************************************************
* occupation collapsed

RECODE  p23_occupation (MISSING=COPY)(LO THRU 99 = 0) (LO THRU 199=1) (LO THRU 299=2) (LO THRU 399=3) (LO THRU 499=4) (LO THRU 599=5) (LO THRU 699=6) (LO THRU 799=7) (LO THRU 899=8) (LO THRU 998 =9) (999 = 10) (ELSE=SYSMIS) INTO p23_occupation_binned.
VALUE LABELS p23_occupation_binned 0 'Armed forces' 1 'Managers' 2 'Professionals' 3 'Technicians and Associate Professionals' 4 'Clerical Support Workers' 5 'Services and Sales Workers' 6 'Skilled Agricultural, Forestry and Fishery Workers' 7 'Craft and Related Trades Workers' 8 'Plant and Machine Operators and Assemblers' 9 'Elementary Occupations' 10 'Not stated'. 
exe. 

************************************************************************************
* recode education into 7 categories

recode  p21_highest_grade (missing = copy) (0 thru 4 = 0) (5 thru 8 = 1) (9 thru 10 = 2) (11 = 3) (12 thru 15 = 4) (16 thru 18 = 5) (19 = 6)  (else = sysmis) into p21_highest_grade_c7.
variable labels p21_highest_grade_c7 'Highest level of education completed (7 categories)'.
formats p21_highest_grade_c7 (F2.0).
value labels p21_highest_grade_c7 0 'None completed' 1 'Elementary completed' 2 'Middleschool completed' 3 'Highschool completed' 4 'undergraduate' 5 'postgraduate' 6 'other'.
exe.

************************************************************************************
* at least one SON CORESIDENT 

COMPUTE SON_cores=(p03_relationship = 3 & p04_sex = 1).
exe.

aggregate outfile * mode = ADDVARIABLES
/break HH_ID
/HH_SON_cores = max(SON_cores). 

************************************************************************************
* at least one DAUGHTER CORESIDENT 

COMPUTE DAUGHTER_cores=(p03_relationship = 3 & p04_sex = 2).
exe.

aggregate outfile * mode = ADDVARIABLES
/break HH_ID
/HH_DAUGHTER_cores = max(DAUGHTER_cores). 


************************************************************************************
* COmpute HH_type - by coresidence of Sons/daughters
************************************************************************************

IF  (HH_SON_cores = 0 &  HH_DAUGHTER_cores = 0) HH_Type_cores = 0. 
IF  (HH_SON_cores = 1 &  HH_DAUGHTER_cores = 0) HH_Type_cores = 1. 
IF  (HH_SON_cores = 0 &  HH_DAUGHTER_cores = 1) HH_Type_cores = 2. 
IF  (HH_SON_cores = 1 &  HH_DAUGHTER_cores = 1) HH_Type_cores = 3. 
VALUE LABELS HH_Type_HoH 0 'No cores children' 1 'Only sons coresident' 2 'Only daughters coresident' 3 'Both sons and daughters coresident'.
VARIABLE LABELS HH_Type_cores 'Type of HH by child coresidence'.
EXECUTE.





************************************************************************************
************************************************************************************
* CROSSTABS FOR SARAH PART ONE: ALL WOMEN EVER MARRIED - CHILDREN/OCCUPATION
************************************************************************************
************************************************************************************


************************************************************************************
** OUTPUT MANAGMENT 

OMS
  /SELECT TABLES
  /IF COMMANDS=['Crosstabs'] SUBTYPES=['Crosstabulation']
  /DESTINATION FORMAT=SAV NUMBERED=TableNumber_
   OUTFILE='C:\Users\Dell\Documents\IBM\SPSS\Statistics\census\output\SH01.sav' VIEWER=YES
  /TAG='SH01.SAV'.

OMS
  /SELECT TABLES
  /IF COMMANDS=['Crosstabs'] SUBTYPES=['Crosstabulation']
  /DESTINATION FORMAT=XLSX
   OUTFILE='C:\Users\Dell\Documents\IBM\SPSS\Statistics\census\output\SH01.xlsx' VIEWER=YES
  /TAG='SH01.XLSX'.

************************************************************************************

CROSSTABS
  /TABLES= p25_children_born_bound BY p05_age_binned BY  p23_occupation_binned  
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.

CROSSTABS
  /TABLES= p25_children_born_bound BY p05_age_binned BY  p21_highest_grade_c7 
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.

CROSSTABS
  /TABLES= p25_children_born_bound BY p05_age_binned BY  batch_urban_rural 
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.

************************************************************************************
************************************************************************************
* END EXPORT
************************************************************************************
* OMSEND.
OMSEND TAG=['SH01.SAV'].
OMSEND TAG=['SH01.XLSX'].






************************************************************************************
* select only Heads of households over 60 - i.e. one row per HH
USE ALL.
SELECT IF (p03_relationship = 1 & p05_age >= 60 ).
exe.

************************************************************************************
************************************************************************************
* CROSSTABS FOR SARAH PART TWO: coresiding children by disability, age, gender and mar.stat
************************************************************************************
************************************************************************************


************************************************************************************
** OUTPUT MANAGMENT 

OMS
  /SELECT TABLES
  /IF COMMANDS=['Crosstabs'] SUBTYPES=['Crosstabulation']
  /DESTINATION FORMAT=SAV NUMBERED=TableNumber_
   OUTFILE='C:\Users\Dell\Documents\IBM\SPSS\Statistics\census\output\SH02.sav' VIEWER=YES
  /TAG='SH02.SAV'.

OMS
  /SELECT TABLES
  /IF COMMANDS=['Crosstabs'] SUBTYPES=['Crosstabulation']
  /DESTINATION FORMAT=XLSX
   OUTFILE='C:\Users\Dell\Documents\IBM\SPSS\Statistics\census\output\SH02.xlsx' VIEWER=YES
  /TAG='SH02.XLSX'.

************************************************************************************

CROSSTABS
  /TABLES= batch_state_region BY HH_Type_cores BY p09_disablity_dummy_sum BY p05_age_binned BY p04_sex  BY p06_marital_status
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.


************************************************************************************
************************************************************************************
* END EXPORT
************************************************************************************
* OMSEND.
OMSEND TAG=['SH02.SAV'].
OMSEND TAG=['SH02.XLSX'].






OUTPUT CLOSE *.



