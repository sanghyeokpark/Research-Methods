/* Type these commands to install the "estout" package: 

ssc install estout

Also: Note you can type help [command] into Stata to get help on any command. 
*/

*open directory
cd "/Users/sp3770/Documents/GitHub/Research-Methods/HW2"

* Read in data: 
insheet using vaping-ban-panel.csv

* Label your variables
label variable stateid "State ID"
label variable year "Year"
label variable vapingban "Vaping Ban"
label variable lunghospitalizations "Lung Hospitalization"

* Generate group variables
generate group=.
replace group = 1 if stateid <= 23
replace group = 0 if stateid > 23
label variable group "Group Designation"

* Generate time variables
generate time=.
replace time = 0 if year <= 2020
replace time = 1 if year >= 2021
label variable time "Before/After Treatment"

* Generate difference-in-difference variables
gen did = group*time
label variable did "Diff-in-Diff Measure"

* Average of lunghospitalizations by year and group
egen avg0 = mean(lunghospitalizations), by(year group)

* Run regression to test for parallel trends
reg lunghospitalizations year if time == 0 & group == 0

* Store regression
eststo reg_parallel_cont

* Run regression to test for parallel trends
reg lunghospitalizations year if time == 0 & group == 1

* Store regression
eststo reg_parallel_treat

* graph of parallel condition
graph twoway ///
scatter lunghospitalizations year if group == 0 || ///
scatter lunghospitalizations year if group == 1 || ///
line avg0 year if group == 0 || ///
line avg0 year if group == 1 ///
, title("Diff-in-Diff Lung Hospitalization") ytitle("# of Hospitalizations") ///
legend(order(4 "Treatment Average" 3 "Control Average" 2 "Treatment Scatter" 1 "Control Scatter")) xline(2021)

* Run second regression to test for did
reg lunghospitalizations group time did i.stateid i.year

* test for state fixed effects
testparm i.stateid

* Store regression
eststo reg_DiD

**********************************
* FOR PEOPLE USING MICROSOFT: 
global tableoptions "bf(%15.3gc) sfmt(%15.3gc) se label noisily noeqlines nonumbers varlabels(_cons Constant, end("" ) nolast)  starlevels(* 0.1 ** 0.05 *** 0.01) replace r2"
esttab reg_parallel_cont using vaping-ban-parallel-test1.rtf, $tableoptions keep(year)
esttab reg_parallel_treat using vaping-ban-parallel-test2.rtf, $tableoptions keep(year)
esttab reg_DiD using vaping-ban-effect.rtf, $tableoptions keep(group time did)
