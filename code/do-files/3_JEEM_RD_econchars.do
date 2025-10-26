use "${data}/Interim\defo_caralc.dta", clear 

*-------------------------------------------------------------------------------
* Vars and Labels (only those used later)
*-------------------------------------------------------------------------------
* Shares / logs used in Yvars
gen sh_bovinos     = bovinos/pobl_tot
gen sh_coca_area   = H_coca*0.01/area
gen sh_sown_area   = tot_sown_area*0.01/area
gen sh_harv_area   = tot_harv_area*0.01/area
gen ln_va          = ln(va)
replace ln_va      = log(pib_cons) if ln_va==.
gen ln_regalias    = log(y_cap)
gen sh_gy          = g_cap/y_cap

* Labels (short, publication-ready)
label variable ln_va                     "Log(GDP)"
label variable night_light               "Night lights"
label variable ln_regalias               "Log(Royalties)"
label variable sh_gy                     "Investment to royalties"
label variable sh_bovinos                "Cattle per capita"
label variable sh_coca_area              "Coca area (sh)"
label variable sh_sown_area              "Sown area (sh)"
label variable sh_harv_area              "Harvested area (sh)"
label variable built_area_floss          "Built on forest lost (%)"
label variable grass_shrub_area_floss    "Grass/shrub on forest lost (%)"
label variable crop_area_floss           "Crops on forest lost (%)"

*-------------------------------------------------------------------------------
* Main Results
*-------------------------------------------------------------------------------
global controls "mayorallied i.mayorallied#c.z_sh_votes_alc z_sh_votes_alc"
global fes      "region year"

rdrobust floss_prim_ideam_area_v2 z_sh_votes_alc, all kernel(triangular) covs(${fes})
global h  = e(h_l)
global ht = round(${h}, .001)
global if "if abs(z_sh_votes_alc)<=${h}"

cap drop tweights
gen tweights = (1-abs(z_sh_votes_alc/${h})) ${if}

eststo clear

*-------------------------------------------------------------------------------
* Economic characteristics (set actually-used outcomes)
*-------------------------------------------------------------------------------
global Yvars "sh_bovinos grass_shrub_area_floss crop_area_floss built_area_floss sh_sown_area sh_harv_area ln_va night_light ln_regalias sh_gy"

mat C = J(4, 10, .)
mat coln C = ${Yvars}

local i = 1
foreach yvar of global Yvars {
    cap drop std_`yvar'
    bys year: egen std_`yvar' = std(`yvar')

    reghdfe std_`yvar' ${controls} [aw=tweights] ${if} & year>=2014, abs(${fes}) vce(robust)
    lincom mayorallied
    mat C[1,`i'] = r(estimate)
    mat C[2,`i'] = r(lb)
    mat C[3,`i'] = r(ub)
    mat C[4,`i'] = r(p)
	
	eststo p1_`i': reghdfe `yvar' ${controls} [aw=tweights] ${if} & year>=2014, abs(${fes}) vce(robust)
	summ `yvar' if e(sample)==1, d
	gl mp1_`i'= "`=string(round(r(mean), .01), "%9.2f")'"
	
    local i = `i' + 1
}

coefplot (mat(C[1]), ci((2 3)) aux(4)), xline(0, lp(dash) lc("maroon")) ///
    b2title("Effect of Partisan Alignment (std)", size(medium)) ciopts(recast(rcap)) ///
    ylab(, labsize(medsmall)) ///
    mlabel(cond(@aux1<=.01, string(@b, "%9.2fc")+"***", ///
           cond(@aux1<=.05, string(@b, "%9.2fc")+"**", ///
           cond(@aux1<=.1,  string(@b, "%9.2fc")+"*",  string(@b, "%9.2fc"))))) ///
    mlabposition(12) mlabgap(*2) mlabsize(medsmall) ///
    xlabel(, labsize(medium)) ytitle("Dependent Variable", size(medium))

gr export "${plots}/coefplot_rd_econchars.pdf", as(pdf) replace

*-------------------------------------------------------------------------------
* Economic characteristics by Gov. Head
*-------------------------------------------------------------------------------
global Yvars "sh_bovinos grass_shrub_area_floss crop_area_floss built_area_floss sh_sown_area sh_harv_area ln_va night_light ln_regalias sh_gy"

mat C = J(4, 10, .)
mat coln C = ${Yvars}

local i = 1
foreach yvar of global Yvars {
    cap drop std_`yvar'
    bys year: egen std_`yvar' = std(`yvar')

    reghdfe std_`yvar' ${controls} [aw=tweights] ${if} & director_gob_law_v2==1 & year>=2014, abs(${fes}) vce(robust)
    lincom mayorallied
    mat C[1,`i'] = r(estimate)
    mat C[2,`i'] = r(lb)
    mat C[3,`i'] = r(ub)
    mat C[4,`i'] = r(p)
	
	eststo p2_`i': reghdfe `yvar' ${controls} [aw=tweights] ${if} & director_gob_law_v2==1 & year>=2014, abs(${fes}) vce(robust)
	summ `yvar' if e(sample)==1, d
	gl mp2_`i'= "`=string(round(r(mean), .01), "%9.2f")'"
	 
    local i = `i' + 1
}

coefplot (mat(C[1]), ci((2 3)) aux(4)), xline(0, lp(dash) lc("maroon")) ///
    b2title("Effect of Partisan Alignment (std)", size(medium)) ciopts(recast(rcap)) ///
    ylab(, labsize(medsmall)) ///
    mlabel(cond(@aux1<=.01, string(@b, "%9.2fc")+"***", ///
           cond(@aux1<=.05, string(@b, "%9.2fc")+"**", ///
           cond(@aux1<=.1,  string(@b, "%9.2fc")+"*",  string(@b, "%9.2fc"))))) ///
    mlabposition(12) mlabgap(*2) mlabsize(medsmall) ///
    xlabel(, labsize(medium)) ytitle("Dependent Variable", size(medium))

gr export "${plots}/coefplot_rd_econchars_govhead.pdf", as(pdf) replace

*-------------------------------------------------------------------------------
* Table
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
* Table: Economic Characteristics — Full sample (A) vs Gov. Head aligned (B)
*-------------------------------------------------------------------------------
* Panel A (open table and write full-sample results)
esttab p1_1 p1_2 p1_3 p1_4 p1_5 p1_6 p1_7 p1_8 p1_9 p1_10 using "${tables}/rd_econchars_results.tex", ///
    keep(mayorallied) se nocons star(* 0.10 ** 0.05 *** 0.01) ///
    label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
    prehead(`"\begin{tabular}{@{}l*{10}{c}}"' ///
            `"\hline \hline \toprule"' ///
            `"\multicolumn{11}{c}{\textit{Panel A: Sample of all REPAs}} \\"' ///
            `"\midrule"' ///
            `" & Cattle & Grass/shrub on & Crops on & Built on & Sown area & Harvested & Log(GDP) & Night lights & Log(Royalties) & Investment to \\"' ///
			`" & per capita & forest loss (\%) & forest loss (\%) & forest loss (\%) & (sh) & area (sh) & & & & Royalties \\"' ///
            `" & (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) & (9) & (10) \\"' ///
            `"\midrule"') ///
    postfoot(`"Dep. mean (level) & ${mp1_1} & ${mp1_2} & ${mp1_3} & ${mp1_4} & ${mp1_5} & ${mp1_6} & ${mp1_7} & ${mp1_8} & ${mp1_9} & ${mp1_10} \\"' ///
             `"\toprule"' ///
             `"\multicolumn{11}{c}{\textit{Panel B: Sample of REPAs with governor as head}} \\"' ///
			 `"\midrule"' ///
            `" & Cattle & Grass/shrub on & Crops on & Built on & Sown area & Harvested & Log(GDP) & Night lights & Log(Royalties) & Public \\"' ///
			`" & per capita & forest loss (\%) & forest loss (\%) & forest loss (\%) & (sh) & area (sh) & & & & Investment (sh) \\"' ///
			 `" & (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) & (9) & (10) \\"' ///
             `"\midrule"' )

* Panel B (append gov-head subsample into the same tabular; then close it)
esttab p2_1 p2_2 p2_3 p2_4 p2_5 p2_6 p2_7 p2_8 p2_9 p2_10 using "${tables}/rd_econchars_results.tex", ///
    keep(mayorallied) se nocons star(* 0.10 ** 0.05 *** 0.01) ///
    label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) append ///
    postfoot(`"Dep. mean (level) & ${mp2_1} & ${mp2_2} & ${mp2_3} & ${mp2_4} & ${mp2_5} & ${mp2_6} & ${mp2_7} & ${mp2_8} & ${mp2_9} & ${mp2_10} \\"' ///
             `"\bottomrule \end{tabular}"')






			 
			 
*END












/*use "${data}/Interim\defo_caralc.dta", clear 


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
gen ln_regalias=log(y_cap)
gen ln_g_total=log(g_total)
gen sh_bovinos=bovinos/pobl_tot
gen sh_coca_area=H_coca*0.01/primary_forest01
gen sh_sown_area=tot_sown_area*0.01/primary_forest01  
gen sh_harv_area=tot_harv_area*0.01/primary_forest01
gen ln_tot_prod=log(tot_prod)
gen ln_va=ln(va)
gen ln_va_prim=ln(va_prim)
gen ln_va_sec=ln(va_sec)
gen ln_va_terc=ln(va_terc)
replace ln_va=log(pib_cons) if ln_va==.
gen ln_bovinos=log(sh_bovinos)
replace tot_harv_area=tot_harv_area*0.01
gen ln_tot_harv_area=log(tot_harv_area)

gen sh_gy = g_cap/y_cap
gen ln_nl = log(night_light)

la var ln_va "Log(GDP)"
la var ln_pib_percapita_cons "Log(GDP percapita)"
la var ln_pib_agricola "Log(Agricultural GDP)"
la var night_light "Night Light - radiance"
la var ln_regalias "Log(Royalties)"
la var ln_g_total "Log(Public expenditure)"
la var sh_bovinos "Cattle per inhabitant (100k)"
la var sh_coca_area "Coca area (%)"
la var sh_sown_area "Crop sown area (%)"
la var sh_harv_area "Crop harvested area (%)"
la var yield_allcrop "Crop yield (tns/ha)"
la var ln_tot_prod "Log(Crop production)"
la var ln_bovinos "Log(Cattle per inhabitant)"
la var ln_tot_harv_area "Log(Harvested area)"

la var ln_va_prim "Log(GDP primary)"
la var ln_va_sec "Log(GDP manufacture)"
la var ln_va_terc "Log(GDP services)"

la var built_area_floss "Built on lost forest (%)"
la var grass_shrub_area_floss "Grass on lost forest (%)"
la var crop_area_floss "Crop on lost forest (%)"

la var sh_gy "Investment from royalties (sh)"


*-------------------------------------------------------------------------------
* Main Results
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

eststo clear

*-------------------------------------------------------------------------------
* Economic characteristics 
*-------------------------------------------------------------------------------
gl Yvars "sh_bovinos grass_shrub_area_floss crop_area_floss built_area_floss sh_sown_area sh_coca_area ln_va night_light ln_regalias sh_gy"

foreach yvar of global Yvars{
tabstat `yvar',by(year)
}

mat C=J(4,16,.)
mat coln C =${Yvars}

local i=1

foreach yvar of global Yvars{

	cap drop std_`yvar'
	bys year: egen std_`yvar'= std(`yvar')
	
	reghdfe std_`yvar' ${controls} [aw=tweights] ${if} & year>=2014, abs(${fes}) vce(robust)
	lincom mayorallied
	mat C[1,`i']= r(estimate) 
	mat C[2,`i']= r(lb)
	mat C[3,`i']= r(ub)
	mat C[4,`i']= r(p)
	
	local i=`i'+1
	
}

coefplot (mat(C[1]), ci((2 3)) aux(4)), xline(0, lp(dash) lc("maroon")) b2title("Effect of Alignment", size(medium)) ciopts(recast(rcap)) ylab(, labsize(medsmall)) ///
mlabel(cond(@aux1<=.01, string(@b, "%9.2fc") +"***", cond(@aux1<=.05, string(@b, "%9.2fc") +"**", cond(@aux1<=.1, string(@b, "%9.2fc") +"*", string(@b, "%9.2fc"))))) mlabposition(12) mlabgap(*2) mlabsize(medsmall) ///
xlabel(, labsize(medium)) l2title("Dependent Variable (std)", size(medium))


END
gr export "${plots}/coefplot_rd_econchars.pdf", as(pdf) replace

*-------------------------------------------------------------------------------
* Economic characteristics by gov head
*-------------------------------------------------------------------------------
gl Yvars "sh_bovinos grass_shrub_area_floss crop_area_floss built_area_floss sh_coca_area yield_allcrop ln_va ln_va_prim ln_va_sec ln_va_terc night_light ln_regalias ln_g_total"

foreach yvar of global Yvars{
tabstat `yvar',by(year)
}

mat C=J(4,13,.)
mat coln C =${Yvars}

local i=1

foreach yvar of global Yvars{

	cap drop std_`yvar'
	bys year: egen std_`yvar'= std(`yvar')
	
	reghdfe std_`yvar' ${controls} [aw=tweights] ${if} & director_gob_law_v2==1 & year>=2014, abs(${fes}) vce(robust)
	lincom mayorallied
	mat C[1,`i']= r(estimate) 
	mat C[2,`i']= r(lb)
	mat C[3,`i']= r(ub)
	mat C[4,`i']= r(p)
	
	local i=`i'+1
	
}

coefplot (mat(C[1]), ci((2 3)) aux(4)), xline(0, lp(dash) lc("maroon")) b2title("Effect of Alignment when Governor is REPA head", size(medium)) ciopts(recast(rcap)) ylab(, labsize(medsmall)) ///
mlabel(cond(@aux1<=.01, string(@b, "%9.2fc") +"***", cond(@aux1<=.05, string(@b, "%9.2fc") +"**", cond(@aux1<=.1, string(@b, "%9.2fc") +"*", string(@b, "%9.2fc"))))) mlabposition(12) mlabgap(*2) mlabsize(medsmall) ///
xlabel(, labsize(medium)) l2title("Dependent Variable (std)", size(medium))

gr export "${plots}/coefplot_rd_econchars_govhead.pdf", as(pdf) replace




















