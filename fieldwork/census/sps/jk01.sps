

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
* Binned age groups - 5 years 

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
* recode education into 7 categories

recode  p21_highest_grade (missing = copy) (0 thru 4 = 0) (5 thru 8 = 1) (9 thru 10 = 2) (11 = 3) (12 thru 15 = 4) (16 thru 18 = 5) (19 = 6)  (else = sysmis) into p21_highest_grade_c7.
variable labels p21_highest_grade_c7 'Highest level of education completed (7 categories)'.
formats p21_highest_grade_c7 (F2.0).
value labels p21_highest_grade_c7 0 'None completed' 1 'Elementary completed' 2 'Middleschool completed' 3 'Highschool completed' 4 'undergraduate' 5 'postgraduate' 6 'other'.
exe.

************************************************************************************
* Duration of residence binned

RECODE  p15_duration_of_residence (MISSING=COPY) (LO THRU 1=1) (LO THRU 2=2) (LO THRU 5=3) (LO THRU 10=4) (LO THRU 20=5) (LO THRU 30=6) (LO THRU 40=7) (LO THRU 50=8) (LO THRU HI=9) (ELSE=SYSMIS) INTO p15_duration_of_residence_binned.

VALUE LABELS  p15_duration_of_residence_binned 1  '1' 2 '2' 3 '3-5' 4 '6-10' 5 '11-20' 6 '21-30' 7 '31-40' 8 '41-50' 9 'over 50'.
EXECUTE.


************************************************************************************
* TWO age groups - 

RECODE  p05_age (MISSING=COPY)  (LO THRU 59 = 1) (LO THRU HI = 2) INTO p05_age_c2.
VARIABLE LABELS  p05_age_c2 'Age (two groups)'.
FORMATS  p05_age_c2 (F5.0).
VALUE LABELS  p05_age_c2 1  '15 - 59' 2 '60+'.
EXECUTE.

************************************************************************************
* COmpute MIGRATION_type1 - this is usual vs previous
************************************************************************************
* compare urban/rural status of usual and previous usual residence

IF  (p16_reason_for_movement = 6) Mig_type1 = 0. 
IF  (p14_usual_res_ur = 1 & p17_prev_res_ur = 1 ) Mig_type1 = 1. 
IF  (p14_usual_res_ur = 2 & p17_prev_res_ur = 1 ) Mig_type1 = 2. 
IF  (p14_usual_res_ur = 1 & p17_prev_res_ur = 2 ) Mig_type1 = 3.
IF  (p14_usual_res_ur = 2 & p17_prev_res_ur = 2 ) Mig_type1 = 4.  

VALUE LABELS Mig_type1 0 'Did Not Move' 1 'Urban-Urban' 2 'Urban-Rural' 3 'Rural-Urban' 4 'Rural-Rural'.
VARIABLE LABELS Mig_type1 'Type of Migration from previous'.
EXECUTE.


************************************************************************************
* COmpute MIGRATION_type2 - this is usual vs birth
************************************************************************************
* compare urban/rural status of usual and birth

recode p11_birth_township (MISSING=COPY) (0 = 0 ) (LO THRU HI=1) (ELSE=SYSMIS) INTO p11_birth_township_dummy.
value labels p11_birth_township_dummy 0 'Same as birthplace' 1 'Different from birthplace'.
exe. 

IF  (p11_birth_township_dummy = 0 & p12_birth_ur = p14_usual_res_ur) Mig_type2 = 0. 
IF  (p12_birth_ur = 1 & p14_usual_res_ur = 1 ) Mig_type2 = 1. 
IF  (p12_birth_ur = 1 & p14_usual_res_ur = 2 ) Mig_type2 = 2. 
IF  (p12_birth_ur = 2 & p14_usual_res_ur = 1 ) Mig_type2 = 3. 
IF  ( p12_birth_ur = 2 & p14_usual_res_ur = 2 ) Mig_type2 = 4. 

VALUE LABELS Mig_type2 0 'Did Not Move' 1 'Urban-Urban' 2 'Urban-Rural' 3 'Rural-Urban' 4 'Rural-Rural'.
VARIABLE LABELS Mig_type2 'Type of Migration from birthplace'.
EXECUTE.



************************************************************************************
* select only over 15s
USE ALL.
SELECT IF (p05_age >=15).
exe.


************************************************************************************
************************************************************************************
* CROSSTABS FOR John Knodel - INTERNAL MIGRATION  
************************************************************************************
************************************************************************************


************************************************************************************
** OUTPUT MANAGMENT 

OMS
  /SELECT TABLES
  /IF COMMANDS=['Crosstabs'] SUBTYPES=['Crosstabulation']
  /DESTINATION FORMAT=SAV NUMBERED=TableNumber_
   OUTFILE='C:\Users\Dell\Documents\IBM\SPSS\Statistics\census\output\JK01.sav' VIEWER=YES
  /TAG='JK01.SAV'.

OMS
  /SELECT TABLES
  /IF COMMANDS=['Crosstabs'] SUBTYPES=['Crosstabulation']
  /DESTINATION FORMAT=XLSX
   OUTFILE='C:\Users\Dell\Documents\IBM\SPSS\Statistics\census\output\JK01.xlsx' VIEWER=YES
  /TAG='JK01.XLSX'.

************************************************************************************



************************************************************************************
* Table 1 

CROSSTABS
  /TABLES= batch_state_region BY p11_birth_township_dummy BY p04_sex
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.

************************************************************************************
* Table 1 

CROSSTABS
  /TABLES= batch_state_region BY p11_birth_township_dummy BY p05_age_c2
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.

************************************************************************************
* Table 1 

CROSSTABS
  /TABLES= batch_state_region BY p11_birth_township_dummy BY batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.

************************************************************************************
* Table 2 

CROSSTABS
  /TABLES= batch_state_region BY Mig_type1 BY p05_age_binned
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.

************************************************************************************
* Table 2 

CROSSTABS
  /TABLES= batch_state_region BY Mig_type2 BY p05_age_binned 
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.


************************************************************************************
* Table 4

COMPUTE filter_$=(p11_birth_township_dummy = 1).
FILTER BY filter_$.
exe.

CROSSTABS
  /TABLES= batch_state_region BY p05_age_c2BY p16_reason_for_movement
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.

Filter off. 

COMPUTE filter_$=(p05_age_c2 = 2).
FILTER BY filter_$.
exe.

************************************************************************************
* Table 1 over 60 

CROSSTABS
  /TABLES= batch_state_region BY p11_birth_township_dummy BY batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.

filter off. 

COMPUTE filter_$=(Mig_type2 = 3).
FILTER BY filter_$.
exe.

************************************************************************************
* Table 3 

CROSSTABS
  /TABLES= batch_state_region BY p11_birth_township_dummy BY p04_sex
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.

************************************************************************************
* Table 3 

CROSSTABS
  /TABLES= batch_state_region BY p11_birth_township_dummy BY p05_age_c2
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.

filter off. 

************************************************************************************
* FILTER only economic migrants:

COMPUTE filter_$=(p16_reason_for_movement = 1).
FILTER BY filter_$.
exe.

************************************************************************************
* Table 5
CROSSTABS
  /TABLES= batch_state_region BY p11_birth_township_dummy BY p04_sex
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.

************************************************************************************
* Table 5 

CROSSTABS
  /TABLES= batch_state_region BY p11_birth_township_dummy BY p05_age_c2
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.

************************************************************************************
* Table 5

CROSSTABS
  /TABLES= batch_state_region BY p11_birth_township_dummy BY batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.


filter off. 


************************************************************************************
************************************************************************************
* END EXPORT
************************************************************************************
* OMSEND.

OMSEND TAG=['JK01.SAV'].
OMSEND TAG=['JK01.XLSX'].



************************************************************************************
** OUTPUT MANAGMENT 

OMS
  /SELECT TABLES
  /IF COMMANDS=['Crosstabs'] SUBTYPES=['Crosstabulation']
  /DESTINATION FORMAT=SAV NUMBERED=TableNumber_
   OUTFILE='C:\Users\Dell\Documents\IBM\SPSS\Statistics\census\output\KHm01.sav' VIEWER=YES
  /TAG='KHm01.SAV'.

OMS
  /SELECT TABLES
  /IF COMMANDS=['Crosstabs'] SUBTYPES=['Crosstabulation']
  /DESTINATION FORMAT=XLSX
   OUTFILE='C:\Users\Dell\Documents\IBM\SPSS\Statistics\census\output\KHm01.xlsx' VIEWER=YES
  /TAG='KHm01.XLSX'.

************************************************************************************
* economic activity by type of migration 

CROSSTABS
  /TABLES= batch_state_region BY Mig_type1 BY p22_activity_status
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.


************************************************************************************
* Rural Urban migration  (usual residence)

COMPUTE filter_$=(Mig_type1 = 3).
FILTER BY filter_$.
exe.

************************************************************************************
* duration by sex

CROSSTABS
  /TABLES= batch_state_region BY p15_duration_of_residence_binned BY p04_sex 
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.

************************************************************************************
* duration by age

CROSSTABS
  /TABLES= batch_state_region BY p15_duration_of_residence_binned BY p05_age_binned
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.

************************************************************************************
* duration by education 

CROSSTABS
  /TABLES= batch_state_region BY p15_duration_of_residence_binned BY p21_highest_grade_c7
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.

filter off. 

************************************************************************************
************************************************************************************
* END EXPORT
************************************************************************************
* OMSEND.

OMSEND TAG=['KHm01.SAV'].
OMSEND TAG=['KHm01.XLSX'].


OUTPUT CLOSE *.



