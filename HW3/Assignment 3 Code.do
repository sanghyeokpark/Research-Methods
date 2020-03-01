/* Type these commands to install the "estout" package: 

ssc install estout

Also: Note you can type help [command] into Stata to get help on any command. 
*/

*open directory
cd "/Users/sp3770/Documents/GitHub/Research-Methods/HW3"

* Read in data: 
insheet using sports-and-education.csv

* Label your variables
label variable collegeid "College ID"
label variable academicquality "Academic Quality"
label variable athleticquality "Athletic Quality"
label variable nearbigmarket "Near Big Market"
label variable ranked2017 "In Ranking in 2017"
label variable alumnidonations2018 "Alumni Donations in 2018"

* Create Balance Tables after t-test
. global balanceopts "bf(%15.3gc) sfmt(%15.3gc) se label noisily noeqlines nonumbers varlabels(_cons Constant, end("" ) nolast)  starlevels(* 0.1 ** 0.05 *** 0.01)"

. estpost ttest academicquality athleticquality nearbigmarket, by(ranked2017) unequal welch
esttab . using balance_table.rtf, cell("mu_1(f(3)) mu_2(f(3)) b(f(3) star)") wide collabels("Control" "Treatment" "Difference") noobs $balanceopts mlabels(none) eqlabels(none) legend replace mgroups(none)

* Run regression to test 
reg ranked2017 academicquality athleticquality nearbigmarket

* Store regression
eststo reg_rank

* Report Regression Table
global tableoptions "bf(%15.3gc) sfmt(%15.3gc) se label noisily noeqlines nonumbers varlabels(_cons Constant, end("" ) nolast)  starlevels(* 0.1 ** 0.05 *** 0.01) replace r2"
esttab reg_rank using ranking_prediction.rtf, $tableoptions keep(academicquality athleticquality nearbigmarket)

* Propensity score
. logit ranked2017 academicquality athleticquality nearbigmarket 

* Create and store the propensity score to "pr"
. predict propensity_score, pr

* graph of stacked histogram
twoway (histogram propensity_score if ranked2017==1, start(0) width(0.1) color(green)) ///
       (histogram propensity_score if ranked2017==0, start(0) width(0.1) ///
	   fcolor(none) lcolor(black)), legend(order(1 "Ranked" 2 "Non-Ranked" )) ///
	   title("Overlap Histogram for Propensity Store")

	   
* Keep if the propensity score is >0.3 or <0.8
keep if (propensity_score <= 0.8)
keep if (propensity_score >= 0.3)	   
	   
* sort by propensity_score
. sort propensity_score
. gen block = floor(_n/4)

* Run regression to test 
reg alumnidonations2018 ranked2017 academicquality athleticquality nearbigmarket i.block

* Store regression
eststo reg_main

* Report Regression Table
global tableoptions "bf(%15.3gc) sfmt(%15.3gc) se label noisily noeqlines nonumbers varlabels(_cons Constant, end("" ) nolast)  starlevels(* 0.1 ** 0.05 *** 0.01) replace r2"
esttab reg_main using ranking_prediction.rtf, $tableoptions keep(ranked2017 academicquality athleticquality nearbigmarket)

