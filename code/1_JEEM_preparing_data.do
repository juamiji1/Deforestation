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
*keep if codepto=="05" | codepto=="15" | codepto=="18" | codepto=="20" | codepto=="25" | codepto=="76" | codepto=="86" | codepto=="91" | codepto=="94" | codepto=="95" | codepto=="97" 

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

*keep if depto=="amazonas" | depto=="caqueta" | depto=="putumayo" | depto=="boyaca" | depto=="cesar" | depto=="cundinamarca" | depto=="guainia" | depto=="guaviare" | depto=="valle del cauca" | depto=="vaupes" | depto=="antioquia"
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
use "${data}\Permisos forestales\base_Corpoamazonia_13march25.dta", clear 

keep if permiso_forest==1 & codigo_dane!=. & fecharesolucion_anio>1999 & fecharesolucion_anio<2010
ren (codigo_dane fecharesolucion_anio) (coddane year)

gen n_resol=1
collapse (sum) n_resol, by(coddane year)
 
tempfile PERMPRE10
save `PERMPRE10', replace

*Corpoamazonia permits after 2010
forval y=2010/2020{
	
	import excel "${data}\Permisos forestales\CORPOAMAZONIA.xlsx", sheet("`y'") firstrow clear

	rename _all, low
	drop if mun==""

	keep cedula depto mun año area volotogado 
	cap nois destring area, replace force

	gen n_resol=1
	collapse (sum) volotogado (mean) n_resol area, by(depto mun cedula)
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

append using `PERMPRE10'

ren (volotogado n_resol area) (perm_volume perm_n_resol perm_area)

tempfile APERM
save `APERM', replace

*Corposucre
use "${data}\Permisos forestales\base_Corposucre_31march25.dta", clear 

keep if permiso_forest==1 & codigo_dane_2!=.
ren (codigo_dane fecharadicacion_anio) (coddane year)

gen perm_n_resol=1
collapse (sum) perm_n_resol, by(coddane year)

tempfile SUCPERM
save `SUCPERM', replace

*CDA
use "${data}\Permisos forestales\base_CDA_15may25.dta", clear 
rename _all, low

collapse (sum) cantidad_especie (mean) permiso_forest area_autorizada, by(actoadmnistrativo coddane year)
collapse (sum) cantidad_especie permiso_forest area_autorizada, by(coddane year)

ren (cantidad_especie permiso_forest area_autorizada) (perm_volume perm_n_resol perm_area)

*Merging both CARs together 
append using `APERM' `SUCPERM'

keep coddane year perm_volume perm_n_resol perm_area

tempfile PERM
save `PERM', replace

*Licencias 
use "${data}/Licencias\base_car.dta", clear

ren (codigo_dane fecharesolucion_anio) (coddane year)

gen n_licencia=1 
gen licencia_minero=1 if sector=="MINERO"

collapse (sum) n_licencia licencia_minero, by(coddane year)

tempfile LICEN
save `LICEN', replace 

*-------------------------------------------------------------------------------
* Fires and hotspots data
*-------------------------------------------------------------------------------
use "${data}/Fires\hotspots_fires.dta", clear

ren _all, low
ren codmpio coddane

tempfile FIRES
save `FIRES', replace 

*-------------------------------------------------------------------------------
* GDP in 1990 at Department level from DANE
*-------------------------------------------------------------------------------
import excel "${data}\DANE\PIB_historico.xlsx", sheet("Sheet1") firstrow clear

tempfile GDP90
save `GDP90', replace

*-------------------------------------------------------------------------------
* Agricultural production in 1990 at Department level from EVA
*-------------------------------------------------------------------------------
import excel "${data}\EVA\superficie_produccion_departamentos_1990_1992_codigos.xlsx", sheet("Sheet1") firstrow clear
ren (Departamento Año Superficie_Total Producción_Total Código_DIVIPOLA) (depto year depto_harvested_area depto_crop_production codepto)

destring codepto, replace

collapse (sum) depto_harvested_area depto_crop_production, by(codepto year)

gen depto_crop_yield=depto_crop_production/depto_harvested_area
replace depto_harvested_area=depto_harvested_area*0.01 

reshape wide depto_harvested_area depto_crop_production depto_crop_yield, i(codepto) j(year)

tempfile DEPTOEVA90
save `DEPTOEVA90', replace

*-------------------------------------------------------------------------------
* Forest Cover data in 1990 at Department level from IDEAM
*-------------------------------------------------------------------------------
import excel "${data}\IDEAM\Proporcion_cubierta_bosques_con_divipola.xlsx", sheet("data") firstrow clear
ren (C E) (depto_forest_cover90 depto_forest_cover00)

keep if indicador=="Superficie cubierta por bosque natural SCBN1  (ha)"
drop indicador

destring depto_forest_cover90 codepto, force replace
replace depto_forest_cover90=depto_forest_cover90*0.01
replace depto_forest_cover00=depto_forest_cover00*0.01

gen depto_forest_change_90_00=(depto_forest_cover00-depto_forest_cover90)/depto_forest_cover90

tempfile DEPTOFOREST90
save `DEPTOFOREST90', replace

*-------------------------------------------------------------------------------
* Forest Cover data at CAR from IDEAM
*-------------------------------------------------------------------------------
import excel "${data}\IDEAM\Proporcion cubierta bosques.xlsx", sheet("Data") firstrow clear
ren (CAR C) (car forest_cover90)

keep if indicador=="Superficie cubierta por bosque natural SCBN1  (ha)"
drop indicador

destring forest_cover90, force replace
replace forest_cover90=forest_cover90*0.01

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

tempfile CARFOREST
save `CARFOREST'

import excel "${data}\muniCAR\CARarea.xls", sheet("Data") firstrow clear

ren _all, lower
ren area car_area

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

keep carcode_master car_area
drop if carcode_master == . 

tempfile CARAREA
save `CARAREA'

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

merge m:1 carcode_master using `CARAREA', keep(1 3) nogen 
merge m:1 carcode_master using `CARFOREST', keep(1 3) nogen 

gen sh_car_forest90_area=forest_cover90*100/car_area

tempfile MCAR3
save `MCAR3'

*-------------------------------------------------------------------------------
* Juntas CAR data
*-------------------------------------------------------------------------------
*import excel "${data}\Juntas CAR\Bases parciales\juntas_directivas_Sept23.xlsx", sheet("Sheet1") firstrow clear
*use "${data}\Juntas CAR\juntas_directivas_19tot_Sex+rol-vot_feb.dta", clear
use "${data}\Juntas CAR\juntas_directivas_19tot_Sex+rol-vot_march.dta", clear

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

*IMPORTANT CHANGE
drop if strpos(lower(position), "delegado") > 0 | strpos(lower(position), "delegada") > 0
	
preserve 
	duplicates tag car year codigo_partido if codigo_partido!=., g(n_party)
	replace n_party=n_party+1
	
	duplicates tag carcode year codigo_partido if type_election!=. & codigo_partido!=., gen(sameparty_gov)
	replace sameparty_gov=sameparty_gov+1
	replace sameparty_gov=. if type_election!=1

	gen each=1
	bys car year: egen total_members=sum(each)
	gen politics2=(type_election<3 | contains_gobloc==1 | contains_gobnac==1)
	bys car year: egen total_pols=sum(politics2)
	gen sh_sameparty_gov=sameparty_gov/total_members
	gen sh_sameparty_gov2=sameparty_gov/total_pols

	keep if type_election==1
	
	gen director_gob=1 if director==1
	replace director_gob=0 if director_gob==.
	
	keep codigo_partido year car type_election coddane sh_sameparty_gov* porc_vots director_gob
	keep if year>1999 & year<2021
	ren (codigo_partido coddane type_election porc_vots) (codigo_partido_cargob codepto type_election_cargob sh_votes_gob )
	
	duplicates drop codepto year, force
	
	tempfile CARGOB
	save `CARGOB', replace

restore 

preserve
	replace type_election=2 if type_election==20
	gen politics=(type_election<3)
	gen politics2=(type_election<3 | contains_gobloc==1 | contains_gobnac==1)
	gen academics=(contains_acad==1)
	gen ethnias=(contains_etn==1)
	gen private=(contains_priv==1)
	gen envngo=(contains_amb==1)
	gen members=1
	
	gen female=1 if sexo=="Femenino"
	replace female=0 if female==.
	
	unique codigo_partido, by(carcode year) gen(tag)
		
	collapse (mean) sh_politics=politics sh_politics2=politics2 sh_academics=academics sh_ethnias=ethnias sh_private=private sh_envngo=envngo sh_female=female n_parties=tag (sum) politics politics2 academics ethnias private envngo members female, by(carcode year)
	
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
	
	gen director_alc=1 if director==1
	replace director_alc=0 if director_alc==.
	
	*keep codigo_partido year car carcode type_election coddane sh_politics sh_same_party
	keep codigo_partido year car carcode type_election coddane sh_same_party director_alc
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
use "${data}\Juntas CAR\sh_politics_law.dta", clear

ren _all, low

gen sh_politics2_law=(gobnacional+gobdeptos+alcaldes)/total
gen sh_private_law=(privados)/total
gen sh_ethnias_law=(comunidadesetnicas)/total
gen sh_envngo_law=(ongsambientales)/total
gen sh_academics_law=(institutosdeinvestigaciónnaci)/total

ren gob_dir director_gob_law

*two (hist sh_politics_law if director_gob_law==0, freq bins(20) color(gray) lcolor(black)) (hist sh_politics_law if director_gob_law==1, freq bins(20) fcolor(none) lcolor(black))

*tab director_gob_law, m

tempfile SHPOLLAW
save `SHPOLLAW', replace

*Juntas CAR revision law
import excel "${data}\Juntas CAR\juntas_directivas_Ley_rev.xlsx", sheet("dta_car") firstrow clear
rename _all, low

ren gob_dir2 director_gob_law_v2
keep carcode_master director_gob_law_v2

tempfile DIRGOBREV
save `DIRGOBREV', replace

*-------------------------------------------------------------------------------
* Electoral data
*-------------------------------------------------------------------------------
foreach y in 2000 2003 2007 2011 2015 2019 {
    
	use "${data}/Elections\raw\Alcaldias/`y'_alcaldia.dta", clear
	bys codmpio: egen tot_votes=total(votos)
	keep if curules==1
	keep ano coddpto departamento codmpio municipio codigo_partido votos curules tot_votes

	ren (ano coddpto codmpio codigo_partido votos tot_votes) (year codepto coddane codigo_partido_alc votos_alc tot_votes_alc)
	
	gen sh_votes_alc=votos_alc/tot_votes_alc

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
* Electoral data (ALL CANDIDATES FOR RDD)
*-------------------------------------------------------------------------------
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

tempfile GOBALL
save `GOBALL'

foreach y in 2000 2003 2007 2011 2015 2019 {
    
	use "${data}/Elections\raw\Alcaldias/`y'_alcaldia.dta", clear
	drop if codigo_lista==997 | codigo_lista==998 

	bys codmpio: egen votantes_muni=total(votos)
	bys coddpto: egen votantes_depto=total(votos)

	gen sh_votes_reg=votantes_muni/votantes_depto

	drop if codigo_lista==999 

	gsort codmpio -votos

	bys codmpio: gen position=_n

	ren (ano coddpto codmpio codigo_partido votos) (year codepto coddane codigo_partido_alc votos_alc)

	*Fixing year var
	replace year=year+1
	
	keep year codepto coddane codigo_partido_alc votos_alc curules position sh_votes_reg
	
	tempfile `y'ALC
	save ``y'ALC', replace
	
}

use `2000ALC', clear 
append using `2003ALC' `2007ALC' `2011ALC' `2015ALC' `2019ALC'

preserve
	keep if curules==1
	sort coddane year 
	bys coddane: gen incumbent=1 if codigo_partido_alc[_n]==codigo_partido_alc[_n-1]
	replace incumbent=0 if incumbent==.
	
	replace year=year-1
	ren year election
	
	tempfile INCUMB
	save `INCUMB', replace
restore

drop sh_votes_reg

merge m:1 codepto year using `GOBALL', keep(1 3) keepus(codigo_partido_gob) nogen 

gen alligned=1 if codigo_partido_alc==codigo_partido_gob

keep if position<3

bys coddane year: egen tot_votos_alc=total(votos_alc)

gen z_sh_votes_alc=votos_alc/tot_votos_alc

bys coddane year: egen close_elec=total(alligned) 
keep if close_elec==1

replace z_sh_votes_alc=z_sh_votes_alc-.5
keep if alligned==1

ren curules win_alc

tempfile ALCALL
save `ALCALL'

use "${data}/Elections\raw\Alcaldias2023/1990_alcaldia.dta", clear

bys codmpio: egen votantes_muni=total(votos)
bys coddpto: egen votantes_depto=total(votos)

gen sh_votes_reg90=votantes_muni/votantes_depto
	
ren (codmpio ano votos) (coddane year votos_alc)

bys coddane year: egen tot_votos_alc90=total(votos_alc)
keep if curules==1 

keep coddane tot_votos_alc90 sh_votes_reg90

tempfile ALC90
save `ALC90'

*-------------------------------------------------------------------------------
* Forest Cover data
*-------------------------------------------------------------------------------
import delimited "${data}/Primary Forest\Primary_Forest_2001.csv", encoding(UTF-8) clear 

rename (codmpio) (coddane)

replace primary_forest01=primary_forest01/1000000

keep coddane primary_forest01

tempfile PRIMARYCOVER
save `PRIMARYCOVER', replace 

*-------------------------------------------------------------------------------
* Deforestation data
*-------------------------------------------------------------------------------
*Hansen deforestation conditioning to pixels with primary forest from Hansen
forval y=1/20{
	import delimited "${data}/Deforestation\forestloss_primary_Hansen\ForestLoss_Year`y'.csv", encoding(UTF-8) clear 

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
	import delimited "${data}/Deforestation\forestloss_primary_IDEAM\ForestLoss_IDEAM_Year`y'.csv", encoding(UTF-8) clear 

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

*Hansen deforestation conditioning to pixels with primary forest from IDEAM and protected areas
forval y=1/20{
	import delimited "${data}/Deforestation\forestloss_illegal_measures\ForestLoss_Illegal_Year`y'.csv", encoding(UTF-8) clear 

	rename (codmpio lossarea`y') (coddane floss_prim_ilegal)
	gen year=2000+`y'
	replace floss_prim_ilegal=floss_prim_ilegal/1000000

	keep coddane year floss_prim_ilegal

	tempfile F`y'
	save `F`y'', replace 
}

use `F1', clear

append using `F2' `F3' `F4' `F5' `F6' `F7' `F8' `F9' `F10' `F11' `F12' `F13' `F14' `F15' `F16' `F17' `F18' `F19' `F20'
sort coddane year 

collapse (sum) floss_prim_ilegal, by(year coddane)

tempfile FLOSS_PRIMARY_ILLEGAL
save `FLOSS_PRIMARY_ILLEGAL', replace 

*Coverting shape to dta 
*shp2dta using "${data}/Gis\workinprogress\muniShp_defoinfo_sp", data("${data}/Gis\workinprogress\muniShp_defoinfo_sp.dta") coordinates("${data}/Gis\workinprogress\muniShp_defoinfo_sp_coord.dta") genid(idmap) genc(coord) replace 

*NEW WAY
*spshape2dta "${data}/Gis\workinprogress\muniShp_defoinfo_sp", replace
*copy "muniShp_defoinfo_sp.dta" "${data}/Gis\workinprogress\muniShp_defoinfo_sp.dta" , replace
*copy "muniShp_defoinfo_sp_shp.dta" "${data}/Gis\workinprogress\muniShp_defoinfo_sp_shp.dta" , replace

*-------------------------------------------------------------------------------
* Night Light data
*-------------------------------------------------------------------------------
forval y=2001/2020{
	import delimited "${data}/Night light\NightLight_Year`y'.csv", encoding(UTF-8) clear 

	rename (codmpio nl`y') (coddane night_light)
	gen year=`y'

	keep coddane year night_light
	
	local y=`y'-2000
	
	tempfile F`y'
	save `F`y'', replace 
}

use `F1', clear

append using `F2' `F3' `F4' `F5' `F6' `F7' `F8' `F9' `F10' `F11' `F12' `F13' `F14' `F15' `F16' `F17' `F18' `F19' `F20'
sort coddane year 

tempfile NLDATA
save `NLDATA', replace 

*-------------------------------------------------------------------------------
* Land Change data
*-------------------------------------------------------------------------------
forval y=2015/2021{
	import delimited "${data}/Land Use\bare_Year`y'.csv", encoding(UTF-8) clear 

	rename (codmpio bare_area`y') (coddane bare_area)
	gen year=`y'-1
	
	replace bare_area=bare_area/1000000
	
	keep coddane year bare_area
	
	local y=`y'-2000
	
	tempfile B`y'
	save `B`y'', replace 
}

use `B15', clear

append using `B16' `B17' `B18' `B19' `B20' `B21'
sort coddane year 

tempfile BARE
save `BARE', replace 

forval y=2015/2021{
	import delimited "${data}/Land Use\built_Year`y'.csv", encoding(UTF-8) clear 

	rename (codmpio built_area`y') (coddane built_area)
	gen year=`y'-1

	replace built_area=built_area/1000000
	
	keep coddane year built_area
	
	local y=`y'-2000
	
	tempfile A`y'
	save `A`y'', replace 
}

use `A15', clear

append using `A16' `A17' `A18' `A19' `A20' `A21'
sort coddane year 

tempfile BUILT
save `BUILT', replace 

forval y=2015/2021{
	import delimited "${data}/Land Use\grass_Year`y'.csv", encoding(UTF-8) clear 

	rename (codmpio grass_area`y') (coddane grass_area)
	gen year=`y'-1

	replace grass_area=grass_area/1000000
	
	keep coddane year grass_area
	
	local y=`y'-2000
	
	tempfile G`y'
	save `G`y'', replace 
}

use `G15', clear

append using `G16' `G17' `G18' `G19' `G20' `G21'
sort coddane year 

tempfile GRASS
save `GRASS', replace 

forval y=2015/2021{
	import delimited "${data}/Land Use\shrub_Year`y'.csv", encoding(UTF-8) clear 

	rename (codmpio shrub_area`y') (coddane shrub_area)
	gen year=`y'-1

	replace shrub_area=shrub_area/1000000
	
	keep coddane year shrub_area
	
	local y=`y'-2000
	
	tempfile S`y'
	save `S`y'', replace 
}

use `S15', clear

append using `S16' `S17' `S18' `S19' `S20' `S21'
sort coddane year 

tempfile SHRUB
save `SHRUB', replace 

forval y=2015/2021{
	import delimited "${data}/Land Use\crop_Year`y'.csv", encoding(UTF-8) clear 

	rename (codmpio crop_area`y') (coddane crop_area)
	gen year=`y'-1

	replace crop_area=crop_area/1000000
	
	keep coddane year crop_area
	
	local y=`y'-2000
	
	tempfile C`y'
	save `C`y'', replace 
}

use `C15', clear

append using `C16' `C17' `C18' `C19' `C20' `C21'
sort coddane year 

tempfile CROP
save `CROP', replace 

merge 1:1 coddane year using `BARE', nogen
merge 1:1 coddane year using `BUILT', nogen
merge 1:1 coddane year using `SHRUB', nogen
merge 1:1 coddane year using `GRASS', nogen

tempfile LANDUSE
save `LANDUSE', replace 

*-------------------------------------------------------------------------------
* BII data
*-------------------------------------------------------------------------------
foreach y in 2000 2005 2010 2015 2020 {
	import delimited "${data}/BII\muni_bii_`y'.csv", encoding(UTF-8) clear 
	
	tempfile BII`y'
	save `BII`y'', replace 
}

use `BII2000', clear

append using `BII2005' `BII2010' `BII2015' `BII2020'
sort coddane year 

duplicates drop 

tempfile BII
save `BII', replace 
	
*-------------------------------------------------------------------------------
* Lobbying data 
*-------------------------------------------------------------------------------
use "${data}/Cuentas Claras\financed_munis.dta", clear

ren codmpio coddane

tempfile LOBBY1
save `LOBBY1', replace

import delimited "${data}/Cuentas Claras\INGRESOS_TERRITORIALES_2015.csv", clear

keep if corporaciónocargo=="Gobernación"
keep if elegido=="Si"

gen private=1 if código==102 | código==106 
replace privat=0 if private==.

destring valor, replace force 
format %12.0g valor  

ren (departamento código) (depto codigo)

gen n_cod=1 

collapse (sum) n_cod private valor, by(depto codigo)

bys depto: egen tot_valor=sum(valor)
format %12.0g tot_valor

gen sh_priv_valor_gob=valor/tot_valor if private>0

collapse (sum) n_cod private (mean) sh_priv_valor_gob, by(depto)

gen sh_priv_gob=private/n_cod
replace sh_priv_valor_gob=0 if sh_priv_valor_gob==.
gen year=2016

replace depto=subinstr(depto,"Ñ","N",.)
replace depto=subinstr(depto,"Á","A",.)
replace depto=subinstr(depto,"É","E",.)
replace depto=subinstr(depto,"Í","I",.)
replace depto=subinstr(depto,"Ó","O",.)
replace depto=subinstr(depto,"Ú","U",.)
replace depto=subinstr(depto,"Ü","U",.)
replace depto=strlower(depto)
replace depto=subinstr(depto,"ñ","n",.)
replace depto=subinstr(depto,"á","a",.)
replace depto=subinstr(depto,"é","e",.)
replace depto=subinstr(depto,"í","i",.)
replace depto=subinstr(depto,"ó","o",.)
replace depto=subinstr(depto,"ú","u",.)
replace depto=subinstr(depto,"ü","u",.)

gen codepto = 91 if depto == "amazonas"
replace codepto = 05 if depto == "antioquia"
replace codepto = 81 if depto == "arauca"
replace codepto = 08 if depto == "atlantico"
replace codepto = 13 if depto == "bolivar"
replace codepto = 15 if depto == "boyaca"
replace codepto = 17 if depto == "caldas"
replace codepto = 18 if depto == "caqueta"
replace codepto = 85 if depto == "casanare"
replace codepto = 19 if depto == "cauca"
replace codepto = 20 if depto == "cesar"
replace codepto = 27 if depto == "choco"
replace codepto = 23 if depto == "cordoba"
replace codepto = 25 if depto == "cundinamarca"
replace codepto = 94 if depto == "guainia"
replace codepto = 95 if depto == "guaviare"
replace codepto = 41 if depto == "huila"
replace codepto = 44 if depto == "la guajira"
replace codepto = 47 if depto == "magdalena"
replace codepto = 50 if depto == "meta"
replace codepto = 52 if depto == "narino"
replace codepto = 54 if depto == "norte de santander"
replace codepto = 86 if depto == "putumayo"
replace codepto = 63 if depto == "quindio"
replace codepto = 66 if depto == "risaralda"
replace codepto = 88 if depto == "san andres"
replace codepto = 68 if depto == "santander"
replace codepto = 70 if depto == "sucre"
replace codepto = 73 if depto == "tolima"
replace codepto = 97 if depto == "vaupes"
replace codepto = 99 if depto == "vichada"

tempfile LOBBY2
save `LOBBY2', replace

import delimited "${data}/Cuentas Claras\INGRESOS_TERRITORIALES_2015.csv", clear

keep if corporaciónocargo=="Alcaldía"
keep if elegido=="Si"

gen private=1 if código==102 | código==106 
replace privat=0 if private==.

destring valor, replace force 
format %12.0g valor  

ren (departamento municipio código) (depto mun codigo)

gen n_cod=1 

collapse (sum) n_cod private valor, by(depto mun codigo)

bys depto mun: egen tot_valor=sum(valor)
format %12.0g tot_valor

gen sh_priv_valor_alc=valor/tot_valor if private>0

collapse (sum) n_cod private (mean) sh_priv_valor_alc, by(depto mun)

gen sh_priv_alc=private/n_cod
replace sh_priv_valor_alc=0 if sh_priv_valor_alc==.
gen year=2016

replace depto=subinstr(depto,"Ñ","N",.)
replace depto=subinstr(depto,"Á","A",.)
replace depto=subinstr(depto,"É","E",.)
replace depto=subinstr(depto,"Í","I",.)
replace depto=subinstr(depto,"Ó","O",.)
replace depto=subinstr(depto,"Ú","U",.)
replace depto=subinstr(depto,"Ü","U",.)
replace depto=strlower(depto)
replace depto=subinstr(depto,"ñ","n",.)
replace depto=subinstr(depto,"á","a",.)
replace depto=subinstr(depto,"é","e",.)
replace depto=subinstr(depto,"í","i",.)
replace depto=subinstr(depto,"ó","o",.)
replace depto=subinstr(depto,"ú","u",.)
replace depto=subinstr(depto,"ü","u",.)

replace mun=subinstr(mun,"Ñ","N",.)
replace mun=subinstr(mun,"Á","A",.)
replace mun=subinstr(mun,"É","E",.)
replace mun=subinstr(mun,"Í","I",.)
replace mun=subinstr(mun,"Ó","O",.)
replace mun=subinstr(mun,"Ú","U",.)
replace mun=subinstr(mun,"Ü","U",.)
replace mun=strlower(mun)
replace mun=subinstr(mun,"corregimiento ","",.)

merge 1:1 depto mun using `DIVIPOLA', keep(1 3) nogen

drop depto mun codepto
drop if coddane==.

tempfile LOBBY3
save `LOBBY3', replace

*-------------------------------------------------------------------------------
* Party Content (green vs no green / left vs right)
*-------------------------------------------------------------------------------
use "${data}/Elections\raw\Partidos_Electorales.dta", clear

duplicates drop nombre_partido, force

tempfile CODPARTY
save `CODPARTY', replace 

use "${data}/Congreso Visible\Votaciones Green_29May.dta", clear

ren _all, low
ren partido_cede nombre_partido

merge 1:1 nombre_partido using `CODPARTY', keep(3) keepus(codigo_partido) nogen

ren mean_partido_votogreen_mean partido_votogreen

summ partido_votogreen, d
gen green_party=(partido_votogreen>=`r(p50)') if partido_votogreen!=.
gen green_party_v2=(partido_votogreen>=`r(p50)') if partido_votogreen!=.

replace green_party_v2=1 if partido_id_cede==194 | partido_id_cede==645
replace green_party_v2=0 if partido_id_cede==14  | partido_id_cede==1

ren codigo_partido codigo_partido_gob

tempfile GREENPARTY
save `GREENPARTY', replace

ren codigo_partido_gob codigo_partido_alc

tempfile GREENPARTYALC
save `GREENPARTYALC', replace

*-------------------------------------------------------------------------------
* Municipality characteristics
*-------------------------------------------------------------------------------
import delimited "${data}\Gaez\muniShp_sut_data.csv", encoding(UTF-8) clear

tempfile SUITCROPS
save `SUITCROPS', replace

use "${data}/Cede\Panel_context_11042025.dta", clear

merge m:1 codmpio using `SUITCROPS', keep(1 3) nogen 

ren (codmpio ano) (coddane year)

gen x=pobl_tot if year<=2000
bys coddane: egen pobl_tot93=mean(x)

gen y=pobreza if year==1993
bys coddane: egen pobreza93=mean(y)

drop x y 

tempfile CEDE
save `CEDE', replace

import excel "${data}\DANE\va_2011-2023.xlsx", sheet("Sheet1") firstrow clear

reshape long va, i(coddane) j(year)
destring coddane, replace

keep coddane year va

tempfile VA
save `VA', replace

import excel "${data}\DANE\va_sector_2011-2021.xlsx", sheet("Sheet1") firstrow clear
destring coddane, replace

keep coddane year va_*

tempfile VAS
save `VAS', replace

*-------------------------------------------------------------------------------
* Merging all together
*-------------------------------------------------------------------------------
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
merge 1:1 coddane using `MCAR3', keep(1 3) keepus(carcode_master forest_cover90 car_area sh_car_forest90_area) nogen

*Reshaping to make a panel data set
reshape long floss, i(coddane) j(year)
replace year=2000+year
keep if year<2021

*Merging other measures of deforestation
*merge 1:1 coddane year using `FLOSS_PRIMARY_HANSEN', nogen
merge 1:1 coddane year using `FLOSS_PRIMARY_IDEAM', nogen // it seems this is the same data
merge 1:1 coddane year using `FLOSS_PRIMARY_ILLEGAL', nogen // it seems this is the same data
merge m:1 coddane using `PRIMARYCOVER', keep(1 3) nogen

*Calculating different normalizations of the forest loss
gen floss_area=floss*100/area    
gen floss_prim00p1=floss*100/fprim00_p1
gen floss_prim00p50=floss*100/fprim00_p50
gen floss_prim01=floss*100/fprim_01
gen floss_prim_ideam_area=floss_prim_ideam*100/area 
gen floss_prim_ideam_area_v2=floss_prim_ideam*100/primary_forest01 

summ floss_prim_ideam_area_v2 , d
replace floss_prim_ideam_area_v2 = . if floss_prim_ideam_area_v2>1 & floss_prim_ideam_area_v2!=.

*Looking at legal vs illegal deforestation
*replace floss_prim_ilegal=0 if floss_prim_ilegal==. // Missings are munis without protected areas
gen floss_prim_legal = floss_prim_ideam - floss_prim_ilegal
gen floss_prim_legal_area_v2 = floss_prim_legal*100/primary_forest01 
gen floss_prim_ilegal_area_v2 = floss_prim_ilegal*100/primary_forest01 

replace floss_prim_ilegal_area_v2 =. if floss_prim_legal_area_v2<0
replace floss_prim_legal_area_v2 =. if floss_prim_legal_area_v2<0

gen sh_floss_prim_ilegal= floss_prim_ilegal*100 / floss_prim_ideam
replace sh_floss_prim_ilegal=. if sh_floss_prim_ilegal>100 & sh_floss_prim_ilegal!=.
replace sh_floss_prim_ilegal=. if floss_prim_ideam_area_v2>1 & floss_prim_ideam_area_v2!=.

*Measure of flow
sort coddane year

gen prim_forest_den = primary_forest01 if year==2001

forval y = 2002/2020{
	
	replace prim_forest_den = prim_forest_den[_n-1] - floss_prim_ideam[_n-1] if year==`y'
} 

gen floss_prim_ideam_area_v3=floss_prim_ideam*100/prim_forest_den 

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
merge 1:1 coddane year using `ALC', keepus(codigo_partido_alc votos_alc sh_votes_alc) keep(1 3) nogen 

sort coddane year, stable
bys coddane: carryforward codigo_partido_alc votos_alc sh_votes_alc, replace 

merge m:1 codepto year using `GOB', keepus(codigo_partido_gob votos_gob) keep(1 3) nogen 
sort coddane year, stable
bys coddane: carryforward codigo_partido_gob votos_gob, replace 

*Merging info about directors of the board
merge 1:1 coddane year using `CARALC', keep(1 3) gen(merge_caralc) 
merge m:1 codepto year using `CARGOB', keep(1 3) nogen 
merge 1:1 coddane year using `PERM', keepus(perm_volume perm_n_resol perm_area) keep(1 3) nogen 
merge 1:1 coddane year using `LICEN', keepus(n_licencia licencia_minero) keep(1 3) nogen 
merge 1:1 coddane year using `LIVESTOCK', keepus(pc_bovinos bovinos) keep(1 3) nogen 
merge 1:1 coddane year using `ENVCRIME', keepus(sh_crime_env sh_crime_forest sh_crime_forest_cond sh_crime_forest_cond_v2 sh_crime_forest_v2 pc_crime_env pc_crime_forest pc_crime_forest_cond crime_environment crime_forest crime_forest_cond crime_forest crime_forest_cond crime_environment_cond sh_crime_env_cond total_procesos) keep(1 3) nogen 
merge 1:1 coddane year using `FIRES', keep(1 3) nogen 
merge 1:1 coddane year using `LOBBY1', keep(1 3) nogen 
merge m:1 codepto year using `LOBBY2', keep(1 3) nogen 
merge 1:1 coddane year using `LOBBY3', keep(1 3) nogen 

sort coddane year, stable
bys coddane: carryforward sh_priv_gob sh_priv_valor_gob, replace 
gen code=codepto if merge_caralc==3

sort coddane year, stable
bys coddane: carryforward sh_priv_alc sh_priv_valor_alc, replace 

*Merging Politic Power in CAR
merge m:1 carcode_master year using `SHPOL', keepus(sh_* politics politics2 academics ethnias private envngo members female n_parties) gen(merge_carcom)
merge m:1 carcode_master using `SHPOLLAW', keepus(sh_*_law director_gob_law) gen(merge_carcom_law)
merge m:1 carcode_master year using `CARPOL', keep(1 3) gen(merge_carpol)
merge m:1 carcode_master using `DIRGOBREV', keep(1 3) nogen

gen election=2000 if year>2000 & year<2004
replace election=2003 if year>2003 & year<2008
replace election=2007 if year>2007 & year<2012
replace election=2011 if year>2011 & year<2016
replace election=2015 if year>2015 & year<2020
replace election=2019 if year>2019

*Restrictions on sample
keep if year>2000 & year<2021
drop if carcode_master==12 // San andres y providencia

merge 1:1 coddane year using `ALCALL', keep(1 3) nogen

sort coddane year, stable
bys coddane election: carryforward z_sh_votes_alc, replace 

merge m:1 codigo_partido_gob using `GREENPARTY', keep(1 3) keepus(partido_votogreen green_party green_party_v2) nogen 
ren (partido_votogreen green_party green_party_v2) (partido_votogreen_gov green_party_gov green_party_v2_gov)

merge m:1 codigo_partido_alc using `GREENPARTYALC', keep(1 3) keepus(partido_votogreen green_party green_party_v2) nogen 
ren (partido_votogreen green_party green_party_v2) (partido_votogreen_alc green_party_alc green_party_v2_alc)

merge 1:1 coddane year using `CEDE', keep(1 3) nogen

merge m:1 election coddane using `INCUMB', keep(1 3) keepus(sh_votes_reg incumbent) nogen

merge m:1 coddane using `ALC90', keep(1 3) nogen
merge m:1 codepto using `DEPTOEVA90', keep(1 3) nogen
merge m:1 codepto using `DEPTOFOREST90', keep(1 3) nogen
merge m:1 codepto using `GDP90', keep(1 3) nogen 

merge 1:1 coddane year using `NLDATA', keep(1 3) nogen
merge 1:1 coddane year using "${data}/EVA\eva_yield.dta", keep(1 3) nogen
merge 1:1 coddane year using `VA', keep(1 3) nogen
merge 1:1 coddane year using `VAS', keep(1 3) nogen

merge 1:1 coddane year using `LANDUSE', keep(1 3) nogen

merge 1:1 coddane year using `BII', keep(1 3) nogen 
bys coddane: carryforward bii, replace 

*-------------------------------------------------------------------------------
* Preparing vars of interest
*-------------------------------------------------------------------------------
*Creating variable of mayor in the CAR's board 
gen mayorinbrd=(codigo_partido_caralc!=.) if sh_politics!=.

*Creating variable of mayor allied with the gobernor in CAR's board
gen mayorallied=(codigo_partido_alc==codigo_partido_gob) if codigo_partido_gob!=.

*Allianza with any politician in the CAR's board
gen mayorallied_wanypol=.
forval i=1/12{
	replace mayorallied_wanypol=1 if codigo_partido_alc==codigo_partido_carpol`i' & codigo_partido_carpol`i'!=.
}

replace mayorallied_wanypol=0 if mayorallied_wanypol==. & mayorallied_wanypol!=1 & codigo_partido_alc!=.

*Political power vars 
gen dmdn_politics = (sh_politics>=.5) if sh_politics!=.
gen dmdn_politics_law = (sh_politics_law>=.5) if sh_politics_law!=.
gen dmdn_politics2=(sh_politics2_law>.5) if sh_politics2_law!=.

*Green party assumption
*replace green_party_v2=1 if green_party_v2==.

la var floss_prim_ideam_area "Primary Forest Loss (%)"
la var mayorallied "Partisan Alignment"

summ floss_prim_ideam_area_v2 , d
replace floss_prim_ideam_area_v2 = . if floss_prim_ideam_area_v2>1 & floss_prim_ideam_area_v2!=.

summ floss_prim_ideam_area_v3 , d
replace floss_prim_ideam_area_v3 = . if floss_prim_ideam_area_v3>1 & floss_prim_ideam_area_v3!=.

*Preparing land use shares
gen bare_area_floss=bare_area*100/floss_prim_ideam
gen built_area_floss=built_area*100/floss_prim_ideam
gen shrub_area_floss=shrub_area*100/floss_prim_ideam
gen grass_area_floss=grass_area*100/floss_prim_ideam
gen crop_area_floss=crop_area*100/floss_prim_ideam

gen grass_shrub_area=grass_area+shrub_area
gen grass_shrub_area_floss=grass_shrub_area*100/floss_prim_ideam

gen landuse_area=grass_area+shrub_area+bare_area+built_area+crop_area
gen landuse_area_floss=landuse_area*100/floss_prim_ideam

*Keeping complete election term years
keep if year <2020


save "${data}/Interim\defo_caralc.dta", replace




*END

