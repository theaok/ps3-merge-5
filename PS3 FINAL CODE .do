//Problem Set 3 
//Rachel Wagner 
//October 11 2018

//version 15
pwd 
ls
cap mkdir  directedStudy
cd directedStudy
ls

//importing Good Reads Sample 
use https://github.com/rachelwagner/ps3-merge-5/raw/master/100ksample1goodreads.dta, clear 
 l datadd in 1/100
//making the date in this data read like the date in holidays data :) 
gen year=substr(datadd, -5,4) 
gen daymo=substr(datadd, 5,6) 
gen mo1=substr(daymo, 1,3)
gen day1=substr(daymo, -2,2)
l datadd year daymo mo1 day1 in 1/10
// Replacing month words with month numbers ("Jan" to "1") 
gen mo2=""
replace mo2="01" if mo1=="Jan"
replace mo2="02" if mo1=="Feb"
replace mo2="03" if mo1=="Mar"
replace mo2="04" if mo1=="Apr"
replace mo2="05" if mo1=="May"
replace mo2="06" if mo1=="Jun"
replace mo2="07" if mo1=="Jul"
replace mo2="08" if mo1=="Aug"
replace mo2="09" if mo1=="Sep"
replace mo2="10" if mo1=="Oct"
replace mo2="11" if mo1=="Nov"
replace mo2="12" if mo1=="Dec"
gen date=year+"-"+mo2+"-"+day1
ta date // it worked!
save dayMoYr, replace 

insheet using https://raw.githubusercontent.com/rachelwagner/ps3-merge-5/master/usholidays.csv,clear name
 //2018-02-19
 ta date in 1/100
  //always before counting sort
 sort date
 count if date==date[_n-1]
 l if date==date[_n-1]
 drop if date=="1989-11-11" & v1==327
 
merge 1:m date using dayMoYr

l date if _merge==1
ta date if _merge==2

//the goodreads data is the most importan one, shouldnt drop from there, but from holidatys
drop if _merge==1
sort booid
//drop if booid==booid[_n-1]
drop _merge

save goodreads_holiday, replace //maybe more parsimoinuious
save goodreadsholidaymerge, replace 

//Merge booid with goodreadsholidays :)
use https://github.com/rachelwagner/ps3-merge-5/raw/master/ratingsgoodbooksample.dta, clear
rename book_id booid
cap drop _merge //supress error 

//------------------------------------
//figuring out if it is unique:
sort booid
count if booid==booid[_n-1]
sort user_id
count if user_id==user_id[_n-1]
sort user_id booid
edit
sort  booid user_id
edit
//need to collapse to merge it!
preserve
collapse rating, by(user_id)
save ratingUser, replace
restore //go back to preserved data
collapse rating, by(booid)
save ratingBook, replace

//--------------------------------------
use ratingBook,clear
merge 1:m booid using goodreadsholidaymerge
drop if _merge==1 //because master is 
//additonal or supreflous dataset abd whatever
//doesnt match from there is useless
//--------------------------------
//and then just mergre with the above

//merge m:1 booid using goodreadsholidaymerge


//save goodreadsholidaybooidmerge, replace 

//investigating why so many unmatched obs 
l booid in 1/100 if _merge==1 //repeated obs because there's going to be reviews on the same bookid
l booid in 1/1000 if _merge==2 // "1.4e+06" for most of using unmatched obs 
ta booid in 1/100000 if _merge==1 
ta booid if _merge==2

//dropping unmatched obs
drop if _merge==1
drop if _merge==2 

save goodreadsholidaybooidmerge, replace //saves matched obs 
