/*	Crée une liste des entreprises afin de connaître :
		
		- les changements de nom de groupe
		- les fusions
		- les structures de contrôle
		
			On travaille à la main car il n'y a pas beaucoup d'entreprises.
			On doit aller chercher sur Internet.

		H nous éclaire un peu, mais insuffisant */
save			"sipri_panel_original.dta", replace
order			A H 
generate		temp=ustrcompare(A,H,"fr")
order			temp, after(H)
save			"filetemp.dta", replace

keep if			temp!=0
sort			A C H

/*	Liste des entreprises dont le nom avant != nom après :

		Nom avant		->	Nom après		période
		--------------		-------------	---------

		EADS 			->	Airbus 			2002-2013
		Airbus Group 	-> 	Airbus 			2014-2017
		
		New Izar		-> 	Izar			2004
		
		Finmeccanica 	-> 	Leonardo		2002-2015
		
		Direction des
		Constructions
		Navales			->	Naval Group		2002
		DCN				->	Naval Group		2003-2006
		DCNS			->	Naval Group		2007-2016
		
		GIAT Industris	->	Nexter			2002-2005
		
		SNECMA Groupe	->	Snecma Groupe	2002-2003
	
	Vérifier si des Nom avant sont eux-mêmes issus de noms encore plus avant.
	
		Il n'y a aucun cas. */
use					"filetemp.dta", clear
keep				A
duplicates			drop
sort				A
generate			temp=regexm(A,"EADS")
replace				temp=regexm(A,"Airbus Group")
replace				temp=regexm(A,"New Izar")
replace				temp=regexm(A,"Finmeccanica")
replace				temp=regexm(A,"Direction des Constructions Navales")
replace				temp=regexm(A,"DCN")
replace				temp=regexm(A,"DCNS")
replace				temp=regexm(A,"GIAT Industris")
replace				temp=regexm(A,"SNECMA Groupe")
table				temp

/*	Prendre les Nom après et vérifier les structures de contrôle sur le web */
drop				temp
erase				"filetemp.dta"				
rename				A group_name
export delimited 	"file_group.csv", delimiter(",") replace

use					"sipri_panel_original.dta", replace
rename				A group_name
rename				H group_name_previous