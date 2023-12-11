/*------------------------------------------------------------------------------
PROJECT: 
AUTHOR: JMJR
TOPIC: 
DATE:

NOTES: I HAVE TO CREATE  MEASURE OF ALLIANCE WITH THE MOST POWERFUL PARTY!!!!!!!!
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
* TWFE Estimation
*
*-------------------------------------------------------------------------------
use "${data}/Interim\defo_caralc.dta", clear

*Labels
label var floss "Total Forest Loss (Km2)"
label var floss_area "Share of Forest Loss"
label var floss_prim00p1 "Share of Primary Forest Loss"

*Keeping the CAR in the south of the country
gen deptokeep=.
levelsof code, local(indeptos)
foreach x of local indeptos{
	dis "`x'"
	replace deptokeep=1 if codepto==`x'
} 
replace deptokeep=0 if deptokeep==.
*keep if deptokeep==1
*keep if year<2016

keep if merge_carcom==3

*-------------------------------------------------------------------------------
* Preparing vars of interest
*-------------------------------------------------------------------------------
sort coddane year, stable

*Creating variable of mayor in the CAR's board 
gen mayorinbrd=(codigo_partido_caralc!=.)

*Creating variable of mayor allied with the gobernor in CAR's board
gen mayorallied=(codigo_partido==codigo_partido_cargob) if codigo_partido_cargob!=.

*Extending to other municipalities under the same CAR
bys codepto year: egen dcarcode=mean(carcode)
*bys dcarcode year: egen dsh_politics=mean(sh_politics)
bys dcarcode year: egen dsh_party=mean(sh_same_party)

*FIX THIS WITH STATUTORY DEFAULT
*sort coddane year, stable
*bys coddane: replace dsh_politics=dsh_politics[_n-1] if dsh_politics==.

*Dummy if politics have the power in the CAR
gen dsh_politics=sh_politics
summ dsh_politics, d
gen dmdn_politics = (dsh_politics>=`r(p50)') if dsh_politics!=.

summ sh_same_party_gob, d
gen dmdn_sameparty_gob = (sh_same_party_gob>=`r(p50)') if sh_same_party_gob!=.

*-------------------------------------------------------------------------------
* Regressions of Mayor allied
*-------------------------------------------------------------------------------
gen myrallied_dsh_politics=mayorallied*dsh_politics
gen myrallied_dmdn_politics=mayorallied*dmdn_politics

gen myrallied_dsh_sameparty_gob=mayorallied*sh_same_party_gob
gen myrallied_dmdn_sameparty_gob=mayorallied*dmdn_sameparty_gob

la var dsh_politics "Share of Politicians"
la var dmdn_politics "I(Politicians majority)"
la var mayorallied "Party alignment"
la var myrallied_dsh_politics "Alignment $\times$ Politicians share"
la var myrallied_dmdn_politics "Alignment $\times$ I(Politicians majority)"

*Erasing files 
cap erase "${tables}\floss_mayorallied.tex"
cap erase "${tables}\floss_mayorallied.txt"
cap erase "${tables}\floss_area_mayorallied.tex"
cap erase "${tables}\floss_area_mayorallied.txt"
cap erase "${tables}\floss_prim00p1_mayorallied.tex"
cap erase "${tables}\floss_prim00p1_mayorallied.txt"

*floss_area floss_prim00p1
foreach var in floss floss_area floss_prim00p1{

	*Simple Difference
	reghdfe `var' mayorallied c.fprim00_p1#i.year c.area#i.year, noabs vce(robust)
	summ `var' if e(sample)==1, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}/`var'_mayorallied.tex", tex(frag) keep(mayorallied) addtext("Year FE", "No", "Muni FE", "No" ) addstat("Dependent mean", ${mean_y}) label nonote nocons append 
	
	*Year FEs
	reghdfe `var' mayorallied c.fprim00_p1#i.year c.area#i.year, a(year) vce(robust)
	summ `var' if e(sample)==1, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}/`var'_mayorallied.tex", tex(frag) keep(mayorallied) addtext("Year FE", "Yes", "Muni FE", "No" ) addstat("Dependent mean", ${mean_y}) label nonote nocons append 
	
	*TWFEs
	reghdfe `var' mayorallied c.fprim00_p1#i.year c.area#i.year, a(year coddane) vce(robust)
	summ `var' if e(sample)==1, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}/`var'_mayorallied.tex", tex(frag) keep(mayorallied) addtext("Year FE", "Yes", "Muni FE", "Yes" ) addstat("Dependent mean", ${mean_y}) label nonote nocons append 
	
	*TWFE + share of politicians in comitte (continuous)
	reghdfe `var' mayorallied dsh_politics myrallied_dsh_politics c.fprim00_p1#i.year c.area#i.year , a(year coddane) vce(robust)
	summ `var' if e(sample)==1, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}/`var'_mayorallied.tex", tex(frag) keep(mayorallied dsh_politics myrallied_dsh_politics) addtext("Year FE", "Yes", "Muni FE", "Yes" ) addstat("Dependent mean", ${mean_y}) label nonote nocons append 
		
	*TWFE + share of politicians in comitte (dichotomous)
	reghdfe `var' mayorallied dmdn_politics myrallied_dmdn_politics c.fprim00_p1#i.year c.area#i.year, a(year coddane) vce(robust)
	summ `var' if e(sample)==1, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}/`var'_mayorallied.tex", tex(frag) keep(mayorallied dmdn_politics myrallied_dmdn_politics) addtext("Year FE", "Yes", "Muni FE", "Yes" ) addstat("Dependent mean", ${mean_y}) label nonote nocons append 
	
}

*-------------------------------------------------------------------------------
* Regressions of Mayor allied + Clusters
*-------------------------------------------------------------------------------

*Erasing files 
cap erase "${tables}\floss_mayorallied_cl.tex"
cap erase "${tables}\floss_mayorallied_cl.txt"
cap erase "${tables}\floss_area_mayorallied_cl.tex"
cap erase "${tables}\floss_area_mayorallied_cl.txt"
cap erase "${tables}\floss_prim00p1_mayorallied_cl.tex"
cap erase "${tables}\floss_prim00p1_mayorallied_cl.txt"

foreach var in floss floss_area floss_prim00p1{

	*Simple Difference
	tsset, clear
	bootstrap, reps(50) seed(783) cluster(carcode_master): reghdfe `var' mayorallied c.fprim00_p1#i.year c.area#i.year, noabs vce(cluster carcode_master)
	summ `var' if e(sample)==1, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}/`var'_mayorallied_cl.tex", tex(frag) keep(mayorallied) addtext("Year FE", "No", "Muni FE", "No" ) addstat("Dependent mean", ${mean_y}) label nonote nocons append 
	
	*Year FEs
	tsset, clear
	bootstrap, reps(50) seed(783) cluster(carcode_master): reghdfe `var' mayorallied c.fprim00_p1#i.year c.area#i.year, a(year) vce(cluster carcode_master)
	summ `var' if e(sample)==1, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}/`var'_mayorallied_cl.tex", tex(frag) keep(mayorallied) addtext("Year FE", "Yes", "Muni FE", "No" ) addstat("Dependent mean", ${mean_y}) label nonote nocons append 
	
	*TWFEs
	tsset, clear
	bootstrap, reps(50) seed(783) cluster(carcode_master): reghdfe `var' mayorallied c.fprim00_p1#i.year c.area#i.year, a(year coddane) vce(cluster carcode_master)
	summ `var' if e(sample)==1, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}/`var'_mayorallied_cl.tex", tex(frag) keep(mayorallied) addtext("Year FE", "Yes", "Muni FE", "Yes" ) addstat("Dependent mean", ${mean_y}) label nonote nocons append 
	
	*TWFE + share of politicians in comitte (continuous)
	tsset, clear
	bootstrap, reps(50) seed(783) cluster(carcode_master): reghdfe `var' mayorallied dsh_politics myrallied_dsh_politics c.fprim00_p1#i.year c.area#i.year, a(year coddane) vce(cluster carcode_master)
	summ `var' if e(sample)==1, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}/`var'_mayorallied_cl.tex", tex(frag) keep(mayorallied dsh_politics myrallied_dsh_politics) addtext("Year FE", "Yes", "Muni FE", "Yes" ) addstat("Dependent mean", ${mean_y}) label nonote nocons append 
		
	*TWFE + share of politicians in comitte (dichotomous)
	tsset, clear
	bootstrap, reps(50) seed(783) cluster(carcode_master): reghdfe `var' mayorallied dmdn_politics myrallied_dmdn_politics c.fprim00_p1#i.year c.area#i.year, a(year coddane) vce(cluster carcode_master)
	summ `var' if e(sample)==1, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}/`var'_mayorallied_cl.tex", tex(frag) keep(mayorallied dmdn_politics myrallied_dmdn_politics) addtext("Year FE", "Yes", "Muni FE", "Yes" ) addstat("Dependent mean", ${mean_y}) label nonote nocons append 
	
}

/*-------------------------------------------------------------------------------
* Regressions of Mayor in Board
*-------------------------------------------------------------------------------
gen myrinbrd_dsh_politics=mayorinbrd*dsh_politics
gen myrinbrd_dmdn_politics=mayorinbrd*dmdn_politics

la var mayorinbrd "Mayor in committee"
la var myrinbrd_dsh_politics "In committee \times Politicians share"
la var myrinbrd_dmdn_politics "In committee \times I(Politicians majority)"

*Erasing files 
cap erase "${tables}\floss_mayorinbrd.tex"
cap erase "${tables}\floss_mayorinbrd.txt"
cap erase "${tables}\floss_area_mayorinbrd.tex"
cap erase "${tables}\floss_area_mayorinbrd.txt"
cap erase "${tables}\floss_prim00p1_mayorinbrd.tex"
cap erase "${tables}\floss_prim00p1_mayorinbrd.txt"

foreach var in floss floss_area floss_prim00p1{

	*Simple Difference
	reghdfe `var' mayorinbrd, noabs vce(robust)
	summ `var' if e(sample)==1, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}/`var'_mayorinbrd.tex", tex(frag) addtext("Year FE", "No", "Muni FE", "No" ) addstat("Dependent mean", ${mean_y}) label nonote nocons append 
	
	*Year FEs
	reghdfe `var' mayorinbrd, a(year) vce(robust)
	summ `var' if e(sample)==1, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}/`var'_mayorinbrd.tex", tex(frag) addtext("Year FE", "Yes", "Muni FE", "No" ) addstat("Dependent mean", ${mean_y}) label nonote nocons append 
	
	*TWFEs
	reghdfe `var' mayorinbrd, a(year coddane) vce(robust)
	summ `var' if e(sample)==1, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}/`var'_mayorinbrd.tex", tex(frag) addtext("Year FE", "Yes", "Muni FE", "Yes" ) addstat("Dependent mean", ${mean_y}) label nonote nocons append 
	
	*TWFE + share of politicians in comitte (continuous)
	reghdfe `var' mayorinbrd dsh_politics myrinbrd_dsh_politics, a(year coddane) vce(robust)
	summ `var' if e(sample)==1, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}/`var'_mayorinbrd.tex", tex(frag) addtext("Year FE", "Yes", "Muni FE", "Yes" ) addstat("Dependent mean", ${mean_y}) label nonote nocons append 
		
	*TWFE + share of politicians in comitte (dichotomous)
	reghdfe `var' mayorinbrd dmdn_politics myrinbrd_dmdn_politics, a(year coddane) vce(robust)
	summ `var' if e(sample)==1, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}/`var'_mayorinbrd.tex", tex(frag) addtext("Year FE", "Yes", "Muni FE", "Yes" ) addstat("Dependent mean", ${mean_y}) label nonote nocons append 
	
}




*END
