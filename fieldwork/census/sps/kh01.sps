* Encoding: UTF-8.
GET
  FILE='D:\one percent.sav'.
DATASET NAME MainFile WINDOW=FRONT.

DATASET ACTIVATE MainFile.

* REMOVE INSTITUTIONS - formtype = 2

USE ALL.
SELECT IF (form_type  = 1).
exe.
DATASET ACTIVATE MainFile.


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


SORT CASES  BY HH_ID.
SPLIT FILE LAYERED BY HH_ID.
split file off.


* farming households: where head of HH is in farming occupation, skilled or unskilled

 * COMPUTE HH_f1=(((600 <= p23_occupation and p23_occupation  <700 ) or p23_occupation =921) and (p03_relationship = 1)).
 * exe.

 * COMPUTE HH_f2=((600 <= p23_occupation and p23_occupation  <700 ) and (p03_relationship = 1)).
 * exe.

 * COMPUTE HH_f3=(((600 <= p23_occupation and p23_occupation  <700 ) or p23_occupation =921) and (p03_relationship = 1 or p03_relationship = 2)).
 * exe.

 * COMPUTE HH_f4=((600 <= p23_occupation and p23_occupation  <700 ) and (p03_relationship = 1 or p03_relationship = 2)).
 * exe.

COMPUTE HH_f5=((600 <= p23_occupation and p23_occupation  <700 ) and (p03_relationship <= 8)).
exe.


* then simply use max to get the total number in each household (break == barcode) 

use all.
aggregate outfile * mode = ADDVARIABLES
/break HH_ID
/FarmingHH = max(HH_f5)


DATASET COPY  FarmingHH.
DATASET ACTIVATE  FarmingHH.
USE ALL.
SELECT IF (FarmingHH = 1).
EXECUTE.

output close *.

