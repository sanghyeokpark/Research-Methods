/* Type these commands to install the "estout" package: 

ssc install estout

Also: Note you can type help [command] into Stata to get help on any command. 
*/

*open directory
cd "/Users/sp3770/Documents/GitHub/Research-Methods/HW4"

* Read in data: 
insheet using crime-iv.csv

* Label your variables
label variable defendantid "Defendent ID"
label variable republicanjudge "Republican Judge"
label variable severityofcrime "Severity of Crime"
label variable monthsinjail "Months in Jail"
label variable recidivates "Recidivates"

* Create Balance Tables after t-test
. global balanceopts "bf(%15.3gc) sfmt(%15.3gc) se label noisily noeqlines nonumbers varlabels(_cons Constant, end("" ) nolast)  starlevels(* 0.1 ** 0.05 *** 0.01)"

. estpost ttest severityofcrime, by(republicanjudge) unequal welch
esttab . using balance_table.rtf, cell("mu_1(f(3)) mu_2(f(3)) b(f(3) star)") wide collabels("Democratic Judge" "Republican Judge" "Difference") noobs $balanceopts mlabels(none) eqlabels(none) legend replace mgroups(none)

* Run regression for first stage
reg monthsinjail republicanjudge severityofcrime
predict monthsinjail_hat, xb
label variable monthsinjail_hat "Predicted Months in Jail"

* Store regression
eststo reg_first

* Report Regression Table
global tableoptions "bf(%15.3gc) sfmt(%15.3gc) se label noisily noeqlines nonumbers varlabels(_cons Constant, end("" ) nolast)  starlevels(* 0.1 ** 0.05 *** 0.01) replace r2"
esttab reg_first using first_stage_reg.rtf, $tableoptions keep(republicanjudge)

* Run regression for second stage
reg recidivates monthsinjail_hat severityofcrime

* Store regression
eststo reg_sec

* Report Regression Table
global tableoptions "bf(%15.3gc) sfmt(%15.3gc) se label noisily noeqlines nonumbers varlabels(_cons Constant, end("" ) nolast)  starlevels(* 0.1 ** 0.05 *** 0.01) replace r2"
esttab reg_sec using reg_second_stage.rtf, $tableoptions keep(monthsinjail_hat)

* Complete IV regression using package
* ssc install ivreg2
* ssc install ranktest
ivreg2 recidivates (monthsinjail=republicanjudge) severityofcrime

* Store regression
eststo reg_IV

global tableoptions "bf(%15.3gc) sfmt(%15.3gc) se label noisily noeqlines nonumbers varlabels(_cons Constant, end("" ) nolast)  starlevels(* 0.1 ** 0.05 *** 0.01) replace r2"
esttab reg_IV using reg_IV.rtf, $tableoptions keep(monthsinjail)


