/* Type these commands to install the "estout" package: 

ssc install estout

Also: Note you can type help [command] into Stata to get help on any command. 
*/

*open directory
cd "/Users/sp3770/Documents/GitHub/Research-Methods/HW1"

* Read in data: 
insheet using assignment1-research-methods.csv

* Label your variables
label variable calledback "Called Back"
label variable eliteschoolcandidate "Elite School Candidate"
label variable malecandidate "Male Candidate"
label variable bigcompanycandidate "Big Company Candidate"
label variable recruiterismale "Male Recruiter"
label variable recruiteriswhite "White Recruiter"

* Run regression: 
reg calledback eliteschoolcandidate malecandidate

* Store regression
eststo regression_one 

**********************************
* FOR PEOPLE USING MICROSOFT: 
global tableoptions "bf(%15.3gc) sfmt(%15.3gc) se label noisily noeqlines nonumbers varlabels(_cons Constant, end("" ) nolast)  starlevels(* 0.1 ** 0.05 *** 0.01) replace r2"
esttab regression_one using Elite-School-Effect.rtf, $tableoptions keep(eliteschoolcandidate malecandidate)
