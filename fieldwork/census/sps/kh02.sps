

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
* disability indexes

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
* Types of farming households: FOUR KINDS
************************************************************************************

SORT CASES  BY HH_ID.

************************************************************************************
* Farming HH where Head is skilled agricultural 

COMPUTE HH_F_HoH=((600 <= p23_occupation and p23_occupation  <700 ) and (p03_relationship = 1)).
 exe.

aggregate outfile * mode = ADDVARIABLES
/break HH_ID
/FarmingHH_F_HoH = max(HH_F_HoH)

************************************************************************************
* Farming HH where head or spouse are skilled agricultural 

COMPUTE HH_F_HoH_Sp =((600 <= p23_occupation and p23_occupation  <700 ) and (p03_relationship = 1 or p03_relationship = 2)).
 exe.

aggregate outfile * mode = ADDVARIABLES
/break HH_ID
/FarmingHH_F_HoH_Sp = max(HH_F_HoH_Sp)

************************************************************************************
* Farming HH where any relative is skilled agricultural 
COMPUTE HH_F_Any =((600 <= p23_occupation and p23_occupation  <700 ) and (p03_relationship <= 8)).
exe.

aggregate outfile * mode = ADDVARIABLES
/break HH_ID
/FarmingHH_F_Any = max(HH_F_Any)

************************************************************************************
* Farming HH where any relative is any type of agricultral AND has the activity status 5 (contributing family worker

COMPUTE HH_F_Any_contr =(((600 <= p23_occupation and p23_occupation  <700 ) or p23_occupation =921) and (p03_relationship <= 8) and (p22_activity_status=5 )).
exe.

aggregate outfile * mode = ADDVARIABLES
/break HH_ID
/FarmingHH_F_Any_contr = max(HH_F_Any_contr)



************************************************************************************
* HEAD OF HH OVER 60 

COMPUTE HoH_over60=((p05_age >=60) and (p03_relationship = 1)).
exe.

aggregate outfile * mode = ADDVARIABLES
/break HH_ID
/Over60_HoH = max(HoH_over60)

************************************************************************************
* PARENTS CORESIDE 

COMPUTE HH_parents_cores=(p03_relationship = 6).
exe.

aggregate outfile * mode = ADDVARIABLES
/break HH_ID
/Parents_coresHH = max(HH_parents_cores)


************************************************************************************
************************************************************************************
* COmpute HH_type - four different ways
************************************************************************************
************************************************************************************

************************************************************************************
* where farming means  FarmingHH_HoH 

IF  (FarmingHH_F_HoH = 0 ) HH_Type_HoH = 0. 
IF  (FarmingHH_F_HoH = 1 & Over60_HoH = 1 ) HH_Type_HoH =1.
IF  (FarmingHH_F_HoH = 1 & Over60_HoH = 0 & Parents_coresHH = 1) HH_Type_HoH =2.
IF  (FarmingHH_F_HoH = 1 & Over60_HoH = 0 & Parents_coresHH = 0) HH_Type_HoH =3.
VALUE LABELS HH_Type_HoH 0 'not farming' 1 'HoH over 60' 2 'HoH under 60 AND parents cores' 3 'HoH under 60 and parents not cores'.
EXECUTE.

************************************************************************************
* where farming means  FarmingHH_HoH_Sp 

IF  (FarmingHH_HoH_Sp = 0 ) HH_Type_HoH_Sp=0. 
IF  (FarmingHH_HoH_Sp = 1 & Over60_HoH = 1 ) HH_Type_HoH_Sp=1.
IF  (FarmingHH_HoH_Sp = 1 & Over60_HoH = 0 & Parents_coresHH = 1) HH_Type_HoH_Sp=2.
IF  (FarmingHH_HoH_Sp = 1 & Over60_HoH = 0 & Parents_coresHH = 0) HH_Type_HoH_Sp=3.
VALUE LABELS HH_Type_HoH_Sp 0 'not farming' 1 'HoH over 60' 2 'HoH under 60 AND parents cores' 3 'HoH under 60 and parents not cores'.
EXECUTE.

************************************************************************************
* where farming means FarmingHH_F_Any 

IF  (FarmingHH_F_Any = 0 ) HH_Type_Any=0. 
IF  (FarmingHH_F_Any = 1 & Over60_HoH = 1 ) HH_Type_Any=1.
IF  (FarmingHH_F_Any = 1 & Over60_HoH = 0 & Parents_coresHH = 1) HH_Type_Any=2.
IF  (FarmingHH_F_Any = 1 & Over60_HoH = 0 & Parents_coresHH = 0) HH_Type_Any=3.
VALUE LABELS HH_Type_Any 'not farming' 1 'HoH over 60' 2 'HoH under 60 AND parents cores' 3 'HoH under 60 and parents not cores'.
EXECUTE.

************************************************************************************
* where farming means 

************************************************************************************
************************************************************************************
* CROSSTABS FOR KEN - PART ONE
* select only Heads of households:

DATASET ACTIVATE MainFile.
USE ALL.
COMPUTE filter_$=(p03_relationship = 1 ).
VARIABLE LABELS filter_$ 'Head of household'.
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'.
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.

CROSSTABS
  /TABLES=p05_age_binned BY p04_sex BY HH_Type_Any_relative
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.

CROSSTABS
  /TABLES= p09_disablity_sum BY p05_age_binned BY p04_sex BY HH_Type
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.

FILTER OFF.


************************************************************************************
** OUTPUT MANAGMENT 
************************************************************************************

OMS
  /SELECT TABLES
  /IF COMMANDS=['Crosstabs'] SUBTYPES=['Crosstabulation']
  /DESTINATION FORMAT=SAV NUMBERED=TableNumber_
   OUTFILE='C:\Users\Dell\Documents\IBM\SPSS\Statistics\census\output\KH01.sav' VIEWER=YES
  /TAG='KH01.SAV'.

OMS
  /SELECT TABLES
  /IF COMMANDS=['Crosstabs'] SUBTYPES=['Crosstabulation']
  /DESTINATION FORMAT=XLSX
   OUTFILE='C:\Users\Dell\Documents\IBM\SPSS\Statistics\census\output\KH01.xlsx' VIEWER=YES
  /TAG='KH01.XLSX'.


DATASET ACTIVATE MainFile.
CROSSTABS
  /TABLES=p05_age_binned BY p04_sex
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.




************************************************************************************
************************************************************************************
* END EXPORT
************************************************************************************
* OMSEND.
OMSEND TAG=['KH01.SAV'].
OMSEND TAG=['KH01.XLSX'].

DATASET CLOSE HeadsOfHH.
OUTPUT CLOSE *.



