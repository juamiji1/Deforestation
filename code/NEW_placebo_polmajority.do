use "${data}/Cede\Panel_context_12032025.dta", clear

keep if ano==1993
ren coddepto codepto 

collapse (sum) pobl_tot desplazados_expulsion (mean) gini nbi pobreza, by(codepto)

ren (gini nbi pobreza) (gini93 nbi93 pobreza93)

tempfile CEDE93
save `CEDE93', replace

use "${data}/Interim\defo_caralc.dta", clear

collapse (sum) tot_votos_alc90 area (mean) depto_harvested_area* depto_crop_production* depto_crop_yield* depto_forest_cover90 depto_forest_change_90_00 pib_19* agg_va_19* min_va_19* sh_politics2_law, by(codepto)

merge 1:1 codepto using `CEDE93', keep(1 3) nogen 

egen tot_votos_col=total(tot_votos_alc90)
gen sh_votos_alc90=tot_votos_alc90/tot_votos_col
gen sh_harvest90=depto_harvested_area1990/area
gen ln_crop_prod90=ln(depto_crop_production1990)
gen sh_forestcov90=depto_forest_cover90/area
gen ln_pib90=ln(pib_1990)
gen ln_agg_va90=ln(agg_va_1990)
gen ln_min_va90=ln(min_va_1990)
gen ln_pobl_tot93=ln(pobl_tot)
gen sh_displaced93= desplazados_expulsion/pobl_tot

cap drop dmdn_politics
gen dmdn_politics=(sh_politics2_law>=.5) if sh_politics2_law!=.

la var sh_forestcov90 "Forest cover - 1990"
la var sh_votos_alc90 "Registered voters - 1990"
la var sh_harvest90 "Harvested area - 1990"
la var ln_crop_prod90 "Log(Crop production) - 1990"
la var depto_crop_yield1990 "Crop yield - 1990"
la var ln_pib90 "Log(GDP) - 1990"
la var ln_agg_va90 "Log(Agriculture value) - 1990"
la var ln_min_va90 "Log(Mining value) - 1990"
la var ln_pobl_tot93 "Log(Total population) - 1993"
la var sh_displaced93 "Displaced population - 1993"
la var gini93 "Gini index - 1993"
la var nbi93 "Unsatisfied basic needs - 1993"
la var pobreza93 "Poverty incidence rate - 1993"
la var depto_forest_change_90_00 "Forest change - 1990 to 2000"
 
gl yvars "sh_forestcov90 depto_forest_change_90_00 sh_votos_alc90 sh_harvest90 ln_crop_prod90 depto_crop_yield1990 ln_pib90 ln_agg_va90 ln_min_va90 ln_pobl_tot93 sh_displaced93 gini93 nbi93 pobreza93"

mat C=J(4,14,.)
mat coln C=${yvars}

local i=1

foreach yvar of global yvars{
	
	egen std_`yvar'= std(`yvar')
	
	bootstrap, reps(100) seed(123):reg std_`yvar' dmdn_politics, r
			
	lincom dmdn_politics
	mat C[1,`i']= r(estimate) 
	mat C[2,`i']= r(lb)
	mat C[3,`i']= r(ub)
	mat C[4,`i']= r(p)
	
	local i=`i'+1
	
}

coefplot (mat(C[1]), ci((2 3)) aux(4)), xline(0, lp(dash) lc("maroon")) b2title("Politician Majority in REPA's Board (std)", size(small)) ciopts(recast(rcap)) ylab(, labsize(small)) l2title("Historical Characteristics at the Department Level") ///
mlabel(cond(@aux1<=.01, "***", cond(@aux1<=.05, "**", cond(@aux1<=.1, "*", """")))) mlabposition(12) mlabgap(*2)

gr export "${plots}/coefplot_historic_vars_polmajority.pdf", as(pdf) replace




*END
