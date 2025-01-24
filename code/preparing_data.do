/*------------------------------------------------------------------------------
PROJECT: 
AUTHOR: JMJR
TOPIC: Master do-file
DATE:

NOTES: DO META!!!!! high deforestation!!!
------------------------------------------------------------------------------*/

clear all 

*Setting directories 
if c(username) == "juami" {
	gl localpath "C:\Users/`c(username)'\Dropbox\My-Research\Deforestation"
	gl overleafpath "C:\Users/`c(username)'\Dropbox\Overleaf\Politicians_Deforestation"
	gl do "C:\Github\Deforestation\code"
	
}
else {
	*gl path "C:\Users/`c(username)'\Dropbox\"
}

gl data "${localpath}\data"
gl tables "${overleafpath}\tables"
gl plots "${overleafpath}\plots"

cd "${data}"

*Setting a pre-scheme for plots
set scheme s2mono
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

*keep if depto=="amazonas" | depto=="caqueta" | depto=="putumayo"
keep if codepto=="05" | codepto=="15" | codepto=="18" | codepto=="20" | codepto=="25" | codepto=="76" | codepto=="86" | codepto=="91" | codepto=="94" | codepto=="95" | codepto=="97" 

tempfile DIVIPOLA
save `DIVIPOLA', replace 

*-------------------------------------------------------------------------------
* Environmental crimes data
*-------------------------------------------------------------------------------
import delimited "${data}\Fiscalia\Conteo_de_Procesos.csv", encoding(UTF-8) clear

*Preparing count of crimes 
destring total_procesos, replace ig(",")

gen crime_environment=total_procesos if grupo_delito=="DELITOS AMBIENTALES"
gen crime_environment_cond=total_procesos if grupo_delito=="DELITOS AMBIENTALES" & condena=="SI"

gen crime_forest=total_procesos if delito=="ILICITO APROVECHAMIENTO DE LOS RECURSOS NATURALES RENOVABLES ART. 328 C.P."
gen crime_forest_cond=total_procesos if delito=="ILICITO APROVECHAMIENTO DE LOS RECURSOS NATURALES RENOVABLES ART. 328 C.P." & condena=="SI"

collapse (sum) total_procesos crime_environment crime_forest crime_forest_cond crime_environment_cond, by(departamento municipio anio_hecho)

*Creating shares 
gen sh_crime_env=crime_environment/total_procesos
gen sh_crime_forest=crime_forest/crime_environment
gen sh_crime_forest_v2=crime_forest/total_procesos
gen sh_crime_forest_cond=crime_forest_cond/crime_environment
gen sh_crime_forest_cond_v2=crime_forest_cond/crime_forest
gen sh_crime_env_cond= crime_environment_cond/crime_environment

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

keep if depto=="amazonas" | depto=="caqueta" | depto=="putumayo" | depto=="boyaca" | depto=="cesar" | depto=="cundinamarca" | depto=="guainia" | depto=="guaviare" | depto=="valle del cauca" | depto=="vaupes" | depto=="antioquia"
keep if year<2021

merge m:1 depto mun using `DIVIPOLA', keep(3) nogen 

*end
*IMPROVE THIS MATCH !!!! <--
*keep(1 3) 
*nogen 
duplicates drop coddane year, force

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
* CAR to muni codes 
*-------------------------------------------------------------------------------
import delimited "${data}\muniCAR\municar.csv", encoding(UTF-8)  clear 

rename (iddane car nombre) (coddane car_master carname_master)
duplicates drop coddane, force

encode car_master, g(carcode_master)

*gen n=1
*collapse n, by(car_master carcode_master)
*label drop carcode_master

tempfile MCAR
save `MCAR'

import delimited "${data}\muniCAR\municar_v2.csv", encoding(UTF-8)  clear 

keep mpio_cdpmp car
ren mpio_cdpmp coddane

replace car=trim(car)

gen carcode_master=.

replace 	carcode_master 	=	1		if 	car	==	"AMVA"
replace 	carcode_master 	=	2		if 	car	==	"AREA EN LITIGIO"
replace 	carcode_master 	=	3		if 	car	==	"CAM"
replace 	carcode_master 	=	4		if 	car	==	"CAR"
replace 	carcode_master 	=	5		if 	car	==	"CARDER"
replace 	carcode_master 	=	6		if 	car	==	"CARDIQUE"
replace 	carcode_master 	=	7		if 	car	==	"CARSUCRE"
replace 	carcode_master 	=	8		if 	car	==	"CAS"
replace 	carcode_master 	=	9		if 	car	==	"CDA"
replace 	carcode_master 	=	10		if 	car	==	"CDMB"
replace 	carcode_master 	=	11		if 	car	==	"CODECHOCO"
replace 	carcode_master 	=	12		if 	car	==	"CORALINA"
replace 	carcode_master 	=	13		if 	car	==	"CORANTIOQUIA"
replace 	carcode_master 	=	14		if 	car	==	"CORMACARENA"
replace 	carcode_master 	=	15		if 	car	==	"CORNARE"
replace 	carcode_master 	=	16		if 	car	==	"CORPAMAG"
replace 	carcode_master 	=	17		if 	car	==	"CORPOAMAZONIA"
replace 	carcode_master 	=	18		if 	car	==	"CORPOBOYACA"
replace 	carcode_master 	=	19		if 	car	==	"CORPOCALDAS"
replace 	carcode_master 	=	20		if 	car	==	"CORPOCESAR"
replace 	carcode_master 	=	21		if 	car	==	"CORPOCHIVOR"
replace 	carcode_master 	=	22		if 	car	==	"CORPOGUAJIRA"
replace 	carcode_master 	=	23		if 	car	==	"CORPOGUAVIO"
replace 	carcode_master 	=	24		if 	car	==	"CORPOMOJANA"
replace 	carcode_master 	=	25		if 	car	==	"CORPONARIÑO"
replace 	carcode_master 	=	26		if 	car	==	"CORPONOR"
replace 	carcode_master 	=	27		if 	car	==	"CORPORINOQUIA"
replace 	carcode_master 	=	28		if 	car	==	"CORPOURABA"
replace 	carcode_master 	=	29		if 	car	==	"CORTOLIMA"
replace 	carcode_master 	=	30		if 	car	==	"CRA"
replace 	carcode_master 	=	31		if 	car	==	"CRC"
replace 	carcode_master 	=	32		if 	car	==	"CRQ"
replace 	carcode_master 	=	33		if 	car	==	"CSB"
replace 	carcode_master 	=	34		if 	car	==	"CVC"
replace 	carcode_master 	=	35		if 	car	==	"CVS"

labmask carcode_master, values(car)

tempfile MCAR2
save `MCAR2'

import delimited "${data}\muniCAR\municar_centroids.csv", encoding(UTF-8)  clear 

keep mgn_anm_mpios_mpio_cdpmp car
ren mgn_anm_mpios_mpio_cdpmp coddane

replace car=trim(car)

gen carcode_master=.

replace 	carcode_master 	=	1		if 	car	==	"AMVA"
replace 	carcode_master 	=	2		if 	car	==	"AREA EN LITIGIO"
replace 	carcode_master 	=	3		if 	car	==	"CAM"
replace 	carcode_master 	=	4		if 	car	==	"CAR"
replace 	carcode_master 	=	5		if 	car	==	"CARDER"
replace 	carcode_master 	=	6		if 	car	==	"CARDIQUE"
replace 	carcode_master 	=	7		if 	car	==	"CARSUCRE"
replace 	carcode_master 	=	8		if 	car	==	"CAS"
replace 	carcode_master 	=	9		if 	car	==	"CDA"
replace 	carcode_master 	=	10		if 	car	==	"CDMB"
replace 	carcode_master 	=	11		if 	car	==	"CODECHOCO"
replace 	carcode_master 	=	12		if 	car	==	"CORALINA"
replace 	carcode_master 	=	13		if 	car	==	"CORANTIOQUIA"
replace 	carcode_master 	=	14		if 	car	==	"CORMACARENA"
replace 	carcode_master 	=	15		if 	car	==	"CORNARE"
replace 	carcode_master 	=	16		if 	car	==	"CORPAMAG"
replace 	carcode_master 	=	17		if 	car	==	"CORPOAMAZONIA"
replace 	carcode_master 	=	18		if 	car	==	"CORPOBOYACA"
replace 	carcode_master 	=	19		if 	car	==	"CORPOCALDAS"
replace 	carcode_master 	=	20		if 	car	==	"CORPOCESAR"
replace 	carcode_master 	=	21		if 	car	==	"CORPOCHIVOR"
replace 	carcode_master 	=	22		if 	car	==	"CORPOGUAJIRA"
replace 	carcode_master 	=	23		if 	car	==	"CORPOGUAVIO"
replace 	carcode_master 	=	24		if 	car	==	"CORPOMOJANA"
replace 	carcode_master 	=	25		if 	car	==	"CORPONARIÑO"
replace 	carcode_master 	=	26		if 	car	==	"CORPONOR"
replace 	carcode_master 	=	27		if 	car	==	"CORPORINOQUIA"
replace 	carcode_master 	=	28		if 	car	==	"CORPOURABA"
replace 	carcode_master 	=	29		if 	car	==	"CORTOLIMA"
replace 	carcode_master 	=	30		if 	car	==	"CRA"
replace 	carcode_master 	=	31		if 	car	==	"CRC"
replace 	carcode_master 	=	32		if 	car	==	"CRQ"
replace 	carcode_master 	=	33		if 	car	==	"CSB"
replace 	carcode_master 	=	34		if 	car	==	"CVC"
replace 	carcode_master 	=	35		if 	car	==	"CVS"

*BARRANQUILLA IS WEIRD!!!

labmask carcode_master, values(car)

tempfile MCAR3
save `MCAR3'

*-------------------------------------------------------------------------------
* Juntas CAR data
*-------------------------------------------------------------------------------
import excel "${data}\Juntas CAR\juntas_directivas.xlsx", sheet("Sheet1") firstrow clear

rename _all, low

replace car=trim(car)

gen carcode=.

replace 	carcode 	=	1		if 	car	==	"AMVA"
replace 	carcode 	=	2		if 	car	==	"AREA EN LITIGIO"
replace 	carcode 	=	3		if 	car	==	"CAM"
replace 	carcode 	=	4		if 	car	==	"CAR"
replace 	carcode 	=	5		if 	car	==	"CARDER"
replace 	carcode 	=	6		if 	car	==	"CARDIQUE"
replace 	carcode 	=	7		if 	car	==	"CARSUCRE"
replace 	carcode 	=	8		if 	car	==	"CAS"
replace 	carcode 	=	9		if 	car	==	"CDA"
replace 	carcode 	=	10		if 	car	==	"CDMB"
replace 	carcode 	=	11		if 	car	==	"CODECHOCO"
replace 	carcode 	=	12		if 	car	==	"CORALINA"
replace 	carcode 	=	13		if 	car	==	"CORANTIOQUIA"
replace 	carcode 	=	14		if 	car	==	"CORMACARENA"
replace 	carcode 	=	15		if 	car	==	"CORNARE"
replace 	carcode 	=	16		if 	car	==	"CORPAMAG"
replace 	carcode 	=	17		if 	car	==	"CORPOAMAZONIA"
replace 	carcode 	=	18		if 	car	==	"CORPOBOYACA"
replace 	carcode 	=	19		if 	car	==	"CORPOCALDAS"
replace 	carcode 	=	20		if 	car	==	"CORPOCESAR"
replace 	carcode 	=	21		if 	car	==	"CORPOCHIVOR"
replace 	carcode 	=	22		if 	car	==	"CORPOGUAJIRA"
replace 	carcode 	=	23		if 	car	==	"CORPOGUAVIO"
replace 	carcode 	=	24		if 	car	==	"CORPOMOJANA"
replace 	carcode 	=	25		if 	car	==	"CORPONARIÑO"
replace 	carcode 	=	26		if 	car	==	"CORPONOR"
replace 	carcode 	=	27		if 	car	==	"CORPORINOQUIA"
replace 	carcode 	=	28		if 	car	==	"CORPOURABA"
replace 	carcode 	=	29		if 	car	==	"CORTOLIMA"
replace 	carcode 	=	30		if 	car	==	"CRA"
replace 	carcode 	=	31		if 	car	==	"CRC"
replace 	carcode 	=	32		if 	car	==	"CRQ"
replace 	carcode 	=	33		if 	car	==	"CSB"
replace 	carcode 	=	34		if 	car	==	"CVC"
replace 	carcode 	=	35		if 	car	==	"CVS"

*Drop obs with this in the string 
drop if strpos(position, "( E )") > 0
drop if strpos(position, "(E )") > 0
drop if strpos(position, "( E)") > 0
drop if strpos(position, "(E)") > 0

preserve 
	duplicates tag car year codigo_partido if codigo_partido!=., g(n_party)
	replace n_party=n_party+1

	gen each=1
	bys car year: egen total_members=sum(each)
	bys car year codigo_partido: gen sh_same_party_gob=n_party/total_members

	keep if type_election==1
	keep codigo_partido year car type_election coddane sh_same_party_gob
	keep if year>1999 & year<2021
	ren (codigo_partido coddane type_election) (codigo_partido_cargob codepto type_election_cargob)
	
	duplicates drop codepto year, force
	
	tempfile CARGOB
	save `CARGOB', replace

restore 

preserve
	
	replace type_election=2 if type_election==20
	gen politics=(type_election<3)
	collapse (mean) sh_politics=politics, by(carcode year)
	replace sh_politics=. if sh_politics==0
	drop if sh_politics==.
	
	ren carcode carcode_master
	
	tempfile SHPOL
	save `SHPOL', replace
	
restore

*bys car year: gen politics=(type_election<3)
*bys car year: egen sh_politics=mean(politics)
preserve
	duplicates tag car year codigo_partido if codigo_partido!=., g(n_party)
	replace n_party=n_party+1

	gen each=1
	bys car year: egen total_members=sum(each)
	bys car year codigo_partido: gen sh_same_party=n_party/total_members
	drop each total_members

	keep if type_election==2
	*keep codigo_partido year car carcode type_election coddane sh_politics sh_same_party
	keep codigo_partido year car carcode type_election coddane sh_same_party
	keep if year>1999 & year<2021
	ren codigo_partido codigo_partido_caralc

	duplicates drop coddane year, force

	tempfile CARALC
	save `CARALC', replace
restore 

keep if type_election!=.
gen each=1
bys car year: egen total_politicians=sum(each) //revise CAM y CAR
bys car year: gen n_politician=_n

keep year carcode n_politician codigo_partido
keep if year>1999 & year<2021
ren (carcode codigo_partido) (carcode_master codigo_partido_carpol)

reshape wide codigo_partido_carpol, i(year carcode) j(n_politician)

tempfile CARPOL
save `CARPOL', replace

*Juntas CAR by Law 
use "${data}\Juntas CAR\juntas_directivas_Ley.dta", clear

tempfile SHPOLLAW
save `SHPOLLAW', replace

*-------------------------------------------------------------------------------
* Electoral data
*-------------------------------------------------------------------------------
foreach y in 2000 2003 2007 2011 2015 2019 {
    
	use "${data}/Elections\raw\Alcaldias/`y'_alcaldia.dta", clear
	keep if curules==1
	keep ano coddpto departamento codmpio municipio codigo_partido votos curules

	ren (ano coddpto codmpio codigo_partido votos) (year codepto coddane codigo_partido_alc votos_alc)

	*Fixing year var
	replace year=year+1
	
	tempfile `y'ALC
	save ``y'ALC', replace
	
}

use `2000ALC', clear 
append using `2003ALC' `2007ALC' `2011ALC' `2015ALC' `2019ALC'

tempfile ALC
save `ALC'

foreach y in 2000 2003 2007 2011 2015 2019 {
    
	use "${data}/Elections\raw\Gobernaciones/`y'_gobernacion.dta", clear
	
	collapse (sum) votos (mean) codigo_partido, by(ano coddpto codigo_lista nombres primer_apellido segundo_apellido)
	
	bys coddpto: egen max_v=max(votos)
	gen curules=(max_v==votos) if votos!=.
	
	keep if curules==1
	drop max_v curules 
	
	ren (ano coddpto codigo_partido votos) (year codepto codigo_partido_gob votos_gob)

	*Fixing year var
	replace year=year+1
	
	tempfile `y'GOB
	save ``y'GOB', replace
	
}

use `2000GOB', clear 
append using `2003GOB' `2007GOB' `2011GOB' `2015GOB' `2019GOB'

tempfile GOB
save `GOB'

*-------------------------------------------------------------------------------
* Deforestation data
*-------------------------------------------------------------------------------
*Hansen deforestation conditioning to pixels with primary forest from Hansen
forval y=1/20{
	import delimited "${data}/Deforestation\forestloss_primary_Hansen\ForestLoss_Year`y'.csv", encoding(UTF-8)  clear 

	rename (codmpio lossarea`y') (coddane floss_prim_hansen)
	gen year=2000+`y'
	replace floss_prim_hansen=floss_prim_hansen/1000000

	keep coddane year floss_prim_hansen

	tempfile F`y'
	save `F`y'', replace 
}

use `F1', clear

append using `F2' `F3' `F4' `F5' `F6' `F7' `F8' `F9' `F10' `F11' `F12' `F13' `F14' `F15' `F16' `F17' `F18' `F19' `F20'
sort coddane year 

tempfile FLOSS_PRIMARY_HANSEN
save `FLOSS_PRIMARY_HANSEN', replace 

*Hansen deforestation conditioning to pixels with primary forest from IDEAM
forval y=1/20{
	import delimited "${data}/Deforestation\forestloss_primary_IDEAM\ForestLoss_IDEAM_Year`y'.csv", encoding(UTF-8)  clear 

	rename (codmpio lossarea`y') (coddane floss_prim_ideam)
	gen year=2000+`y'
	replace floss_prim_ideam=floss_prim_ideam/1000000

	keep coddane year floss_prim_ideam

	tempfile F`y'
	save `F`y'', replace 
}

use `F1', clear

append using `F2' `F3' `F4' `F5' `F6' `F7' `F8' `F9' `F10' `F11' `F12' `F13' `F14' `F15' `F16' `F17' `F18' `F19' `F20'
sort coddane year 

tempfile FLOSS_PRIMARY_IDEAM
save `FLOSS_PRIMARY_IDEAM', replace 

*Coverting shape to dta 
*shp2dta using "${data}/Gis\workinprogress\muniShp_defoinfo_sp", data("${data}/Gis\workinprogress\muniShp_defoinfo_sp.dta") coordinates("${data}/Gis\workinprogress\muniShp_defoinfo_sp_coord.dta") genid(idmap) genc(coord) replace 

*NEW WAY
*spshape2dta "${data}/Gis\workinprogress\muniShp_defoinfo_sp", replace
*copy "muniShp_defoinfo_sp.dta" "${data}/Gis\workinprogress\muniShp_defoinfo_sp.dta" , replace
*copy "muniShp_defoinfo_sp_shp.dta" "${data}/Gis\workinprogress\muniShp_defoinfo_sp_shp.dta" , replace

use "${data}/Gis\workinprogress\muniShp_defoinfo_sp.dta", clear

*Renaming vars
rename _all, low
ren (nmg id_espa floss01 floss02 floss03 floss04 floss05 floss06 floss07 floss08 floss09 fcv00_1 fc00_50 fcovr01) (muni_name coddane floss1 floss2 floss3 floss4 floss5 floss6 floss7 floss8 floss9 fprim00_p1 fprim00_p50 fprim_01)

keep muni_name coddane area-fprim_01 

*Reshaping the data 
destring coddane, replace
duplicates drop coddane, force

*Merging muni-CARs keys
*merge 1:1 coddane using `MCAR', keep(1 3) keepus(carcode_master)
*merge 1:1 coddane using `MCAR2', keep(1 3) keepus(carcode_master) 
merge 1:1 coddane using `MCAR3', keep(1 3) keepus(carcode_master) nogen

*Reshaping to make a panel data set
reshape long floss, i(coddane) j(year)
replace year=2000+year
keep if year<2021

*Merging other measures of deforestation
*merge 1:1 coddane year using `FLOSS_PRIMARY_HANSEN', nogen
merge 1:1 coddane year using `FLOSS_PRIMARY_IDEAM', nogen // it seems this is the same data

*Calculating different normalizations of the forest loss
gen floss_area=floss*100/area    
gen floss_prim00p1=floss*100/fprim00_p1
gen floss_prim00p50=floss*100/fprim00_p50
gen floss_prim01=floss*100/fprim_01
gen floss_prim_ideam_area=floss_prim_ideam*100/area 

*Fixing departamental code 
tostring(coddane), gen(codepto)
replace codepto="0"+codepto if length(codepto)<5
replace codepto=substr(codepto,1,2)
destring codepto, replace

*Fixing carcode when missing
*bys codepto year: egen carmode=mode(carcode_master), minmode
*replace carcode_master=carmode if carcode_master==.
*drop carmode

*Merging info about mayor elections
merge 1:1 coddane year using `ALC', keepus(codigo_partido_alc votos_alc) keep(1 3) nogen 
sort coddane year, stable
bys coddane: carryforward codigo_partido_alc votos_alc, replace 

merge m:1 codepto year using `GOB', keepus(codigo_partido_gob votos_gob) keep(1 3) nogen 
sort coddane year, stable
bys coddane: carryforward codigo_partido_gob votos_gob, replace 

*Merging info about directors of the board
merge 1:1 coddane year using `CARALC', keep(1 3) gen(merge_caralc) 
merge m:1 codepto year using `CARGOB', keep(1 3) nogen 
merge 1:1 coddane year using `PERM', keepus(perm_volume pc_perm_resol perm_n_resol perm_area pc_perm_area pc_perm_vol) keep(1 3) nogen 
merge 1:1 coddane year using `LIVESTOCK', keepus(pc_bovinos bovinos) keep(1 3) nogen 
merge 1:1 coddane year using `ENVCRIME', keepus(sh_crime_env sh_crime_forest sh_crime_forest_cond sh_crime_forest_cond_v2 sh_crime_forest_v2 pc_crime_env pc_crime_forest pc_crime_forest_cond crime_environment crime_forest crime_forest_cond crime_forest crime_forest_cond crime_environment_cond sh_crime_env_cond) keep(1 3) nogen 
merge 1:1 coddane year using `FIRES', keep(1 3) nogen 

gen code=codepto if merge_caralc==3

*Merging Politic Power in CAR
merge m:1 carcode_master year using `SHPOL', keepus(sh_politics) gen(merge_carcom)
merge m:1 carcode_master using `SHPOLLAW', keepus(sh_politics_law) gen(merge_carcom_law)
merge m:1 carcode_master year using `CARPOL', keep(1 3) gen(merge_carpol)

save "${data}/Interim\defo_caralc.dta", replace




*END

