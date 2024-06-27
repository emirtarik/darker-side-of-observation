
/* ================================= */
/* 		Analyze data				 */
/* 		version created 12/03/24	 */
/* ================================= */


/* COLORS
maroon navy -- information revealed
olive_teal gs10 eltgreen -- donations
eltblue emidblue -- evaluations
sienna stone -- keep give distinction
*/


clear all
********************************************************************************
**** Set relative paths

**** Define user
*global user "C:\Users\74749\Dropbox" //Emeric?
*global user "/Users/roberto.galbiati/Dropbox" //RG
global user "/Users/emir/Dropbox" //Emir
*cd "$user/Norms and reminders/ExpeData/CLEAN/"

**** Define paths (dependent on forward or backward slash)

/* Paths with backslash 
global path "$user\Norms and reminders\ExpeData\CLEAN\"
global path_fig "$user\Norms and reminders\ExpeData\CLEAN\results\figures\"
global path_tab "$user\Norms and reminders\ExpeData\CLEAN\results\tables\"
global path_raw_data "$user\Norms and reminders\ExpeData\CLEAN\data\raw\" 
global path_analysis_data "$user\Norms and reminders\ExpeData\CLEAN\data\analysis\" 
*/

* Paths with forward slash 
global path "$user/Norms and reminders/ExpeData/CLEAN/"
global path_fig "$user/Norms and reminders/ExpeData/CLEAN/results/figures/"
global path_tab "$user/Norms and reminders/ExpeData/CLEAN/results/tables/"
global path_raw_data "$user/Norms and reminders/ExpeData/CLEAN/data/raw/" 
global path_analysis_data "$user/Norms and reminders/ExpeData/CLEAN/data/analysis/" 





********************************************************************************
**** Set macros 

global pre_treatment_vars age i.educ i.female i.children i.income  

global post_treatment_exogenous i.prev_donation_charity i.prev_donation_foreigner i.prev_volunteering i.prev_blooddonation self_esteem_score probability_medecins i.ARUP_benevolent ARUP_percentage_funding
  
global se_vars se_value se_qualities se_failure se_capable se_pride se_positivity se_satisfied se_self_respect se_uselessness se_good_for_nothing
  
********************************************************************************
**** Import the dataset

* Latest version:
use "${path_analysis_data}analysis.dta", clear



* Label variables

label define choice_judged_otherlabel 1 "Give" 0 "Keep"
label values choice_judged_other choice_judged_otherlabel

*label define won_prizelabel 1 "Yes" 0 "No"
*label values won_prize won_prizelabel

label define donationlabel 1 "Donated 100€" 0 "Kept 25€"
label values donation donationlabel

label define femalelabel 1 "Female" 0 "Male"
label values female femalelabel

label define childrenlabel 0 "No" 1 "Yes"
label values children childrenlabel

label define educlabel 1 "No degree" 2 "Primary school" 3 "Middle school (former certificate)" 4 "Post-middle school professional license" 5 "Intermediate vocational certificate" 6 "Vocational high school degree" 7 "High school degree" 8 "Trade school/vocational training diploma" 9 "College degree"
label values educ educlabel

label define incomelabel 1 "< 1000 euros" 2 "1001-1500 euros" 3 "1501-1750 euros" 4 "1751-2000 euros" 5 "2001-2500 euros" 6 "2501-3000 euros" 7 "3001-4000 euros" 8 "4001-5000 euros" 9 "5001-7000 euros" 10 "> 7001 euros" 11 "Do not wish to answer"
label values income incomelabel

label define treatmentlabel /*1 "D"*/ 2 "D{subscript:p}" 3 "D{subscript:a}" 4 "O{subscript:p}"  6 "O{subscript:a}"  
*label define treatmentlabel 1 "D" 2 "Dp" 3 "Da" 4 "Op"  6 "Oa"  
label values treatment treatmentlabel

label define activelabel 1 "D{subscript:a} & O{subscript:a}" 0 "D{subscript:p}"
label values active activelabel

label define seen_ARUP 1 "Revealed the ARUP" 0 "Hid the ARUP"
label values asso_shown seen_ARUP 
label values asso_shown_combined seen_ARUP
label values asso_shown_eval seen_ARUP

label define info 1 "Option to see the ARUP" 0 "No option to see the ARUP"
label values info info

label var time "Time spent on the experiment"

*labeling predicted donations
label define pred_donationlabel 1 "P.Donated 100€" 0 "P.Kept 25€"
label values LLpred_donation pred_donationlabel
label values LRpred_donation pred_donationlabel
label values LPMpred_donation pred_donationlabel
label values Gpred_donation pred_donationlabel
label values LLpred_donation_allwithnoinfo pred_donationlabel
label values LRpred_donation_allwithnoinfo pred_donationlabel
label values LPMpred_donation_allwithnoinfo pred_donationlabel
label values Gpred_donation_allwithnoinfo pred_donationlabel
label values LLpred_donation_allwithinfo pred_donationlabel
label values LRpred_donation_allwithinfo pred_donationlabel
label values LPMpred_donation_allwithinfo pred_donationlabel
label values Gpred_donation_allwithinfo pred_donationlabel





********************************************************************************
**** REGRESSIONS 
********************************************************************************

generate keep = (donation == 0 | Gpred_donation == 0) if inlist(treatment, 4, 6)
generate obskeep = (choice_judged_other == 0) if inlist(treatment, 4, 6)




********************************************************************************
* Regression 1 - Evaluation on the interaction between Oa and ObsKeep - DiD
eststo clear

reg evaluation dummy_oa obskeep dummy_oa##obskeep if info == 1 & keep == 1
eststo model1

reg evaluation dummy_oa obskeep dummy_oa##obskeep if info == 1 & keep == 0
eststo model2

esttab model1 model2 using "${path_tab}reg1a.tex", replace ar2 label ///
    main(varlabels("Evaluation" "Dummy \$O_a$" "Obskeep" "Dummy \$O_a$ * Obskeep")) ///
    cells(b(fmt(3) star) se(fmt(3) par)) ///
    title("Regression Results") ///
	starlevels(* 0.1 ** 0.05 *** 0.01)
********************************************************************************
eststo clear

reg evaluation dummy_oa obskeep dummy_oa##obskeep if info == 0 & keep == 1
eststo model3

reg evaluation dummy_oa obskeep dummy_oa##obskeep if info == 0 & keep == 0
eststo model4

esttab model3 model4 using "${path_tab}reg1b.tex", replace ar2 label ///
    main(varlabels("Evaluation" "Dummy \$O_a$" "Obskeep" "Dummy \$O_a$ * Obskeep")) ///
    cells(b(fmt(3) star) se(fmt(3) par)) ///
    title("Regression Results") ///
	starlevels(* 0.1 ** 0.05 *** 0.01)


********************************************************************************
**** TABLES 
********************************************************************************


********************************************************************************
* Table 1 - Descriptive statistics
est clear
estpost tabstat age educ female children income, c(stat) stat(mean sd) by(game) 
esttab using "${path_tab}table1.tex", replace ////
 cells("mean(fmt(%8.2fc))" "sd(par)") nostar unstack nonumber ///
  compress nonote noobs gap booktabs   ///
   collabels(none) ///
   eqlabels("\$D_p$" "\$D_a$" "\$O_p$" "\$O_a$") /// 
   nomtitles


   
   
   
********************************************************************************
**** GRAPHS 
********************************************************************************


********************************************************************************
* Figure 1 - Evaluations by keep or give

cibar evaluation if treatment==4 | treatment==6, over1(treatment) over2(choice_judged_other) over3(info) barcol(eltblue emidblue) ///
graphopts(graphregion(fcolor(white)) ysc(range(2 5)) ylabel(2 (0.5) 5) legend(cols(1) pos(11) ring(0) region(lcolor(black))) ytitle("Mean evaluation"))
graph export  "${path_fig}figure1.pdf", replace
********************************************************************************





********************************************************************************
* Figure 1 - Real evaluations vs predicted evaluations / info vs no info

* Figure 1A - Logit Lasso Predictions
* without INFO
cibar evaluation if treatment==6 & info==0, over1(donation) over2(choice_judged_other) barcol(sienna stone) ///
graphopts(graphregion(fcolor(white)) ysc(range(2 5)) ylabel(2 (1) 5) legend(cols(1) pos(11) ring(0) region(lcolor(black))) ytitle("Mean evaluation") title("Active observers: real share"))
 graph save "${path_fig}actual_a_l.gph", replace
 
cibar evaluation if treatment==4 & info==0, over1(LLpred_donation) over2(choice_judged_other) barcol(sienna stone) ///
graphopts(graphregion(fcolor(white)) ysc(range(2 5)) ylabel(2 (1) 5) legend(cols(1) pos(11) ring(0) region(lcolor(black))) ytitle("Mean evaluation") title("Passive observers: LL pred share")) 
graph save "${path_fig}predicted_a_1.gph", replace 
 
 graph combine  "${path_fig}actual_a_l.gph" "${path_fig}predicted_a_1.gph", graphregion(color(white)) ycommon /*title("Panel A.1 - Logit Lasso (0.666 accuracy), no info treatment", size(medlarge))*/ graphregion(margin(zero))	 	
   graph export  "${path_fig}fig1_appendix_LL_info.pdf", replace 

* with INFO
cibar evaluation if treatment==6 & info==1, over1(donation) over2(choice_judged_other) barcol(sienna stone) ///
graphopts(graphregion(fcolor(white)) ysc(range(2 5)) ylabel(2 (1) 5) legend(cols(1) pos(11) ring(0) region(lcolor(black))) ytitle("Mean evaluation") title("Active observers: real share"))
 graph save "${path_fig}actual_a_2.gph", replace
 
cibar evaluation if treatment==4 & info==1, over1(LLpred_donation) over2(choice_judged_other) barcol(sienna stone) ///
graphopts(graphregion(fcolor(white)) ysc(range(2 5)) ylabel(2 (1) 5) legend(cols(1) pos(11) ring(0) region(lcolor(black))) ytitle("Mean evaluation") title("Passive observers: LL pred share")) 
graph save "${path_fig}predicted_a_2.gph", replace 
 
 graph combine  "${path_fig}actual_a_2.gph" "${path_fig}predicted_a_2.gph", graphregion(color(white)) ycommon /*title("Panel A.2 - Logit Lasso (0.549 accuracy), info treatment", size(medlarge))*/ graphregion(margin(zero))	 	
   graph export  "${path_fig}fig1_appendix_LL_info.pdf", replace 
  


* Figure 1 - Logit Ridge Predictions
* without INFO
cibar evaluation if treatment==6 & info==0, over1(donation) over2(choice_judged_other) barcol(sienna stone) ///
graphopts(graphregion(fcolor(white)) ysc(range(2 5)) ylabel(2 (1) 5) legend(cols(1) pos(11) ring(0) region(lcolor(black))) ytitle("Mean evaluation") title("Active observers: real share"))
 graph save "${path_fig}actual_b_l.gph", replace
 
cibar evaluation if treatment==4 & info==0, over1(LRpred_donation) over2(choice_judged_other) barcol(sienna stone) ///
graphopts(graphregion(fcolor(white)) ysc(range(2 5)) ylabel(2 (1) 5) legend(cols(1) pos(11) ring(0) region(lcolor(black))) ytitle("Mean evaluation") title("Passive observers: LR pred share")) 
graph save "${path_fig}predicted_b_1.gph", replace 
 
 graph combine  "${path_fig}actual_b_l.gph" "${path_fig}predicted_b_1.gph", graphregion(color(white)) ycommon /*title("Panel B.1 - Logit Ridge (0.700 accuracy), no info treatment", size(medlarge))*/ graphregion(margin(zero))	 	
   graph export  "${path_fig}fig1.pdf", replace 

* with INFO
cibar evaluation if treatment==6 & info==1, over1(donation) over2(choice_judged_other) barcol(sienna stone) ///
graphopts(graphregion(fcolor(white)) ysc(range(2 5)) ylabel(2 (1) 5) legend(cols(1) pos(11) ring(0) region(lcolor(black))) ytitle("Mean evaluation") title("Active observers: real share"))
 graph save "${path_fig}actual_b_2.gph", replace
 
cibar evaluation if treatment==4 & info==1, over1(LRpred_donation) over2(choice_judged_other) barcol(sienna stone) ///
graphopts(graphregion(fcolor(white)) ysc(range(2 5)) ylabel(2 (1) 5) legend(cols(1) pos(11) ring(0) region(lcolor(black))) ytitle("Mean evaluation") title("Passive observers: LR pred share")) 
graph save "${path_fig}predicted_b_2.gph", replace 
 
 graph combine  "${path_fig}actual_b_2.gph" "${path_fig}predicted_b_2.gph", graphregion(color(white)) ycommon /*title("Panel B.2 - Logit Ridge (0.662 accuracy), info treatment", size(medlarge))*/ graphregion(margin(zero))	 	
   graph export  "${path_fig}fig1_appendix_LR_info.pdf", replace


   
* Figure 1B - LPM Predictions
* without INFO
cibar evaluation if treatment==6 & info==0, over1(donation) over2(choice_judged_other) barcol(sienna stone) ///
graphopts(graphregion(fcolor(white)) ysc(range(2 5)) ylabel(2 (1) 5) legend(cols(1) pos(11) ring(0) region(lcolor(black))) ytitle("Mean evaluation") title("Active observers: real share"))
 graph save "${path_fig}actual_c_l.gph", replace
 
cibar evaluation if treatment==4 & info==0, over1(LPMpred_donation) over2(choice_judged_other) barcol(sienna stone) ///
graphopts(graphregion(fcolor(white)) ysc(range(2 5)) ylabel(2 (1) 5) legend(cols(1) pos(11) ring(0) region(lcolor(black))) ytitle("Mean evaluation") title("Passive observers: LPM pred share")) 
graph save "${path_fig}predicted_c_1.gph", replace 
 
 graph combine  "${path_fig}actual_c_l.gph" "${path_fig}predicted_c_1.gph", graphregion(color(white)) ycommon /*title("Panel C.1 - LPM (0.733 accuracy), no info treatment", size(medlarge))*/ graphregion(margin(zero))	 	
   graph export  "${path_fig}fig1_appendix_LPM_noinfo.pdf", replace 

* with INFO
cibar evaluation if treatment==6 & info==1, over1(donation) over2(choice_judged_other) barcol(sienna stone) ///
graphopts(graphregion(fcolor(white)) ysc(range(2 5)) ylabel(2 (1) 5) legend(cols(1) pos(11) ring(0) region(lcolor(black))) ytitle("Mean evaluation") title("Active observers: real share"))
 graph save "${path_fig}actual_c_2.gph", replace
 
cibar evaluation if treatment==4 & info==1, over1(LPMpred_donation) over2(choice_judged_other) barcol(sienna stone) ///
graphopts(graphregion(fcolor(white)) ysc(range(2 5)) ylabel(2 (1) 5) legend(cols(1) pos(11) ring(0) region(lcolor(black))) ytitle("Mean evaluation") title("Passive observers: LPM pred share")) 
graph save "${path_fig}predicted_c_2.gph", replace 
 
 graph combine  "${path_fig}actual_c_2.gph" "${path_fig}predicted_c_2.gph", graphregion(color(white)) ycommon /*title("Panel C.2 - LPM (0.662 accuracy), info treatment", size(medlarge))*/ graphregion(margin(zero))	 	
   graph export  "${path_fig}fig1_appendix_LPM_info.pdf", replace 
   
   
   
* Figure 1C - Gaussian NB Predictions
* without INFO
cibar evaluation if treatment==6 & info==0, over1(donation) over2(choice_judged_other) barcol(sienna stone) ///
graphopts(graphregion(fcolor(white)) ysc(range(2 5)) ylabel(2 (1) 5) legend(cols(1) pos(11) ring(0) region(lcolor(black))) ytitle("Mean evaluation") title("Active observers: real share"))
 graph save "${path_fig}actual_d_l.gph", replace
 
cibar evaluation if treatment==4 & info==0, over1(Gpred_donation) over2(choice_judged_other) barcol(sienna stone) ///
graphopts(graphregion(fcolor(white)) ysc(range(2 5)) ylabel(2 (1) 5) legend(cols(1) pos(11) ring(0) region(lcolor(black))) ytitle("Mean evaluation") title("Passive observers: Gaussian NB pred share")) 
graph save "${path_fig}predicted_d_1.gph", replace 
 
 graph combine  "${path_fig}actual_d_l.gph" "${path_fig}predicted_d_1.gph", graphregion(color(white)) ycommon /*title("Panel C.1 - Gaussian NB (0.633 accuracy), no info treatment", size(medlarge))*/ graphregion(margin(zero))	 	
   graph export  "${path_fig}fig1_appendix_GNB_noinfo.pdf", replace 

* with INFO
cibar evaluation if treatment==6 & info==1, over1(donation) over2(choice_judged_other) barcol(sienna stone) ///
graphopts(graphregion(fcolor(white)) ysc(range(2 5)) ylabel(2 (1) 5) legend(cols(1) pos(11) ring(0) region(lcolor(black))) ytitle("Mean evaluation") title("Active observers: real share"))
 graph save "${path_fig}actual_d_2.gph", replace
 
cibar evaluation if treatment==4 & info==1, over1(LPMpred_donation) over2(choice_judged_other) barcol(sienna stone) ///
graphopts(graphregion(fcolor(white)) ysc(range(2 5)) ylabel(2 (1) 5) legend(cols(1) pos(11) ring(0) region(lcolor(black))) ytitle("Mean evaluation") title("Passive observers: Gaussian NB pred share")) 
graph save "${path_fig}predicted_d_2.gph", replace 
 
 graph combine  "${path_fig}actual_d_2.gph" "${path_fig}predicted_d_2.gph", graphregion(color(white)) ycommon /*title("Panel C.2 - Gaussian NB (0.676 accuracy), info treatment", size(medlarge))*/ graphregion(margin(zero))	 	
   graph export  "${path_fig}fig1_appendix_GNB_info.pdf", replace  
********************************************************************************
* Figure 2C.1 - Cumulative dist
cumul evaluation if treatment==4, gen(c_t4)
cumul evaluation if treatment==6, gen(c_t6)

twoway (line c_t4 evaluation, sort lcolor(blue) lpattern(dash)) ///
       (line c_t6 evaluation, sort lcolor(red)), ///
       legend(label(1 "O{subscript:p}") label(2 "O{subscript:a}")) ///
	   ytitle("CDF of evaluation") xtitle("Evaluations")
graph export "${path_fig}figure2_cumul.pdf", replace




********************************************************************************
* Figure 2 - Information revealed by dictators
cibar asso_shown_combined if treatment<4, over1(donation) over2(treatment)  barcol(eltblue emidblue)  bargap(10) ///
graphopts(graphregion(fcolor(white)) ysc(range(0 1)) ylabel(0 (0.2) 1) legend(cols(1) pos(11) ring(0) region(lcolor(black))) ytitle("Information revealed"))  
	graph export  "${path_fig}figure2.pdf", replace

	
* Figure 2B - Information revealed by observers
cibar asso_shown_combined if treatment>3, over1(treatment)  barcol(maroon navy)  bargap(10) ///
graphopts(graphregion(fcolor(white)) text( .85 1.6  "`=ustrunescape("\u23AB")'" "`=ustrunescape("\u23AA")'"  "`=ustrunescape("\u23AA")'"    "`=ustrunescape("\u23AC")'" "`=ustrunescape("\u23AA")'" "`=ustrunescape("\u23AA")'"   "`=ustrunescape("\u23AD")'" , /// 
size(vhuge) orientation(vertical))  text(0.88 1.6 "***", size(big)) ysc(range(0 1)) ylabel(0 (0.2) 1) legend(cols(1) pos(5) ring(0) region(lcolor(black))) ytitle("Information revealed"))  
	graph export  "${path_fig}fig2.pdf", replace
********************************************************************************






********************************************************************************
* Figure 3

* Figure 3A - Access to info before evaluating by donation
cibar asso_shown_eval if treatment==6, over1(donation)  barcol(sienna stone)  bargap(10) ///
graphopts(graphregion(fcolor(white)) ysc(range(0 1)) ylabel(0 (0.2) 1) legend(cols(1) pos(11) ring(0) region(lcolor(black))) ytitle("Information revealed before evaluation") xtitle("O{subscript:a}"))
	graph export  "${path_fig}fig3A.pdf", replace

	
	
* Figure 3B - Access to info before evaluating by access to info while donating
cibar asso_shown_eval if treatment==6, over1(donation) over2(asso_shown) barcol(sienna stone)  bargap(10) ///
graphopts(graphregion(fcolor(white)) ysc(range(0 1)) ylabel(0 (0.2) 1) legend(cols(1) pos(11) ring(0) region(lcolor(black))) ytitle("Information revealed before evaluation"))
	graph export  "${path_fig}fig3B.pdf", replace
********************************************************************************  





********************************************************************************
* Figure 4A - Donations by actively observed vs. passively observed
reg donation i.treatment if treatment!=4 & info==0, robust // significant
reg donation i.treatment if treatment!=4 & info==1, robust // no significance
reg donation ib(6).treatment if treatment!=4 & info==0, robust // no significance between Oa and Da

 
cibar donation if treatment!=4, over1(treatment) over2(info) barcol(olive_teal gs10 emidblue)  bargap(10) ///
graphopts(graphregion(fcolor(white)) ///
ysc(range(0 0.4)) ylabel(0 (0.05) 0.4) legend(cols(1) pos(5) ring(0) region(lcolor(black))) ytitle("Mean donation"))
	graph export  "${path_fig}fig4_byinfo.pdf", replace
	
* Figure 4 - no info separate graph
reg donation i.treatment if treatment!=4 & info==0, robust // significant

cibar donation if treatment!=4 & info==0, over1(treatment) barcol(olive_teal eltgreen gs10)  bargap(10) ///
graphopts(graphregion(fcolor(white)) ///
ysc(range(0 0.4)) ylabel(0 (0.05) 0.4) legend(cols(1) pos(5) ring(0) region(lcolor(black))) ytitle("Mean donation"))
	graph export  "${path_fig}fig4.pdf", replace	
	
*ttesttable donation treatment if info==0, tex(figure5A_noinfo) pre("\begin{table}[!ht]\centering") post("\caption{Cross table of differences in mean by group\end{table}")
	
	
	
eststo clear
	
preserve
keep if inlist(treatment, 2, 3) & info == 0
ttest donation, by(treatment)

// Generate new variables from stored results
gen mean1 = r(mu_1)
gen mean2 = r(mu_2)
gen diff = r(mu_1) - r(mu_2)
gen pvalue = r(p)

// Use estpost to store these as estimation results
estpost tabstat mean1 mean2 diff pvalue, c(stat) stat(mean)

// Store results
eststo t23
restore
	
	
preserve
keep if inlist(treatment, 2, 6) & info == 0
ttest donation, by(treatment)

// Generate new variables from stored results
gen mean1 = r(mu_1)
gen mean2 = r(mu_2)
gen diff = r(mu_1) - r(mu_2)
gen pvalue = r(p)

// Use estpost to store these as estimation results
estpost tabstat mean1 mean2 diff pvalue, c(stat) stat(mean)

// Store results
eststo t26
restore


preserve
keep if inlist(treatment, 3, 6) & info == 0
ttest donation, by(treatment)

// Generate new variables from stored results
gen mean1 = r(mu_1)
gen mean2 = r(mu_2)
gen diff = r(mu_1) - r(mu_2)
gen pvalue = r(p)

// Use estpost to store these as estimation results
estpost tabstat mean1 mean2 diff pvalue, c(stat) stat(mean)

// Store results
eststo t36
restore
	
esttab t23 t26 t36 using `"${path_tab}figure5A_noinfo.tex"', replace booktabs label nonumbers mtitle("$D_p$ - $D_a$" "$D_p$ - $O_a$" "$D_a$ - $O_a$") // problematic.

	
	
* Figure 4B - Donations, Op vs. Da and Oa
preserve
replace donation = Gpred_donation if treatment == 4 & missing(donation)

reg donation i.treatment if treatment!=2 & info==0, robust // no significance
reg donation i.treatment if treatment!=2 & info==1, robust // no significance
reg donation ib(6).treatment if treatment!=2 & info==0, robust // when base category is Oa - no significance
 

cibar donation if treatment!=2, over1(treatment) over2(info) barcol(gs10 olive_teal eltgreen)  bargap(10) ///
graphopts(graphregion(fcolor(white)) ///
ysc(range(0 0.4)) ylabel(0 (0.05) 0.4) legend(cols(1) pos(5) ring(0) region(lcolor(black))) ytitle("Mean donation"))
	graph export  "${path_fig}figure5B.pdf", replace

restore
********************************************************************************



********************************************************************************
* Figure 5 - average evaluation expectations - dictators
table treatment info, statistic(mean expected_evaluation) 


cibar expected_evaluation if treatment<4, over1(treatment) over2(donation) barcol(eltblue emidblue) ///
graphopts(graphregion(fcolor(white)) ysc(range(2 5)) ylabel(2 (1) 5) legend(cols(1) pos(11) ring(0) region(lcolor(black))) ytitle("Mean expected evaluation"))
 graph export  "${path_fig}fig5A.pdf", replace 
 
cibar expected_evaluation if treatment<4, over1(treatment) over2(donation) over3(info) barcol(eltblue emidblue) ///
graphopts(graphregion(fcolor(white)) ysc(range(2 5)) ylabel(2 (1) 5) legend(cols(1) pos(11) ring(0) region(lcolor(black))) ytitle("Mean expected evaluation")) 
graph export "${path_fig}fig5B.pdf", replace 
 
   
********************************************************************************
* * Figure 6 - average evaluation expectations - observers (Op predicted values for donation)
preserve
label define fig5_predlabel 1 "Donated 100€" 0 "Kept 25€"
label values LRpred_donation fig5_predlabel

cibar expected_evaluation if treatment>3, over1(treatment) over2(LRpred_donation) over3(info) barcol(eltblue emidblue) ///
graphopts(graphregion(fcolor(white)) ysc(range(2 5)) ylabel(2 (1) 5) legend(cols(1) pos(11) ring(0) region(lcolor(black))) ytitle("Mean expected evaluation"))
 graph export  "${path_fig}fig6.pdf", replace 
 
restore 
********************************************************************************




********************************************************************************
* Figure 6 - Info revealed

cibar asso_shown_combined if treatment==6, over1(donation)  barcol()  bargap(10) ///
graphopts(graphregion(fcolor(white)) ysc(range(0 1)) ylabel(0 (0.2) 1) legend(cols(1) pos(11) ring(0) region(lcolor(black))) ytitle("Information revealed overall") xtitle("O{subscript:a}"))
	graph export  "${path_fig}figure6A.pdf", replace
	
cibar asso_shown_eval if treatment==4, over1(Gpred_donation_allwithnoinfo)  barcol()  bargap(10) ///
graphopts(graphregion(fcolor(white)) ysc(range(0 1)) ylabel(0 (0.2) 1) legend(cols(1) pos(11) ring(0) region(lcolor(black))) ytitle("Information revealed while evaluating") xtitle("O{subscript:p}"))
	graph export  "${path_fig}figure6B.pdf", replace
	
********************************************************************************
	
	
	
	
	
********************************************************************************	
* Request - $O_a$ real vs predicted comparison
* without INFO
cibar evaluation if treatment==6 & info==0, over1(donation) over2(choice_judged_other) ///
graphopts(graphregion(fcolor(white)) ysc(range(2 5)) ylabel(2 (1) 5) legend(cols(1) pos(11) ring(0) region(lcolor(black))) ytitle("Mean evaluation") title("Active observers: real share"))
 graph save "${path_fig}actual_r_l.gph", replace
 
cibar evaluation if treatment==6 & info==0, over1(Gpred_donation) over2(choice_judged_other) ///
graphopts(graphregion(fcolor(white)) ysc(range(2 5)) ylabel(2 (1) 5) legend(cols(1) pos(11) ring(0) region(lcolor(black))) ytitle("Mean evaluation") title("Active observers: Gaussian NB pred share")) 
graph save "${path_fig}predicted_r_1.gph", replace 
 
 graph combine  "${path_fig}actual_r_l.gph" "${path_fig}predicted_r_1.gph", graphregion(color(white)) ycommon title("Panel R.1 - Gaussian NB, no info treatment", size(medlarge)) graphregion(margin(zero))	 	
   graph export  "${path_fig}requestR1.pdf", replace 

* with INFO
cibar evaluation if treatment==6 & info==1, over1(donation) over2(choice_judged_other) ///
graphopts(graphregion(fcolor(white)) ysc(range(2 5)) ylabel(2 (1) 5) legend(cols(1) pos(11) ring(0) region(lcolor(black))) ytitle("Mean evaluation") title("Active observers: real share"))
 graph save "${path_fig}actual_r_2.gph", replace
 
cibar evaluation if treatment==6 & info==1, over1(Gpred_donation) over2(choice_judged_other) ///
graphopts(graphregion(fcolor(white)) ysc(range(2 5)) ylabel(2 (1) 5) legend(cols(1) pos(11) ring(0) region(lcolor(black))) ytitle("Mean evaluation") title("Active observers: Gaussian NB pred share")) 
graph save "${path_fig}predicted_r_2.gph", replace 
 
 graph combine  "${path_fig}actual_r_2.gph" "${path_fig}predicted_r_2.gph", graphregion(color(white)) ycommon title("Panel R.2 - Gaussian NB, info treatment", size(medlarge)) graphregion(margin(zero))	 	
   graph export  "${path_fig}requestR2.pdf", replace 
   

* irrespective of INFO - based on info training
cibar evaluation if treatment==6, over1(donation) over2(choice_judged_other) ///
graphopts(graphregion(fcolor(white)) ysc(range(2 5)) ylabel(2 (1) 5) legend(cols(1) pos(11) ring(0) region(lcolor(black))) ytitle("Mean evaluation") title("Active observers: real share"))
 graph save "${path_fig}actual_r_2.gph", replace
 
cibar evaluation if treatment==6, over1(Gpred_donation_allwithinfo) over2(choice_judged_other) ///
graphopts(graphregion(fcolor(white)) ysc(range(2 5)) ylabel(2 (1) 5) legend(cols(1) pos(11) ring(0) region(lcolor(black))) ytitle("Mean evaluation") title("Active observers: Gaussian NB pred share")) 
graph save "${path_fig}predicted_r_2.gph", replace 
 
 graph combine  "${path_fig}actual_r_2.gph" "${path_fig}predicted_r_2.gph", graphregion(color(white)) ycommon title("Panel R.3 - Gaussian NB, all participants / based on the info model", size(medlarge)) graphregion(margin(zero))	 	
   graph export  "${path_fig}requestR3.pdf", replace 


//  cibar donation if treatment==2 | treatment==6, over(treatment) barcol(olive_teal gs10 eltgreen )  ///
// graphopts(graphregion(fcolor(white) ) text( .37 1.6  "`=ustrunescape("\u23AB")'" "`=ustrunescape("\u23AA")'"  "`=ustrunescape("\u23AA")'"    "`=ustrunescape("\u23AC")'" "`=ustrunescape("\u23AA")'" "`=ustrunescape("\u23AA")'"   "`=ustrunescape("\u23AD")'" , /// 
// size(vhuge) orientation(vertical))  text(0.39 1.6 "**", size(big)) ysc(range(0 0.4)) ylabel(0 (0.05) 0.4) legend(cols(1) pos(4) ring(0) region(lcolor(black))) ytitle("Mean donation"))  bargap(10)
  