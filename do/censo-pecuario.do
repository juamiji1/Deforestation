/*------------------------------------------------------------------------------
PROJECT: Ideology & deforestation
TOPIC: master do-file
DATE: 09-07-2019
AUTHORS: JMJR & LM
NOTES:

------------------------------------------------------------------------------*/

clear all 

*Setting directories 
if c(username) == "jmjimenez" {
	gl path "C:\Users/`c(username)'\Dropbox\My-Research\Archivos compartidos Deforestación-Partidos Politicos"
}
else {
}

gl data ${path}/Censo pecuario

cd "${data}"

*2016
import excel "bovino_16_20.xlsx", sheet("2016") firstrow clear

rename _all, low
rename  (departamentos municipio totalbovinos2016 totalfincasconbovinos2016) (depto muni total_bovino2016 total_fincas2016)

replace depto=subinstr(depto,"-"," ",.)
replace muni=subinstr(muni,"-"," ",.)
replace muni=subinstr(muni,"_"," ",.)
replace muni=subinstr(muni,"Ñ","N",.)
replace muni=subinstr(muni," Ma","",.)
replace muni="PUEBLO VIEJO" if muni=="PUEBLOVIEJO"

tempfile X16
save `X16', replace

*2017
import excel "bovino_16_20.xlsx", sheet("2017") firstrow clear

rename _all, low
rename  (departamentos municipio totalbovinos2017 totalfincasconbovinos2017) (depto muni total_bovino2017 total_fincas2017)

replace depto=subinstr(depto,"-"," ",.)
replace muni=subinstr(muni,"-"," ",.)
replace muni=subinstr(muni,"_"," ",.)
replace muni=subinstr(muni,"Ñ","N",.)
replace muni=subinstr(muni," Ma","",.)
replace muni="EL PINON" if muni=="ELPINON"
replace muni="CERRO DE SAN ANTONIO" if muni=="CERRO  DE SAN ANTONIO"

merge 1:1 depto muni using `X16'
drop _merge

tempfile X17
save `X17', replace

*2018
import excel "bovino_16_20.xlsx", sheet("2018") firstrow clear

rename _all, low
rename  (departamento municipio totalbovinos2018 totalfincasconbovinos2018) (depto muni total_bovino2018 total_fincas2018)

replace depto=subinstr(depto,"-"," ",.)
replace muni=subinstr(muni,"-"," ",.)
replace muni=subinstr(muni,"_"," ",.)
replace muni=subinstr(muni,"Ñ","N",.)
replace muni=subinstr(muni," Ma","",.)
replace muni=subinstr(muni,"Á","A",.)
replace muni=subinstr(muni,"É","E",.)
replace muni=subinstr(muni,"Í","I",.)
replace muni=subinstr(muni,"Ó","O",.)
replace muni=subinstr(muni,"Ú","U",.)
replace muni=subinstr(muni,"Ü","U",.)
replace muni="PUEBLO VIEJO" if muni=="PUEBLOVIEJO"

merge 1:1 depto muni using `X17'
drop _merge

tempfile X18
save `X18', replace

*2019
import excel "bovino_16_20.xlsx", sheet("2019") firstrow clear

rename _all, low
rename  (departamento municipio totalbovinos2019 totalfincasconbovinos2019) (depto muni total_bovino2019 total_fincas2019)

replace depto=subinstr(depto,"-"," ",.)
replace depto=subinstr(depto,"Á","A",.)
replace depto=subinstr(depto,"É","E",.)
replace depto=subinstr(depto,"Í","I",.)
replace depto=subinstr(depto,"Ó","O",.)
replace depto=subinstr(depto,"Ú","U",.)
replace depto=subinstr(depto,"Ñ","N",.)
replace depto="NORTE SANTANDER" if depto=="NORTE DE SANTANDER"
replace depto="VALLE" if depto=="VALLE DEL CAUCA"
replace depto="S.ANDRES/PROVID" if depto=="ARCHIPIELAGO DE SAN ANDRES, PROVIDENCIA Y "
replace depto="DISTRITO CAPITAL" if depto=="BOGOTA, D. C."

replace muni=subinstr(muni,"-"," ",.)
replace muni=subinstr(muni,"_"," ",.)
replace muni=subinstr(muni,"Ñ","N",.)
replace muni=subinstr(muni," Ma","",.)
replace muni=subinstr(muni,"Á","A",.)
replace muni=subinstr(muni,"É","E",.)
replace muni=subinstr(muni,"Í","I",.)
replace muni=subinstr(muni,"Ó","O",.)
replace muni=subinstr(muni,"Ú","U",.)
replace muni=subinstr(muni,"Ü","U",.)
replace muni="MIRITI PARANA" if muni=="MIRITI   PARANA"
replace muni="DON MATIAS" if muni=="DONMATIAS"
replace muni="GUICAN" if muni=="GUICAN DE LA SIERRA"
replace muni="PIENDAMO" if muni=="PIENDAMO   TUNIA"
replace muni="BOGOTA,D.C." if muni=="BOGOTA, D.C."
replace muni="HATO NUEVO" if muni=="HATONUEVO"
replace muni="PUEBLO VIEJO" if muni=="PUEBLOVIEJO"
replace muni="CUCUTA" if muni=="SAN JOSE DE CUCUTA"
replace muni="VALLE SAN JOSE" if muni=="VALLE DE SAN JOSE"
replace muni="TOLUVIEJO" if muni=="TOLU VIEJO"
replace muni="ARMERO GUAYABAL" if muni=="ARMERO"

merge 1:1 depto muni using `X18'
drop _merge

replace muni=subinstr(muni," Am","",.)
replace muni=subinstr(muni," An","",.)
replace muni=subinstr(muni," At","",.)
replace muni=subinstr(muni," Bl","",.)
replace muni=subinstr(muni," By","",.)
replace muni=subinstr(muni," Cl","",.)
replace muni=subinstr(muni," Cq","",.)
replace muni=subinstr(muni," Cs","",.)
replace muni=subinstr(muni," Ca","",.)
replace muni=subinstr(muni," Ce","",.)
replace muni=subinstr(muni," Ch","",.)
replace muni=subinstr(muni," Co","",.)
replace muni=subinstr(muni," Cu","",.)
replace muni=subinstr(muni," Gn","",.)
replace muni=subinstr(muni," Gv","",.)
replace muni=subinstr(muni," H","",.) if depto=="HUILA"
replace muni=subinstr(muni," LG","",.)
replace muni=subinstr(muni," Me","",.)
replace muni=subinstr(muni," N","",.) if depto=="NARINO"
replace muni=subinstr(muni," NS","",.)
replace muni=subinstr(muni," P","",.) if depto=="PUTUMAYO"
replace muni=subinstr(muni," Q","",.) if depto=="QUINDIO"
replace muni=subinstr(muni," R","",.) if depto=="RISARALDA"
replace muni=subinstr(muni," SAYP","",.)
replace muni=subinstr(muni," Sa","",.)
replace muni=subinstr(muni," Su","",.)
replace muni=subinstr(muni," T","",.) if depto=="TOLIMA"
replace muni=subinstr(muni," V","",.) if depto=="VALLE"

tempfile X19
save `X19', replace

*2020
import excel "bovino_16_20.xlsx", sheet("2020") firstrow clear

rename _all, low
rename  (departamento municipio totalbovinos2019 totalfincasconbovinos2019 ) (depto muni total_bovino2020 total_fincas2020)

replace depto=subinstr(depto,"-"," ",.)
replace depto=subinstr(depto,"Á","A",.)
replace depto=subinstr(depto,"É","E",.)
replace depto=subinstr(depto,"Í","I",.)
replace depto=subinstr(depto,"Ó","O",.)
replace depto=subinstr(depto,"Ú","U",.)
replace depto=subinstr(depto,"Ñ","N",.)
replace depto="NORTE SANTANDER" if depto=="NORTE DE SANTANDER"
replace depto="VALLE" if depto=="VALLE DEL CAUCA"
replace depto="S.ANDRES/PROVID" if depto=="SAN ANDRES Y PROVIDENCIA"
replace depto="DISTRITO CAPITAL" if depto=="BOGOTA D.C."

replace muni=subinstr(muni,"-"," ",.)
replace muni=subinstr(muni,"_"," ",.)
replace muni=subinstr(muni,"Ñ","N",.)
replace muni=subinstr(muni," Ma","",.)
replace muni=subinstr(muni,"Á","A",.)
replace muni=subinstr(muni,"É","E",.)
replace muni=subinstr(muni,"Í","I",.)
replace muni=subinstr(muni,"Ó","O",.)
replace muni=subinstr(muni,"Ú","U",.)
replace muni=subinstr(muni,"Ü","U",.)
replace muni="BOGOTA,D.C." if muni=="BOGOTA D.C."
replace muni="DON MATIAS" if muni=="DONMATIAS"
replace muni="GUICAN" if muni=="GUICAN DE LA SIERRA"
replace muni="HATO NUEVO" if muni=="HATONUEVO"
replace muni="PUEBLO VIEJO" if muni=="PUEBLOVIEJO"
replace muni="VALLE SAN JOSE" if muni=="VALLE DE SAN JOSE"
replace muni="TOLUVIEJO" if muni=="TOLU VIEJO"
replace muni="OLAYA HERRERA" if muni=="OLAYAERRERA" 
replace muni="SANTA HELENA DEL OPON" if muni=="SANTAELENA DEL OPON"
replace muni="LAICTORIA" if muni=="LA VICTORIA" & depto=="VALLE"
replace muni="PUEBLOICO" if muni=="PUEBLO RICO"
replace muni="SANTAOSA DE CABAL" if muni=="SANTA ROSA DE CABAL"

merge 1:1 depto muni using `X19'
drop _merge

rename codigomunicipio codmuni 

reshape long total_bovino total_fincas, i(depto muni codmuni) j(year)


save "censo_pecuario_16_20.dta", replace 




*END

