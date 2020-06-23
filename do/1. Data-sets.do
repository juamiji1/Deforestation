/*------------------------------------------------------------------------------
Topic: This do file prepare the deforestation data at the mucipal level for Colombia
in 2000 to 2018.

Date: July-1st-2019
Author: JMJR
------------------------------------------------------------------------------*/

clear all

*Log file
*log using "$logs\1_Data_sets_(`c(current_date)').txt", replace text


*-------------------------------------------------------------------------------
* 					1. Preparing Elections Data 
*
*-------------------------------------------------------------------------------
*NOTE: Liseth dos will be placed in this section!!!!!!!!!!!! 

*Prepare 2011 data
use ${data}\Elections\alcaldia2011, clear

*Add the municipal code to alcaldia 2011
merge m:1 departamento using ${data}\Elections\codepto.dta, nogen
merge m:1 coddpto municipio using ${data}\Elections\codmuni.dta, keep(1 3)

order departamento coddpto municipio codmpio 

*Fixing municipal codes
replace codmpio = 5148 in 113
replace codmpio = 5585 in 334
replace codmpio = 5697 in 429
replace codmpio = 5893 in 508
replace codmpio = 11001 in 637
replace codmpio = 13600 in 755
replace codmpio = 15572 in 1074
replace codmpio = 19517 in 1510
replace codmpio = 19532 in 1513
replace codmpio = 19760 in 1557
replace codmpio = 23670 in 1820
replace codmpio = 25662 in 2151
replace codmpio = 25843 in 2249
replace codmpio = 27150 in 2340
replace codmpio = 41378 in 2474
replace codmpio = 47161 in 2636
replace codmpio = 47170 in 2641
replace codmpio = 50711 in 2911
replace codmpio = 52019 in 2914
replace codmpio = 52203 in 2943
replace codmpio = 52258 in 2974
replace codmpio = 52435 in 3033
replace codmpio = 63302 in 3284
replace codmpio = 68235 in 3457
replace codmpio = 70230 in 3690
replace codmpio = 76111 in 4022
replace codmpio = 86573 in 4334

*Filling municipal codes
gen x=1 if codmpio!=.
sort municipio x
bys municipio: replace codmpio=codmpio[_n-1] if codmpio==.
drop x
keep coddpto municipio codmpio candidato codigo_partido1 votos

rename codigo_partido1 codigo_partido
gen year=2011

order year

tempfile 2011
save `2011', replace

*Prepare 2015 data
use ${data}\Elections\alcaldia2015, clear

rename ano year
keep year coddpto codmpio municipio codigo_partido1 primer_apellido segundo_apellido nombre votos curules
rename codigo_partido1 codigo_partido 
gen candidato=nombre+" "+primer_apellido+" "+segundo_apellido
keep year coddpto codmpio municipio codigo_partido candidato votos curules

tempfile 2015
save `2015', replace

*Append all the panel
use ${data}\Elections\alcaldia2000, clear
append using ${data}\Elections\alcaldia2003 ${data}\Elections\alcaldia2007
keep year coddpto codmpio municipio codigo_partido primer_apellido segundo_apellido nombre votos curules

gen candidato=nombre+" "+primer_apellido+" "+segundo_apellido

keep year coddpto codmpio municipio codigo_partido candidato votos curules

append using `2011' `2015'

*Renaming variables so we can use electoral classification.do
rename (votos codigo_partido curules candidato) (votes party_code seats candidate)  

*Fixing candidate 
replace candidate=trim(candidate)

*ordering the data set
sort codmpio year, stable


save elections_panel.dta, replace


*-------------------------------------------------------------------------------
* 					2. Preparing Maps Data 
*
*-------------------------------------------------------------------------------

*Converting Municipal shape file to dta data
shp2dta using ${maps}/Municipios\Municipios.shp, database(${data}\municipios.dta) coordinates(${data}\municipcoord.dta) genid(idmap) replace

use municipios.dta, clear
duplicates drop IDDANE, force 
rename IDDANE codmuni
save, replace 

*Converting Departament shape file to dta data
shp2dta using ${maps}\Departamentos\Departamentos.shp, database(${data}\departamentos.dta) coordinates(${data}\deptocoord.dta) genid(idmap2) replace

use departamentos.dta, clear 
rename COD_DANE_D codepto 
destring codepto, replace
save, replace


*-------------------------------------------------------------------------------
* 					3. Preparing Deforestation Data 
*
*-------------------------------------------------------------------------------
*Import the data and prepare it
forval y=2000/2018{
	import delimited ${data}\Deforestation\deforest`y'.csv, clear
	keep area_km2 iddane nmg loss*
	order iddane nmg area_km2
	rename (iddane nmg) (codmuni name_muni)
	duplicates drop codmuni, force 
	reshape long loss, i(codmuni) j(year)
	egen col_loss=sum(loss)
	replace col_loss=col_loss/1000000 
	save deforest`y'.dta, replace 
}

*Append the data 
use deforest2000.dta, clear 
  
forval y=2001/2018{
	append using deforest`y'.dta
	*erase deforest`y'.dta
}

sort codmuni year

*Municipal forest loss in KM2
gen loss_km2=loss/1000000  // We cannot use the year 2000 all loss is normalized using that year as a base.
gen x=loss_km2 if year==2000
bys codmuni: egen area00=mean(x)
replace loss_km2=. if year==2000

/*Outliers: 
*sum loss_km2, d
*tab name_muni if loss_km2>`r(p99)' & loss_km2<.
*tabstat loss_km2 if loss_km2>`r(p99)' & loss_km2<., by(name_muni) s(N mean sd min max)
*tabstat loss_km2 if loss_km2>`r(p99)' & loss_km2<., by(codmuni) s(N mean sd min max)
*tab year if loss_km2>`r(p99)' & loss_km2<.
*replace loss_km2=. if loss_km2<`r(p1)'
*replace loss_km2=. if loss_km2>`r(p99)'
*/

*share of forest loss 
gen loss_area00=loss_km2/area00

bys codmuni: egen total_loss=sum(loss_km2) if year!=2000
gen total_area00=total_loss/area00

*Colombian forest loss in KM2
gen y=col_loss if year==2000
bys codmuni: egen col_area00=mean(y) 
gen col_loss_area00=col_loss/col_area00

drop x y 

*Merging data with municipalities to plot maps
merge m:1 codmuni using municipios.dta, keep(3) nogen keepus(COD_DANE_D idmap)
rename COD_DANE_D codepto 
destring codepto, replace

*Merging data with departament name
merge m:1 codepto using departamentos, keep(1 3) nogen keepus(DEPTO)
rename DEPTO depto

*Coding missings for 2000 data (is the base)
replace loss_area00=. if year==2000
replace col_loss_area00=. if year==2000

*Declaring as panel data
tsset codmuni year

*Ordering and renaming 
rename (codmuni name_muni) (codmpio municipio) 
order idmap codepto depto codmpio municipio year area_km2 area00 loss loss_km2 ///
loss_area00 total_loss total_area00 col_area00 col_loss col_loss_area00

*Election year created with the actual period in power
gen year_elections=2000 if year>2000 & year<2004
replace year_elections=2003 if year<2008 & year_elections==. & year!=2000
replace year_elections=2007 if year<2012 & year_elections==. & year!=2000
replace year_elections=2011 if year<2016 & year_elections==. & year!=2000
replace year_elections=2015 if year>2015 & year_elections==. & year!=2000

tab year year_elections

*Organizing the data set
sort codepto codmpio year

*Labels 
la var idmap "ID for mapping"
la var codepto "Department DANE code"
la var depto "Department name"
la var codmpio "Municipality DANE code"
la var municipio "Municipality name"
la var year "Year"
la var area_km2 "Area in Km2"
la var area00 "Area in Km2 of 2000 (Hansen)"
la var loss "Yearly forest loss in m2 (Hansen)"
la var loss_km2 "Yearly forest loss in Km2 (Hansen)"
la var loss_area00 "Forest loss share (2000 base)"
la var total_loss "Total forest loss (2001-2018)"
la var total_area00 "Total forest loss share of 2000 area"
la var col_area00 "Country area in Km2 of 2000 (Hansen)"
la var col_loss "Country forest loss in Km2 (Hansen)"
la var col_loss_area00 "Forest loss share (2000 base)"
la var year_elections "Period of elections"

*saving the data set at the year level 
save forestloss_00_18.dta, replace 

*Deforestation at the election period level
collapse area00 (sum) loss_km2, by(codepto depto codmpio municipio year_elections idmap)
drop if year_election==.

*Loss in shares 
gen loss_area00=loss_km2/area00

*Labels 
la var idmap "ID for mapping"
la var codepto "Department DANE code"
la var depto "Department name"
la var codmpio "Municipality DANE code"
la var municipio "Municipality name"
la var area00 "Area in Km2 of 2000 (Hansen)"
la var loss_km2 "Yearly forest loss in Km2 (Hansen)"
la var loss_area00 "Forest loss share (2000 base)"

*Saving the data at the election year level
save elections_forestloss_00_18, replace 


*-------------------------------------------------------------------------------
*  						4. Elections & deforestation
*
*-------------------------------------------------------------------------------
*NOTE: not forget manual cleaning...... Also there are some weird duplicates (codmpio==47745 & year==2011) 

*OLD VERSION: use elections_panel_CLASFPART_16072019.dta, clear 

use elections_panel_CLASFPART_02122019.dta, clear

*Organizing the data set & renaming variables should be FOR NOW. 
rename (coddpto votos codigo_partido curules candidato) (codepto votes party_code seats candidate)  
order codepto codmpio municipio year party_code party votes seats

keep codepto-candidate ideology step

gsort codmpio year -votes

*Drop info with no party codes (white and null or unmarked votes)
table candidate year if party_code==.												// NOTE: fix MARTIN MIGUEL LAMBRANO MARSIGLIA.
drop if party_code==. 		

*Order of voting
bys codmpio year: egen rank=rank(votes), f

*Keeping the first two parties in the race (there can be 3)
keep if rank<3

*Total votes
bys codmpio year: egen total_votes=sum(votes)

*Winner's ideology data base
preserve 
	keep if rank==1
	
	gen sh_votes_winner=(votes/total_votes)-.5
	
	duplicates drop codmpio year, force
	
	sort codmpio year 
	
	bys codmpio: gen incumbent=1 if party_code==party_code[_n-1]
	replace incumbent=0 if incumbent==.
	
	isid codmpio year
	rename year year_elections

	save winner_ideology.dta, replace
restore 

*Left party in the race
gen x=1 if ideology==1
bys codmpio year: egen race_left=mean(x)

*Right party in the race
gen y=1 if ideology==2
bys codmpio year: egen race_right=mean(y)

drop x y 

*Share of votes of left party in close race (normalized to 0)
gen sh_votes_left=(votes/total_votes)-.5 if ideology==1

*Share of votes of right party in close race (normalized to 0)
gen sh_votes_right=(votes/total_votes)-.5 if ideology==2

*Left winner variable 
gen winner_left=(sh_votes_left>=0) if sh_votes_left!=.

*Right winner variable 
gen winner_right=(sh_votes_right>=0) if sh_votes_right!=.

*Creating data with info of close races in which left parties are involved
preserve 
	keep if sh_votes_left!=.
	duplicates tag codmpio year, g(dup)
	drop if winner_left==0 & dup==1
	drop dup
	
	isid codmpio year
	rename year year_elections
	
	save left_races_info.dta, replace
restore

*Creating data with info of close races in which right parties are involved
keep if sh_votes_right!=.
duplicates tag codmpio year, g(dup)
drop if winner_right==0 & dup==1
drop dup

isid codmpio year
rename year year_elections

save right_races_info.dta, replace


*-------------------------------------------------------------------------------
* 							5. CEDE panel 
*
*-------------------------------------------------------------------------------
use muni_generales.dta, clear
cap nois rename (coddepto ano) (codepto year)
save, replace

use muni_conflicto.dta, clear
cap nois rename ano year 
save, replace

*-------------------------------------------------------------------------------
* 							6. Environmental permits
*
*-------------------------------------------------------------------------------
import excel permits.xlsx, first clear
rename *, low
keep fechafinalizacion nombredepartamento nombremunicipio
rename (fechafinalizacion nombredepartamento nombremunicipio) (date departamento municipio)

*Dropping permits without date 													// NOTE: Can we look them up?
drop if date==.
 
*Year of permit
gen year=year(date)

*Fixing names before merging depto and codmpio codes 
replace departamento="BOGOTA D.C." if departamento=="BOGOTA  D. C."
replace departamento="CHOCO" if departamento=="CHOCÓ"
replace departamento="NORTE DE SAN" if departamento=="NORTE DE SANTANDER"
replace departamento="VALLE" if departamento=="VALLE DEL CAUCA"
replace departamento="CHOCO" if municipio=="DARIEN"
replace departamento="CALDAS" if municipio=="LA DORADA"

replace municipio="ARIGUANI (EL DIFICIL)" if municipio=="ARIGUANI"
replace municipio="ARIGUANI (EL DIFICIL)" if municipio=="ARIGUANÍ"
replace municipio="ALGARROBO" if municipio=="Algarrobo"
replace municipio="BARRANQUILLA" if municipio=="BARRANQUILLA URBANA"
replace municipio="BOGOTA" if municipio=="BOGOTA D.C."
replace municipio="BUGALAGRANDE" if municipio=="BUGA"
replace municipio="YONDO-CASABE" if municipio=="CASABE"
replace municipio="CHIBOLO" if municipio=="CHIVOLO"
replace municipio="COVENAS" if municipio=="COVEÑAS"
replace municipio="CARTAGENA" if municipio=="Cartagena Urbano"
replace municipio="CARMEN DEL DARIEN" if municipio=="DARIEN"
replace municipio="VALLE DEL GUAMUEZ (LA HORMIGA)" if municipio=="LA HORMIGA"
replace municipio="URIBE" if municipio=="LA URIBE"
replace municipio="LA PAZ" if municipio=="La Paz"
replace municipio="NUEVA GRANADA" if municipio=="Nueva Granada"
replace municipio="PARATEBUENO (LA NAGUAYA)" if municipio=="PARATEBUENO"
replace municipio="GUAPI" if municipio=="PARQUE NACIONAL NATURAL GORGONA"
replace municipio="PAZ DE ARIPORO (MORENO)" if municipio=="PAZ DE ARIPORO"
replace municipio="PIJINO DEL CARMEN" if municipio=="PIJIÑO DEL CARMEN"
replace municipio="PUERTO BOYACA (PUERTO VASQUEZ)" if municipio=="PUERTO BOYACA"
replace municipio="PURACE (COCONUCO)" if municipio=="PURACÉ"
replace municipio="PUERTO NARE-LA MAGDALENA" if municipio=="Puerto Nare"
replace municipio="QUIBDO" if municipio=="SAN FRANCISCO DE QUIBDO"
replace municipio="ISNOS" if municipio=="SAN JOSE DE ISNOS"
replace municipio="PASTO" if municipio=="SAN JUAN DE PASTO"

replace municipio="SAN MARTIN DE LOS LLANOS" if municipio=="SAN MARTIN" & departamento=="META"
replace municipio="SAN VICENTE DE CHUCURI" if municipio=="SAN VICENTE CHUCURI"
replace municipio="CALI" if municipio=="SANTIAGO DE CALI"
replace municipio="TESALIA (CARNICERIAS)" if municipio=="TESALIA"
replace municipio="VALLE DEL GUAMUEZ (LA HORMIGA)" if municipio=="Valle del Guamuez"
replace municipio="YONDO-CASABE" if municipio=="YONDO"

*Add the municipal code to alcaldia 2011
merge m:1 departamento using ${data}\Elections\codepto.dta, keep(1 3) nogen  	//NOTE: There are not permits in GUAINIA?
merge m:1 coddpto municipio using ${data}\Elections\codmuni.dta, keep(1 3) nogen

*Number of permits by year and municipio
gen permits=1
collapse (sum) permits, by(coddpto municipio codmpio year)

*Fixing errors
replace year=2012 if year==2022

*Ordering the data 
order coddpto codmpio municipio year
sort codmpio year


save permits.dta, replace


*-------------------------------------------------------------------------------
* 		6. Elections & Deforestation at the year level data set
*
*-------------------------------------------------------------------------------
use forestloss_00_18.dta, clear

*Merging municipal characteristics
merge 1:1 codmpio year using muni_generales.dta, keep(1 3) nogen keepus(indrural altura discapital disbogota dismdo gandina gcaribe gpacifica gorinoquia gamazonia)

*Merging conflict variables
merge 1:1 codmpio year using muni_conflicto.dta, keep(1 3) nogen keepus(H_coca lotes_coca coca)

*Merging permits 
merge 1:1 codmpio year using permits.dta, keep(1 3) nogen

*Merging races with left parties info
merge m:1 codmpio year_elections using left_races_info.dta, keep(1 3) keepus(race_left sh_votes_left winner_left) nogen

*Merging races with right parties info
merge m:1 codmpio year_elections using right_races_info.dta, keep(1 3) keepus(race_right sh_votes_right winner_right) nogen

*Share of coca 
gen km2_coca=H_coca/100
gen sh_coca=km2_coca/area00
replace sh_coca=0 if sh_coca==.

sort codmpio year 

*Variables by election year
gl vars "indrural altura discapital disbogota coca km2_coca sh_coca lotes_coca"
foreach var of global vars{
	gen x=`var' if year==2000 | year==2003 | year==2007 | year==2011 | year==2015
	replace x=x[_n-1] if year==2001 | year==2004 | year==2008 | year==2012 | year==2016
	replace x=. if year==2000 | year==2003 | year==2007 | year==2011 | year==2015
	replace x=x[_n-1] if x==.
	
	replace `var'=x
	drop x
}

*Capital city
tostring codmpio, replace
gen length=length(codmpio)
replace codmpio="0"+codmpio if length==4
gen capital=substr(codmpio,3,3)
destring capital, replace
replace capital=(capital==1)

drop length 

*Labeling
la var indrural "Rural index"
la var altura "Altitude"
la var discapital "Distance to departamental capital"
la var disbogota "Distance to Bogota"
la var coca "Coca (dummy)"
la var km2_coca "Coca (Km2)"
la var sh_coca "Coca share (2000 base)"
la var lotes_coca "Number of coca fields"
la var permits "Evironmental permits (ANLA)"
la var sh_votes_left "Share of votes for left"
la var sh_votes_right "Share of votes for right"
la var gandina "Region Andina"
la var gcaribe "Region Caribe"
la var gpacifica "Region Pacifica"
la var gorinoquia "Region Orinoquia"
la var gamazonia "Region Amazonia"

*Ordering the data
sort codmpio year 

save forestloss_00_18_races.dta, replace


*-------------------------------------------------------------------------------
* 		6. Elections & Deforestation at the election year level data set
*
*-------------------------------------------------------------------------------
use elections_forestloss_00_18, clear 

*Merging races with left parties info
merge 1:1 codmpio year_elections using left_races_info.dta, keep(1 3) keepus(race_left sh_votes_left winner_left) nogen

*Merging races with right parties info
merge 1:1 codmpio year_elections using right_races_info.dta, keep(1 3) keepus(race_right sh_votes_right winner_right) nogen

*Renaming to merge municipal characteristics
rename year_election year

*Merging municipal characteristics
merge 1:1 codmpio year using muni_generales.dta, keep(1 3) nogen keepus(indrural altura discapital disbogota dismdo gandina gcaribe gpacifica gorinoquia gamazonia pobl_tot)

*Merging conflict variables
merge 1:1 codmpio year using muni_conflicto.dta, keep(1 3) nogen keepus(H_coca lotes_coca coca)

*Share of coca 
gen km2_coca=H_coca/100
gen sh_coca=km2_coca/area00
replace sh_coca=0 if sh_coca==.

rename year year_election

*Capital city
tostring codmpio, replace
gen length=length(codmpio)
replace codmpio="0"+codmpio if length==4
gen capital=substr(codmpio,3,3)
destring capital, replace
replace capital=(capital==1)

drop length 

*Labeling
la var indrural "Rural index"
la var altura "Altitude"
la var discapital "Distance to departamental capital"
la var disbogota "Distance to Bogota"
la var coca "Coca (dummy)"
la var km2_coca "Coca (Km2)"
la var sh_coca "Coca share (2000 base)"
la var lotes_coca "Number of coca fields"
*la var permits "Evironmental permits (ANLA)"
la var sh_votes_left "Share of votes for left"
la var sh_votes_right "Share of votes for right"
la var gandina "Region Andina"
la var gcaribe "Region Caribe"
la var gpacifica "Region Pacifica"
la var gorinoquia "Region Orinoquia"
la var gamazonia "Region Amazonia"

*Ordering the data
sort codmpio year_election 

save elections_forestloss_00_18_races.dta, replace







*log c




*END


