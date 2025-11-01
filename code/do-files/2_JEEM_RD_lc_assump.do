use "${data}/Interim\defo_caralc.dta", clear


*-------------------------------------------------------------------------------
* McCrary test
*
*-------------------------------------------------------------------------------
rddensity z_sh_votes_alc if floss_prim_ideam_area_v2!=., c(0) noplot
gl pval = round(`e(pv_q)', .01)

rddensity z_sh_votes_alc, c(0) plot h(${h}) plot_range(-.1 .1) ///
    cirl_opt(acolor(gs6%30) alw(vvthin))  esll_opt(clc(gs2%90) clw(medthick)) ///
    cirr_opt(acolor(gs6%30) alw(vvthin))  eslr_opt(clc(gs2%90) clw(medthick)) ///
    nohist graph_opt(title("") xline(0, lc(maroon) lp(dash)) legend(off) ///
    b2title("Vote Margin", size(medium)) xtitle("") ytitle("Frequency", size(medium)) ///
    note("p-value=${pval}"))

gr export "${plots}\mccraryplot_z_sh_votes_alc.pdf", as(pdf) replace


*-------------------------------------------------------------------------------
* Local Continuity Assumption
*
*-------------------------------------------------------------------------------
gl controls "mayorallied i.mayorallied#c.z_sh_votes_alc z_sh_votes_alc"
gl fes      "region year"

rdrobust floss_prim_ideam_area_v2 z_sh_votes_alc, all kernel(triangular) covs(${fes})
gl h  = e(h_l)
gl ht = round(${h}, .001)
gl if "if abs(z_sh_votes_alc)<=${h}"

cap drop tweights
gen tweights = (1-abs(z_sh_votes_alc/${h})) ${if}

*-------------------------------------------------------------------------------
* Preparing vars
*-------------------------------------------------------------------------------
* Coca share
tab year if H_coca!=.
replace H_coca = 0 if H_coca==.
gen sh_area_coca = H_coca/area
gen sh_area_agro=areamuniagro/area

* Night lights (log)
gen ln_nl = log(night_light)

* GDP per capita (log)
gen ln_pibpc = ln(pib_percapita)
gen ln_va=ln(va)
replace ln_va=log(pib_cons) if ln_va==.

* Royalties (log)
ren SRAingeominasanh_giros_totales giros_totales
gen ln_regalias = ln(giros_totales)

* Public investment shares
gen desemp_fisc_index=DF_desemp_fisc if DF_desemp_fisc>0
gen sh_invenv = inv_ambiental/inv_total
gen ln_inv_total=ln(inv_total)

* Cattle
gen sh_bovinos = bovinos/pobl_tot

* Crimes (shares needed for demovars)
gen sh_crimeenv    = crime_environment/total_procesos
gen sh_crimeforest = crime_forest/crime_environment
gen crime_env_rate=(crime_environment/pobl_tot)*10000
gen crime_forest_rate=(crime_forest/pobl_tot)*10000

* Population (log, anchored to 2010 then averaged at coddane)
gen ln_pobl_tot = ln(pobl_tot93)
replace ln_pobl_tot = . if year!=2010
bys coddane: egen ln_pobl_tot18 = mean(ln_pobl_tot)

* Poverty MPI (rename to mpi)
ren IPM mpi

* --- Geovars used directly in coefplot of "geographic characteristics" ---
gen ln_area = ln(area)
bys carcode_master: egen cararea = sum(area)
gen sh_area = area*100/cararea

* Distance to markets (log)
gen ln_dist_mcados = ln(dismdo)

* Crop suitability (mean over chosen SUTs)
egen mean_sut_crops = rowmean(sut_cof sut_banana sut_cocoa sut_rice sut_oil)
replace mean_sut_crops=mean_sut_crops /10000 //Normalizing by max

* Forest cover share & PA share
gen sh_area_forest = primary_forest01/area
gen sh_paarea      = pa_area/area

*-------------------------------------------------------------------------------
* Sample for pre-treatment construction and merge back
*-------------------------------------------------------------------------------
reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2!=., ///
    abs(${fes}) vce(robust)
gen regsample = e(sample)

* Only keep variables that will become pre_* and are actually used in coefplots
gl varst "ln_pibpc ln_nl ln_regalias sh_invenv sh_area_coca sh_bovinos ln_pobl_tot mpi indrural sh_votes_reg incumbent sh_crimeenv sh_crimeforest sh_votes_alc incumbent_gob sh_area_agro bii ln_va desemp_fisc_index ln_inv_total floss_prim_ideam_area_v2"

preserve
    bys coddane: egen always = max(regsample)

    sort coddane election year, stable
    collapse (firstnm) ${varst} regsample always, by(coddane election)
    sort coddane election

    replace regsample = . if regsample==0
    by coddane: carryforward regsample, gen(xt)
    replace xt = 0 if xt==. & always==1

    keep if always==1
    collapse (mean) ${varst}, by(coddane xt)
    keep if xt==0
    drop xt

    ren (${varst}) pre_=
    tempfile NONCONSTANTVARS
    save `NONCONSTANTVARS', replace
restore

merge m:1 coddane using `NONCONSTANTVARS', keep(1 3) nogen

* Geovars
la var ln_area        "Log(Area km²)"
la var sh_area        "Area in REPA (sh)"
la var sh_area_forest "Primary forest cover (sh)"
la var ln_dist_mcados "Log(Distance to market)"
la var mean_sut_crops "Crop suitability"
la var altura "Elevation (masl)"

* Econ pre-treatment
la var pre_ln_pibpc     "Log(GDP per capita)"
la var pre_ln_nl        "Log(Night Light)"
la var pre_ln_regalias  "Log(Royalties)"
la var pre_sh_invenv    "Environment Investment (sh)"
la var pre_sh_area_coca "Coca area (sh)"
la var pre_sh_bovinos   "Cattle per inhabitant"

* Demo pre-treatment
la var pre_ln_pobl_tot     "Log(Total population)"
la var pre_mpi             "Poverty index (MPI)"
la var pre_indrural        "Rurality index"
la var pre_sh_votes_reg    "Registered voter (sh)"
la var pre_incumbent       "Party incumbency"
la var pre_sh_crimeenv     "Environment crimes (sh)"
la var pre_sh_crimeforest  "Forestry crimes (sh)"

*-------------------------------------------------------------------------------
* LC Results — Plot 1: Physical / Land cover & Access (7 vars)
*-------------------------------------------------------------------------------
// *gl physvars "altura mean_sut_crops ln_area sh_area sh_area_forest sh_paarea ln_dist_mcados"
// gl physvars "ln_area sh_area pre_sh_area_agro sh_area_forest altura mean_sut_crops ln_dist_mcados pre_bii"
//
// mat C1 = J(4, 8, .)
// mat coln C1 = ${physvars}
//
// local i = 1
// foreach yvar of global physvars {
//     cap drop std_`yvar'
//     egen std_`yvar' = std(`yvar')
//	
//     reghdfe std_`yvar' ${controls} [aw=tweights] ${if} & ///
//         director_gob_law_v2!=., abs(${fes}) vce(robust)
//	
//     lincom mayorallied
//     mat C1[1,`i'] = r(estimate)
//     mat C1[2,`i'] = r(lb)
//     mat C1[3,`i'] = r(ub)
//     mat C1[4,`i'] = r(p)
//	
// 	eststo p1_`i': reghdfe `yvar' ${controls} [aw=tweights] ${if} & ///
//         director_gob_law_v2!=., abs(${fes}) vce(robust)
// 	summ `yvar' if e(sample)==1, d
// 	gl mp1_`i'= "`=string(round(r(mean), .01), "%9.2f")'"
//	
//     local i = `i' + 1
//
// }
//
// coefplot (mat(C1[1]), ci((2 3)) aux(4)), xline(0, lp(dash) lc("maroon")) ///
//     b2title("Effect of Partisan Alignment (std)", size(medsmall)) ///
//     ciopts(recast(rcap)) ylab(, labsize(medsmall)) ///
//     ytitle("Dependent Variable (Pre-treatment)", size(medium)) ///
//     mlabel(cond(@aux1<=.01,"***",cond(@aux1<=.05,"**",cond(@aux1<=.1,"*","")))) ///
//     mlabposition(12) mlabgap(*2)
//
// 	gr export "${plots}\rdplot_lc_results_geovars.pdf", as(pdf) replace 
	
*-------------------------------------------------------------------------------
* LC Results — Plot 2: Economic activity & Investment (7 vars)
*-------------------------------------------------------------------------------
*gl econvars "pre_ln_pibpc pre_ln_regalias pre_sh_invpib pre_sh_invenv pre_ln_nl pre_sh_area_coca pre_sh_bovinos"
gl econvars "pre_ln_va pre_ln_nl pre_desemp_fisc_index pre_ln_regalias pre_ln_inv_total pre_sh_invenv pre_sh_area_coca pre_sh_bovinos pre_floss_prim_ideam_area_v2 sh_paarea"

mat C2 = J(4, 10, .)
mat coln C2 = ${econvars}

local i = 1
foreach yvar of global econvars {
    cap drop std_`yvar'
    egen std_`yvar' = std(`yvar')
	
	reghdfe std_`yvar' ${controls} [aw=tweights] ${if} & ///
        director_gob_law_v2!=., abs(${fes}) vce(robust)
			
    lincom mayorallied
    mat C2[1,`i'] = r(estimate)
    mat C2[2,`i'] = r(lb)
    mat C2[3,`i'] = r(ub)
    mat C2[4,`i'] = r(p)
		
	eststo p2_`i': reghdfe `yvar' ${controls} [aw=tweights] ${if} & ///
        director_gob_law_v2!=., abs(${fes}) vce(robust)
	summ `yvar' if e(sample)==1, d
	gl mp2_`i'= "`=string(round(r(mean), .01), "%9.2f")'"
	
    local i = `i' + 1
	
}

coefplot (mat(C2[1]), ci((2 3)) aux(4)), xline(0, lp(dash) lc("maroon")) ///
    b2title("Effect of Partisan Alignment (std)", size(medsmall)) ///
    ciopts(recast(rcap)) ylab(, labsize(medsmall)) ///
    ytitle("Dependent Variable (Pre-treatment)", size(medium)) ///
    mlabel(cond(@aux1<=.01,"***",cond(@aux1<=.05,"**",cond(@aux1<=.1,"*","")))) ///
    mlabposition(12) mlabgap(*2)	
	
END
	gr export "${plots}\rdplot_lc_results_econvars.pdf", as(pdf) replace 

*-------------------------------------------------------------------------------
* LC Results — Plot 3: Demographics, Politics & Security (7 vars)
*-------------------------------------------------------------------------------
gl demopolsec "pre_ln_pobl_tot pre_mpi pre_indrural pre_sh_votes_reg pre_incumbent pre_sh_crimeenv pre_sh_crimeforest"

mat C3 = J(4, 7, .)
mat coln C3 = ${demopolsec}

local i = 1
foreach yvar of global demopolsec {
    cap drop std_`yvar'
    egen std_`yvar' = std(`yvar')
	
    reghdfe std_`yvar' ${controls} [aw=tweights] ${if} & ///
        director_gob_law_v2!=., abs(${fes}) vce(robust)
	
    lincom mayorallied
    mat C3[1,`i'] = r(estimate)
    mat C3[2,`i'] = r(lb)
    mat C3[3,`i'] = r(ub)
    mat C3[4,`i'] = r(p)
	
	eststo p3_`i': reghdfe `yvar' ${controls} [aw=tweights] ${if} & ///
        director_gob_law_v2!=., abs(${fes}) vce(robust)
	summ `yvar' if e(sample)==1, d
	gl mp3_`i'= "`=string(round(r(mean), .01), "%9.2f")'"
	
    local i = `i' + 1
	
}

coefplot (mat(C3[1]), ci((2 3)) aux(4)), xline(0, lp(dash) lc("maroon")) ///
    b2title("Effect of Partisan Alignment (std)", size(medsmall)) ///
    ciopts(recast(rcap)) ylab(, labsize(medsmall)) ///
    ytitle("Dependent Variable (Pre-treatment)", size(medium)) ///
    mlabel(cond(@aux1<=.01,"***",cond(@aux1<=.05,"**",cond(@aux1<=.1,"*","")))) ///
    mlabposition(12) mlabgap(*2)
			
	gr export "${plots}\rdplot_lc_results_demovars.pdf", as(pdf) replace 

*-------------------------------------------------------------------------------
* Table
*-------------------------------------------------------------------------------
* --- Plot 1: Physical / Land cover & Access ---
esttab p1_1 p1_2 p1_3 p1_4 p1_5 p1_6 p1_7 using "${tables}/rd_lc_results.tex", ///
    keep(mayorallied) se nocons star(* 0.10 ** 0.05 *** 0.01) ///
    label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
    prehead(`"\begin{tabular}{@{}l*{7}{c}}"' ///
            `"\hline \hline \toprule"' ///
            `"\multicolumn{8}{c}{\textit{Panel A: Geographical Characteristics}} \\"' ///
			`"\midrule"' ///
            `" & Elevation (masl) & Crop suitability & Log(Area km$^{2}$) & Ecological Area (sh) & Primary forest (sh) & Protected area (sh) & Log(Distance to market) \\"' ///
            `" & (1) & (2) & (3) & (4) & (5) & (6) & (7) \\"' ///
            `"\midrule"') ///
    postfoot(`" Dependent mean (lvl) & ${mp1_1} & ${mp1_2} & ${mp1_3} & ${mp1_4} & ${mp1_5} & ${mp1_6} & ${mp1_7} \\"' ///
			`"\toprule"' ///
            `" \multicolumn{8}{c}{\textit{Panel B: Economic Characteristics}} \\"' ///
			`"\midrule"' ///
            `" & Log(GDP pc) & Log(Royalties) & Public Inv. (sh) & Env. Inv. (sh) & Log(Night Light) & Coca area (sh) & Cattle per inhabitant \\"' ///
            `" & (8) & (9) & (10) & (11) & (12) & (13) & (14) \\"' ///
            `"\midrule"')

* --- Plot 2: Economic activity & Investment ---
esttab p2_1 p2_2 p2_3 p2_4 p2_5 p2_6 p2_7 using "${tables}/rd_lc_results.tex", ///
    keep(mayorallied) se nocons star(* 0.10 ** 0.05 *** 0.01) ///
    label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) append ///
    postfoot(`" Dependent mean (lvl) & ${mp2_1} & ${mp2_2} & ${mp2_3} & ${mp2_4} & ${mp2_5} & ${mp2_6} & ${mp2_7} \\"' ///
			`"\toprule"' ///
            `"\multicolumn{8}{c}{\textit{Panel C: Demographic and Politic Characteristics}} \\"' ///
			`"\midrule"' ///
            `" & Log(Population) & Poverty index & Rurality index & Registered voters (sh) & Party Incumbent & Env. crimes (sh) & Forestry crimes (sh) \\"' ///
            `" & (15) & (16) & (17) & (18) & (19) & (20) & (21) \\"' ///
            `"\midrule"')

* --- Plot 3: Demographics, Politics & Security ---
esttab p3_1 p3_2 p3_3 p3_4 p3_5 p3_6 p3_7 using "${tables}/rd_lc_results.tex", ///
    keep(mayorallied) se nocons star(* 0.10 ** 0.05 *** 0.01) ///
    label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) append ///
    postfoot(`" Dependent mean (lvl) & ${mp3_1} & ${mp3_2} & ${mp3_3} & ${mp3_4} & ${mp3_5} & ${mp3_6} & ${mp3_7} \\"' ///
			`"\bottomrule \end{tabular}"')
			

			
			
			
			
			
			
			

*END







/*use "${data}/Interim\defo_caralc.dta", clear 


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

pca sut_cof sut_banana sut_cocoa sut_rice sut_oil, components(1) 
predict sut_pc, score

egen area_siembra=rowtotal(as_arrozr as_arrozsm as_arrozsme as_palmaa as_palmaam as_palmar as_soya), m
gen sh_area_siembra=area_siembra/area
replace sh_area_siembra=0 if sh_area_siembra==.

egen producto_siembra=rowtotal(p_arrozr p_arrozsm p_arrozsme p_palmaa p_palmaam p_palmar p_soya), m
replace producto_siembra=0 if producto_siembra==.
gen ln_prod_crops=ln(producto_siembra)

gen primary_forest01_nopa=primary_forest01 - primary_forest01_pa

gen sh_area_forest=primary_forest01/area
gen sh_area_forest_pa=primary_forest01_pa/area
gen sh_area_forest_nopa=primary_forest01_nopa/area

replace sh_area_forest=0 if primary_forest01_nopa<0
replace sh_area_forest_pa=0 if primary_forest01_nopa<0
replace sh_area_forest_nopa=0 if primary_forest01_nopa<0

ren SRAingeominasanh_giros_totales giros_totales

egen dist_mcados=rowmean(dismdo distancia_mercado)
gen ln_dist_mcados=ln(dist_mcados)

egen mean_sut_crops=rowmean(sut_cof sut_banana sut_cocoa sut_rice sut_oil)

gen ln_area=ln(area)
gen sh_area_agro=areamuniagro/area

replace total_procesos=0 if total_procesos==.
replace crime_environment=0 if crime_environment==.
replace crime_forest=0 if crime_forest==.

gen crime_rate=(total_procesos/pobl_tot)*10000
gen crime_env_rate=(crime_environment/pobl_tot)*10000
gen crime_forest_rate=(crime_forest/pobl_tot)*10000

bys coddane: egen mean_nbi=mean(nbi)
bys coddane: egen mean_gini=mean(gini)

ren IPM mpi
bys coddane: egen mean_ipm=mean(mpi)

gen ln_pibpc=ln(pib_percapita)
gen ln_pibagro=ln(pib_agricola)
gen ln_pibtot=ln(pib_total)
gen ln_regalias=ln(giros_totales)
gen ln_inv_total=ln(inv_total)
gen ln_inv_ambiental=ln(inv_ambiental)

gen desemp_fisc_index=DF_desemp_fisc

gen sh_area_bovino=bovinos/area
gen ln_pobl_tot93=ln(pobl_tot93)
gen ln_pobl_tot=ln(pobl_tot)

replace ln_pobl_tot=. if year!=2010
bys coddane: egen ln_pobl_tot18=mean(ln_pobl_tot)

gen ln_va=ln(va)
gen ln_va_prim=ln(va_prim)
gen ln_va_sec=ln(va_sec)
gen ln_va_terc=ln(va_terc)
replace ln_va=log(pib_cons) if ln_va==.

summ night_light, d
replace night_light=. if night_light>`r(p99)' | night_light<`r(p1)'

*Sample var
reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2!=., abs(${fes}) vce(robust)
gen regsample=e(sample)

*Asigning the pre-treatment var value
gl varst "ln_pibagro ln_pibtot pobl_rur crime_rate crime_env_rate crime_forest_rate ln_pibpc desemp_fisc_index ln_regalias ln_inv_total ln_inv_ambiental sh_area_coca sh_area_siembra ln_prod_crops sh_area_bovino floss_prim_ideam_area sh_area_agro nbi mpi indrural sh_votes_reg incumbent ln_va ln_va_prim ln_va_sec ln_va_terc night_light bii"

preserve 
	bys coddane: egen always=max(regsample)

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
la var sh_area_forest_pa `" "Protected Primary" "forest cover (sh)" "'
la var sh_area_forest_nopa `" "Unprotected Primary" "forest cover (sh)" "'
la var altura "Altitude (masl)"
la var mean_sut_crops "Crop suitability"
la var ln_dist_mcados "Log(Distance to market Km2)"
la var gamazonia "Amazonia region"
la var gorinoquia "Orinoquia region"
la var gpacifica "Pacific region"
la var gcaribe "Caribe region"
la var gandina "Andean region"

la var ln_pobl_tot93 "Log(Population-'93)"
la var pobreza93 "Poverty incidence-'93"
la var pre_nbi "UBN index"
la var mean_gini "Gini index"
la var pre_mpi "Poverty index"
la var pre_crime_rate "Crime rate" 
la var pre_crime_env_rate "Env. crime rate"
la var pre_crime_forest_rate "Forest crime rate"
la var pre_indrural "Rurality index"
la var pre_sh_votes_reg "Registered voter (sh)"
la var pre_incumbent "Incumbent (prob)"

la var ln_pibtot "Log(Total GDP)"
la var pre_ln_va "Log(Total GDP)"
la var pre_desemp_fisc_index "Fiscal performance Index "
la var pre_ln_regalias "Log(Royalties)"
la var pre_ln_inv_total "Log(Public Investment)"
la var pre_ln_inv_ambiental "Log(Env. Investment)"
la var pre_sh_area_coca "Coca area (sh)"
la var pre_sh_area_siembra "Planted area (sh)"
la var pre_ln_prod_crops "Log(Crop produce ton)"
la var pre_sh_area_bovino "Cattle per Km2"
la var pre_floss_prim_ideam_area "Primary Forest loss (sh)"

la var pre_night_light "Night Light"
la var pre_bii "Biodiversity Index"

*-------------------------------------------------------------------------------
* LC Results
*-------------------------------------------------------------------------------
eststo clear

*Geographic characteristics
gl geovars "ln_area pre_sh_area_agro sh_area_forest sh_area_forest_pa sh_area_forest_nopa altura mean_sut_crops ln_dist_mcados pre_bii"

mat CG=J(4,9,.)
mat coln CG=${geovars}

local i=1

foreach yvar of global geovars {
	
	egen std_`yvar'= std(`yvar')
	
	eststo g`i': reghdfe std_`yvar' ${controls} [aw=tweights] ${if} & director_gob_law_v2!=., abs(${fes}) vce(robust)
		
	lincom mayorallied
	mat CG[1,`i']= r(estimate) 
	mat CG[2,`i']= r(lb)
	mat CG[3,`i']= r(ub)
	mat CG[4,`i']= r(p)
	
	local i=`i'+1
}

*Demographic characteristics
gl demovars "ln_pobl_tot93 pobreza93 pre_indrural mean_gini pre_crime_rate pre_crime_env_rate pre_crime_forest_rate pre_sh_votes_reg pre_incumbent"

mat CD=J(4,9,.)
mat coln CD=${demovars}

local i=1

foreach yvar of global demovars {
	
	egen std_`yvar'= std(`yvar')
	
	eststo d`i': reghdfe std_`yvar' ${controls} [aw=tweights] ${if} & director_gob_law_v2!=., abs(${fes}) vce(robust)
		
	lincom mayorallied
	mat CD[1,`i']= r(estimate) 
	mat CD[2,`i']= r(lb)
	mat CD[3,`i']= r(ub)
	mat CD[4,`i']= r(p)
	
	local i=`i'+1
}

*Economic characteristics
gl econvars "pre_ln_va pre_night_light pre_desemp_fisc_index pre_ln_regalias pre_ln_inv_total pre_ln_inv_ambiental pre_sh_area_coca pre_sh_area_bovino pre_floss_prim_ideam_area"

mat CE=J(4,9,.)
mat coln CE=${econvars}

local i=1

foreach yvar of global econvars {
	
	egen std_`yvar'= std(`yvar')
	
	eststo e`i': reghdfe std_`yvar' ${controls} [aw=tweights] ${if} & director_gob_law_v2!=., abs(${fes}) vce(robust)
		
	lincom mayorallied
	mat CE[1,`i']= r(estimate) 
	mat CE[2,`i']= r(lb)
	mat CE[3,`i']= r(ub)
	mat CE[4,`i']= r(p)
	
	local i=`i'+1
}

*-------------------------------------------------------------------------------
* Tables and coefplots
*-------------------------------------------------------------------------------
*Exporting geographic results 
esttab g1 g2 g3 g4 g5 g6 g7 g8 g9 using "${tables}/rdplot_lc_results_geovars.tex", keep(mayorallied) ///
se nocons star(* 0.10 ** 0.05 *** 0.01) ///
label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
prehead(`"\begin{tabular}{@{}l*{9}{c}}"' ///
            `"\hline \toprule"'                     ///
            `" & \multicolumn{7}{c}{Geographic Characteristics} \\ \cmidrule(l){2-10}"'                   ///
            `" & Log(Area Km2) & Agricultural area (sh) & Forest area (sh) & Protected Forest area (sh) & Unprotected Forest area (sh) & Altitude (masl) & Crop suitability (gaez) & Log(Distance to market Km2) & Biodiversity Intactness (\%) \\"'                   ///
            `" & (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) & (9)  \\"'                       ///
            `" \toprule"')  ///
    postfoot(`"\bottomrule \end{tabular}"') 

coefplot (mat(CG[1]), ci((2 3)) aux(4)), xline(0, lp(dash) lc("maroon")) b2title("Magnitude of the partisan alignment coefficient (std)", size(medsmall)) ciopts(recast(rcap)) ylab(, labsize(medsmall)) l2title("Dependent variable in pre-treatment", size(medium)) ///
mlabel(cond(@aux1<=.01, "***", cond(@aux1<=.05, "**", cond(@aux1<=.1, "*", """")))) mlabposition(12) mlabgap(*2)

gr export "${plots}\rdplot_lc_results_geovars.pdf", as(pdf) replace 

*Exporting demographic results 
esttab d1 d2 d3 d4 d5 d6 d7 d8 d9 using "${tables}/rdplot_lc_results_demovars.tex", keep(mayorallied) ///
se nocons star(* 0.10 ** 0.05 *** 0.01) ///
label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
prehead(`"\begin{tabular}{@{}l*{9}{c}}"' ///
            `"\hline \toprule"'                     ///
            `" & \multicolumn{9}{c}{Demographic Characteristics} \\ \cmidrule(l){2-10}"'                   ///
            `" & Log(Population in 1993 & Poverty incidence in 1993 & Rurality index & Gini index & Crime rate (1k inh) & Env. crime rate (10k inh) & Forest crime rate (10k inh) & Register voters (sh) & Incumbent (prob) \\"'                   ///
            `" & (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) & (9) \\"'                       ///
            `" \toprule"')  ///
    postfoot(`"\bottomrule \end{tabular}"') 

coefplot (mat(CD[1]), ci((2 3)) aux(4)), xline(0, lp(dash) lc("maroon")) b2title("Magnitude of the partisan alignment coefficient (std)", size(medsmall)) ciopts(recast(rcap)) ylab(, labsize(medsmall)) l2title("Dependent variable in pre-treatment", size(medium)) ///
mlabel(cond(@aux1<=.01, "***", cond(@aux1<=.05, "**", cond(@aux1<=.1, "*", """")))) mlabposition(12) mlabgap(*2)

gr export "${plots}\rdplot_lc_results_demovars.pdf", as(pdf) replace 

*Exporting economic results 
esttab e1 e2 e3 e4 e5 e6 e7 e8 e9 using "${tables}/rdplot_lc_results_econvars.tex", keep(mayorallied) ///
se nocons star(* 0.10 ** 0.05 *** 0.01) ///
label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
prehead(`"\begin{tabular}{@{}l*{9}{c}}"' ///
            `"\hline \toprule"'                     ///
            `" & \multicolumn{9}{c}{Economic Characteristics} \\ \cmidrule(l){2-10}"'                   ///
            `" & Log(Total GDP) & Night Light & Fiscal performance Index & Log(Royalties) & Log(Public Investment) & Log(Env. Investment) & Coca area (sh) & Cattle per Km2 & Primary Forest loss (sh) \\"'                   ///
            `" & (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) & (9) \\"'                       ///
            `" \toprule"')  ///
    postfoot(`"\bottomrule \end{tabular}"') 
	
coefplot (mat(CE[1]), ci((2 3)) aux(4)), xline(0, lp(dash) lc("maroon")) b2title("Magnitude of the partisan alignment coefficient (std)", size(medsmall)) ciopts(recast(rcap)) ylab(, labsize(medsmall)) l2title("Dependent variable in pre-treatment", size(medium)) ///
mlabel(cond(@aux1<=.01, "***", cond(@aux1<=.05, "**", cond(@aux1<=.1, "*", """")))) mlabposition(12) mlabgap(*2)

gr export "${plots}\rdplot_lc_results_econvars.pdf", as(pdf) replace 










*END
