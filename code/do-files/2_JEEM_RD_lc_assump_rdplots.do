use "${data}/Interim\defo_caralc.dta", clear 

*-------------------------------------------------------------------------------
* McCrary test
*
*-------------------------------------------------------------------------------
rddensity z_sh_votes_alc, c(0) noplot h(0.098)
gl pval=round(`e(pv_q)', .01)

rddensity z_sh_votes_alc, c(0) plot h(${h}) plot_range(-.1 .1) cirl_opt(acolor(gs6%30) alw(vvthin)) esll_opt(clc(gs2%90) clw(medthick)) cirr_opt(acolor(gs6%30) alw(vvthin)) eslr_opt(clc(gs2%90) clw(medthick)) nohist graph_opt(title("") xline(0, lc(maroon) lp(dash)) legend(off) b2title("Vote Margin", size(medium)) xtitle("") ytitle("Frequency", size(medium)) note("p-value=${pval}"))

gr export "${plots}\mccraryplot_z_sh_votes_alc.pdf", as(pdf) replace 


*-------------------------------------------------------------------------------
* Local Continuity Assumption
*
*-------------------------------------------------------------------------------
gl controls "mayorallied i.mayorallied#c.z_sh_votes_alc z_sh_votes_alc"
gl fes "region year"

rdrobust floss_prim_ideam_area_v2 z_sh_votes_alc, all kernel(triangular) covs(${fes})
gl h = e(h_l)
gl ht= round(${h}, .001)
gl if "if abs(z_sh_votes_alc)<=${h}"

cap drop tweights
gen tweights=(1-abs(z_sh_votes_alc/${h})) ${if}

*-------------------------------------------------------------------------------
* Preparing vars
*-------------------------------------------------------------------------------
tab year if H_coca!=.
replace H_coca=0 if H_coca==.
gen sh_area_coca=H_coca/area

egen area_siembra=rowtotal(as_arrozr as_arrozsm as_arrozsme as_palmaa as_palmaam as_palmar as_soya), m
gen sh_area_siembra=area_siembra/area
replace sh_area_siembra=0 if sh_area_siembra==.

egen producto_siembra=rowtotal(p_arrozr p_arrozsm p_arrozsme p_palmaa p_palmaam p_palmar p_soya), m
replace producto_siembra=0 if producto_siembra==.
gen ln_prod_crops=ln(producto_siembra)

gen primary_forest01_nopa=primary_forest01 - primary_forest01_pa

gen sh_area_forest=primary_forest01/area

replace sh_area_forest=0 if primary_forest01_nopa<0

ren SRAingeominasanh_giros_totales giros_totales

egen dist_mcados=rowmean(dismdo)
gen ln_dist_mcados=ln(dist_mcados)

egen mean_sut_crops=rowmean(sut_cof sut_banana sut_cocoa sut_rice sut_oil) 
replace mean_sut_crops=mean_sut_crops/10000

gen ln_area=ln(area)
gen sh_area_agro=areamuniagro/area

replace total_procesos=0 if total_procesos==.
replace crime_environment=0 if crime_environment==.
replace crime_forest=0 if crime_forest==.

gen crime_rate=(total_procesos/pobl_tot)*100000
gen crime_env_rate=(crime_environment/pobl_tot)*100000
gen crime_forest_rate=(crime_forest/pobl_tot)*100000

bys coddane: egen mean_gini=mean(gini)

ren IPM mpi
bys coddane: egen mean_ipm=mean(mpi)

gen ln_pibpc=ln(pib_percapita)
gen ln_regalias=ln(giros_totales)
gen ln_inv_total=ln(inv_total)

gen sh_invenv = inv_ambiental/inv_total

gen desemp_fisc_index=DF_desemp_fisc

gen sh_area_bovino=bovinos/area
gen ln_pobl_tot93=ln(pobl_tot93)

gen pobl_tot93_dens=pobl_tot93/area

gen ln_va=ln(va)
replace ln_va=log(pib_cons) if ln_va==.

summ night_light, d
gen ln_nl=log(night_light)

bys carcode_master: egen cararea = sum(area)
bys carcode_master: egen carpaarea = sum(pa_area)
gen sh_area = area*100/cararea
gen sh_paarea = pa_area*100/carpaarea

*Sample var
reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2!=., abs(${fes}) vce(robust)
gen regsample=e(sample)
gl N=e(N)

*Asigning the pre-treatment var value
gl varst "ln_va ln_nl ln_regalias ln_inv_total sh_invenv sh_area_coca sh_area_bovino floss_prim_ideam_area sh_area_agro indrural crime_rate crime_env_rate crime_forest_rate sh_votes_alc incumbent_gob bii desemp_fisc_index"

preserve 
	bys coddane: egen always=max(regsample)
	
	sort coddane election year, stable
	collapse (mean) ${varst} regsample always, by(election coddane)
	sort coddane election

	replace regsample=. if regsample==0
	by coddane: carryforward regsample, gen(xt)
	replace xt=0 if xt==. & always==1

	keep if always==1
	collapse (mean) ${varst}, by(coddane xt)
	keep if xt==0
	drop xt
	
	ren (${varst}) pre_=
	
	tempfile NONCONSTANTVARS
	save `NONCONSTANTVARS', replace 
restore

merge m:1 coddane using `NONCONSTANTVARS', keep(1 3) nogen 

*Labels
la var ln_area "Log(Area Km2)"
la var pre_sh_area_agro "Agricultural area (sh)"
la var sh_area_forest "Primary forest cover (sh)"
la var altura "Altitude (masl)"
la var mean_sut_crops "Crop suitability"
la var ln_dist_mcados "Log(Distance to market Km2)"
la var sh_area "Area in REPA (sh)"
la var sh_paarea "Protected area in REPA (sh)"
la var pre_ln_nl "Log(Night Light)"
la var pobl_tot93_dens "Population density-'93"

la var ln_pobl_tot93 "Log(Population-'93)"
la var mean_gini "Gini index"
la var pre_crime_rate "Crime rate" 
la var pre_crime_env_rate "Env. crime rate"
la var pre_crime_forest_rate "Forest crime rate"
la var pre_indrural "Rurality index"
la var pre_sh_votes_alc "Registered voter (sh)"
la var pre_incumbent_gob "Incumbent (prob)"
la var pre_sh_invenv "Enviromental investment (Sh)"

la var pre_ln_va "Log(Total GDP)"
la var pre_desemp_fisc_index "Fiscal performance Index "
la var pre_ln_regalias "Log(Royalties)"
la var pre_ln_inv_total "Log(Public Investment)"
la var pre_sh_area_coca "Coca area (sh)"
la var pre_sh_area_bovino "Cattle per Km2"
la var pre_floss_prim_ideam_area "Primary Forest loss (sh)"

la var ruggedness "Ruggedness (mts)"

*-------------------------------------------------------------------------------
* LC Results
*-------------------------------------------------------------------------------
eststo clear

*Geographic characteristics
gl geovars "ln_area sh_area pre_sh_area_agro sh_area_forest sh_paarea altura ruggedness mean_sut_crops ln_dist_mcados"

foreach yvar of global geovars {
	
	local yvarlabel : var label `yvar'
	cap drop rdplot_*
rdplot `yvar' z_sh_votes_alc ${if}, all kernel(triangular) h(${h}) p(1) ci(95) genvars covs(${fes})

	preserve
		collapse (mean) rdplot_mean_y rdplot_N tweights, by(rdplot_mean_x)
		
		local var "rdplot_mean_y"
		ren rdplot_mean_x x
		ren rdplot_N n
		
		gen ntweights=n*tweights
		
		two (scatter `var' x if abs(x)<=${h}, mcolor(gs6) xline(0, lc(maroon) lp(dash))) ///
		(lfitci `var' x [aw = ntweights] if x<0 & abs(x)<=${h}, clc(gs2%90) clw(medthick) acolor(gs6%30) alw(vvthin)) ///
		(lfitci `var' x [aw = ntweights] if x>=0 & abs(x)<=${h}, clc(gs2%90) clw(medthick) acolor(gs6%30) alw(vvthin)), ///
		legend(off) ///
		l2title("`yvarlabel'", size(medsmall)) b2title("Vote Margin", size(medsmall)) ///
		xtitle("") name(`var', replace)
		
		gr export "${plots}\rdplot_`yvar'.pdf", as(pdf) replace 
	restore 
	
}

*Demographic characteristics
gl demovars "ln_pobl_tot93 pobl_tot93_dens pre_indrural mean_gini pre_crime_rate pre_crime_env_rate pre_crime_forest_rate pre_sh_votes_alc pre_incumbent_gob"

foreach yvar of global demovars {
	
	local yvarlabel : var label `yvar'
	cap drop rdplot_*
rdplot `yvar' z_sh_votes_alc ${if}, all kernel(triangular) h(${h}) p(1) ci(95) genvars covs(${fes})

	preserve
		collapse (mean) rdplot_mean_y rdplot_N tweights, by(rdplot_mean_x)
		
		local var "rdplot_mean_y"
		ren rdplot_mean_x x
		ren rdplot_N n
		
		gen ntweights=n*tweights
		
		two (scatter `var' x if abs(x)<=${h}, mcolor(gs6) xline(0, lc(maroon) lp(dash))) ///
		(lfitci `var' x [aw = ntweights] if x<0 & abs(x)<=${h}, clc(gs2%90) clw(medthick) acolor(gs6%30) alw(vvthin)) ///
		(lfitci `var' x [aw = ntweights] if x>=0 & abs(x)<=${h}, clc(gs2%90) clw(medthick) acolor(gs6%30) alw(vvthin)), ///
		legend(off) ///
		l2title("`yvarlabel'", size(medsmall)) b2title("Vote Margin", size(medsmall)) ///
		xtitle("") name(`var', replace)
		
		gr export "${plots}\rdplot_`yvar'.pdf", as(pdf) replace 
	restore 
	
}

*Economic characteristics
gl econvars "pre_ln_va pre_ln_nl pre_desemp_fisc_index pre_ln_regalias pre_ln_inv_total pre_sh_invenv pre_sh_area_coca pre_sh_area_bovino pre_floss_prim_ideam_area"

foreach yvar of global econvars {
	
	local yvarlabel : var label `yvar'
	cap drop rdplot_*
rdplot `yvar' z_sh_votes_alc ${if} & `yvar'!=., all kernel(triangular) h(${h}) p(1) ci(95) genvars covs(${fes})

	preserve
		collapse (mean) rdplot_mean_y rdplot_N tweights, by(rdplot_mean_x)
		
		local var "rdplot_mean_y"
		ren rdplot_mean_x x
		ren rdplot_N n
		
		gen ntweights=n*tweights
		
		two (scatter `var' x if abs(x)<=${h}, mcolor(gs6) xline(0, lc(maroon) lp(dash))) ///
		(lfitci `var' x [aw = ntweights] if x<0 & abs(x)<=${h}, clc(gs2%90) clw(medthick) acolor(gs6%30) alw(vvthin)) ///
		(lfitci `var' x [aw = ntweights] if x>=0 & abs(x)<=${h}, clc(gs2%90) clw(medthick) acolor(gs6%30) alw(vvthin)), ///
		legend(off) ///
		l2title("`yvarlabel'", size(medsmall)) b2title("Vote Margin", size(medsmall)) ///
		xtitle("") name(`var', replace)
		
		gr export "${plots}\rdplot_`yvar'.pdf", as(pdf) replace 
	restore 
	
}





