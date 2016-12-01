

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
VARIABLE LABELS p09_disablity_sum 'Disabilites regular sum (12)'.

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

VARIABLE LABELS p09_disablity_rescaled_sum 'Disabilites rescaled sum (8)'.

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

VARIABLE LABELS p09_disablity_dummy_sum 'Disabilites dummy sum (4)'.

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
* Farming HH where any relative is any type of agricultral AND has the activity status 5 (contributing family worker) OR 4 (household worker)

COMPUTE HH_F_Any_contr =(((600 <= p23_occupation and p23_occupation  <700 ) or p23_occupation =921) and (p03_relationship <= 8) and (p22_activity_status=5 or p22_activity_status=4 )).
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
VARIABLE LABELS HH_Type_HoH 'Type of Farming HH (HoH is 6xx)'
EXECUTE.

************************************************************************************
* where farming means  FarmingHH_HoH_Sp 

IF  (FarmingHH_HoH_Sp = 0 ) HH_Type_HoH_Sp=0. 
IF  (FarmingHH_HoH_Sp = 1 & Over60_HoH = 1 ) HH_Type_HoH_Sp=1.
IF  (FarmingHH_HoH_Sp = 1 & Over60_HoH = 0 & Parents_coresHH = 1) HH_Type_HoH_Sp=2.
IF  (FarmingHH_HoH_Sp = 1 & Over60_HoH = 0 & Parents_coresHH = 0) HH_Type_HoH_Sp=3.
VALUE LABELS HH_Type_HoH_Sp 0 'not farming' 1 'HoH over 60' 2 'HoH under 60 AND parents cores' 3 'HoH under 60 and parents not cores'.
VARIABLE LABELS HH_Type_HoH_Sp 'Type of Farming HH (HoH or Spouse is 6xx)'
EXECUTE.

************************************************************************************
* where farming means FarmingHH_F_Any 

IF  (FarmingHH_F_Any = 0 ) HH_Type_Any=0. 
IF  (FarmingHH_F_Any = 1 & Over60_HoH = 1 ) HH_Type_Any=1.
IF  (FarmingHH_F_Any = 1 & Over60_HoH = 0 & Parents_coresHH = 1) HH_Type_Any=2.
IF  (FarmingHH_F_Any = 1 & Over60_HoH = 0 & Parents_coresHH = 0) HH_Type_Any=3.
VALUE LABELS HH_Type_Any 'not farming' 1 'HoH over 60' 2 'HoH under 60 AND parents cores' 3 'HoH under 60 and parents not cores'.
VARIABLE LABELS HH_Type_Any 'Type of Farming HH (Any relative is 6xx)'
EXECUTE.

************************************************************************************
* where farming means FarmingHH_F_Any_contr

IF  (FarmingHH_F_Any_contr = 0 ) HH_Type_Any_contr =0. 
IF  (FarmingHH_F_Any_contr = 1 & Over60_HoH = 1 ) HH_Type_Any_contr =1.
IF  (FarmingHH_F_Any_contr = 1 & Over60_HoH = 0 & Parents_coresHH = 1) HH_Type_Any_contr =2.
IF  (FarmingHH_F_Any_contr = 1 & Over60_HoH = 0 & Parents_coresHH = 0) HH_Type_Any_contr =3.
VALUE LABELS HH_Type_Any_contr 'not farming' 1 'HoH over 60' 2 'HoH under 60 AND parents cores' 3 'HoH under 60 and parents not cores'.
VARIABLE LABELS HH_Type_Any_contr 'Type of Farming HH (Any relative is 6xx/921 AND contributing)'
EXECUTE.


************************************************************************************
* AVAILABILITY OF HHLABOUR - MALE
************************************************************************************
* HH member, not Head, activity status = contributing or any farming occupation

COMPUTE Avail_Labour_M = 0
IF  (p04_sex = 1 AND p03_relationship NE 1 & ((p22_activity_status = 5 or p22_activity_status = 4) or ((600 <= p23_occupation and p23_occupation  <700 ) or p23_occupation =921)) Avail_Labour_M = 1. 
exe.

aggregate outfile * mode = ADDVARIABLES
/break HH_ID
/HH_N_Avail_Labour_M = sum(Avail_Labour_M).

VARIABLE LABELS HH_N_Avail_Labour_M  'Number of available MALE agri labourers in HH'.


************************************************************************************
* AVAILABILITY OF HHLABOUR - FEMALE
************************************************************************************
* HH member, not Head, activity status = contributing or any farming occupation

COMPUTE Avail_Labour_F = 0
IF  (p04_sex = 2 AND p03_relationship NE 1 & ((p22_activity_status = 5 or p22_activity_status = 4) or ((600 <= p23_occupation and p23_occupation  <700 ) or p23_occupation =921)) Avail_Labour_F = 1. 
exe.

aggregate outfile * mode = ADDVARIABLES
/break HH_ID
/HH_N_Avail_Labour_F = sum(Avail_Labour_F).

VARIABLE LABELS HH_N_Avail_Labour_F 'Number of available FEMALE agri labourers in HH'.

************************************************************************************
* AVAILABILITY OF HHLABOUR
************************************************************************************

COMPUTE HH_N_Avail_Labour = HH_N_Avail_Labour_M + HH_N_Avail_Labour_F.
EXE.

VARIABLE LABELS HH_N_Avail_Labour 'Total Number of available agri labourers in HH'.


************************************************************************************
* NO CAR, MOTORCYCLE OR TRACTOR IN HH
************************************************************************************
* 

COMPUTE No_Vehicle = 0.
IF  (p39g_car_truck_van + p39h_motorcycle_moped + p39h_j_4_wheel_tractor = 0) No_Vehice = 1. 
exe.

aggregate outfile * mode = ADDVARIABLES
/break HH_ID
/HH_No_Vehicle = max(No_Vehicle).
VALUE LABELS HH_No_Vehicle 0 'at least one motor vehicle' 1 'No motor vehicles'. 
VARIABLE LABELS HH_No_Vehicle  'No motor vehicle in HH'.
exe. 

************************************************************************************
* select only Heads of households - i.e. one row per HH
USE ALL.
SELECT IF (p03_relationship = 1).
exe.



************************************************************************************
************************************************************************************
* CROSSTABS FOR KEN - PART ONE: Age by Gender by disability by HH type by region?
************************************************************************************
************************************************************************************


************************************************************************************
** OUTPUT MANAGMENT 

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

************************************************************************************
* HoH Farming HH

CROSSTABS
  /TABLES= batch_state_region BY HH_Type_HoH BY p09_p09_disablity_dummy_sum BY p05_age_binned BY p04_sex 
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.

************************************************************************************
* HoH or spouse Farming HH

CROSSTABS
  /TABLES= batch_state_region BY HH_Type_HoH_Sp BY p09_p09_disablity_dummy_sum BY p05_age_binned BY p04_sex 
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.

************************************************************************************
* Any relative Farming HH

CROSSTABS
  /TABLES= batch_state_region BY HH_Type_Any BY p09_p09_disablity_dummy_sum BY p05_age_binned BY p04_sex 
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.

************************************************************************************
* Any relative contributing Farming HH

CROSSTABS
  /TABLES= batch_state_region BY HH_Type_Any_contr BY p09_p09_disablity_dummy_sum BY p05_age_binned BY p04_sex 
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





************************************************************************************
************************************************************************************
* CROSSTABS FOR KEN - PART Two: distribution of M/F/Total number of available
* labour in HH for different HH type and region, male and female HoH
************************************************************************************
************************************************************************************


************************************************************************************
** OUTPUT MANAGMENT 

OMS
  /SELECT TABLES
  /IF COMMANDS=['Crosstabs'] SUBTYPES=['Crosstabulation']
  /DESTINATION FORMAT=SAV NUMBERED=TableNumber_
   OUTFILE='C:\Users\Dell\Documents\IBM\SPSS\Statistics\census\output\KH02.sav' VIEWER=YES
  /TAG='KH02.SAV'.

OMS
  /SELECT TABLES
  /IF COMMANDS=['Crosstabs'] SUBTYPES=['Crosstabulation']
  /DESTINATION FORMAT=XLSX
   OUTFILE='C:\Users\Dell\Documents\IBM\SPSS\Statistics\census\output\KH02.xlsx' VIEWER=YES
  /TAG='KH02.XLSX'.

************************************************************************************
* HoH Farming HH

CROSSTABS
  /TABLES= batch_state_region BY HH_Type_HoH BY p04_sex BY HH_N_Avail_Labour HH_N_Avail_Labour_M HH_N_Avail_Labour_F
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.

************************************************************************************
* HoH or spouse Farming HH

CROSSTABS
  /TABLES= batch_state_region BY HH_Type_HoH_Sp BY p04_sex BY HH_N_Avail_Labour HH_N_Avail_Labour_M HH_N_Avail_Labour_F
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.

************************************************************************************
* Any relative Farming HH

CROSSTABS
  /TABLES= batch_state_region BY HH_Type_Any BY p04_sex BY HH_N_Avail_Labour HH_N_Avail_Labour_M HH_N_Avail_Labour_F
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.

************************************************************************************
* Any relative contributing Farming HH

CROSSTABS
  /TABLES= batch_state_region BY HH_Type_Any_contr BY p04_sex BY HH_N_Avail_Labour HH_N_Avail_Labour_M HH_N_Avail_Labour_F
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.


************************************************************************************
************************************************************************************
* END EXPORT
************************************************************************************
* OMSEND.
OMSEND TAG=['KH02.SAV'].
OMSEND TAG=['KH02.XLSX'].



************************************************************************************
************************************************************************************
* CROSSTABS FOR KEN - PART THREE: 
************************************************************************************
************************************************************************************


************************************************************************************
** OUTPUT MANAGMENT 

OMS
  /SELECT TABLES
  /IF COMMANDS=['Crosstabs'] SUBTYPES=['Crosstabulation']
  /DESTINATION FORMAT=SAV NUMBERED=TableNumber_
   OUTFILE='C:\Users\Dell\Documents\IBM\SPSS\Statistics\census\output\KH03.sav' VIEWER=YES
  /TAG='KH03.SAV'.

OMS
  /SELECT TABLES
  /IF COMMANDS=['Crosstabs'] SUBTYPES=['Crosstabulation']
  /DESTINATION FORMAT=XLSX
   OUTFILE='C:\Users\Dell\Documents\IBM\SPSS\Statistics\census\output\KH03.xlsx' VIEWER=YES
  /TAG='KH03.XLSX'.

************************************************************************************
* HoH Farming HH

CROSSTABS
  /TABLES= batch_state_region BY HH_Type_HoH BY p04_sex BY HH_No_Vehicle
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.

************************************************************************************
* HoH or spouse Farming HH

CROSSTABS
  /TABLES= batch_state_region BY HH_Type_HoH_Sp BY p04_sex BY HH_No_Vehicle
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.

************************************************************************************
* Any relative Farming HH

CROSSTABS
  /TABLES= batch_state_region BY HH_Type_Any BY p04_sex BY HH_No_Vehicle
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.

************************************************************************************
* Any relative contributing Farming HH

CROSSTABS
  /TABLES= batch_state_region BY HH_Type_Any_contr BY p04_sex BY HH_No_Vehicle
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.


************************************************************************************
************************************************************************************
* END EXPORT
************************************************************************************
* OMSEND.
OMSEND TAG=['KH03.SAV'].
OMSEND TAG=['KH03.XLSX'].


OUTPUT CLOSE *.



