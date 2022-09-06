/*------------------------------------------------------------------------------
PROJECT: 
AUTHOR: JMJR
TOPIC: Master do-file
DATE:

NOTES: 
------------------------------------------------------------------------------*/

clear all 

*Setting directories 
if c(username) == "juami" {
	gl localpath "C:\Users/`c(username)'\Dropbox\My-Research\Deforestation"
	*gl overleafpath "C:\Users/`c(username)'\Dropbox\Overleaf\GD-draft-slv"
	gl do "C:\Github\Deforestation\code"
	
}
else {
	*gl path "C:\Users/`c(username)'\Dropbox\"
}

gl data "${localpath}\data"
gl tables "${localpath}\work\tables"
gl plots "${localpath}\work\plots"

cd "${data}"

*Setting a pre-scheme for plots
grstyle init
grstyle title color black
grstyle color background white
grstyle color major_grid dimgray


*-------------------------------------------------------------------------------
* Preparing data
*
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
* DIVIPOLA data
*-------------------------------------------------------------------------------
import delimited "${data}\Permisos forestales\DIVIPOLA.csv", encoding(UTF-8) clear

ren (códigodepartamento códigomunicipio nombredepartamento nombremunicipio) (codepto coddane depto mun)

drop if coddane==. 

*Fixing strings
replace mun=subinstr(mun,"Ñ","N",.)
replace mun=subinstr(mun,"Á","A",.)
replace mun=subinstr(mun,"É","E",.)
replace mun=subinstr(mun,"Í","I",.)
replace mun=subinstr(mun,"Ó","O",.)
replace mun=subinstr(mun,"Ú","U",.)
replace mun=subinstr(mun,"Ü","U",.)
replace mun=subinstr(mun,"corregimiento ","",.)

replace depto=subinstr(depto,"Ñ","N",.)
replace depto=subinstr(depto,"Á","A",.)
replace depto=subinstr(depto,"É","E",.)
replace depto=subinstr(depto,"Í","I",.)
replace depto=subinstr(depto,"Ó","O",.)
replace depto=subinstr(depto,"Ú","U",.)
replace depto=subinstr(depto,"Ü","U",.)

replace depto=strlower(depto)
replace mun=strlower(mun)
replace mun="leguizamo" if mun=="puerto leguizamo" & depto=="putumayo"

keep if depto=="amazonas" | depto=="caqueta" | depto=="putumayo"
	
tempfile DIVIPOLA
save `DIVIPOLA', replace 

*-------------------------------------------------------------------------------
* Environmental crimes data
*-------------------------------------------------------------------------------
import delimited "${data}\Fiscalia\Conteo_de_Procesos.csv", encoding(UTF-8) clear

*Preparing count of crimes 
destring total_procesos, replace ig(",")

gen crime_environment=total_procesos if grupo_delito=="DELITOS AMBIENTALES"
gen crime_forest=total_procesos if delito=="ILICITO APROVECHAMIENTO DE LOS RECURSOS NATURALES RENOVABLES ART. 328 C.P."
gen crime_forest_cond=total_procesos if delito=="ILICITO APROVECHAMIENTO DE LOS RECURSOS NATURALES RENOVABLES ART. 328 C.P." & condena=="SI"

collapse (sum) total_procesos crime_environment crime_forest crime_forest_cond, by(departamento municipio anio_hecho)

*Creating shares 
gen sh_crime_env=crime_environment/total_procesos
gen sh_crime_forest=crime_forest/crime_environment
gen sh_crime_forest_v2=crime_forest/total_procesos
gen sh_crime_forest_cond=crime_forest_cond/crime_environment
gen sh_crime_forest_cond_v2=crime_forest_cond/crime_forest

ren (departamento municipio anio_hecho) (depto mun year)

*Fixing strings
replace mun=subinstr(mun,"Ñ","N",.)
replace mun=subinstr(mun,"Á","A",.)
replace mun=subinstr(mun,"É","E",.)
replace mun=subinstr(mun,"Í","I",.)
replace mun=subinstr(mun,"Ó","O",.)
replace mun=subinstr(mun,"Ú","U",.)
replace mun=subinstr(mun,"Ü","U",.)
replace mun=subinstr(mun,"corregimiento ","",.)

replace depto=subinstr(depto,"Ñ","N",.)
replace depto=subinstr(depto,"Á","A",.)
replace depto=subinstr(depto,"É","E",.)
replace depto=subinstr(depto,"Í","I",.)
replace depto=subinstr(depto,"Ó","O",.)
replace depto=subinstr(depto,"Ú","U",.)
replace depto=subinstr(depto,"Ü","U",.)

replace depto=subinstr(depto,"ñ","n",.)
replace depto=subinstr(depto,"á","a",.)
replace depto=subinstr(depto,"é","e",.)
replace depto=subinstr(depto,"í","i",.)
replace depto=subinstr(depto,"ó","o",.)
replace depto=subinstr(depto,"ú","u",.)
replace depto=subinstr(depto,"ü","u",.)

replace depto=strlower(depto)
replace mun=strlower(mun)

keep if depto=="amazonas" | depto=="caqueta" | depto=="putumayo"
keep if year<2021

merge m:1 depto mun using `DIVIPOLA', keep(1 3) nogen 

*Calculating percentage changes 
tsset coddane year
gen pc_crime_env=D.crime_environment/L.crime_environment
gen pc_crime_forest=D.crime_forest/L.crime_forest
gen pc_crime_forest_cond=D.crime_forest_cond/L.crime_forest_cond

tempfile ENVCRIME
save `ENVCRIME', replace

*-------------------------------------------------------------------------------
* Livestock census data
*-------------------------------------------------------------------------------
import excel "${data}\Productos agropecuarios\ICA\Censo Bovino por Municipio 2008 - 2019.xlsx", sheet("import") firstrow clear

destring coddane bovinos2014 bovinos2015, replace force

reshape long bovinos, i(coddane) j(year)

*Calculating percentage changes 
tsset coddane year
gen pc_bovinos=D.bovinos/L.bovinos

tempfile LIVESTOCK
save `LIVESTOCK', replace

*-------------------------------------------------------------------------------
* Forestal permits data
*-------------------------------------------------------------------------------
forval y=2010/2020{
	
	import excel "${data}\Permisos forestales\CORPOAMAZONIA.xlsx", sheet("`y'") firstrow clear

	rename _all, low
	drop if mun==""

	keep cedula depto mun año area volotogado 
	cap nois destring area, replace force

	gen n_resol=1
	collapse (sum) volotogado n_resol (mean) area, by(depto mun cedula)
	collapse (sum) volotogado n_resol area, by(depto mun)

	keep if depto=="Amazonas" | depto=="Caquetá" | depto=="Putumayo"

	gen year=`y'
	
	*Fixing strings
	replace mun=subinstr(mun,"Ñ","N",.)
	replace mun=subinstr(mun,"Á","A",.)
	replace mun=subinstr(mun,"É","E",.)
	replace mun=subinstr(mun,"Í","I",.)
	replace mun=subinstr(mun,"Ó","O",.)
	replace mun=subinstr(mun,"Ú","U",.)
	replace mun=subinstr(mun,"Ü","U",.)

	replace depto=subinstr(depto,"Ñ","N",.)
	replace depto=subinstr(depto,"Á","A",.)
	replace depto=subinstr(depto,"É","E",.)
	replace depto=subinstr(depto,"Í","I",.)
	replace depto=subinstr(depto,"Ó","O",.)
	replace depto=subinstr(depto,"Ú","U",.)
	replace depto=subinstr(depto,"Ü","U",.)
	
	replace depto=subinstr(depto,"ñ","n",.)
	replace depto=subinstr(depto,"á","a",.)
	replace depto=subinstr(depto,"é","e",.)
	replace depto=subinstr(depto,"í","i",.)
	replace depto=subinstr(depto,"ó","o",.)
	replace depto=subinstr(depto,"ú","u",.)
	replace depto=subinstr(depto,"ü","u",.)
	
	replace depto=strlower(depto)
	replace mun=strlower(mun)
	replace mun=subinstr(mun,"corregimiento ","",.)
		
	tempfile PERM`y'
	save `PERM`y'', replace 
	
}

use `PERM2010', clear
append using `PERM2011' `PERM2012' `PERM2013' `PERM2014' `PERM2015' `PERM2016' `PERM2017' `PERM2018' `PERM2019' `PERM2020' 

merge m:1 depto mun using `DIVIPOLA', keep(1 3) nogen

ren (volotogado n_resol area) (perm_volume perm_n_resol perm_area)

*Calculating percentage changes 
tsset coddane year
gen pc_perm_resol=D.perm_n_resol/L.perm_n_resol
gen pc_perm_vol=D.perm_volume/L.perm_volume
gen pc_perm_area=D.perm_area/L.perm_area

tempfile PERM
save `PERM', replace 

*-------------------------------------------------------------------------------
* Fires and hotspots data
*-------------------------------------------------------------------------------
use "${data}/Fires\hotspots_fires.dta", clear

ren _all, low
ren codmpio coddane

tempfile FIRES
save `FIRES', replace 

*-------------------------------------------------------------------------------
* Juntas CAR data
*-------------------------------------------------------------------------------
import excel "${data}\Juntas CAR\juntas_directivas.xlsx", sheet("Sheet1") firstrow clear

rename _all, low

preserve 

	keep if type_election==1
	keep codigo_partido year car type_election coddane
	keep if year>1999 & year<2021
	ren (codigo_partido coddane type_election) (codigo_partido_cargob codepto type_election_cargob)

	tempfile CARGOB
	save `CARGOB', replace

restore 

keep if type_election==2
keep codigo_partido year car type_election coddane
keep if year>1999 & year<2021
ren codigo_partido codigo_partido_caralc

tempfile CARALC
save `CARALC', replace

*-------------------------------------------------------------------------------
* Alcaldes data
*-------------------------------------------------------------------------------
foreach y in 2000 2003 2007 2011 2015 2019 {
    
	use "${data}/Elections\raw\Alcaldias/`y'_alcaldia.dta", clear
	keep if curules==1
	keep ano coddpto departamento codmpio municipio codigo_partido votos curules

	ren (ano coddpto codmpio) (year codepto coddane)

	*Fixing year var
	replace year=year+1
	
	tempfile `y'ALC
	save ``y'ALC', replace
	
}

use `2000ALC', clear 
append using `2003ALC' `2007ALC' `2011ALC' `2015ALC' `2019ALC'

tempfile ALC
save `ALC'

*-------------------------------------------------------------------------------
* Deforestation data
*-------------------------------------------------------------------------------
*Coverting shape to dta 
*shp2dta using "${data}/Gis\workinprogress\muniShp_defoinfo_sp", data("${data}/Gis\workinprogress\muniShp_defoinfo_sp.dta") coord("${data}/Gis\workinprogress\muniShp_defoinfo_sp_coord.dta") genid(ID) genc(coord) replace 

use "${data}/Gis\workinprogress\muniShp_defoinfo_sp.dta", clear

*Renaming vars
rename _all, low
ren (nmg id_espa floss01 floss02 floss03 floss04 floss05 floss06 floss07 floss08 floss09 fcv00_1 fc00_50 fcovr01) (muni_name coddane floss1 floss2 floss3 floss4 floss5 floss6 floss7 floss8 floss9 fprim00_p1 fprim00_p50 fprim_01)

keep muni_name coddane area-fprim_01 

*Reshaping the data 
destring coddane, replace
duplicates drop coddane, force

reshape long floss, i(coddane) j(year)
replace year=2000+year
keep if year<2021

*Calculating different normalizations of the forest loss
gen floss_area=floss/area    
gen floss_prim00p1=floss/fprim00_p1
gen floss_prim00p50=floss/fprim00_p50
gen floss_prim01=floss/fprim_01

*Fixing departamental code 
tostring(coddane), gen(codepto)
replace codepto="0"+codepto if length(codepto)<5
replace codepto=substr(codepto,1,2)
destring codepto, replace

*Merging info about mayor elections
merge 1:1 coddane year using `ALC', keepus(codigo_partido votos) keep(1 3) nogen 
sort coddane year, stable
bys coddane: carryforward codigo_partido votos, replace 
 
*Merging info about directors of the board
merge 1:1 coddane year using `CARALC', keep(1 3) nogen 
merge m:1 codepto year using `CARGOB', keep(1 3) nogen 
merge 1:1 coddane year using `PERM', keepus(perm_volume pc_perm_resol perm_n_resol perm_area pc_perm_area pc_perm_vol) keep(1 3) nogen 
merge 1:1 coddane year using `LIVESTOCK', keepus(pc_bovinos bovinos) keep(1 3) nogen 
merge 1:1 coddane year using `ENVCRIME', keepus(sh_crime_env sh_crime_forest sh_crime_forest_cond sh_crime_forest_cond_v2 sh_crime_forest_v2 pc_crime_env pc_crime_forest pc_crime_forest_cond crime_environment crime_forest crime_forest_cond) keep(1 3) nogen 

merge 1:1 coddane year using `FIRES', keep(1 3) nogen 



*-------------------------------------------------------------------------------
* Preparing vars of interest
*-------------------------------------------------------------------------------
*FORNOW JUST TRYING WITH CORPOAMAZONIA
keep if codepto==18 | codepto==86 | codepto==91
sort coddane year, stable

*Creating variable of mayor in the CAR's board 
gen mayorinbrd=(codigo_partido_caralc!=.)

*Creating variable of mayor allied with the gobernor in CAR's board
gen mayorallied=(codigo_partido==codigo_partido_cargob) if codigo_partido_cargob!=.

*Creating logs of dependent vars
foreach var in perm_area perm_n_resol perm_volume bovinos crime_environment crime_forest crime_forest_cond{
	
	gen ln_`var'=ln(`var')
	
}




END

*SOME STATISTICS 
foreach var in floss floss_area floss_prim00p1 floss_prim00p50 floss_prim01 pc_perm_vol perm_volume pc_perm_resol perm_n_resol pc_perm_area perm_area pc_bovinos bovinos sh_crime_env sh_crime_forest sh_crime_forest_v2 pc_crime_env pc_crime_forest crime_environment crime_forest sh_crime_forest_cond sh_crime_forest_cond_v2 pc_crime_forest_cond crime_forest_cond{
	
	reghdfe `var' mayorinbrd, a(year coddane) vce(cluster codepto)
	
}

foreach var in ln_perm_area ln_perm_n_resol ln_perm_volume ln_bovinos ln_crime_environment ln_crime_forest ln_crime_forest_cond{
	
	reghdfe `var' mayorinbrd, a(year coddane) vce(cluster codepto)
	
}

foreach var in nfires nfiresbosque nfiresagro pct_areafireagro pct_areafirebosque pct_areafire{
	
	reghdfe `var' mayorinbrd, a(year coddane) vce(cluster codepto)
	
}



foreach var in floss floss_area floss_prim00p1 floss_prim00p50 floss_prim01 perm_volume pc_perm_resol perm_
n_resol perm_area pc_bovinos bovinos sh_crime_env sh_crime_forest sh_crime_forest_v2 pc_crime_env pc_crime_forest crime_environment crime_forest{
	
	reghdfe `var' mayorallied, a(year coddane)  vce(cluster codepto)
	
}




foreach var in floss floss_area floss_prim00p1 floss_prim00p50 floss_prim01 perm_volume perm_n_resol perm_area bovinos crime_environment crime_forest{
	
	dis "Dependent variable: `var'"	
	did_multiplegt `var' coddane year mayorinbrd, breps(100) cluster(codepto)
	
}












*END

