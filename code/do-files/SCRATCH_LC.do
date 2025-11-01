use "${data}/Interim\defo_caralc.dta", clear 

*-------------------------------------------------------------------------------
* McCrary test
*
*-------------------------------------------------------------------------------
rddensity z_sh_votes_alc if floss_prim_ideam_area_v2!=., c(0) noplot
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

gen crime_rate=(total_procesos/pobl_tot)*1000
gen crime_env_rate=(crime_environment/pobl_tot)*1000
gen crime_forest_rate=(crime_forest/pobl_tot)*1000

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

mat CG=J(4,9,.)
mat coln CG=${geovars}

local i=1

foreach yvar of global geovars {
	
	cap drop std_`yvar'
	egen std_`yvar'= std(`yvar')
	
    reghdfe std_`yvar' ${controls} [aw=tweights] ${if} & ///
        director_gob_law_v2!=., abs(${fes}) vce(robust)
		
	lincom mayorallied
	mat CG[1,`i']= r(estimate) 
	mat CG[2,`i']= r(lb)
	mat CG[3,`i']= r(ub)
	mat CG[4,`i']= r(p)
	
	eststo p1_`i': reghdfe `yvar' ${controls} [aw=tweights] ${if} & ///
        director_gob_law_v2!=., abs(${fes}) vce(robust)
	summ `yvar' if e(sample)==1, d
	gl mp1_`i'= "`=string(round(r(mean), .01), "%9.2f")'"
	
	local i=`i'+1
}

coefplot (mat(CG[1]), ci((2 3)) aux(4)), xline(0, lp(dash) lc("maroon")) b2title("Magnitude of the partisan alignment coefficient (std)", size(medsmall)) ciopts(recast(rcap)) ylab(, labsize(medsmall)) l2title("Dependent variable in pre-treatment", size(medium)) ///
mlabel(cond(@aux1<=.01, "***", cond(@aux1<=.05, "**", cond(@aux1<=.1, "*", """")))) mlabposition(12) mlabgap(*2)

gr export "${plots}\rdplot_lc_results_geovars.pdf", as(pdf) replace 

*Demographic characteristics
gl demovars "ln_pobl_tot93 pobl_tot93_dens pre_indrural mean_gini pre_crime_rate pre_crime_env_rate pre_crime_forest_rate pre_sh_votes_alc pre_incumbent_gob"

mat CD=J(4,9,.)
mat coln CD=${demovars}

local i=1

foreach yvar of global demovars {
	
	cap drop std_`yvar'
	egen std_`yvar'= std(`yvar')
	
	reghdfe std_`yvar' ${controls} [aw=tweights] ${if} & ///
        director_gob_law_v2!=., abs(${fes}) vce(robust)
		
	lincom mayorallied
	mat CD[1,`i']= r(estimate) 
	mat CD[2,`i']= r(lb)
	mat CD[3,`i']= r(ub)
	mat CD[4,`i']= r(p)
		
	eststo p2_`i': reghdfe `yvar' ${controls} [aw=tweights] ${if} & ///
        director_gob_law_v2!=., abs(${fes}) vce(robust)
	summ `yvar' if e(sample)==1, d
	gl mp2_`i'= "`=string(round(r(mean), .01), "%9.2f")'"
	
	local i=`i'+1
}

coefplot (mat(CD[1]), ci((2 3)) aux(4)), xline(0, lp(dash) lc("maroon")) b2title("Magnitude of the partisan alignment coefficient (std)", size(medsmall)) ciopts(recast(rcap)) ylab(, labsize(medsmall)) l2title("Dependent variable in pre-treatment", size(medium)) ///
mlabel(cond(@aux1<=.01, "***", cond(@aux1<=.05, "**", cond(@aux1<=.1, "*", """")))) mlabposition(12) mlabgap(*2)

gr export "${plots}\rdplot_lc_results_demovars.pdf", as(pdf) replace 

*Economic characteristics
gl econvars "pre_ln_va pre_ln_nl pre_desemp_fisc_index pre_ln_regalias pre_ln_inv_total pre_sh_invenv pre_sh_area_coca pre_sh_area_bovino pre_floss_prim_ideam_area"

mat CE=J(4,9,.)
mat coln CE=${econvars}

local i=1

foreach yvar of global econvars {
	
	cap drop std_`yvar'
	egen std_`yvar'= std(`yvar')
	
    reghdfe std_`yvar' ${controls} [aw=tweights] ${if} & ///
        director_gob_law_v2!=., abs(${fes}) vce(robust)
		
	lincom mayorallied
	mat CE[1,`i']= r(estimate) 
	mat CE[2,`i']= r(lb)
	mat CE[3,`i']= r(ub)
	mat CE[4,`i']= r(p)
	
	eststo p3_`i': reghdfe `yvar' ${controls} [aw=tweights] ${if} & ///
	director_gob_law_v2!=., abs(${fes}) vce(robust)
	summ `yvar' if e(sample)==1, d
	gl mp3_`i'= "`=string(round(r(mean), .01), "%9.2f")'"
	
	local i=`i'+1
}

coefplot (mat(CE[1]), ci((2 3)) aux(4)), xline(0, lp(dash) lc("maroon")) b2title("Magnitude of the partisan alignment coefficient (std)", size(medsmall)) ciopts(recast(rcap)) ylab(, labsize(medsmall)) l2title("Dependent variable in pre-treatment", size(medium)) ///
mlabel(cond(@aux1<=.01, "***", cond(@aux1<=.05, "**", cond(@aux1<=.1, "*", """")))) mlabposition(12) mlabgap(*2)

gr export "${plots}\rdplot_lc_results_econvars.pdf", as(pdf) replace 

*-------------------------------------------------------------------------------
* Table
*-------------------------------------------------------------------------------
* --- Panel A: Geographical Characteristics (9 vars, order = geovars) ---
esttab p1_1 p1_2 p1_3 p1_4 p1_5 p1_6 p1_7 p1_8 p1_9 using "${tables}/rd_lc_results.tex", ///
    keep(mayorallied) se nocons star(* 0.10 ** 0.05 *** 0.01) ///
    label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
    prehead(`"\begin{tabular}{@{}l*{9}{c}}"' ///
            `"\hline \hline \toprule"' ///
            `"\multicolumn{10}{c}{\textit{Panel A: Geographical Characteristics}} \\"' ///
            `"\midrule"' ///
            `" & Log(Area km2) & Area in REPA (sh) & Agricultural area (sh) & Primary forest & Protected area & Altitude (masl) & Ruggedness (mts) & Crop suitability & Log(Distance to \\"' ///
			`" & & & & cover (sh) & in REPA (sh) &  &  &  & market km2) \\"' ///
            `" & (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) & (9) \\"' ///
            `"\midrule"') ///
    postfoot(`" Dependent mean & ${mp1_1} & ${mp1_2} & ${mp1_3} & ${mp1_4} & ${mp1_5} & ${mp1_6} & ${mp1_7} & ${mp1_8} & ${mp1_9} \\"' ///
            `"\toprule"' ///
            `"\multicolumn{10}{c}{\textit{Panel B: Demographic and Politic Characteristics}} \\"' ///
            `"\midrule"' ///
            `" & Log(Population-'93) & Population & Rurality & Gini & Crime rate & Env. crime rate & Forest crime rate & Registered & Party incumbency \\"' ///
			`" &  & density-'93 & index & index & (per 1k inh) & (per 1k inh) & (per 1k inh) & voters (sh) & (prob) \\"' ///
            `" & (10) & (11) & (12) & (13) & (14) & (15) & (16) & (17) & (18) \\"' ///
            `"\midrule"')

* --- Panel B: Demographic and Politic Characteristics (9 vars, order = demovars) ---
esttab p2_1 p2_2 p2_3 p2_4 p2_5 p2_6 p2_7 p2_8 p2_9 using "${tables}/rd_lc_results.tex", ///
    keep(mayorallied) se nocons star(* 0.10 ** 0.05 *** 0.01) ///
    label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) append ///
    postfoot(`" Dependent mean (lvl) & ${mp2_1} & ${mp2_2} & ${mp2_3} & ${mp2_4} & ${mp2_5} & ${mp2_6} & ${mp2_7} & ${mp2_8} & ${mp2_9} \\"' ///
            `"\toprule"' ///
            `"\multicolumn{10}{c}{\textit{Panel C: Economic Characteristics}} \\"' ///
            `"\midrule"' ///
            `" & Log(Total GDP) & Log(Night Light) & Fiscal performance  & Log(Royalties) & Log(Public & Enviromental & Coca area (sh) & Cattle head & Primary forest \\"' ///
			`" & &  & index  &  & investment) & investment (Sh) &  & per Km2 & loss (sh) \\"' ///
            `" & (19) & (20) & (21) & (22) & (23) & (24) & (25) & (26) & (27) \\"' ///
            `"\midrule"')

* --- Panel C: Economic Characteristics (9 vars, order = econvars) ---
esttab p3_1 p3_2 p3_3 p3_4 p3_5 p3_6 p3_7 p3_8 p3_9 using "${tables}/rd_lc_results.tex", ///
    keep(mayorallied) se nocons star(* 0.10 ** 0.05 *** 0.01) ///
    label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) append ///
    postfoot(`" Dependent mean & ${mp3_1} & ${mp3_2} & ${mp3_3} & ${mp3_4} & ${mp3_5} & ${mp3_6} & ${mp3_7} & ${mp3_8} & ${mp3_9} \\"' ///
	        `"\midrule"' ///
			`" Bandwidth & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} \\"' ///
            `"\bottomrule \end{tabular}"')
