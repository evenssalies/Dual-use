/*

 SIPRI
 
*/

cls
clear all
set maxvar 32000
set more off
global		HTTP="http://www.frequency.fr/"
local		DO="$HTTP"+"localhost.do"
do			"`DO'" doc

/*************************************
* Cree le fichier "sipri_panel.csv"  *
**************************************/

/*	Liste des variables :

		A : Firm
		B : Country
		C : Year
		D : Arms revenues as % of total revenues
		E : Total revenues (US$ m)
		F : Arms revenues (US$ m)
		G : Dual use
		H : Name in original SIPRI table */

/*	Panel europeen */
local 			FILEIN="DATA\Production\SIPRI_European_panel_2002-2024.xlsx"
import excel using 	///
				"`FILEIN'", sheet("EU panel") clear
drop in 		1
generate		EU=1
save			"sipri_panel_eu_original.dta", replace 

/*	Panel non-europeen*/
local 			FILEIN="DATA\Production\SIPRI_European_panel_2002-2024.xlsx"
import excel using	///
				"`FILEIN'", sheet("Other Europe (non-EU)") clear
drop in 		1	
generate		EU=0
save			"sipri_panel_non-eu_original.dta", replace 

/*	Empile les panels (meme nombre de variables) */
append using	"sipri_panel_eu_original.dta"
save			"sipri_panel_original.dta", replace 

use				"sipri_panel_original.dta", clear

cd				"C:\Users\82128\Documents\GitHub\Dual-use\"

/*	ligne : pour remettre le fichier dans l'ordre de départ si néc. */
generate		line=_n

/* 	group : nom du groupe */
do				"sipri_panel_group.do"

/*	country :	nom du pays
	alpha2 :	code iso-2
	ue27_2020 :	= 1 si country est dans l'EU 27
	ze20 :		= 1 si country est dans la zone euro  */
do				"sipri_panel_country.do"

/*	year [check what year it is] */
rename			C year
destring		year, replace

/*	y_total :	revenu total de l'entreprise (M USD) */
rename			E y_total
destring		y_total, replace

/*	y_arm :		revenu armement (M USD) */
rename			F y_arm
destring		y_arm, replace

/*	y_non_arm :	revenu hors armement (M USD) */
generate		y_non_arm=y_total-y_arm

/*	y_arm_pc : revenus armement (% du revenu total) */
drop			D
generate		y_arm_pc=y_arm/y_total

/*	y_non_arm_pc : revenus hors armement (% du revenu total) */
generate		y_non_arm_pc=1-y_arm_pc

/*	dualuse :	entreprise dans les technologies duales */
drop			G
generate		dualuse=(y_arm_pc<.5)
tostring		dualuse, replace
replace			dualuse="Yes" if dualuse=="1"
replace			dualuse="No" if dualuse=="0"
		
/*	Arrange les variables */
order			group_name* year y_total y_non_arm y_arm* dualuse ///
				country alpha2 EU ue27_2020 ze21
compress
sort			group_name year 

/***************************
* Etiquetter des variables *
****************************/

label variable	group_name "groupe"
label variable	group_name_previous "groupe avant"
label variable	year "annee"
label variable	y_total "revenu total (M USD)"
label variable	y_non_arm "revenu hors arm. (M USD)"
label variable	y_arm "revenu arm. (M USD)"
label variable	y_arm_pc "revenu arm. (%)"
label variable	y_non_arm_pc "revenu hors arm. (%)"
label variable	dualuse "groupe double-usage (1/0)"
label variable	country "pays"
label variable	alpha2 "Code iso 2 du pays"
label variable	EU "continent europeen (1/0)"
label variable	ue27_2020 "ue 27 (1/0)"
label variable	ze21 "ze 21"

save			"sipri_panel.dta", replace
		
/**************************************************
* Statistiques descriptives, tableaux, graphiques *
***************************************************/

egen			dualuse_y_mean=mean(y_arm_pc) if dualuse=="Yes", by(year)
egen			dualuse_n_mean=mean(y_arm_pc) if dualuse=="No", by(year)

keep if			group_name=="Airbus"|group_name=="BAE Systems"

keep			year dualuse_n_mean dualuse_y_mean

generate		d=(dualuse_y_mean!=.)
generate		y=dualuse_y_mean
replace			y=dualuse_n_mean if d==0

drop			dualuse*

xtset			d year

/*	y en base 1 en 2002 : y divise par sa valeur de 2002, pour d=1 et d=0 */
generate		y_base2002=.
foreach dd in 0 1 {
	summarize	y if d==`dd' & year==2002, meanonly
	replace		y_base2002=y/r(mean) if d==`dd'
}

xtline			y_base2002, overlay
