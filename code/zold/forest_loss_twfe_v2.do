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
*gen dmdn_politics = (dsh_politics>=`r(p50)') if dsh_politics!=.

gen dmdn_politics = (dsh_politics>=.5) if dsh_politics!=.
bys carcode_master: egen mode_dmd_pol=mode(dsh_politics), maxmode

tab carcode_master mode_dmd_pol

summ sh_same_party_gob, d
gen dmdn_sameparty_gob = (sh_same_party_gob>=`r(p50)') if sh_same_party_gob!=.

*
gen mayorallied_wanypol=.
forval i=1/19{
	replace mayorallied_wanypol=1 if codigo_partido==codigo_partido_carpol`i' & codigo_partido_carpol`i'!=.
}

replace mayorallied_wanypol=0 if mayorallied_wanypol==. & mayorallied_wanypol!=1 & codigo_partido!=.

*-------------------------------------------------------------------------------
* Regressions of Mayor allied
*-------------------------------------------------------------------------------
gen myrallied_dsh_politics=mayorallied*dsh_politics
gen myrallied_dmdn_politics=mayorallied*dmdn_politics
gen myrallied_dmdn_politics2=mayorallied*mode_dmd_pol

gen myrallied_dsh_sameparty_gob=mayorallied*sh_same_party_gob
gen myrallied_dmdn_sameparty_gob=mayorallied*dmdn_sameparty_gob

gen myrinbrd_dsh_politics=mayorinbrd*dsh_politics
gen myrinbrd_dmdn_politics=mayorinbrd*dmdn_politics




gen myrallied_any_dmdn_politics=mayorallied_wanypol*dmdn_politics

la var dsh_politics "Share of Politicians"
la var dmdn_politics "I(Politicians majority)"
la var mayorallied "Party alignment"
la var myrallied_dsh_politics "Alignment $\times$ Politicians share"
la var myrallied_dmdn_politics "Alignment $\times$ I(Politicians majority)"
la var mayorinbrd "Mayor in board"
la var myrinbrd_dsh_politics "In board \times Politicians share"
la var myrinbrd_dmdn_politics "In board \times I(Politicians majority)"


reghdfe floss_area mayorallied dmdn_politics myrallied_dmdn_politics, a(year coddane) vce(robust)


reghdfe floss_area mayorallied mode_dmd_pol myrallied_dmdn_politics2, a(year coddane) vce(robust)





*Erasing files 
cap erase "${tables}\floss_mayorallied_inbrd.tex"
cap erase "${tables}\floss_mayorallied_inbrd.txt"
cap erase "${tables}\floss_area_mayorallied_inbrd.tex"
cap erase "${tables}\floss_area_mayorallied_inbrd.txt"
cap erase "${tables}\floss_prim00p1_mayorallied_inbrd.tex"
cap erase "${tables}\floss_prim00p1_mayorallied_inbrd.txt"

*floss_area floss_prim00p1
foreach var in floss floss_area floss_prim00p1{
	
	*TWFEs mayorinbd
	reghdfe `var' mayorinbrd, a(year coddane) vce(robust)
	summ `var' if e(sample)==1, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}/`var'_mayorallied_inbrd.tex", tex(frag) addtext("Year FE", "Yes", "Muni FE", "Yes" ) addstat("Dependent mean", ${mean_y}) label nonote append 
	
	*TWFEs mayorallied
	reghdfe `var' mayorallied, a(year coddane) vce(robust)
	summ `var' if e(sample)==1, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}/`var'_mayorallied_inbrd.tex", tex(frag) addtext("Year FE", "Yes", "Muni FE", "Yes" ) addstat("Dependent mean", ${mean_y}) label nonote append 
	

	*TWFE + share of politicians in comitte (dichotomous)
	reghdfe `var' mayorallied dmdn_politics myrallied_dmdn_politics, a(year coddane) vce(robust)
	summ `var' if e(sample)==1, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}/`var'_mayorallied_inbrd.tex", tex(frag) addtext("Year FE", "Yes", "Muni FE", "Yes" ) addstat("Dependent mean", ${mean_y}) label nonote append sortvar(mayorinbrd mayorallied dmdn_politics myrallied_dmdn_politics _cons)
	
}

foreach var in floss floss_area floss_prim00p1{
	
	*Mayor gov allied
	mat C=J(3,4,.)

	reghdfe `var' mayorallied dmdn_politics myrallied_dmdn_politics, a(year coddane) vce(robust)

	lincom _cons
	mat C[1,1]= r(estimate) 
	mat C[2,1]= r(lb)
	mat C[3,1]= r(ub)

	lincom mayorallied +_cons
	mat C[1,2]= r(estimate) 
	mat C[2,2]= r(lb)
	mat C[3,2]= r(ub)

	lincom dmdn_politics +_cons
	mat C[1,3]= r(estimate) 
	mat C[2,3]= r(lb)
	mat C[3,3]= r(ub)

	lincom mayorallied + dmdn_politics + myrallied_dmdn_politics +_cons
	mat C[1,4]= r(estimate) 
	mat C[2,4]= r(lb)
	mat C[3,4]= r(ub)

	mat coln C = "No-Alignment + Minority" "Alignment + Minority" "No-Alignment + Mayority" "Alignment + Mayority"
	
	local varlabel : variable label `var' 
	coefplot (mat(C[1]), ci((2 3))), xtitle("Effect on `varlabel'")
	gr export "${plots}/coefplot_did_mayor_gov_allied_`var'.pdf", as(pdf) replace
		
	*Mayor and any politician allied
	mat C=J(3,4,.)

	reghdfe `var' mayorallied_wanypol dmdn_politics myrallied_any_dmdn_politics, a(year coddane) vce(robust)

	lincom _cons
	mat C[1,1]= r(estimate) 
	mat C[2,1]= r(lb)
	mat C[3,1]= r(ub)

	lincom mayorallied_wanypol +_cons
	mat C[1,2]= r(estimate) 
	mat C[2,2]= r(lb)
	mat C[3,2]= r(ub)

	lincom dmdn_politics +_cons
	mat C[1,3]= r(estimate) 
	mat C[2,3]= r(lb)
	mat C[3,3]= r(ub)

	lincom mayorallied_wanypol + dmdn_politics + myrallied_any_dmdn_politics +_cons
	mat C[1,4]= r(estimate) 
	mat C[2,4]= r(lb)
	mat C[3,4]= r(ub)

	mat coln C = "No-Alignment + Minority" "Alignment + Minority" "No-Alignment + Mayority" "Alignment + Mayority"
	
	local varlabel : variable label `var' 
	coefplot (mat(C[1]), ci((2 3))), xtitle("Effect on `varlabel'")
	gr export "${plots}/coefplot_did_mayor_anypol_allied_`var'.pdf", as(pdf) replace

	*Mayor in the board
	mat C=J(3,4,.)

	reghdfe `var' mayorinbrd dmdn_politics myrinbrd_dmdn_politics, a(year coddane) vce(robust)

	lincom _cons
	mat C[1,1]= r(estimate) 
	mat C[2,1]= r(lb)
	mat C[3,1]= r(ub)

	lincom mayorinbrd +_cons
	mat C[1,2]= r(estimate) 
	mat C[2,2]= r(lb)
	mat C[3,2]= r(ub)

	lincom dmdn_politics +_cons
	mat C[1,3]= r(estimate) 
	mat C[2,3]= r(lb)
	mat C[3,3]= r(ub)

	lincom mayorinbrd + dmdn_politics + myrinbrd_dmdn_politics +_cons
	mat C[1,4]= r(estimate) 
	mat C[2,4]= r(lb)
	mat C[3,4]= r(ub)

	mat coln C = "No-Board + Minority" "In-Board + Minority" "No-Board + Mayority" "In-Board + Mayority"
	
	local varlabel : variable label `var' 
	coefplot (mat(C[1]), ci((2 3))), xtitle("Effect on `varlabel'")
	gr export "${plots}/coefplot_did_mayor_inboard_`var'.pdf", as(pdf) replace

}


		

*END