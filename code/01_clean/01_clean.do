
/* =================================*/
/* 		Clean data 					*/
/* 		version created 15/09/23	*/
/* =================================*/

** define userc

clear all

*######### SET GLOBAL USER ##########*

*global user "C:\Users\74749\Dropbox"
*global user "/Users/frohlyconstance/Dropbox" //Constance
global user "/Users/emir/Dropbox" //Emir
*global user "/Users/roberto.galbiati/Dropbox" //roberto.galbiati

cd "$user/Norms and reminders/ExpeData/CLEAN/"


/* Paths with backslash 
global path "$user\Norms and reminders\ExpeData\CLEAN\"
global path_fig "$user\Norms and reminders\ExpeData\CLEAN\results\figures\"
global path_tab "$user\Norms and reminders\ExpeData\CLEAN\results\tables\"
global path_raw_data "$user\Norms and reminders\ExpeData\CLEAN\data\raw\" 
global path_analysis_data "$user\Norms and reminders\ExpeData\CLEAN\data\analysis\" 
*/


* paths with forward slash 
global path "$user/Norms and reminders/ExpeData/CLEAN/"
global path_fig "$user/Norms and reminders/ExpeData/CLEAN/results/figures/"
global path_tab "$user/Norms and reminders/ExpeData/CLEAN/results/tables/"
global path_raw_data "$user/Norms and reminders/ExpeData/CLEAN/data/raw/" 
global path_analysis_data "$user/Norms and reminders/ExpeData/CLEAN/data/analysis/" 

import excel using "${path_raw_data}raw_data.xlsx", clear  firstrow case(lower)

* Label the variables with the first row of the data
qui ds
local varlist `r(varlist)'
foreach var of loc varlist {
	local test= `var'[1]
	label var `var' "`test'"
}
drop if _n==1


* For the test : keep if the data was generated on 4/13
*keep if  strpos(recordeddate, "4/13/2023 ")>0 | strpos(recordeddate, "4/14/2023 ")>0| strpos(recordeddate, "4/15/2023 ")>0| strpos(recordeddate, "4/16/2023 ")>0| strpos(recordeddate, "4/17/2023 ")>0| strpos(recordeddate, "4/18/2023 ")>0| strpos(recordeddate, "4/19/2023 ")>0| strpos(recordeddate, "4/20/2023 ")>0| strpos(recordeddate, "4/21/2023 ")>0| strpos(recordeddate, "4/22/2023 ")>0| strpos(recordeddate, "4/23/2023 ")>0| strpos(recordeddate, "4/24/2023 ")>0

gen recday =  dofc(clock(recordeddate, "MDYhm"))
format recday %td
order recday 
keep if recday >= td(13apr2023) //keep after start of first wave
drop if recday >= td(01jul2023) & recday < td(15sep2023) //drop in between wave1 and wave2
drop recordeddate

* Labeling survey waves
gen wave = 1 if recday < td(15sep2023)
replace wave = 2 if recday >= td(15sep2023)


* Keep only people who finished the survey 
destring finished, replace // This is equivalent to progress=="100" 
drop progress

destring locationlatitude, gen(latitude)
destring locationlongitude, gen(longitude)
drop location*

* Keep only Cint sourced surveys
*drop if cintid==""

* Keep only those who accepted to participate in the study
gen accept_to_participate=(q12=="J'accepte de participer à cette étude") if q12!=""
drop q12 

* Variables that we won't need:
drop *_firstclick
drop *_pagesubmit

* Variables that we might need:
drop *_clickcount
drop *_lastclick

* Whether the participant chose to see the information
rename inf info
destring info, replace

* Whether the participant observed a decision to donate or keep the money
gen choice_judged_other = 1 if random=="0" // if random = 0, the observer judges a decision to give 100€
replace choice_judged_other = 0 if random=="1" // if random = 1, the observer judges a decision to keep 25€
drop random 

* ID_yapper
*rename q51 ID_yapper
*destring q51, gen(ID_yapper) force //How many non-numeric observations do we loose by forcing it? 

* code_validation: used to donate money on behalf of the participant
destring code_validation, replace

* tirage = randomly selected to receive the money
gen winning_draw = (tirage=="1")
drop tirage

* Delete for GDPR concerns:
drop recipient*

* Variables that are not interesting for the test survey:
drop status distributionchannel userlanguage ipaddress externalreference // q42 = attention check, q62 = attention_check, q83 = accept_to_share_data_donation

* Check that the attention checks are satisfied (q42 & q62)
gen attention_check=q42
replace attention_check=q62 if q42==""
*encode attention_check, gen(attention_check2) // because of the pilot text answer
destring attention_check, replace  // How many obs do we lose with/without  force? None on 13/04/23
drop q42 q62


*gen accept_to_share_data_don = (q83=="Je confirme") if q83!=""
*drop q83

gen asso_shown=(strpos(q47, "Oui")>0) if q47!=""
replace asso_shown = 1 if strpos(q47, "Oui")>0
replace asso_shown = 0 if strpos(q47, "Non")>0
gen donation=(strpos(q425, "Renoncer")>0) if q425!="" // equivalent to destring decision_don, replace
gen expected_evaluation=q429_1 // was q91_1 before 13/04, now q429_1
replace expected_evaluation=q621_1 if expected_evaluation==""  // was q96_1 before 13/04, now q621_1
destring expected_evaluation, replace
destring q430_1, gen(expected_proportion_don)
replace expected_proportion_don = real(q622_1) if q430_1==""
gen asso_shown_eval=(strpos(q610, "Oui")>0) if q610!=""
replace asso_shown_eval = 1 if strpos(q611, "Oui")>0
replace asso_shown_eval = 0 if strpos(q611, "Non")>0
destring q619_1, gen(evaluation) // evaluation_other_choice // was q97_1 before 13/04, now q619_1

gen asso_shown_combined = asso_shown // create combined shown info variable
replace asso_shown_combined = asso_shown_eval if missing(asso_shown_combined) // fill in for passive observers

*gen asso_shown = rbinomial(1,0.5) // q47
*gen donation = rbinomial(1,0.5) // q425
*gen expected_evaluation = runiformint(0,5) // q429_1 or q91_1
*gen expected_proportion_active = runiform() //q430_1
*gen asso_shown_2 = rbinomial(1,0.5) // q610
*gen asso_shown_3 = rbinomial(1,0.5) // q611
*gen evaluation = runiformint(0,5) //q619_1 or q97_1
*gen expected_evaluation_other = runiformint(0,5) // q621_1 or q96_1
*gen expected_proportion_passive = runiform() //q622_1

*replace donation=. if game=="3"
*cap 

* ! For the actual data: check that there are no duplicates in the ipaddresses

*gen attention_check1=(q42=="5") if q52!=""
*gen attention_check2=(q62=="5") if q62!=""
*gen asso_shown=(q47=="1") if q47!="" // Dummy variable equal to 1 if the participant chose to see the ARUP. Related to seen_ARUP.
*gen donation=(q425=="0") if q425!=""
*destring q526_1, gen(expected_evaluation)
destring q430_1, gen(expected_proportion_active)
*destring q610, gen(evaluation)
* gen asso_shown_other=(q610=="1") if q610!="" // q611?
destring q621_1, gen(expected_evaluation_other)
*destring q621_1, gen(expected_proportion_passive) //cf. expected_proportion_passive (old name)

drop q47 q425 q429_1 q430_1 q610 q611 q619_1 q621_1 q622_1 /*decision_don*/

* Destring and drop variables
sort responseid
encode responseid,  gen(ID)
drop responseid

destring q510, gen(age)
drop q510

/*
gen educ = 1 if q512=="Sans diplôme"
replace educ = 2 if q512=="Certificat d'études primaires"
replace educ = 3 if q512=="Ancien brevet BEPC"
replace educ = 4 if q512=="Brevet d'enseignement professionnel (BEP)"
replace educ = 5 if q512=="Certificat d'aptitude professionnelle (CAP)"
replace educ = 6 if q512=="BAC d'enseignement technique et professionnel"
replace educ = 7 if q512=="BAC d'enseignement général"
replace educ = 8 if q512=="BAC +2 (DUT, BTS, D\EUG)"
replace educ = 9 if q512=="Diplôme de l'enseignement supérieur (2ème ou 3ème cycles, grande école)"
*/
* This scale is only valid for the test ! 
encode q512, gen(temp)
gen educ=1 if temp==9
replace educ=2 if temp==7
replace educ=3 if temp==1
replace educ=4 if temp==5
replace educ=5 if temp==6
replace educ=6 if temp==4
replace educ=7 if temp==3
replace educ=8 if temp==2
replace educ=9 if temp==8
drop q512 temp

gen female=(q514=="Femme") if q514=="Femme"|q514=="Homme"
drop q514

gen children=(q516=="Oui") if q516!=""
drop q516

rename q620 comment 

destring q74_14, gen(probability_medecins)
drop q74_14

destring q74_15, gen(probability_ceramique)
drop q74_15

destring q75_1, gen(ARUP_benevolent)
drop q75_1

destring q76_2, gen(ARUP_percentage_funding)
drop q76_2

gen income=1 if q77=="Moins de 1000 euros par mois"
replace income=2 if q77=="De 1001 à 1500 euros par mois"
replace income=3 if q77=="De 1501 à 1750 euros par mois"
replace income=4 if q77=="De 1751 à 2000 euros par mois"
replace income=5 if q77=="De 2001 à 2500 euros par mois"
replace income=6 if q77=="De 2501 à 3000 euros par mois"
replace income=7 if q77=="De 3001 à 4000 euros par mois"
replace income=8 if q77=="De 4001 à 5000 euros par mois"
replace income=9 if q77=="De 5001 à 7000 euros par mois"
replace income=10 if q77=="Plus de 7001 euros par mois"
replace income=11 if q77=="Ne souhaite pas répondre"
drop q77

destring q78_1, gen(prev_donation_charity)
drop q78_1

destring q78_2, gen(prev_donation_foreigner)
drop q78_2 

destring q78_3, gen(prev_volunteering)
drop q78_3 

destring q78_4, gen(prev_blooddonation)
drop q78_4 

gen double starttime = clock(startdate, "DMYhms")
format starttime %tc

gen double endtime = clock(enddate, "DMYhms")
format endtime %tc
drop startdate enddate

gen time = round((endtime-starttime)/60000) // How long does the experiment last


destring game, replace

* To reproduce the variable treatment of the first experiment (from 1 to 6), run :
gen treatment=2 if game==1
replace treatment=3 if game==2
replace treatment=4 if game==3
replace treatment=6 if game==4
cap */

* Generate treatment dummies
gen dummy_dp = (game==1)
gen dummy_da = (game==2)
gen dummy_op = (game==3)
gen dummy_oa = (game==4)

* To use active vs passive dictator game comparisons
gen active=1 if game==2 | game==4
replace active=0 if game==1 | game==3
cap */

* Get a variable with the duration of the experiment 
* ! Issue with the values of the variable durationinseconds
*destring durationinseconds, gen(duration_expe)
*label var duration_expe "Duration of the experiment in seconds" 
* Keep in mind that the individuals could quit and come back to the experiment if they wanted to 
drop  durationinseconds 

* Self-esteem variables need to between 0 and 3 and be higher for better self-valuation. We need to reverse the scale for variables 3, 5, 8, 9 and 10.

* "Je pense que je suis une personne de valeur, au moins égale à n'importe qui d'autre."
gen se_value = 0 if q79_1=="Tout à fait en désaccord"
replace se_value = 1 if q79_1=="Plutôt en désaccord"
replace se_value = 2 if q79_1=="Plutôt en accord"
replace se_value = 3 if q79_1=="Tout à fait en accord"

* "Je pense que je possède un certain nombre de belles qualités"
gen se_qualities = 0 if q79_2=="Tout à fait en désaccord"
replace se_qualities = 1 if q79_2=="Plutôt en désaccord"
replace se_qualities = 2 if q79_2=="Plutôt en accord"
replace se_qualities = 3 if q79_2=="Tout à fait en accord"

* "Tout bien considéré, je suis porté-e à me considérer comme un-e raté-e."
gen se_failure = 3 if q79_3=="Tout à fait en désaccord"
replace se_failure = 2 if q79_3=="Plutôt en désaccord"
replace se_failure = 1 if q79_3=="Plutôt en accord"
replace se_failure = 0 if q79_3=="Tout à fait en accord"

* "Je suis capable de faire les choses aussi bien que la majorité des gens."
gen se_capable = 0 if q79_4=="Tout à fait en désaccord"
replace se_capable = 1 if q79_4=="Plutôt en désaccord"
replace se_capable = 2 if q79_4=="Plutôt en accord"
replace se_capable = 3 if q79_4=="Tout à fait en accord"

* "Je sens peu de raisons d'être fier-e de moi."
gen se_pride = 3 if q79_5=="Tout à fait en désaccord"
replace se_pride = 2 if q79_5=="Plutôt en désaccord"
replace se_pride = 1 if q79_5=="Plutôt en accord"
replace se_pride = 0 if q79_5=="Tout à fait en accord"

* "J'ai une attitude positive vis-à-vis moi-même."
gen se_positivity = 0 if q79_6=="Tout à fait en désaccord"
replace se_positivity = 1 if q79_6=="Plutôt en désaccord"
replace se_positivity = 2 if q79_6=="Plutôt en accord"
replace se_positivity = 3 if q79_6=="Tout à fait en accord"

* "Dans l'ensemble, je suis satisfait-e de moi."
gen se_satisfied = 0 if q79_7=="Tout à fait en désaccord"
replace se_satisfied = 1 if q79_7=="Plutôt en désaccord"
replace se_satisfied = 2 if q79_7=="Plutôt en accord"
replace se_satisfied = 3 if q79_7=="Tout à fait en accord"

* "J'aimerais avoir plus de respect pour moi-même."
gen se_self_respect = 3 if q79_8=="Tout à fait en désaccord"
replace se_self_respect = 2 if q79_8=="Plutôt en désaccord"
replace se_self_respect = 1 if q79_8=="Plutôt en accord"
replace se_self_respect = 0 if q79_8=="Tout à fait en accord"

* "Parfois je me sens vraiment inutile."
gen se_uselessness = 3 if q79_9=="Tout à fait en désaccord"
replace se_uselessness = 2 if q79_9=="Plutôt en désaccord"
replace se_uselessness = 1 if q79_9=="Plutôt en accord"
replace se_uselessness = 0 if q79_9=="Tout à fait en accord"

* "Il m'arrive de penser que je suis un-e bon-ne à rien."
gen se_good_for_nothing = 3 if q79_10=="Tout à fait en désaccord"
replace se_good_for_nothing = 2 if q79_10=="Plutôt en désaccord"
replace se_good_for_nothing = 1 if q79_10=="Plutôt en accord"
replace se_good_for_nothing = 0 if q79_10=="Tout à fait en accord"
drop q79*

* Destring the variables that store the settings 
destring duration, gen(parameter_duration)
destring endowment, gen(parameter_endowment)
destring showupfee, gen(parameter_showupfee)
destring don, gen(parameter_donationamount)
destring arup1, gen(parameter_arup1)
destring arup2, gen(parameter_arup2)
rename ass_description parameter_arup_desc
drop duration endowment showupfee don arup1 arup2

* The following variables no longer exist in the version from 24/03/2023
*destring q21, gen(tester_game)
*destring q22, gen(tester_info)
*destring q23, gen(tester_win)


order userid password cintid ID game accept_to_participate /*accept_to_share_data_don*/ age educ female children starttime endtime donation expected_evaluation asso_shown info asso_shown_eval evaluation comment   probability_medecins probability_ceramique ARUP_benevolent ARUP_percentage_funding prev* se_* latitude longitude
sort treatment


* What's status?
* What's the difference between 526_1 and 528_1? I think they're dupplicates
* Why do we have both q610 and q611? 
* Test for differences across distribution channel, click count, time spent between first and last click, and maybe across user language. 

* I haven't found the variables that replace the following: (requires the final dataset)
*rename blocC_others_choice choice_judged_other
*rename got100euros won_prize
*rename rosenberg_score rosenberg_score


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

label define info 1 "Option to see the ARUP" 0 "No option to see the ARUP"
label values info info

label var time "Time spent on the experiment"

* Compute self-esteem scores

gen self_esteem_score = se_value + se_qualities + se_failure + se_capable + se_pride + se_positivity + se_satisfied + se_self_respect + se_uselessness + se_good_for_nothing

* Create notes on the variables

notes: ID "Integer. Unique ID number attributed to each participant"
notes: time_start "String. Time at which the participant started the survey"
notes: payoff "Continuous. Final payoff of the participant."
notes: treatment "Categorical. Treatment, randomly drawn (from 1 to 6)"
notes: active "Binary. 1 if the treatment is an active game, 0 if not"
notes: choice_judged_other "Binary. Choice of another player, that the player has to judge (C1.2)."
notes: won_prize "Binary. 1 if the player was chosen, 0 if not (E1)."
notes: donation "Binary, 1 if the player donated the money, 0 if kept it (B1.3)."
notes: exc_ARUP "Integer. Number of associations the player chose to display."
notes: asso_shown "String. List of associations that the player saw prior to making their choice (B1.4)."
notes: number_asso_shown_other "Integer. Number of associations another player displayed before making their choice."
notes: asso_shown_other "String. List of associations that another player saw prior to making their choice (C1.2)."
notes: age "Integer. Age of the player (A2)."
notes: educ "Categorical. Level of education of the respondent (A3)."
notes: female "Binary. 0 if the player is a man, 1 if the player is a woman (A4)."
notes: children "Binary. Equal to 1 if the participant has children, and equal to 0 if the participant does not have children. Displayed on screen A8."
notes: expected_evaluation "Continuous (1-5). Belief of the player about other player's judgement of his action (B2)."
notes: expected_proportion_active "Continuous (0-100). Player's belief about the percentage of other players that made the same choice as them (B3)."
notes: evaluation "Continuous (1-5). Judgement of the player on another player's action (C1.2)."
notes: comment "String. Comment left by the player that judged an action. Displayed after the experiment."
notes: expected_evaluation_other "Continuous. Player's belief about the evaluation that other players made of the choice they judged (C2)."
notes: expected_proportion_passive "Continuous (0-100). Players belief about the share of other players that made the same choice (B3)."
notes: ARUP_benevolent "Level (1-5). How benevolent does the player think ARUP are? (D1.1)."
notes: ARUP_percentage_funding "Continuous. What percentage of an ARUP's funding does the player think goes towards their actions (D1.2)."
notes: probability_ceramique "Continuous (0-100). Player's belief about the probability that the ceramics association will receive the donation (D2)."
notes: probability_medecins "Continuous (0-100). Player's belief about the probability that Doctors Without Borders will receive the donation (D2)."
notes: income "Level. Range of the monthly salary of the participant (D3)."
notes: prev_donation_charity "Level (1-5). How often did the participant give to an ARUP in the past (D5)."
notes: prev_donation_foreigner "Level (1-5). How often did the participant give to an individual in need in the past(D5)."
notes: prev_volunteering "Level (1-5). How often did the participant volunteer in the past (D5)."
notes: prev_blooddonation "Level (1-5). How often did the participant give blood in the past (D5)."
notes: se_value "Level variable. Answer to self-esteem question number 1 (D6)"
notes: se_qualities "Level variable. Answer to self-esteem question number 2 (D6)"
notes: se_capable "Level variable. Answer to self-esteem question number 3 (D6)"
notes: se_positivity "Level variable. Answer to self-esteem question number 4 (D6)"
notes: se_satisfied "Level variable. Answer to self-esteem question number 5 (D6)"
notes: se_failure "Level variable. Answer to self-esteem question number 6 (D6)"
notes: se_pride "Level variable. Answer to self-esteem question number 7 (D6)"
notes: se_self_respect "Level variable. Answer to self-esteem question number 8 (D6)"
notes: se_uselessness "Level variable. Answer to self-esteem question number 9 (D6)"
notes: se_good_for_nothing "Level variable. Answer to self-esteem question number 10 (D6)"
notes: self_esteem_score "Integer. Self-esteem score, sum of self-esteem questions."
notes: voted_presidential_elections "Binary variable. Did the participant vote in the last elections (D7)"
notes: voted_candidate "Categorical variable. For which candidate did the participant vote (D8)"


gen income_group=1
replace income_group=2 if income>3 & income<7
replace income_group=3 if income>6 & income<11

gen high_income=0
replace high_income=. if income==11
replace high_income=1 if income>5 & income<11

/* Replace Income brackets with the center value
* Income variable that takes the value of the median of each interval. This accounts for non-linear income effects
replace income=500 if income==1
replace income=1250 if income==2
replace income=1625 if income==3
replace income=1875 if income==4
replace income=2250 if income==5
replace income=2750 if income==6
replace income=3500 if income==7
replace income=4500 if income==8
replace income=6000 if income==9
replace income=10000 if income==10
replace income=. if income==11

label define incomelabel2 500 "< 1000 euros" 1250 "1001-1500 euros" 1625 "1501-1750 euros" 1875 "1751-2000 euros" 2250 "2001-2500 euros" 2750 "2501-3000 euros" 3500 "3001-4000 euros" 4500 "4001-5000 euros" 6000 "5001-7000 euros" 10000 "> 7001 euros" 
label values income incomelabel2

*/

** Label variables

label variable evaluation "Observers' evaluation"

label variable  prev_donation_charity "past donation to a charity"
label variable  prev_donation_foreigner  "past donation"
label variable  prev_volunteering  "past volunteering"
label variable prev_blooddonation "past blood donation"


label var treatment "Dictator with a passive/active observer, Passive/Active observer"
label var choice_judged_other "Donation decision that is observed and judged"
label var donation "Decision to donate or not"
label var self_esteem_score "Self esteem score"
label var ARUP_benevolent "Benevolent ARUP"
label var ARUP_percentage_funding "ARUP percentage funding"


*** Select observations in scope:

keep if finished=="True" // Do we keep only people who finished the survey?
keep if accept_to_participate==1 // We drop 4 more observations here
drop finished 


preserve
keep if attention_check==5
sort ID
save "${path_analysis_data}analysis_to_python.dta", replace
restore






***** THE REST OF THIS DO FILE WAS FOR CONDUCTING PAYMENT PROCEDURES TO PARTICIPANTS *****


// * Generate the mean evaluation by group 
//
// * Moderate : identify insulting comments here // we can't drop any observation though because we need to fill them up
// gen moderated = (comment=="Felis purus eget suspendisse! Massa scelerisque urna. Sapien ut, volutpat eros augue.")
// replace moderated = 1 if comment=="Il aurait pu déduire les 100 de donation pour ces impots " |comment=="14"|comment=="1" |comment=="Les informations données sont claires; si vous êtes tiŕé au sort donc reconnu comme gagnant, vous avez 2 possibilités:soit vous recevez 25 euros soit 100 euros sont versés, en votre nom, à une association d'utilité oublique. En renonçant à votre don, le don de 100euros est donc réalisé à l'association à votre nom." |comment=="C'est mon choix parce qu'a l'heure actuelle, l'argent est très important. Désolé"|comment=="Je serai heureuse de pouvoir donner mon avis, merci "|comment=="Toi aussi !"
// replace moderated=1 if attention_check!=5
//
// replace comment = "C'est légitime de vouloir conserver cette somme" if comment=="C'est légitime de vouloir conserver cette femme "
//
// replace comment= "Ce participant n'a pas ajouté de commentaire écrit." if comment==""
//
// sort ID
//
// gen mean_evaluation=.
// gen comment1=""
// gen comment2=""
// gen comment3=""
//
// levels ID if game!=3, local(ID_list)
// foreach id in `ID_list' {
//	
// 	*local id = 2
// di "`id'"
//
// 	sort ID
// 	set seed `id'
// 	gen random = runiform()
//
// gen id=(ID==`id')
// gsort -id // bring the observation of interest in the first row for the if conditions below to work correctly
//
// 	if game==1 & donation==1 & info==1 {
// 		replace random=. if game!=3 | choice !=1 | info!=1 | mod==1
// 		sort random
// 		su evaluation if _n<=3
// 		replace mean_evaluation=`r(mean)' if ID==`id'
//		
// 		replace comment1 = comment[1] if ID==`id'
// 		replace comment2 = comment[2] if ID==`id'
// 		replace comment3 = comment[3] if ID==`id'
// 	}
//
// 	if game==1 & donation==0 & info==1 {
// 		replace random=. if game!=3 | choice !=0 | info!=1 | mod==1
// 		sort random
// 		su evaluation if _n<=3
// 		replace mean_evaluation=`r(mean)' if ID==`id'
//		
// 		replace comment1 = comment[1] if ID==`id'
// 		replace comment2 = comment[2] if ID==`id'
// 		replace comment3 = comment[3] if ID==`id'
// 	}
//
// 	if game==1 & donation==1 & info==0 {
// 		replace random=. if game!=3 | choice !=1 | info!=0 | mod==1
// 		sort random
// 		su evaluation if _n<=3
// 		replace mean_evaluation=`r(mean)' if ID==`id'
//		
// 		replace comment1 = comment[1] if ID==`id'
// 		replace comment2 = comment[2] if ID==`id'
// 		replace comment3 = comment[3] if ID==`id'
// 	}
//
// 	if game==1 & donation==0 & info==0 {
// 		replace random=. if game!=3 | choice !=0 | info!=0 | mod==1
// 		sort random
// 		su evaluation if _n<=3
// 		replace mean_evaluation=`r(mean)' if ID==`id'
//		
// 		replace comment1 = comment[1] if ID==`id'
// 		replace comment2 = comment[2] if ID==`id'
// 		replace comment3 = comment[3] if ID==`id'
// 	}
//	
// 	if (game==2|game==4) & donation==1 & info==1 {
// 		replace random=. if game!=4 | choice !=1 | info!=1 | ID==`id' | mod==1
// 		sort random
// 		su evaluation if _n<=3
// 		replace mean_evaluation=`r(mean)' if ID==`id'
//		
// 		replace comment1 = comment[1] if ID==`id'
// 		replace comment2 = comment[2] if ID==`id'
// 		replace comment3 = comment[3] if ID==`id'
// 	}
//
// 	if (game==2|game==4) & donation==0 & info==1 {
// 		replace random=. if game!=4 | choice !=0 | info!=1 | ID==`id' | mod==1
// 		sort random
// 		su evaluation if _n<=3
// 		replace mean_evaluation=`r(mean)' if ID==`id'
//		
// 		replace comment1 = comment[1] if ID==`id'
// 		replace comment2 = comment[2] if ID==`id'
// 		replace comment3 = comment[3] if ID==`id'
// 	}
//
// 	if (game==2|game==4) & donation==1 & info==0 {
// 		replace random=. if game!=4 | choice !=1 | info!=0 | ID==`id' | mod==1
// 		sort random
// 		su evaluation if _n<=3
// 		replace mean_evaluation=`r(mean)' if ID==`id'
//		
// 		replace comment1 = comment[1] if ID==`id'
// 		replace comment2 = comment[2] if ID==`id'
// 		replace comment3 = comment[3] if ID==`id'
// 	}
//
// 	if (game==2|game==4) & donation==0 & info==0 {
// 		replace random=. if game!=4 | choice !=0 | info!=0 | ID==`id' | mod==1
// 		sort random
// 		su evaluation if _n<=3
// 		replace mean_evaluation=`r(mean)' if ID==`id'
//		
// 		replace comment1 = comment[1] if ID==`id'
// 		replace comment2 = comment[2] if ID==`id'
// 		replace comment3 = comment[3] if ID==`id'
// 	}
//	
// 	drop random 
// 	drop id
// }
//
// sort game ID
//
// /* OLD
// su evaluation if game==3 & choice==1 & info==1
// gen mean_evaluation = `r(mean)' if game==1 & donation==1 & info==1
// su evaluation if game==3 & choice==0 & info==1
// replace mean_evaluation = `r(mean)' if game==1 & donation==0 & info==1
// su evaluation if game==4 & choice==1 & info==1 // Enlever le jugement de cette personne
// replace mean_evaluation = `r(mean)' if (game==2 | game==4) & donation==1 & info==1
// su evaluation if game==4 & choice==0 & info==1
// replace mean_evaluation = `r(mean)' if (game==2 | game==4) & donation==0 & info==1
//
// su evaluation if game==3 & choice==1 & info==0
// replace mean_evaluation = `r(mean)' if game==1 & donation==1 & info==0
// su evaluation if game==3 & choice==0 & info==0
// replace mean_evaluation = `r(mean)' if game==1 & donation==0 & info==0
// su evaluation if game==4 & choice==1 & info==0
// replace mean_evaluation = `r(mean)' if (game==2 | game==4) & donation==1 & info==0
// su evaluation if game==4 & choice==0 & info==0
// replace mean_evaluation = `r(mean)' if (game==2 | game==4) & donation==0 & info==0
// */
//
// * Compute the bonuses as per the chemin de fer
// set seed 1234
// gen random1 = runiform(0,100)
// gen bonus_probabilityMSF = (probability_medecins > random1)
//
// gen random2 = runiform(0,16)
// gen distance = (expected_evaluation - mean_evaluation)^2
// gen bonus_evaluation = (random2 > distance)
//
// gen attention_check_dummy = (attention_check==5)
//
// gen bonus_fixe = parameter_showupfee * attention_check_dummy
//
// * Generate the variable with the amount that the participant will receive in the end
// gen bonus_variable =  (parameter_endowment*(1 - donation)*winning_draw*attention_check_dummy) + bonus_probabilityMSF*attention_check_dummy + bonus_evaluation*attention_check_dummy
// replace bonus_variable = bonus_probabilityMSF*attention_check_dummy if bonus_variable==. // because the passive observers have missing values in donation since they weren't offered the choice to keep or donate
//
// drop random1 random2 distance parameter_showupfee
//
// count if winning_draw==1
// local n_winningdraw = `r(N)'
// ta winning_draw
// di round(`n_winningdraw'/`r(N)',0.01)
// *assert round(`n_winningdraw'/`r(N)', 0.01) == 0.05  // should = 1/20
// *su donation accept_to_share_data_don
// *assert `r(mean)'==1
//
// *gen MSF = donation * winning_draw * 100 * (attention_check_dummy)
//
// label var attention_check_dummy "Passed the attention check"
//
//
// * Generate the data for FF
// export excel userid password cintid /*ID_yapper*/ game code_validation donation decision_don winning_draw bonus_probabilityMSF bonus_evaluation /*MSF accept_to_share_data_don*/ attention_check_dummy mean_evaluation comment1 comment2 comment3 if wave==2 ///
//  using "${path_data}soself_FF_payment" ///
// , firstrow(variables) replace 
//
// ta recday
// ta recday if attention_check==5
//
// ta winning_draw if attention_check==5
//
// ta decision_don
// ta decision_don if winning_draw==1
//
// ta game
//
// ta info
// ta asso_shown if info==1
// ta asso_shown_eval if info==1





