
use "${data}/Interim\defo_caralc.dta", clear

merge m:1 codepto using "${data}/Interim\lcvars90.dta", keep(1 3) nogen

replace sh_politics=sh_politics2_law
summ sh_politics, d

cap drop dmdn_politics
gen dmdn_politics=(sh_politics>.5) if sh_politics!=.

summ sh_sameparty_gov, d
gen d_sameparty_gov=(sh_sameparty_gov>=.1) if sh_sameparty_gov!=.
gen d_sameparty_gov2=(sh_sameparty_gov2>=.2) if sh_sameparty_gov2!=.

gen z_sh_politics2_law=sh_politics2_law-.5

tab z_sh_politics2_law if floss_prim_ideam_area_v2!=.

la var dmdn_politics "Politicians majority"

END

eststo clear

mat C=J(4,5,.)
mat coln C= "All" "Governor is head" "Governor not head" "Gov head + pols her party" "Gov head + pols not her party"

eststo s0: reghdfe floss_prim_ideam_area_v2 dmdn_politics, abs(year) vce(cl coddane)
lincom dmdn_politics
mat C[1,1]= r(estimate) 
mat C[2,1]= r(lb)
mat C[3,1]= r(ub)
mat C[4,1]= r(p)

eststo s1: reghdfe floss_prim_ideam_area_v2 dmdn_politics if director_gob_law==1, abs(year) vce(cl coddane)
lincom dmdn_politics
mat C[1,2]= r(estimate) 
mat C[2,2]= r(lb)
mat C[3,2]= r(ub)
mat C[4,2]= r(p)

eststo s2: reghdfe floss_prim_ideam_area_v2 dmdn_politics if director_gob_law==0, abs(year) vce(cl coddane)
lincom dmdn_politics
mat C[1,3]= r(estimate) 
mat C[2,3]= r(lb)
mat C[3,3]= r(ub)
mat C[4,3]= r(p)

eststo s3: reghdfe floss_prim_ideam_area_v2 dmdn_politics if d_sameparty_gov==1 & director_gob_law==1, abs(year) vce(cl coddane)
lincom dmdn_politics
mat C[1,4]= r(estimate) 
mat C[2,4]= r(lb)
mat C[3,4]= r(ub)
mat C[4,4]= r(p)

eststo s4: reghdfe floss_prim_ideam_area_v2 dmdn_politics if d_sameparty_gov==0 & director_gob_law==1, abs(year) vce(cl coddane)
lincom dmdn_politics
mat C[1,5]= r(estimate) 
mat C[2,5]= r(lb)
mat C[3,5]= r(ub)
mat C[4,5]= r(p)

coefplot (mat(C[1]), ci((2 3)) aux(4)), xline(0, lp(dash) lc("maroon")) b2title("Effect of Politicians Majority in REPA's Board on Deforestation (%)", size(small)) ciopts(recast(rcap)) ylab(, labsize(small)) ///
mlabel(cond(@aux1<=.01, string(@b, "%9.2fc") +"***", cond(@aux1<=.05, string(@b, "%9.2fc") +"**", cond(@aux1<=.1, string(@b, "%9.2fc") +"*", string(@b, "%9.2fc"))))) mlabposition(12) mlabgap(*2)
gr export "${plots}/coefplot_fact1.pdf", as(pdf) replace

eststo clear

mat C=J(4,4,.)
mat coln C= " . + pols her party + mayor aligned" ". + pols her party + mayor not aligned" " . + pols not her party + mayor aligned" ". + pols not her party + mayor not aligned"

eststo s5: reghdfe floss_prim_ideam_area_v2 dmdn_politics if d_sameparty_gov==1 & director_gob_law==1 & mayorallied==1, abs(year) vce(robust)
lincom dmdn_politics
mat C[1,1]= r(estimate) 
mat C[2,1]= r(lb)
mat C[3,1]= r(ub)
mat C[4,1]= r(p)

eststo s6: reghdfe floss_prim_ideam_area_v2 dmdn_politics if d_sameparty_gov==1 & director_gob_law==1 & mayorallied==0, abs(year) vce(robust)
lincom dmdn_politics
mat C[1,2]= r(estimate) 
mat C[2,2]= r(lb)
mat C[3,2]= r(ub)
mat C[4,2]= r(p)

eststo s7: reghdfe floss_prim_ideam_area_v2 dmdn_politics if d_sameparty_gov==0 & director_gob_law==1 & mayorallied==1, abs(year) vce(robust)
lincom dmdn_politics
mat C[1,3]= r(estimate) 
mat C[2,3]= r(lb)
mat C[3,3]= r(ub)
mat C[4,3]= r(p)

eststo s8: reghdfe floss_prim_ideam_area_v2 dmdn_politics if d_sameparty_gov==0 & director_gob_law==1 & mayorallied==0, abs(year) vce(robust)
lincom dmdn_politics
mat C[1,4]= r(estimate) 
mat C[2,4]= r(lb)
mat C[3,4]= r(ub)
mat C[4,4]= r(p)

coefplot (mat(C[1]), ci((2 3)) aux(4)), xline(0, lp(dash) lc("maroon")) b2title("Effect of Politicians Majority in REPA's Board on Deforestation (%)", size(small)) ciopts(recast(rcap)) ylab(, labsize(small)) ///
mlabel(cond(@aux1<=.01, string(@b, "%9.2fc") +"***", cond(@aux1<=.05, string(@b, "%9.2fc") +"**", cond(@aux1<=.1, string(@b, "%9.2fc") +"*", string(@b, "%9.2fc"))))) mlabposition(12) mlabgap(*2)
gr export "${plots}/coefplot_fact2.pdf", as(pdf) replace

eststo clear

mat C=J(4,4,.)
mat coln C= "Gov head + mayor aligned" "Gov head + mayor not aligned" " Gov not head + mayor aligned" "Gov not head + mayor not aligned"

eststo s5: reghdfe floss_prim_ideam_area_v2 dmdn_politics if director_gob_law==1 & mayorallied==1, abs(year) vce(cl coddane)
lincom dmdn_politics
mat C[1,1]= r(estimate) 
mat C[2,1]= r(lb)
mat C[3,1]= r(ub)
mat C[4,1]= r(p)

eststo s6: reghdfe floss_prim_ideam_area_v2 dmdn_politics if director_gob_law==1 & mayorallied==0, abs(year) vce(cl coddane)
lincom dmdn_politics
mat C[1,2]= r(estimate) 
mat C[2,2]= r(lb)
mat C[3,2]= r(ub)
mat C[4,2]= r(p)

eststo s7: reghdfe floss_prim_ideam_area_v2 dmdn_politics if director_gob_law==0 & mayorallied==1, abs(year) vce(cl coddane)
lincom dmdn_politics
mat C[1,3]= r(estimate) 
mat C[2,3]= r(lb)
mat C[3,3]= r(ub)
mat C[4,3]= r(p)

eststo s8: reghdfe floss_prim_ideam_area_v2 dmdn_politics if director_gob_law==0 & mayorallied==0, abs(year) vce(cl coddane)
lincom dmdn_politics
mat C[1,4]= r(estimate) 
mat C[2,4]= r(lb)
mat C[3,4]= r(ub)
mat C[4,4]= r(p)

coefplot (mat(C[1]), ci((2 3)) aux(4)), xline(0, lp(dash) lc("maroon")) b2title("Effect of Politicians Majority in REPA's Board on Deforestation (%)", size(small)) ciopts(recast(rcap)) ylab(, labsize(small)) ///
mlabel(cond(@aux1<=.01, string(@b, "%9.2fc") +"***", cond(@aux1<=.05, string(@b, "%9.2fc") +"**", cond(@aux1<=.1, string(@b, "%9.2fc") +"*", string(@b, "%9.2fc"))))) mlabposition(12) mlabgap(*2)
gr export "${plots}/coefplot_fact3.pdf", as(pdf) replace



*Creating matrix to export estimates
mat coef=J(3,5,.)
mat coln coef= .05 .1 .15 .2 .25

*Estimations
local h=0.05
forval c=1/5{

	*Conditional for all specifications
	gl if "if abs(z_sh_politics2_law)<=`h'"

	*Replicating triangular weights
	cap drop tweights
	gen tweights=(1-abs(z_sh_politics2_law/`h')) ${if}
	
	*Total Households
	reghdfe floss_prim_ideam_area_v2 dmdn_politics [aw=tweights] ${if}, abs(year) vce(cl coddane)
	lincom dmdn_politics	
	mat coef[1,`c']= r(estimate) 
	mat coef[2,`c']= r(lb)
	mat coef[3,`c']= r(ub)
	
	local h=`h'+0.05	
}

*Plotting estimates 
coefplot (mat(coef[1]), ci((2 3)) label("X")), vert recast(line) lwidth(*2) color(gs2%70) ///
ciopts(recast(rarea) color(gs6%40) acolor(gs6%30) alw(vvthin)) yline(0, lp(dash) lcolor(maroon)) ///
ylabel(,labsize(small)) xlabel(,labsize(small)) b2title("Bandwidth of Politicians Margin in REPA's Board ", size(medsmall)) ///
l2title("Effect of Politicians Majority on Forest Loss (%)", size(small))
gr export "${plots}/coefplot_fact4.pdf", as(pdf) replace
 
 
 


reghdfe floss_prim_ideam_area_v2 d_sameparty_gov dmdn_politics 1.d_sameparty_gov#1.dmdn_politics, abs(year) vce(cl coddane)
reghdfe floss_prim_ideam_area_v2 d_sameparty_gov2 dmdn_politics 1.d_sameparty_gov2#1.dmdn_politics, abs(year) vce(cl coddane)


reghdfe floss_prim_ideam_area_v2 d_sameparty_gov dmdn_politics 1.d_sameparty_gov#1.dmdn_politics, abs(year coddane) vce(cl coddane)
reghdfe floss_prim_ideam_area_v2 d_sameparty_gov2 dmdn_politics 1.d_sameparty_gov2#1.dmdn_politics, abs(year coddane) vce(cl coddane)


reghdfe floss_prim_ideam_area_v2 d_sameparty_gov, abs(year coddane) vce(cl coddane)
reghdfe floss_prim_ideam_area_v2 d_sameparty_gov2, abs(year coddane) vce(cl coddane)



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

gl Xvars "sh_forestcov90 depto_forest_change_90_00 sh_votos_alc90 sh_harvest90 ln_crop_prod90 depto_crop_yield1990 ln_pib90 ln_agg_va90 ln_min_va90 ln_pobl_tot93 sh_displaced93 gini93 nbi93 pobreza93"

egen panel_id = group(carcode_master coddane year)
drop if panel_id==.

reghdfe floss_prim_ideam_area_v2 dmdn_politics ${Xvars} [aw=tweights] ${if}, abs(year) vce(cl coddane)


*Creating matrix to export estimates
mat coef=J(3,5,.)
mat coln coef= .05 .1 .15 .2 .25

*Estimations
local h=0.05
forval c=1/5{

	*Conditional for all specifications
	gl if "if abs(z_sh_politics2_law)<=`h'"

	*Replicating triangular weights
	cap drop tweights
	gen tweights=(1-abs(z_sh_politics2_law/`h')) ${if}
	
	*Total Households
	reghdfe floss_prim_ideam_area_v2 dmdn_politics ${Xvars} [aw=tweights] ${if}, abs(year) vce(cl coddane)
	lincom dmdn_politics	
	mat coef[1,`c']= r(estimate) 
	mat coef[2,`c']= r(lb)
	mat coef[3,`c']= r(ub)
	
	local h=`h'+0.05	
}

*Plotting estimates 
coefplot (mat(coef[1]), ci((2 3)) label("X")), vert recast(line) lwidth(*2) color(gs2%70) ///
ciopts(recast(rarea) color(gs6%40) acolor(gs6%30) alw(vvthin)) yline(0, lp(dash) lcolor(maroon)) ///
ylabel(,labsize(small)) xlabel(,labsize(small)) b2title("Bandwidth of Politicians Margin in REPA's Board ", size(medsmall)) ///
l2title("Effect of Politicians Majority on Forest Loss (%)", size(small))
gr export "${plots}/coefplot_fact5.pdf", as(pdf) replace

gen ln_pib_total=log(pib_total)
gen ln_pib_percapita_cons=log(pib_percapita_cons)
gen ln_pib_agricola=log(pib_agricola)
gen ln_pib_industria=log(pib_industria)
gen ln_pib_servicios=log(pib_servicios)
gen ln_pib_percapita= log(pib_percapita)
gen ln_regalias=log(y_cap_regalias)
gen ln_g_total=log(g_total)
gen sh_bovinos=bovinos/area
gen sh_coca_area=H_coca*0.01/area
gen sh_sown_area=tot_sown_area*0.01/area  
gen sh_harv_area=tot_harv_area*0.01/area
gen ln_tot_prod=log(tot_prod)
gen ln_va=ln(va)
replace ln_va=log(pib_cons) if ln_va==.
gen ln_bovinos=log(bovinos)

la var ln_va "Log(GDP)"
la var ln_pib_percapita_cons "Log(GDP percapita)"
la var ln_pib_agricola "Log(Agricultural GDP)"
la var night_light "Night Light - radiance"
la var ln_regalias "Log(Royalties)"
la var ln_g_total "Log(Public expenditure)"
la var sh_bovinos "Cattler per Km2"
la var sh_coca_area "Coca area (%)"
la var sh_sown_area "Crop sown area (%)"
la var sh_harv_area "Crop harvested area (%)"
la var yield_allcrop "Crop yield"
la var ln_tot_prod "Log(Crop production)"
la var ln_bovinos "Log(Cattle)"

gl Yvars "ln_va ln_pib_percapita_cons ln_pib_agricola night_light ln_regalias ln_g_total ln_bovinos sh_coca_area sh_sown_area sh_harv_area yield_allcrop ln_tot_prod"

mat C=J(4,12,.)
mat coln C =${Yvars}

local i=1

foreach yvar of global Yvars{
	
	egen std_`yvar'= std(`yvar')
	
	reghdfe std_`yvar' dmdn_politics ${Xvars} [aw=tweights] ${if}, abs(year) vce(cl coddane)
	lincom dmdn_politics
	mat C[1,`i']= r(estimate) 
	mat C[2,`i']= r(lb)
	mat C[3,`i']= r(ub)
	mat C[4,`i']= r(p)
	
	local i=`i'+1
	
}

coefplot (mat(C[1]), ci((2 3)) aux(4)), xline(0, lp(dash) lc("maroon")) b2title("Politician Majority in REPA's Board (std)", size(small)) ciopts(recast(rcap)) ylab(, labsize(small)) l2title("Municipal Characteristics") ///
mlabel(cond(@aux1<=.01, string(@b, "%9.2fc") +"***", cond(@aux1<=.05, string(@b, "%9.2fc") +"**", cond(@aux1<=.1, string(@b, "%9.2fc") +"*", string(@b, "%9.2fc"))))) mlabposition(12) mlabgap(*2) mlabsize(vsmall)
gr export "${plots}/coefplot_fact6.pdf", as(pdf) replace

tab z_sh_politics2_law if floss_prim_ideam_area_v2!=.
tabstat floss_prim_ideam_area_v2, by(z_sh_politics2_law) s(mean N)



*Creating matrix to export estimates
gen z_round = string(round(z_sh_politics2_law, 0.001)) if floss_prim_ideam_area_v2!=.
replace z_round ="" if z_round=="."
replace z_round =".1" if z_round==".136"

tab z_round 

mat C=J(3,10,.)
mat coln C= -.115 -.071 -.045 -.038 .038 .083 .1 .143 .2 .237

local c=1 
local zrunning " -.115 -.071 -.045 -.038 .038 .083 .1 .143 .2 .237"

foreach h of local zrunning{
	*Conditional for all specifications
	gl if ""
	
	*Regression 
	reghdfe floss_prim_ideam_area_v2 if z_round=="`h'", abs(year) vce(cl coddane)
	
	lincom _cons	
	mat C[1,`c']= r(estimate) 
	mat C[2,`c']= r(lb)
	mat C[3,`c']= r(ub)
	
	local c=`c'+1
}

coefplot (mat(C[1]), ci((2 3))), vert ciopts(recast(rcap)) ///
xline(4.5, lp(dash) lc("maroon")) ///
l2title("Primary Forest Loss (%)", size(medium)) ///
b2title("Seat Margin Held by Politicians in REPAs Board", size(medium))
gr export "${plots}/coefplot_forestloss_polmargin_fig0.pdf", as(pdf) replace

coefplot (mat(C[1]), ci((2 3))), vert ciopts(recast(rcap)) ///
xline(4.5, lp(dash) lc("maroon")) xline(3.5, lp(dash)) xline(5.5, lp(dash)) ///
l2title("Primary Forest Loss (%)", size(medium)) ///
b2title("Seat Margin Held by Politicians in REPAs Board", size(medium))
gr export "${plots}/coefplot_forestloss_polmargin_fig1.pdf", as(pdf) replace

coefplot (mat(C[1]), ci((2 3))), vert ciopts(recast(rcap)) ///
xline(4.5, lp(dash) lc("maroon")) xline(1.8, lp(dash)) xline(6.2, lp(dash)) ///
l2title("Primary Forest Loss (%)", size(medium)) ///
b2title("Seat Margin Held by Politicians in REPAs Board", size(medium))
gr export "${plots}/coefplot_forestloss_polmargin_fig2.pdf", as(pdf) replace




mean floss_prim_ideam_area_v2 if carcode_master==14, over(year)
mat B=e(b)
mat coln B = 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20

coefplot (mat(B[1]), label("Macarena") mcolor("gs9")), vert noci recast(connected) xline(4, lp(dash)) xline(8, lp(dash)) xline(12, lp(dash)) xline(16, lp(dash)) xline(20, lp(dash))  l2title("Primary Forest Loss (%)", size(medsmall)) b2title("Years", size(medsmall)) addplot(scatteri 26 12 26 13 26 14 26 15 26 16, recast(area) color(gs5%20) lcolor(white) base(0)) plotregion(margin(zero))

gr export "${plots}/forestloss_trend_cormacarena.pdf", as(pdf) replace



gl if "if abs(z_sh_politics2_law)<=.04"
reghdfe floss_prim_ideam_area_v2 dmdn_politics ${if}, noabs vce(robust)
reghdfe floss_prim_ideam_area_v2 dmdn_politics ${if}, abs(year) vce(robust)
reghdfe floss_prim_ideam_area_v2 dmdn_politics ${if}, abs(year) vce(cl coddane)

tab z_sh_politics2_law carcode_master if e(sample)==1

rdrandinf floss_prim_ideam_area_v2 z_sh_politics2_law, c(0) wl(-.04) wr(.04)

two (scatter floss_prim_ideam_area_v2 z_sh_politics2_law ${if}) (lfit floss_prim_ideam_area_v2 z_sh_politics2_law ${if} & dmdn_politics==0) (lfit floss_prim_ideam_area_v2 z_sh_politics2_law ${if} & dmdn_politics==1), xline(0, lp(dash) lc(maroon)) 

rdrandinf floss_prim_ideam_area_v2 z_sh_politics2_law, c(0) wl(-.075) wr(.075)

rdrandinf floss_prim_ideam_area_v2 z_sh_politics2_law, c(0) wl(-.085) wr(.085)

eststo clear

tab z_sh_politics2_law if floss_prim_ideam_area_v2!=.

eststo s0: reghdfe floss_prim_ideam_area_v2 ${if} & dmdn_politics==0, abs(year) vce(cl coddane)
eststo s1: reghdfe floss_prim_ideam_area_v2 ${if} & dmdn_politics==1, abs(year) vce(cl coddane)

coefplot s0 s1

reghdfe floss_prim_ideam_area_v2 dmdn_politics if carcode_master!=14, abs(year) vce(cl coddane)
reghdfe floss_prim_ideam_area_v2 dmdn_politics, abs(year) vce(cl coddane)



hist z_sh_politics2_law if floss_prim_ideam_area_v2!=., frac width(0.01)

gen z_sh_politics2_law_v2=z_sh_politics2_law if floss_prim_ideam_area_v2!=.

collapse (mean) z_sh_politics2_law_v2, by(carcode_master) 
hist z_sh_politics2_law_v2, frac width(0.01)



mat C=J(4,5,.)
mat coln C= .04 .05 .08 .1 .25

local i=1

foreach h in .04 .05 .08 .1 .25{
	
	gl if "if abs(z_sh_politics2_law)<`h'"
	cap drop tweights
	gen tweights=(1-abs(z_sh_politics2_law/`h')) ${if}
	
	eststo est_`i': reghdfe floss_prim_ideam_area_v2 dmdn_politics [aw=tweights] ${if}, abs(year) vce(cl coddane)
	
	lincom dmdn_politic
	mat C[1,`i']= r(estimate) 
	mat C[2,`i']= r(lb)
	mat C[3,`i']= r(ub)
	mat C[4,`i']= r(p)
	
	summ floss_prim_ideam_area_v2 ${if} & dmdn_politics==0
	gl meany_`i'=string(round(r(mean), .01), "%9.2fc")
			
	local i=`i'+1
}

coefplot (mat(C[1]), ci((2 3)) aux(4)), vert ciopts(recast(rcap)) ///
yline(0, lp(dash) lc("maroon")) ///
mlabel(cond(@aux1<=.01, string(@b, "%9.2fc") +"***", cond(@aux1<=.05, string(@b, "%9.2fc") +"**", cond(@aux1<=.1, string(@b, "%9.2fc") +"*", string(@b, "%9.2fc"))))) mlabposition(3) mlabgap(*2) mlabsize(medsmall) ///
l2title("Primary Forest Loss (%)", size(medium)) ///
b2title("Bandwidth of Seat Margin Held by Politicians in REPAs Board", size(medium))
gr export "${plots}/coefplot_rd_seatmargin.pdf", as(pdf) replace

*Exporting geographic results 
esttab est_1 est_2 est_3 est_4 est_5 using "${tables}/rd_seatmargin.tex", keep(dmdn_politics) ///
se nocons star(* 0.10 ** 0.05 *** 0.01) ///
label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
prehead(`"\begin{tabular}{@{}l*{5}{c}}"' ///
            `"\hline \toprule"'                     ///
            `" & \multicolumn{11}{c}{Primary Forest Loss (\%)} \\ "'                   ///
            `" & (1) & (2) & (3) & (4) & (5) \\"'                       ///
            `" \toprule"')  ///
    postfoot(`" Control mean & ${meany_1} & ${meany_2} & ${meany_3} & ${meany_4} & ${meany_4} \\"' ///
		`" & & & & & \\"' ///
		`" Bandwidth & .04 & .05 & .08 & .1 & All \\"' ///
	`"\bottomrule \end{tabular}"') 

	

gl if "if abs(z_sh_politics2_law)<.07"
reghdfe floss_prim_ideam_area_v2 1.dmdn_politics##1.d_sameparty_gov##1.director_gob_law##1.mayorallied, abs(year) vce(cl coddane)

reghdfe floss_prim_ideam_area_v2 1.dmdn_politics##1.d_sameparty_gov##1.director_gob_law##1.mayorallied, abs(year) vce(cl coddane)
	

reghdfe floss_prim_ideam_area_v2 1.dmdn_politics##1.d_sameparty_gov##1.director_gob_law, abs(year) vce(cl coddane)

reghdfe floss_prim_ideam_area_v2 1.dmdn_politics##1.director_gob_law , abs(year) vce(cl coddane)

reghdfe floss_prim_ideam_area_v2 dmdn_politics ${if} & director_gob_law==0, abs(year) vce(cl coddane)
reghdfe floss_prim_ideam_area_v2 dmdn_politics ${if} & director_gob_law==1, abs(year) vce(cl coddane)
reghdfe floss_prim_ideam_area_v2 dmdn_politics ${if} , abs(year) vce(cl coddane)

tab dmdn_politics director_gob_law if e(sample)==1
tab carcode_master  if e(sample)==1

reghdfe floss_prim_ideam_area_v2 dmdn_politics ${if} & d_sameparty_gov==0, abs(year) vce(cl coddane)
reghdfe floss_prim_ideam_area_v2 dmdn_politics ${if} & d_sameparty_gov==1, abs(year) vce(cl coddane)
reghdfe floss_prim_ideam_area_v2 dmdn_politics ${if} , abs(year) vce(cl coddane)

reghdfe floss_prim_ideam_area_v2 1.dmdn_politics##1.d_sameparty_gov ${if} , abs(year) vce(cl coddane)


gl Xvars "sh_forestcov90 sh_votos_alc90 sh_harvest90 ln_crop_prod90 depto_crop_yield1990 ln_pib90 ln_agg_va90 ln_min_va90 ln_pobl_tot93 sh_displaced93 gini93 nbi93 pobreza93"

reghdfe floss_prim_ideam_area_v2 dmdn_politics ${if} & director_gob_law==0, abs(year) vce(cl coddane)
reghdfe floss_prim_ideam_area_v2 dmdn_politics ${if} & director_gob_law==1, abs(year) vce(cl coddane)
reghdfe floss_prim_ideam_area_v2 dmdn_politics ${if} , abs(year) vce(cl coddane)

reghdfe floss_prim_ideam_area_v2 mayorinbrd ${if} & dmdn_politics==0, abs(year) vce(cl coddane)
reghdfe floss_prim_ideam_area_v2 mayorinbrd ${if} & dmdn_politics==1, abs(year) vce(cl coddane)


local h=0.08
gl if "if abs(z_sh_politics2_law)<`h'"
cap drop tweights
gen tweights=(1-abs(z_sh_politics2_law/`h')) ${if}

reghdfe floss_prim_ideam_area_v2 dmdn_politics [aw=tweights] ${if}, abs(year) vce(cl coddane)

reghdfe floss_prim_ideam_area_v2 dmdn_politics [aw=tweights] ${if} & director_gob_law==0, abs(year) vce(cl coddane)
reghdfe floss_prim_ideam_area_v2 dmdn_politics [aw=tweights] ${if} & director_gob_law==1, abs(year) vce(cl coddane)

reghdfe floss_prim_ideam_area_v2 dmdn_politics [aw=tweights] ${if} & mayorallied_wanypol==0, abs(year) vce(cl coddane)
reghdfe floss_prim_ideam_area_v2 dmdn_politics [aw=tweights] ${if} & mayorallied_wanypol==1, abs(year) vce(cl coddane)


*replace green_party_gov=0 if green_party_gov==.
*replace green_party_v2_alc=0 if green_party_v2_alc==.

reghdfe floss_prim_ideam_area_v2 dmdn_politics [aw=tweights] ${if} & mayorallied_wanypol==1 & green_party_v2_alc==1, abs(year) vce(cl coddane)
reghdfe floss_prim_ideam_area_v2 dmdn_politics [aw=tweights] ${if} & mayorallied_wanypol==1 & green_party_v2_alc==0, abs(year) vce(cl coddane)

reghdfe floss_prim_ideam_area_v2 dmdn_politics [aw=tweights] ${if} & green_party_v2_alc==1, abs(year) vce(cl coddane)
reghdfe floss_prim_ideam_area_v2 dmdn_politics [aw=tweights] ${if} & green_party_v2_alc==0, abs(year) vce(cl coddane)


reghdfe floss_prim_ideam_area_v2 dmdn_politics [aw=tweights] ${if} & mayorallied_wanypol==1 & green_party_v2_alc==1, abs(year) vce(cl coddane)
reghdfe floss_prim_ideam_area_v2 dmdn_politics [aw=tweights] ${if} & mayorallied_wanypol==0 & green_party_v2_alc==1, abs(year) vce(cl coddane)

reghdfe floss_prim_ideam_area_v2 dmdn_politics [aw=tweights] ${if} & mayorallied_wanypol==1 & green_party_v2_alc==0, abs(year) vce(cl coddane)
reghdfe floss_prim_ideam_area_v2 dmdn_politics [aw=tweights] ${if} & mayorallied_wanypol==0 & green_party_v2_alc==0, abs(year) vce(cl coddane)








gen dmdn_politics_mayorallied=dmdn_politics*mayorallied_wanypol

la var mayorallied_wanypol "Mayor–Board Politician Alignment"
la var dmdn_politics_mayorallied "Majority $\times$ Alignment"


local i=1

foreach h in .04 .05 .08 .1 .25{
	
	gl if "if abs(z_sh_politics2_law)<`h'"
	cap drop tweights
	gen tweights=(1-abs(z_sh_politics2_law/`h')) ${if}
	
	eststo est_`i': reghdfe floss_prim_ideam_area_v2 dmdn_politics mayorallied_wanypol dmdn_politics_mayorallied [aw=tweights] ${if}, abs(year) vce(robust)
	
	summ floss_prim_ideam_area_v2 ${if} & dmdn_politics==0
	gl meany_`i'=string(round(r(mean), .01), "%9.2fc")

	local i=`i'+1
}

*Exporting geographic results 
esttab est_1 est_2 est_3 est_4 est_5 using "${tables}/rd_seatmargin_hetalignment.tex", keep(dmdn_politics mayorallied_wanypol dmdn_politics_mayorallied) ///
se nocons star(* 0.10 ** 0.05 *** 0.01) ///
label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
prehead(`"\begin{tabular}{@{}l*{5}{c}}"' ///
            `"\hline \toprule"'                     ///
            `" & \multicolumn{11}{c}{Primary Forest Loss (\%)} \\ "'                   ///
            `" & (1) & (2) & (3) & (4) & (5) \\"'                       ///
            `" \toprule"')  ///
    postfoot(`" Control mean & ${meany_1} & ${meany_2} & ${meany_3} & ${meany_4} & ${meany_4} \\"' ///
		`" & & & & & \\"' ///
		`" Bandwidth & .04 & .05 & .08 & .1 & All \\"' ///
	`"\bottomrule \end{tabular}"') 



	





local h=0.04
gl if "if abs(z_sh_politics2_law)<`h'"
cap drop tweights
gen tweights=(1-abs(z_sh_politics2_law/`h')) ${if}

mat C=J(4,2,.)
mat coln C= "Mayor Green + Aligned" "Mayor Green + Not Aligned" 

*"Mayor not Green + Aligned" "Mayor not Green + not Aligned"

reghdfe floss_prim_ideam_area_v2 dmdn_politics [aw=tweights] ${if} & mayorallied_wanypol==1 & green_party_v2_alc==1, abs(year) vce(robust)
lincom dmdn_politics
mat C[1,1]= r(estimate) 
mat C[2,1]= r(lb)
mat C[3,1]= r(ub)
mat C[4,1]= r(p)

reghdfe floss_prim_ideam_area_v2 dmdn_politics [aw=tweights] ${if} & mayorallied_wanypol==0 & green_party_v2_alc==1, abs(year) vce(robust)
lincom dmdn_politics
mat C[1,2]= r(estimate) 
mat C[2,2]= r(lb)
mat C[3,2]= r(ub)
mat C[4,2]= r(p)

coefplot (mat(C[1]), ci((2 3)) aux(4)), xline(0, lp(dash) lc("maroon")) b2title("Effect of Politicians Majority in REPA's Board on Forest Loss (%)", size(medsmall)) ciopts(recast(rcap)) ylab(, labsize(small)) ///
mlabel(cond(@aux1<=.01, string(@b, "%9.2fc") +"***", cond(@aux1<=.05, string(@b, "%9.2fc") +"**", cond(@aux1<=.1, string(@b, "%9.2fc") +"*", string(@b, "%9.2fc"))))) mlabposition(12) mlabgap(*2)
gr export "${plots}/coefplot_rd_seatmargin_greenalignment_placebo.pdf", as(pdf) replace











gen election_year=1 if year==2000 | year==2003 | year==2007 | year==2011 | year==2015 | year==2019
replace election_year=0 if election_year==.

local h=0.04
gl if "if abs(z_sh_politics2_law)<`h'"
cap drop tweights
gen tweights=(1-abs(z_sh_politics2_law/`h')) ${if}

mat C=J(4,4,.)
mat coln C= "Mayor in Board" "Mayor not in Board" "Electoral Year" "Non-Electoral Year" 

reghdfe floss_prim_ideam_area_v2 dmdn_politics [aw=tweights] ${if} & mayorinbrd==1 , abs(year) vce(robust)
lincom dmdn_politics
mat C[1,1]= r(estimate) 
mat C[2,1]= r(lb)
mat C[3,1]= r(ub)
mat C[4,1]= r(p)

reghdfe floss_prim_ideam_area_v2 dmdn_politics [aw=tweights] ${if} & mayorinbrd==0, abs(year) vce(robust)
lincom dmdn_politics
mat C[1,2]= r(estimate) 
mat C[2,2]= r(lb)
mat C[3,2]= r(ub)
mat C[4,2]= r(p)

reghdfe floss_prim_ideam_area_v2 dmdn_politics [aw=tweights] ${if} & election_year==1 , abs(year) vce(robust)
lincom dmdn_politics
mat C[1,3]= r(estimate) 
mat C[2,3]= r(lb)
mat C[3,3]= r(ub)
mat C[4,3]= r(p)

reghdfe floss_prim_ideam_area_v2 dmdn_politics [aw=tweights] ${if} & election_year==0, abs(year) vce(robust)
lincom dmdn_politics
mat C[1,4]= r(estimate) 
mat C[2,4]= r(lb)
mat C[3,4]= r(ub)
mat C[4,4]= r(p)

coefplot (mat(C[1]), ci((2 3)) aux(4)), xline(0, lp(dash) lc("maroon")) b2title("Effect of Politicians Majority in REPA's Board on Forest Loss (%)", size(medsmall)) ciopts(recast(rcap)) ylab(, labsize(small)) ///
mlabel(cond(@aux1<=.01, string(@b, "%9.2fc") +"***", cond(@aux1<=.05, string(@b, "%9.2fc") +"**", cond(@aux1<=.1, string(@b, "%9.2fc") +"*", string(@b, "%9.2fc"))))) mlabposition(12) mlabgap(*2)
gr export "${plots}/coefplot_rd_seatmargin_mayorinbrd.pdf", as(pdf) replace








*END




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
replace ln_va=log(pib_cons) if ln_va==.
gen ln_bovinos=log(sh_bovinos)

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
la var yield_allcrop "Crop yield"
la var ln_tot_prod "Log(Crop production)"
la var ln_bovinos "Log(Cattle per Km2)"

gl Yvars "ln_va ln_pib_percapita_cons ln_pib_agricola night_light ln_regalias ln_g_total ln_bovinos sh_harv_area ln_tot_prod yield_allcrop"

mat C=J(4,10,.)
mat coln C =${Yvars}

local i=1

foreach yvar of global Yvars{
		
	local h=0.05
	gl if "if abs(z_sh_politics2_law)<`h'"
	cap drop tweights
	gen tweights=(1-abs(z_sh_politics2_law/`h')) ${if}
	
	cap drop std_`yvar'
	egen std_`yvar'= std(`yvar')
	
	reghdfe std_`yvar' dmdn_politics [aw=tweights] ${if} & floss_prim_ideam_area_v2!=., abs(year) vce(cl coddane)
	lincom dmdn_politics
	mat C[1,`i']= r(estimate) 
	mat C[2,`i']= r(lb)
	mat C[3,`i']= r(ub)
	mat C[4,`i']= r(p)
	
	local i=`i'+1
	
}

coefplot (mat(C[1]), ci((2 3)) aux(4)), xline(0, lp(dash) lc("maroon")) b2title("Politician Majority in REPA's Board (std)", size(small)) ciopts(recast(rcap)) ylab(, labsize(small)) l2title("Municipal Characteristics") ///
mlabel(cond(@aux1<=.01, string(@b, "%9.2fc") +"***", cond(@aux1<=.05, string(@b, "%9.2fc") +"**", cond(@aux1<=.1, string(@b, "%9.2fc") +"*", string(@b, "%9.2fc"))))) mlabposition(12) mlabgap(*2) mlabsize(vsmall)
gr export "${plots}/coefplot_rd_seatmargin_econchars.pdf", as(pdf) replace



mat C=J(4,10,.)
mat coln C =${Yvars}

local i=1

foreach yvar of global Yvars{
		
	local h=0.05
	gl if "if abs(z_sh_politics2_law)<`h'"
	cap drop tweights
	gen tweights=(1-abs(z_sh_politics2_law/`h')) ${if}
	
	cap drop std_`yvar'
	egen std_`yvar'= std(`yvar') ${if}
	
	reghdfe std_`yvar' dmdn_politics [aw=tweights] ${if} & floss_prim_ideam_area_v2!=. & mayorallied_wanypol==1, abs(year) vce(cl coddane)
	lincom dmdn_politics
	mat C[1,`i']= r(estimate) 
	mat C[2,`i']= r(lb)
	mat C[3,`i']= r(ub)
	mat C[4,`i']= r(p)
	
	local i=`i'+1
	
}

coefplot (mat(C[1]), ci((2 3)) aux(4)), xline(0, lp(dash) lc("maroon")) b2title("Politician Majority in REPA's Board (std)", size(small)) ciopts(recast(rcap)) ylab(, labsize(small)) l2title("Municipal Characteristics") ///
mlabel(cond(@aux1<=.01, string(@b, "%9.2fc") +"***", cond(@aux1<=.05, string(@b, "%9.2fc") +"**", cond(@aux1<=.1, string(@b, "%9.2fc") +"*", string(@b, "%9.2fc"))))) mlabposition(12) mlabgap(*2) mlabsize(vsmall)
gr export "${plots}/coefplot_rd_seatmargin_econchars_mayoraligned.pdf", as(pdf) replace

