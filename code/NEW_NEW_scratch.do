
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
tabstat floss_prim_ideam_area if sh_politics!=., by(carcode_master) s(N mean sd min p25 p50 p75 max) save

*-------------------------------------------------------------------------------
* Composition Mandated by law for all CARs
*-------------------------------------------------------------------------------
two (hist sh_politics, frac color(gray)) (hist sh_politics_law, frac fcolor(none) lcolor(black))  
two (hist sh_politics2, frac color(gray)) (hist sh_politics2_law, frac fcolor(none) lcolor(black))  
two (hist sh_ethnias, frac color(gray)) (hist sh_ethnias_law, frac fcolor(none) lcolor(black))  
two (hist sh_private, frac color(gray)) (hist sh_private_law, frac fcolor(none) lcolor(black))  
two (hist sh_envngo, frac color(gray)) (hist sh_envngo_law, frac fcolor(none) lcolor(black))  
two (hist sh_academics, frac color(gray)) (hist sh_academics_law, frac fcolor(none) lcolor(black))  

foreach var in sh_politics sh_politics2 sh_ethnias sh_private sh_envngo sh_academics {
	
	gen diff_`var' = `var'- `var'_law	

}

foreach var in sh_politics sh_politics2 sh_ethnias sh_private sh_envngo sh_academics {
	
	hist diff_`var', frac

}

two (kdensity diff_sh_politics) (kdensity diff_sh_politics2) (kdensity diff_sh_ethnias) (kdensity diff_sh_private) (kdensity diff_sh_envngo) (kdensity diff_sh_academics)

*-------------------------------------------------------------------------------
* Composition Mandated by CAR 
*-------------------------------------------------------------------------------
foreach var in sh_politics sh_politics2 sh_ethnias sh_private sh_envngo sh_academics {
	
	tabstat `var' if `var'!=., by(carcode_master) s(N mean sd min p25 p50 p75 max) save
	*tabstatmat S

}

foreach var in sh_politics sh_politics2 sh_ethnias sh_private sh_envngo sh_academics {
	
	tabstat diff_`var' if diff_`var'!=., by(carcode_master) s(N mean sd min p25 p50 p75 max) save
	*tabstatmat S

}

*-------------------------------------------------------------------------------
* 
*-------------------------------------------------------------------------------
reghdfe floss_prim_ideam_area mayorinbrd, a(year coddane) vce(robust)
reghdfe floss_prim_ideam_area mayorallied, a(year coddane) vce(robust)
reghdfe floss_prim_ideam_area mayorallied_wanypol, a(year coddane) vce(robust)

reghdfe floss_prim_ideam_area sh_politics, a(year coddane) vce(robust)
reghdfe floss_prim_ideam_area sh_politics2, a(year coddane) vce(robust)
reghdfe floss_prim_ideam_area sh_ethnias, a(year coddane) vce(robust)
reghdfe floss_prim_ideam_area sh_private, a(year coddane) vce(robust)
reghdfe floss_prim_ideam_area sh_envngo, a(year coddane) vce(robust)
reghdfe floss_prim_ideam_area sh_academics, a(year coddane) vce(robust)

reghdfe floss_prim_ideam_area sh_politics_law, a(year) vce(robust)
reghdfe floss_prim_ideam_area sh_politics2_law, a(year) vce(robust)
reghdfe floss_prim_ideam_area sh_ethnias_law, a(year) vce(robust)
reghdfe floss_prim_ideam_area sh_private_law, a(year) vce(robust)
reghdfe floss_prim_ideam_area sh_envngo_law, a(year) vce(robust)
reghdfe floss_prim_ideam_area sh_academics_law, a(year) vce(robust)

reghdfe floss_prim_ideam_area diff_sh_politics, a(year coddane) vce(robust)
reghdfe floss_prim_ideam_area diff_sh_politics2, a(year coddane) vce(robust)
reghdfe floss_prim_ideam_area diff_sh_ethnias, a(year coddane) vce(robust)
reghdfe floss_prim_ideam_area diff_sh_private, a(year coddane) vce(robust)
reghdfe floss_prim_ideam_area diff_sh_envngo, a(year coddane) vce(robust)
reghdfe floss_prim_ideam_area diff_sh_academics, a(year coddane) vce(robust)

*-------------------------------------------------------------------------------
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


reghdfe floss_prim_ideam mayorallied if dmdn_politics!=., a(year coddane) vce(robust)
reghdfe floss_prim_ideam mayorallied dmdn_politics, a(year coddane) vce(robust)
reghdfe floss_prim_ideam mayorallied dmdn_politics myrallied_dmdn_politics, a(year coddane) vce(robust)

reghdfe floss_prim_ideam mayorallied dmdn_politics_law myrallied_dmdn_politics_law, a(year coddane) vce(robust)
reghdfe floss_prim_ideam mayorallied dmdn_politics_law myrallied_dmdn_politics_law, a(year) vce(robust)


reghdfe floss_prim_ideam_area mayorinbrd sh_politics mayorinbrd_sh_politics, a(year coddane) vce(robust)
reghdfe floss_prim_ideam_area mayorallied sh_politics myrallied_sh_politics, a(year coddane) vce(robust)

reghdfe floss_prim_ideam_area mayorallied sh_politics myrallied_diff_sh_politics, a(year coddane) vce(robust)


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













