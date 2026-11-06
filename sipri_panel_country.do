/*	COUNTRY (55 pays, c'est l'OCDE 39 + d'autres que j'identifierai après)
		B : Pays nom :			55
		EU : Union européenne :	 2 */

/*	Reécrire les noms de pays mal écrits */
sort			B
table			B

rename			B country

replace			country="Czech Republic" if country=="Czechia"





























/*	alpha2 (codes ISO2)
		Remarque : pas besoin de charger moi-même, cool. */
rename			I alpha2

/*	REGION 
		Remarque :	il y a 5 régions : China, EU, Japan, ROW, US
		tabulate COUNTRY if REGION=="[nom de la région]" et di r(r) pour voir
		combien de pays par région. 
				- Singapour est dans China et ROW. 
				- Hong Kong et Cayman Islands dans China */
rename			J REGION
replace			REGION="ROW" if COUNTRY=="Cayman Islands"
replace			REGION="ROW" if COUNTRY=="Singapore"

/*		#COUNTRY par REGION */
capture drop	TEMP
save			"filetemp.dta", replace
keep			REGION COUNTRY
duplicates drop
egen			TEMP=count(COUNTRY), by(REGION)
sort			REGION COUNTRY
/*						China :  2 pays 							+ 1 NA,
						EU : 	21 pays,
						Japan :  1 pays 							+ 1 NA,
						ROW : 	30 pays (Argentine, ..., Vietnam) 	+ 1 NA,
						US : 	 1 pays 							+ 1 NA,
			Remarques : ça fait 55 pays + 4 NA */

/*		Donner un pays aux entreprises qui n'en n'ont pas. */
use				"filetemp.dta", clear

/*			REGION = "China" 
			
			AIM												vérifié : 	CN
			AVICOPTER										vérifié : 	CN
			CHINA RESOURCES DOUBLE CRANE PHARMACEUTICAL		explicite : CN
			CSI
			DO-FLUORIDE
			EMPYREAN
			ANSU QILIANSHAN CEMENT
			GOKE
			GRAND PHARMACEUTICAL							vérifié : 	CN
			SUZHOU MAXWELL TECHNOLOGIES						explicite :	CN
			XINYI SOLAR
			
			Dans le cas de REGION = "China", le COUNTRY ne peut être que
				la Chine hors Hong Kong ou Hong Kong. Quand je regarde les 
				données, je n'ai qu'une entreprise à Hong Kong
				(XIWANG SPECIAL STEEL COMPANY). La mettre dans China (il n'y
				a pas de problème de monnaie car j'ai pris les variables qui
				sont déjà converties en euro), et ne créer qu'un pays : "China"
				pour cette entreprise et les "NA".
*/ 
*list 			RAISON if REGION=="China"&COUNTRY=="NA"
replace			COUNTRY="China" if	COUNTRY=="ChinaexceptHongKong"| ///
									REGION=="China"&COUNTRY=="NA"| ///
									COUNTRY=="Hong Kong"
*table 			alpha2 if REGION=="China"&COUNTRY=="China"
replace			alpha2="CN" if COUNTRY=="China"&alpha2!="CN"

/*			REGION = "Japan"

			SUMITOMO RIKO									vérifié :	JP
*/
*list 			RAISON if REGION=="Japan"&COUNTRY=="NA"
replace			COUNTRY="Japan" if REGION=="Japan"&COUNTRY=="NA"
*table 			alpha2 if REGION=="Japan"
replace			alpha2="JP" if COUNTRY=="Japan"

/*			REGION = "ROW" 

			ALPHAWAVE										vérifié :	GB
			KOMAX											vérifié :	CH

			Choix de substitution basé sur le fait que ces entreprises sont
			déjà observées dans ces pays dans la base.
*/
*list 			RAISON if REGION=="ROW"&COUNTRY=="NA"
*table			COUNTRY if RAISON=="ALPHAWAVE"
*table			alpha2 if RAISON=="ALPHAWAVE"
replace			COUNTRY="United Kingdom" if RAISON=="ALPHAWAVE"&COUNTRY=="NA"
replace			alpha2="GB" if RAISON=="ALPHAWAVE"&alpha2=="NA"
*table			COUNTRY if RAISON=="KOMAX"
*table			alpha2 if RAISON=="KOMAX"
replace			COUNTRY="Switzerland" if RAISON=="KOMAX"&COUNTRY=="NA"
replace			alpha2="CH" if RAISON=="KOMAX"&alpha2=="NA"

/*			REGION = "US"

			ALKAMI TECHNOLOGY
			CLEAR SECURE
			ENTRADA
			EVERCOMMERCE
			HALOZYME THERAPEUTICS
			HARMONY BIOSCIENCES
			INSPIRE
			NUVALENT
			OUSTER

			Ces entreprises sont aux United States la majorité des années
			(10 années sur 11, 15/18, etc.). Le choix de substitution est
			basé sur cela, comme la région précédente. Et quand COUNTRY est NA,
			alpha2 est aussi NA.		
 */
*list 			RAISON if REGION=="US"&COUNTRY=="NA"
*table			COUNTRY alpha2 if RAISON=="ALKAMI TECHNOLOGY"
*table			COUNTRY alpha2 if RAISON=="CLEAR SECURE"
*table			COUNTRY alpha2 if RAISON=="ENTRADA"
*table			COUNTRY alpha2 if RAISON=="EVERCOMMERCE"
*table			COUNTRY alpha2 if RAISON=="HALOZYME THERAPEUTICS"
*table			COUNTRY alpha2 if RAISON=="HARMONY BIOSCIENCES"
*table			COUNTRY alpha2 if RAISON=="INSPIRE"
*table			COUNTRY alpha2 if RAISON=="NUVALENT"
*table			COUNTRY alpha2 if RAISON=="OUSTER"
replace			COUNTRY="United States" if COUNTRY=="NA"
replace			alpha2="US" if alpha2=="NA"