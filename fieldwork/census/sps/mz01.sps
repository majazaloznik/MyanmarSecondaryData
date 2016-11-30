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

* new var:  number of generations in household:
first split file into households - barcode used as the is the unique identifier

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

* CROSSTABS FOR GL - PART ONE
* select only heads of househodls 

DATASET COPY  onePercentHeads.
DATASET ACTIVATE  onePercentHeads.
FILTER OFF.
USE ALL.
SELECT IF (p03_relationship = 1).
EXECUTE.

DATASET ACTIVATE onePercentHeads.


* GROUPED AGE BY TYPES OF DISABILITY (5 YEAR AGE GROUPS)

CROSSTABS
  /TABLES=p09a_disability_seeing p09b_disability_hearing p09c_disability_walking 
    p09d_disability_remembering BY age_head_binned_5
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN 
  /COUNT ROUND CELL.




CROSSTABS
  /TABLES=p09a_disability_seeing p09b_disability_hearing p09c_disability_walking 
    p09d_disability_remembering BY age_head_binned_10
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN 
  /COUNT ROUND CELL.

CROSSTABS
  /TABLES=p09a_disability_seeing p09b_disability_hearing p09c_disability_walking 
    p09d_disability_remembering BY sex_head
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN 
  /COUNT ROUND CELL.

CROSSTABS
  /TABLES=p09a_disability_seeing p09b_disability_hearing p09c_disability_walking 
    p09d_disability_remembering BY marital_status_head
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN 
  /COUNT ROUND CELL.


CROSSTABS
  /TABLES=p09a_disability_seeing p09b_disability_hearing p09c_disability_walking 
    p09d_disability_remembering BY number_of_people
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN 
  /COUNT ROUND CELL.

CROSSTABS
  /TABLES=p09a_disability_seeing p09b_disability_hearing p09c_disability_walking 
    p09d_disability_remembering BY unique_generations
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN 
  /COUNT ROUND CELL.

CROSSTABS
  /TABLES=p09a_disability_seeing p09b_disability_hearing p09c_disability_walking 
    p09d_disability_remembering BY p21_highest_grade
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN 
  /COUNT ROUND CELL.


CROSSTABS
  /TABLES=p09a_disability_seeing p09b_disability_hearing p09c_disability_walking 
    p09d_disability_remembering BY p22_activity_status
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN 
  /COUNT ROUND CELL.

CROSSTABS
  /TABLES=p09a_disability_seeing p09b_disability_hearing p09c_disability_walking 
    p09d_disability_remembering BY batch_urban_rural
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT COLUMN 
  /COUNT ROUND CELL.

