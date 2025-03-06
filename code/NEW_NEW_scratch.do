
use "${data}/Interim\defo_caralc.dta", clear

keep if year>2000 & year<2021
drop if carcode_master==12 // San andres y providencia

*-------------------------------------------------------------------------------
* Descriptives
*
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
* Basics
*-------------------------------------------------------------------------------
*Time spam:
tab year //(2001-2020)

*Municipalities 
unique coddane if politics!=. //(619 out of 1123 ~ 50%)

*Cars
unique carcode_master if politics!=. //(19 of 33 ~ 57%)

*-------------------------------------------------------------------------------
* Deforestation by CAR
*-------------------------------------------------------------------------------
tabstat floss_prim_ideam if sh_politics!=., by(carcode_master) s(N mean sd min p25 p50 p75 max) save
tabstatmat S

mata: st_matrix("R", st_matrix("S")); st_matrixrowstripe("S", J(0,2,""))

mat colnames R = "N" "Mean" "SD" "Min" "p25" "p50" "p75" "Max"
mat rownames R = "CAM" "CAR" "CARDER" "CARDIQUE" "CDA" "CORANTIOQUIA" "CORMACARENA" "CORNARE" "CORPAMAG" "CORPOAMAZONIA" "CORPOCALDAS" "CORPOCESAR" "CORPOCHIVOR" "CORPOGUAVIO" "CORPOMOJANA" "CORPORINOQUIA" "CORTOLIMA" "CVC" "Total"

tempfile X X1
frmttable using `X', statmat(R) sdec(0,3) fragment tex nocenter 
filefilter `X' "${tables}\floss_prim_ideam_per_CAR.tex", from("r}\BS\BS") to("r}") replace 

tabstat floss_prim_ideam_area if sh_politics!=., by(carcode_master) s(N mean sd min p25 p50 p75 max) save
tabstatmat S

mata: st_matrix("R", st_matrix("S")); st_matrixrowstripe("S", J(0,2,""))

mat colnames R = "N" "Mean" "SD" "Min" "p25" "p50" "p75" "Max"
mat rownames R = "CAM" "CAR" "CARDER" "CARDIQUE" "CDA" "CORANTIOQUIA" "CORMACARENA" "CORNARE" "CORPAMAG" "CORPOAMAZONIA" "CORPOCALDAS" "CORPOCESAR" "CORPOCHIVOR" "CORPOGUAVIO" "CORPOMOJANA" "CORPORINOQUIA" "CORTOLIMA" "CVC" "Total"

tempfile X X1
frmttable using `X', statmat(R) sdec(0,3) fragment tex nocenter 
filefilter `X' "${tables}\floss_prim_ideam_area_per_CAR.tex", from("r}\BS\BS") to("r}") replace 

*-------------------------------------------------------------------------------
* Composition Mandated by law for all CARs
*-------------------------------------------------------------------------------
foreach var in sh_politics sh_politics2 sh_ethnias sh_private sh_envngo sh_academics {
	
	gen diff_`var' = `var'- `var'_law	
	
	two (hist `var', frac color(gray)) (hist `var'_law, frac fcolor(none) lcolor(black))  
	gr export "${plots}/hist_realvslaw_`var'.pdf", as(pdf) replace
	
	hist diff_`var', frac
	gr export "${plots}/hist_diff_`var'.pdf", as(pdf) replace

}

two (kdensity diff_sh_politics) (kdensity diff_sh_politics2) (kdensity diff_sh_ethnias) (kdensity diff_sh_private) (kdensity diff_sh_envngo) (kdensity diff_sh_academics)
gr export "${plots}/hist_diff_sh_all.pdf", as(pdf) replace

*-------------------------------------------------------------------------------
* Composition Mandated by CAR 
*-------------------------------------------------------------------------------
foreach var in sh_politics sh_politics2 sh_ethnias sh_private sh_envngo sh_academics {
	
	tabstat `var' if `var'!=., by(carcode_master) s(N mean sd min p25 p50 p75 max) save
	tabstatmat S

	mata: st_matrix("R", st_matrix("S")); st_matrixrowstripe("S", J(0,2,""))

	mat colnames R = "N" "Mean" "SD" "Min" "p25" "p50" "p75" "Max"
	mat rownames R = "CAM" "CAR" "CARDER" "CARDIQUE" "CDA" "CORANTIOQUIA" "CORMACARENA" "CORNARE" "CORPAMAG" "CORPOAMAZONIA" "CORPOCALDAS" "CORPOCESAR" "CORPOCHIVOR" "CORPOGUAVIO" "CORPOMOJANA" "CORPORINOQUIA" "CORTOLIMA" "CVC" "Total"

	tempfile X X1
	frmttable using `X', statmat(R) sdec(0,3) fragment tex nocenter 
	filefilter `X' "${tables}/`var'_per_CAR.tex", from("r}\BS\BS") to("r}") replace 

}

foreach var in sh_politics sh_politics2 sh_ethnias sh_private sh_envngo sh_academics {
	
	tabstat diff_`var' if diff_`var'!=., by(carcode_master) s(N mean sd min p25 p50 p75 max) save
	tabstatmat S

	mata: st_matrix("R", st_matrix("S")); st_matrixrowstripe("S", J(0,2,""))

	mat colnames R = "N" "Mean" "SD" "Min" "p25" "p50" "p75" "Max"
	mat rownames R = "CAM" "CAR" "CARDER" "CARDIQUE" "CDA" "CORANTIOQUIA" "CORMACARENA" "CORNARE" "CORPAMAG" "CORPOAMAZONIA" "CORPOCALDAS" "CORPOCESAR" "CORPOCHIVOR" "CORPOGUAVIO" "CORPOMOJANA" "CORPORINOQUIA" "CORTOLIMA" "CVC" "Total"

	tempfile X X1
	frmttable using `X', statmat(R) sdec(0,3) fragment tex nocenter 
	filefilter `X' "${tables}\diff_`var'_per_CAR.tex", from("r}\BS\BS") to("r}") replace 

}

*-------------------------------------------------------------------------------
* Correlations to think 
*-------------------------------------------------------------------------------
cap erase "${tables}\corr_floss_prim_ideam_area_mayorvars.tex"
cap erase "${tables}\corr_floss_prim_ideam_area_mayorvars.txt"
cap erase "${tables}\corr_floss_prim_ideam_area_shvars.tex"
cap erase "${tables}\corr_floss_prim_ideam_area_shvars.txt"
cap erase "${tables}\corr_floss_prim_ideam_area_shvars_law.tex"
cap erase "${tables}\corr_floss_prim_ideam_area_shvars_law.txt"
cap erase "${tables}\corr_floss_prim_ideam_area_diffshvars.tex"
cap erase "${tables}\corr_floss_prim_ideam_area_diffshvars.txt"

foreach var in mayorinbrd mayorallied mayorallied_wanypol {
	
	reghdfe floss_prim_ideam_area `var', a(year coddane) vce(robust)
	outreg2 using "${tables}/corr_floss_prim_ideam_area_mayorvars.tex", tex(frag) addtext("Year FE", "Yes", "Muni FE", "Yes" ) nonote append 
	
}

foreach var in sh_politics sh_politics2 sh_ethnias sh_private sh_envngo sh_academics {
	
	reghdfe floss_prim_ideam_area `var', a(year coddane) vce(robust)
	outreg2 using "${tables}/corr_floss_prim_ideam_area_shvars.tex", tex(frag) addtext("Year FE", "Yes", "Muni FE", "Yes" ) nonote append 
	
	reghdfe floss_prim_ideam_area `var'_law, a(year) vce(robust)
	outreg2 using "${tables}/corr_floss_prim_ideam_area_shvars_law.tex", tex(frag) addtext("Year FE", "Yes", "Muni FE", "Yes" ) nonote append 
	
	reghdfe floss_prim_ideam_area diff_`var', a(year coddane) vce(robust)
	outreg2 using "${tables}/corr_floss_prim_ideam_area_diffshvars.tex", tex(frag) addtext("Year FE", "Yes", "Muni FE", "Yes" ) nonote append 
}

*-------------------------------------------------------------------------------
* REGRESSIONS: 
*
*-------------------------------------------------------------------------------
*Political power vars 
gen dmdn_politics = (sh_politics>=.5) if sh_politics!=.
gen dmdn_politics_law = (sh_politics_law>=.5) if sh_politics!=.

*Interactions
gen mayorinbrd_dmdn_politics=dmdn_politics*mayorinbrd
gen mayorinbrd_sh_politics=sh_politics*mayorinbrd

gen myrallied_dmdn_politics=mayorallied*dmdn_politics
gen myrallied_sh_politics=mayorallied*sh_politics
gen myrallied_diff_sh_politics=mayorallied*diff_sh_politics

gen myrallied_dmdn_politics_law=mayorallied*dmdn_politics_law

*-------------------------------------------------------------------------------
* TWFE: 
*-------------------------------------------------------------------------------
*Partisan allignment 
foreach yvar in floss_prim_ideam floss_prim_ideam_area {
	
	reghdfe `yvar' mayorallied if dmdn_politics!=., a(year coddane) vce(robust)
	outreg2 using "${tables}/twfe_`yvar'_mayorallied.tex", tex(frag) addtext("Year FE", "Yes", "Muni FE", "Yes", "Majority", "Full") nonote replace 
	
	reghdfe `yvar' mayorallied dmdn_politics, a(year coddane) vce(robust)
	outreg2 using "${tables}/twfe_`yvar'_mayorallied.tex", tex(frag) addtext("Year FE", "Yes", "Muni FE", "Yes", "Majority", "Full") nonote append 
	
	reghdfe `yvar' mayorallied dmdn_politics myrallied_dmdn_politics, a(year coddane) vce(robust)
	outreg2 using "${tables}/twfe_`yvar'_mayorallied.tex", tex(frag) addtext("Year FE", "Yes", "Muni FE", "Yes", "Majority", "Full") nonote append 
	
	reghdfe `yvar' mayorallied if dmdn_politics==0, a(year coddane) vce(robust)
	outreg2 using "${tables}/twfe_`yvar'_mayorallied.tex", tex(frag) addtext("Year FE", "Yes", "Muni FE", "Yes", "Majority", "No") nonote append 
	
	reghdfe `yvar' mayorallied if dmdn_politics==1, a(year coddane) vce(robust)
	outreg2 using "${tables}/twfe_`yvar'_mayorallied.tex", tex(frag) addtext("Year FE", "Yes", "Muni FE", "Yes", "Majority", "Yes") nonote append 


}
	
*Mayor in board
foreach yvar in floss_prim_ideam floss_prim_ideam_area {
	
	reghdfe `yvar' mayorinbrd if dmdn_politics!=., a(year coddane) vce(robust)
	outreg2 using "${tables}/twfe_`yvar'_mayorinbrd.tex", tex(frag) addtext("Year FE", "Yes", "Muni FE", "Yes", "Majority", "Full") nonote replace 
	
	reghdfe `yvar' mayorinbrd dmdn_politics, a(year coddane) vce(robust)
	outreg2 using "${tables}/twfe_`yvar'_mayorinbrd.tex", tex(frag) addtext("Year FE", "Yes", "Muni FE", "Yes", "Majority", "Full") nonote append 
	
	reghdfe `yvar' mayorinbrd dmdn_politics mayorinbrd_dmdn_politics, a(year coddane) vce(robust)
	outreg2 using "${tables}/twfe_`yvar'_mayorinbrd.tex", tex(frag) addtext("Year FE", "Yes", "Muni FE", "Yes", "Majority", "Full") nonote append 
	
	reghdfe `yvar' mayorinbrd if dmdn_politics==0, a(year coddane) vce(robust)
	outreg2 using "${tables}/twfe_`yvar'_mayorinbrd.tex", tex(frag) addtext("Year FE", "Yes", "Muni FE", "Yes", "Majority", "No") nonote append 
	
	reghdfe `yvar' mayorinbrd if dmdn_politics==1, a(year coddane) vce(robust)
	outreg2 using "${tables}/twfe_`yvar'_mayorinbrd.tex", tex(frag) addtext("Year FE", "Yes", "Muni FE", "Yes", "Majority", "Yes") nonote append 

}
	
*-------------------------------------------------------------------------------
*  Agriculture!
*-------------------------------------------------------------------------------
summ bovinos, d
gen y=(bovinos>=`r(p50)') if bovinos!=.
gen x=(bovinos>=`r(mean)') if bovinos!=.
bys coddane: egen med_bovinos=max(y)
bys coddane: egen mean_bovinos=max(x)
drop x y 

reghdfe floss_prim_ideam_area mayorallied med_bovinos 1.mayorallied#1.med_bovinos if dmdn_politics!=., a(year coddane) vce(robust)
reghdfe floss_prim_ideam_area mayorallied mean_bovinos 1.mayorallied#1.mean_bovinos, a(year coddane) vce(robust)

reghdfe floss_prim_ideam_area mayorallied med_bovinos 1.mayorallied#1.med_bovinos dmdn_politics 1.mayorallied#1.dmdn_politics 1.mayorallied#1.dmdn_politics#1.med_bovinos, a(year coddane) vce(robust)



reghdfe floss_prim_ideam_area mayorallied if dmdn_politics!=. & med_bovinos==0, a(year coddane) vce(robust)
reghdfe floss_prim_ideam_area mayorallied if dmdn_politics!=. & med_bovinos==1, a(year coddane) vce(robust)

reghdfe floss_prim_ideam_area mayorallied if dmdn_politics==0 & med_bovinos==1, a(year coddane) vce(robust)
reghdfe floss_prim_ideam_area mayorallied if dmdn_politics==1 & med_bovinos==1, a(year coddane) vce(robust)

*-------------------------------------------------------------------------------
*  Vote share of mayors 
*-------------------------------------------------------------------------------
summ sh_votes_alc, d
gen med_sh_votes_alc=(sh_votes_alc>=`r(p50)') if sh_votes_alc!=.

reghdfe floss_prim_ideam_area mayorallied sh_votes_alc 1.mayorallied#c.sh_votes_alc if dmdn_politics!=., a(year coddane) vce(robust)
reghdfe floss_prim_ideam_area mayorallied med_sh_votes_alc 1.mayorallied#c.med_sh_votes_alc if dmdn_politics!=., a(year coddane) vce(robust)

reghdfe floss_prim_ideam_area mayorallied if dmdn_politics!=. & med_sh_votes_alc==0, a(year coddane) vce(robust)
reghdfe floss_prim_ideam_area mayorallied if dmdn_politics!=. & med_sh_votes_alc==1, a(year coddane) vce(robust)

*-------------------------------------------------------------------------------
*  Share of females in the board
*-------------------------------------------------------------------------------
reghdfe floss_prim_ideam_area mayorallied sh_female 1.mayorallied#c.sh_female if dmdn_politics!=., a(year coddane) vce(robust)

*-------------------------------------------------------------------------------
*  Party diversity
*-------------------------------------------------------------------------------
gen diff_parties_politicians= n_parties-politics
gen diff_politicians_parties= politics-n_parties

reghdfe floss_prim_ideam_area mayorallied n_parties 1.mayorallied#c.n_parties if dmdn_politics!=., a(year coddane) vce(robust)
reghdfe floss_prim_ideam_area mayorallied n_parties 1.mayorallied#c.n_parties sh_politics 1.mayorallied#c.sh_politics 1.mayorallied#c.n_parties#c.sh_politics if dmdn_politics!=., a(year coddane) vce(robust)

reghdfe floss_prim_ideam_area mayorallied n_parties 1.mayorallied#c.n_parties if dmdn_politics==0, a(year coddane) vce(robust)
reghdfe floss_prim_ideam_area mayorallied n_parties 1.mayorallied#c.n_parties if dmdn_politics==1, a(year coddane) vce(robust)

reghdfe floss_prim_ideam_area mayorallied diff_parties_politicians 1.mayorallied#c.diff_parties_politicians if dmdn_politics!=., a(year coddane) vce(robust)
reghdfe floss_prim_ideam_area mayorallied diff_politicians_parties 1.mayorallied#c.diff_politicians_parties if dmdn_politics!=., a(year coddane) vce(robust)

*-------------------------------------------------------------------------------
*  Permits
*-------------------------------------------------------------------------------
gen n_permits=perm_n_resol
replace n_permits=n_licencia if n_permits==.
replace n_permits=0 if n_permits==.

reghdfe perm_n_resol mayorallied if dmdn_politics!=., a(year) vce(robust)
reghdfe floss_prim_ideam_area mayorallied if dmdn_politics!=. & perm_n_resol!=., a(year) vce(robust)

reghdfe n_licencia mayorallied if dmdn_politics!=., a(year coddane) vce(robust)
reghdfe n_licencia mayorallied dmdn_politics myrallied_dmdn_politics, a(year coddane) vce(robust)

reghdfe n_permits mayorallied if dmdn_politics!=., a(year coddane) vce(robust)
reghdfe n_permits mayorallied dmdn_politics myrallied_dmdn_politics, a(year coddane) vce(robust)


replace crime_environment=0 if crime_environment==. & year>2009
replace crime_forest=0 if crime_forest==. & year>2009

reghdfe crime_environment mayorallied if dmdn_politics!=., a(year coddane) vce(robust)
reghdfe crime_environment mayorallied dmdn_politics myrallied_dmdn_politics, a(year coddane) vce(robust)

reghdfe crime_forest mayorallied if dmdn_politics!=., a(year coddane) vce(robust)
reghdfe crime_forest mayorallied dmdn_politics myrallied_dmdn_politics, a(year coddane) vce(robust)

*-------------------------------------------------------------------------------
* Other
*-------------------------------------------------------------------------------
replace sh_sameparty_gov=0 if sh_politics!=. & sh_sameparty_gov==.
summ sh_sameparty_gov, d
gen med_sh_sameparty_gov=(sh_sameparty_gov>=`r(p50)') if sh_sameparty_gov!=.


reghdfe floss_prim_ideam_area mayorallied sh_politics 1.mayorallied#c.sh_politics if dmdn_politics!=., a(year coddane) vce(robust)
reghdfe floss_prim_ideam_area mayorallied sh_sameparty_gov 1.mayorallied#c.sh_sameparty_gov if dmdn_politics!=., a(year coddane) vce(robust)
reghdfe floss_prim_ideam_area mayorallied med_sh_sameparty_gov 1.mayorallied#c.med_sh_sameparty_gov if dmdn_politics!=., a(year coddane) vce(robust)

replace sh_votes_gov=0 if sh_politics!=. & sh_votes_gov==.
summ sh_votes_gov, d
gen med_sh_votes_gov=(sh_votes_gov>=`r(p50)') if sh_votes_gov!=.

reghdfe floss_prim_ideam_area mayorallied sh_votes_gov 1.mayorallied#c.sh_votes_gov if dmdn_politics!=., a(year coddane) vce(robust)
reghdfe floss_prim_ideam_area mayorallied med_sh_votes_gov 1.mayorallied#c.med_sh_votes_gov if dmdn_politics!=., a(year coddane) vce(robust)

gen sh_additionalpol = sh_politics-sh_sameparty_gov
reghdfe floss_prim_ideam_area mayorallied sh_additionalpol 1.mayorallied#c.sh_additionalpol if dmdn_politics!=., a(year coddane) vce(robust)

*-------------------------------------------------------------------------------
* Lobbying
*-------------------------------------------------------------------------------
replace financed_won=0 if financed_won==. & year>2011 & year<2020
gen d_priv_gob=(sh_priv_gob>=.5) if sh_priv_gob!=.

reghdfe floss_prim_ideam_area mayorallied financed_won 1.mayorallied#1.financed_won if dmdn_politics!=., a(year coddane) vce(robust)

reghdfe floss_prim_ideam_area mayorallied sh_priv_gob 1.mayorallied#c.sh_priv_gob if dmdn_politics!=., a(year coddane) vce(robust)
reghdfe floss_prim_ideam_area mayorallied d_priv_gob 1.mayorallied#1.d_priv_gob if dmdn_politics!=., a(year coddane) vce(robust)

reghdfe floss_prim_ideam_area mayorallied sh_priv_valor_gob 1.mayorallied#c.sh_priv_valor_gob if dmdn_politics!=., a(year coddane) vce(robust)


/*-------------------------------------------------------------------------------
* ES: 
*-------------------------------------------------------------------------------
reghdfe floss_prim_ideam mayorallied if dmdn_politics==0, a(year coddane) vce(robust)
reghdfe floss_prim_ideam mayorallied if dmdn_politics==1, a(year coddane) vce(robust)

global dyn = 3
global pla = 3
global nboot = 50

did_multiplegt floss_prim_ideam_area coddane year mayorallied if dmdn_politics==0, average_effect robust_dynamic dynamic(${dyn}) placebo(${pla}) breps(${nboot}) longdiff_placebo covariances seed(123) 

did_multiplegt floss_prim_ideam coddane year mayorallied if dmdn_politics==1, average_effect robust_dynamic dynamic(${dyn}) placebo(${pla}) breps(${nboot}) longdiff_placebo covariances seed(123) 


reghdfe floss_prim_ideam mayorallied dmdn_politics myrallied_dmdn_politics, a(year coddane) vce(robust)
reghdfe floss mayorallied dmdn_politics myrallied_dmdn_politics, a(year coddane) vce(robust)

reghdfe floss_prim_ideam mayorallied dmdn_politics myrallied_dmdn_politics, a(year i.year#c.area coddane) vce(robust)
reghdfe floss mayorallied dmdn_politics myrallied_dmdn_politics, a(year i.year#c.area year coddane) vce(robust)

reghdfe floss_prim_ideam mayorallied dmdn_politics myrallied_dmdn_politics, a(year coddane) vce(robust)
reghdfe floss_area mayorallied dmdn_politics myrallied_dmdn_politics, a(year coddane) vce(robust)

reghdfe floss_prim_ideam mayorallied if dmdn_politics==0, a(year coddane) vce(robust)
reghdfe floss_prim_ideam mayorallied if dmdn_politics==1, a(year coddane) vce(robust)




reghdfe floss_prim_ideam_area mayorallied sh_politics myrallied_sh_politics, a(year coddane) vce(robust)













