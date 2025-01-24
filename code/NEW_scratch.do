*-------------------------------------------------------------------------------
* TWFE Estimation
*
*-------------------------------------------------------------------------------
use "${data}/Interim\defo_caralc.dta", clear

*-------------------------------------------------------------------------------
* Preparing vars of interest
*-------------------------------------------------------------------------------
*Creating variable of mayor in the CAR's board 
gen mayorinbrd=(codigo_partido_caralc!=.) if sh_politics!=.

*Creating variable of mayor allied with the gobernor in CAR's board
gen mayorallied=(codigo_partido_alc==codigo_partido_gob) if codigo_partido_gob!=.

*Allianza with any politician in the CAR's board
gen mayorallied_wanypol=.
forval i=1/19{
	replace mayorallied_wanypol=1 if codigo_partido_alc==codigo_partido_carpol`i' & codigo_partido_carpol`i'!=.
}

replace mayorallied_wanypol=0 if mayorallied_wanypol==. & mayorallied_wanypol!=1 & codigo_partido_alc!=.

*Political power vars 
gen dmdn_politics = (sh_politics>=.5) if sh_politics!=.
gen dmdn_politics_law = (sh_politics_law>=.5) if sh_politics_law!=.

summ sh_same_party_gob, d
gen dmdn_sameparty_gob = (sh_same_party_gob>=`r(p50)') if sh_same_party_gob!=.

*Difference in composition from law
gen diff_sh_politics=sh_politics - sh_politics_law

*Interactions
gen myrallied_dmdn_politics=mayorallied*dmdn_politics
gen myrallied_dmdn_politics_law=mayorallied*dmdn_politics_law

gen mayorinbrd_dmdn_politics=dmdn_politics*mayorinbrd

*Labels
label var floss "Total Forest Loss (Km2)"
label var floss_area "Share of Forest Loss"
label var floss_prim00p1 "Share of Primary Forest Loss"
label var floss_prim_ideam "Primary Forest Loss - IDEAM (Km2)"
label var floss_prim_ideam_area "Share of Primary Forest Loss - IDEAM (%)"




END

reghdfe floss_prim_ideam mayorinbrd, a(year coddane) vce(robust)
reghdfe floss_prim_ideam mayorallied, a(year coddane) vce(robust)
reghdfe floss_prim_ideam mayorallied dmdn_politics myrallied_dmdn_politics, a(year coddane) vce(robust)
reghdfe floss_prim_ideam mayorallied dmdn_politics_law myrallied_dmdn_politics_law, a(year coddane) vce(robust)

reghdfe floss_prim_ideam mayorinbrd dmdn_politics mayorinbrd_dmdn_politics, a(year coddane) vce(robust)

reghdfe floss_prim_ideam sh_politics, a(year coddane) vce(robust)
reghdfe floss_prim_ideam dmdn_politics, a(year coddane) vce(robust)

reghdfe floss_prim_ideam sh_politics_law, a(year) vce(robust)
reghdfe floss_prim_ideam dmdn_politics_law, a(year) vce(robust)

reghdfe floss_prim_ideam diff_sh_politics, a(year coddane) vce(robust)

reghdfe floss_prim_ideam mayorallied if dmdn_politics==1, a(year coddane) vce(robust)
reghdfe floss_prim_ideam mayorallied if dmdn_politics==0, a(year coddane) vce(robust)


global dyn = 3
global pla = 3
global nboot = 50

did_multiplegt floss coddane year mayorallied if dmdn_politics==1, average_effect robust_dynamic dynamic(${dyn}) placebo(${pla}) breps(${nboot}) trends_nonparam(fprim00_p1 area) longdiff_placebo covariances seed(783)

did_multiplegt floss_prim_ideam coddane year mayorallied if dmdn_politics==1, average_effect robust_dynamic dynamic(${dyn}) placebo(${pla}) breps(${nboot}) longdiff_placebo covariances seed(783)

did_multiplegt floss_prim_ideam coddane year mayorallied if dmdn_politics==0, average_effect robust_dynamic dynamic(${dyn}) placebo(${pla}) breps(${nboot}) longdiff_placebo covariances seed(783)








