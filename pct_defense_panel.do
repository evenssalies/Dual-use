/* 

 Demandes de brevets PCT : Etats-Unis, Chine, France, Allemagne, Espagne, Italie
 Technologies relatives a la defense.

 Entrée  : queries/job_WxsOXzYzGB48GQwUGaRWk1bO6bDs.csv
           (resultat de queries/dual_use_applications_by_year.sql)
 Sortie  : pct_defense_panel.png

*/

cls
clear all
set more off

/*	Lecture du resultat BigQuery : country_code, year, applications */
import delimited using "queries\job_WxsOXzYzGB48GQwUGaRWk1bO6bDs.csv", clear

/*	Addition des demandes par pays et par annee */
collapse (sum) applications, by(country_code year)

/*	Une ligne par annee, une colonne par pays */
reshape wide applications, i(year) j(country_code) string

/*	Annee sans demande dans le CSV : zero et non manquant */
foreach v of varlist applications* {
	replace `v' = 0 if missing(`v')
}

/*	Controle : 2000 a 2021, une ligne par annee */
assert _N == 22

/*	Graphique de gauche : Etats-Unis et Chine, echelle verticale 0 a 300 */
twoway ///
	(connected applicationsUS year, lcolor("0 70 170") mcolor("0 70 170") msymbol(O) msize(small) lwidth(medthick)) ///
	(connected applicationsCN year, lcolor("204 160 0") mcolor("204 160 0") msymbol(O) msize(small) lwidth(medthick)), ///
	xlabel(2000(5)2020, tlength(0) grid glpattern(solid) glwidth(vthin) glcolor(gs12)) xscale(noline) ///
	ylabel(0(50)300, angle(0) tlength(0) format(%12.0fc) grid glpattern(solid) glwidth(vthin) glcolor(gs12)) yscale(range(0 300) noline) ///
	xline(2021, lcolor(gs12) lwidth(vthin) lpattern(solid)) ///
	xtitle("") ///
	ytitle("Demandes de brevets PCT") ///
	legend(order(1 "États-Unis" 2 "Chine") position(6) rows(1) region(lstyle(none))) ///
	graphregion(color(white)) plotregion(lstyle(none) margin(zero)) ///
	name(gauche, replace)

/*	Graphique de droite : France, Allemagne, Espagne, Italie, echelle verticale 0 a 150 */
twoway ///
	(connected applicationsFR year, lcolor("0 128 128") mcolor("0 128 128") msymbol(O) msize(small) lwidth(medthick)) ///
	(connected applicationsDE year, lcolor("40 40 40") mcolor("40 40 40") msymbol(O) msize(small) lwidth(medthick)) ///
	(connected applicationsES year, lcolor("128 0 32") mcolor("128 0 32") msymbol(O) msize(small) lwidth(medthick)) ///
	(connected applicationsIT year, lcolor("140 150 50") mcolor("140 150 50") msymbol(O) msize(small) lwidth(medthick)), ///
	xlabel(2000(5)2020, tlength(0) grid glpattern(solid) glwidth(vthin) glcolor(gs12)) xscale(noline) ///
	ylabel(0(25)150, angle(0) tlength(0) format(%12.0fc) grid glpattern(solid) glwidth(vthin) glcolor(gs12)) yscale(range(0 150) noline) ///
	xline(2021, lcolor(gs12) lwidth(vthin) lpattern(solid)) ///
	xtitle("") ///
	legend(order(1 "France" 2 "Allemagne" 3 "Espagne" 4 "Italie") position(6) rows(1) region(lstyle(none))) ///
	graphregion(color(white)) plotregion(lstyle(none) margin(zero)) ///
	name(droite, replace)

/*	Les deux graphiques cote a cote */
graph combine gauche droite, ///
	rows(1) ///
	graphregion(color(white)) ///
	note(`"Source : Google Patents Public Data (BigQuery), demandes PCT, date de priorité, pays du déposant, comptage fractionnaire."' `"Codes IPC (défense) : F41, F42, B63G, B21D51/54, B21K21/04, B21K21/06, B21K21/14, B60R7/14, B64D1/04,"' `"B64D1/06, B64D7/, E04H9/04, E04H9/08, E04H9/12, E06B5/10, G01S1/42, G01S19/18, G06G7/80, A62D101/02."', size(vsmall)) ///
	name(pct_defense_panel, replace)

graph export "pct_defense_panel.png", name(pct_defense_panel) replace width(1400)
graph export "pct_defense_panel.pdf", name(pct_defense_panel) replace