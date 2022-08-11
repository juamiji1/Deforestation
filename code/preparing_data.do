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
* Juntas CAR data
*-------------------------------------------------------------------------------
import excel "${data}\Juntas CAR\juntas_directivas.xlsx", sheet("Sheet1") firstrow clear

rename _all, low

preserve 

	keep if type_election==1
	keep codigo_partido year car type_election coddane
	keep if year>1999
	ren (codigo_partido coddane) (codigo_partido_gob codepto)

	tempfile CARGOB
	save `CARGOB', replace

restore 

keep if type_election==2
keep codigo_partido year car type_election coddane
keep if year>1999
ren codigo_partido codigo_partido_alc

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

*Calculating different normalizations of the forest loss
gen floss_area=floss/area    
gen floss_prim00p1=floss/fprim00_p1
gen floss_prim00p50=floss/fprim00_p50
gen floss_prim01=floss/fprim_01

*Merging all the other information 


















