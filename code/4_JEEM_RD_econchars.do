
use "${data}/Interim\defo_caralc.dta", clear 

*-------------------------------------------------------------------------------
* Vars and Labels
*
*-------------------------------------------------------------------------------
gen ln_pib_total=log(pib_total)
gen ln_pib_percapita_cons=log(pib_percapita_cons)
gen ln_pib_agricola=log(pib_agricola)
gen ln_pib_industria=log(pib_industria)
gen ln_pib_servicios=log(pib_servicios)
gen ln_pib_percapita= log(pib_percapita)
gen ln_regalias=log(y_cap_regalias)
gen ln_g_total=log(g_total)
gen sh_bovinos=bovinos/primary_forest01
gen sh_coca_area=H_coca*0.01/primary_forest01
gen sh_sown_area=tot_sown_area*0.01/primary_forest01  
gen sh_harv_area=tot_harv_area*0.01/primary_forest01
gen ln_tot_prod=log(tot_prod)
gen ln_va=ln(va)
gen ln_va_prim=ln(va_prim)
gen ln_va_sec=ln(va_sec)
gen ln_va_terc=ln(va_terc)
replace ln_va=log(pib_cons) if ln_va==.
gen ln_bovinos=log(bovinos)
replace tot_harv_area=tot_harv_area*0.01
gen ln_tot_harv_area=log(tot_harv_area)

la var ln_va "Log(GDP)"
la var ln_pib_percapita_cons "Log(GDP percapita)"
la var ln_pib_agricola "Log(Agricultural GDP)"
la var night_light "Night Light - radiance"
la var ln_regalias "Log(Royalties)"
la var ln_g_total "Log(Public expenditure)"
la var sh_bovinos "Cattle per Km2"
la var sh_coca_area "Coca area (%)"
la var sh_sown_area "Crop sown area (%)"
la var sh_harv_area "Crop harvested area (%)"
la var yield_allcrop "Crop yield (tns/ha)"
la var ln_tot_prod "Log(Crop production)"
la var ln_bovinos "Log(Cattle per Km2)"
la var ln_tot_harv_area "Log(Harvested area)"

la var ln_va_prim "Log(GDP primary)"
la var ln_va_sec "Log(GDP secondary)"
la var ln_va_terc "Log(GDP tertiary)"

la var built_area_floss "Built on lost forest (%)"
la var grass_shrub_area_floss "Grass on lost forest (%)"
la var crop_area_floss "Crop on lost forest (%)"


*-------------------------------------------------------------------------------
* Main Results
*
*-------------------------------------------------------------------------------
summ z_sh_votes_alc, d

rdrobust floss_prim_ideam_area_v2 z_sh_votes_alc, all kernel(triangular)
gl h = e(h_l)
gl ht= round(${h}, .001)
gl p = e(p)
gl k = e(kernel)
gl if "if abs(z_sh_votes_alc)<=${h}"
gl controls "mayorallied i.mayorallied#c.z_sh_votes_alc z_sh_votes_alc"

cap drop tweights
gen tweights=(1-abs(z_sh_votes_alc/${h})) ${if}

eststo clear

*-------------------------------------------------------------------------------
* Economic characteristics 
*-------------------------------------------------------------------------------
gl Yvars "ln_va ln_va_prim ln_va_sec ln_va_terc night_light ln_regalias ln_g_total ln_bovinos yield_allcrop built_area_floss grass_shrub_area_floss crop_area_floss"

foreach yvar of global Yvars{
tabstat `yvar',by(year)
}

mat C=J(4,12,.)
mat coln C =${Yvars}

local i=1

foreach yvar of global Yvars{

	cap drop std_`yvar'
	bys year: egen std_`yvar'= std(`yvar')
	
	reghdfe std_`yvar' ${controls} [aw=tweights] ${if} & year>=2014, abs(year) vce(cl coddane)
	lincom mayorallied
	mat C[1,`i']= r(estimate) 
	mat C[2,`i']= r(lb)
	mat C[3,`i']= r(ub)
	mat C[4,`i']= r(p)
	
	local i=`i'+1
	
}

coefplot (mat(C[1]), ci((2 3)) aux(4)), xline(0, lp(dash) lc("maroon")) b2title("Effect of Alignment on Dep Var (std)", size(medium)) ciopts(recast(rcap)) ylab(, labsize(medsmall)) ///
mlabel(cond(@aux1<=.01, string(@b, "%9.2fc") +"***", cond(@aux1<=.05, string(@b, "%9.2fc") +"**", cond(@aux1<=.1, string(@b, "%9.2fc") +"*", string(@b, "%9.2fc"))))) mlabposition(12) mlabgap(*2) mlabsize(medsmall) ///
xlabel(, labsize(medium)) l2title("Dependent Variable", size(medium))

gr export "${plots}/coefplot_rd_econchars.pdf", as(pdf) replace




















