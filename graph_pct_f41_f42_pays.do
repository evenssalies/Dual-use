/*

 Demandes de brevets PCT : France, Allemagne, Espagne, Italie
 Technologies F41 et F42 additionnees (armes, munitions et explosifs)
 Style : graphique de gauche, diapositive 23 de presentation.pdf

 Entree  : queries/job_KsJJjEZLVvewmkA6bKusbsWvskuL.csv
           (resultat de queries/a62d_applications_by_year.sql)
 Sortie  : graph_pct_f41_f42_pays.png

*/

cls
clear all
set more off

/*	Lecture du resultat BigQuery : tech, country_code, year, applications */
import delimited using "queries\job_KsJJjEZLVvewmkA6bKusbsWvskuL.csv", clear

/*	Addition de F41 et F42 par pays et par annee.
	Une demande classee dans F41 et F42 a la fois est comptee deux fois. */
collapse (sum) applications, by(country_code year)

/*	Une ligne par annee, une colonne par pays */
reshape wide applications, i(year) j(country_code) string

/*	Annee sans demande dans le CSV : zero et non manquant */
foreach v of varlist applications* {
	replace `v' = 0 if missing(`v')
}

/*	Controle : 2000 a 2021, une ligne par annee */
assert _N == 22

/*	Graphique : memes couleurs, marqueurs et ordre de legende que le graphique de gauche */
twoway ///
	(connected applicationsFR year, lcolor("0 128 128") mcolor("0 128 128") msymbol(O) msize(small) lwidth(medthick)) ///
	(connected applicationsDE year, lcolor("40 40 40") mcolor("40 40 40") msymbol(O) msize(small) lwidth(medthick)) ///
	(connected applicationsES year, lcolor("230 160 30") mcolor("230 160 30") msymbol(O) msize(small) lwidth(medthick)) ///
	(connected applicationsIT year, lcolor("140 150 50") mcolor("140 150 50") msymbol(O) msize(small) lwidth(medthick)), ///
	xlabel(2000(5)2020, nogrid) ///
	ylabel(, angle(0) format(%12.0fc) nogrid) ///
	xtitle("") ///
	ytitle("Demandes de brevets PCT") ///
	note("Source : Google Patents Public Data (BigQuery), date de priorite, comptage fractionnaire ; F41 et F42 additionnees", size(vsmall)) ///
	legend(order(1 "France" 2 "Allemagne" 3 "Espagne" 4 "Italie") position(6) rows(1) region(lstyle(none))) ///
	graphregion(color(white)) plotregion(lstyle(none)) ///
	name(pct_f41_f42_pays, replace)

graph export "graph_pct_f41_f42_pays.png", name(pct_f41_f42_pays) replace width(1400)
