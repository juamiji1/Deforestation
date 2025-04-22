
use "${data}/Interim\defo_caralc.dta", clear

merge m:1 codepto using "${data}/Interim\lcvars90.dta", keep(1 3) nogen

cap drop dmdn_politics
gen dmdn_politics=(sh_politics2_law>.5) if sh_politics2_law!=.

gen dmdn_politics_mayorallied=dmdn_politics*mayorallied_wanypol

summ sh_sameparty_gov, d
gen d_sameparty_gov=(sh_sameparty_gov>=.1) if sh_sameparty_gov!=.
gen d_sameparty_gov2=(sh_sameparty_gov2>=.2) if sh_sameparty_gov2!=.

gen z_sh_politics2_law=sh_politics2_law-.5

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

la var dmdn_politics "Politicians majority"
la var mayorallied_wanypol "Mayor–Board Politician Alignment"
la var dmdn_politics_mayorallied "Majority $\times$ Alignment"

tab z_sh_politics2_law if floss_prim_ideam_area_v2!=.

*-------------------------------------------------------------------------------
* Plot of the seat distribution between politicians vs non-politicians in the board
*-------------------------------------------------------------------------------
*Kdensity
egen sh_other=rowtotal(sh_ethnias sh_private sh_envngo sh_academics), m

two (kdensity sh_politics) (kdensity sh_other), ///
legend(order(1 "Politicians" 2 "Non-Politicians")) l2title("Kdensity Estimator", size(medsmall)) xtitle("") ///
b2title("Share of each member type on the board", size(medsmall))

gr export "${plots}/kdensity_sh_memberstype.pdf", as(pdf) replace

*-------------------------------------------------------------------------------
* Time trends of reduced form
*-------------------------------------------------------------------------------
mean floss_prim_ideam_area_v2 if dmdn_politics==0 & year>2000 & year<2021 & carcode_master!=14, over(year)
mat b0=e(b)
mat coln b0 = 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20

mean floss_prim_ideam_area_v2 if dmdn_politics==1 & year>2000 & year<2021 & carcode_master!=14, over(year)
mat b1=e(b)
mat coln b1 = 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20

gen x = 12 if year==2012
replace x = 13 if year==2013
replace x = 14 if year==2014
replace x = 15 if year==2015
replace x = 16 if year==2016

gen y = 17 if x!=.

coefplot (mat(b0[1]), label("Politicians minority") mcolor("gs9")) (mat(b1[1]), label("Politicians majority") color("gs6")), vert noci recast(connected) xline(4, lp(dash)) xline(8, lp(dash)) xline(12, lp(dash)) xline(16, lp(dash)) xline(20, lp(dash))  l2title("Primary Forest Loss (%)", size(medsmall)) b2title("Years", size(medsmall)) addplot(scatteri 16 12 16 13 16 14 16 15 16 16, recast(area) color(gs5%20) lcolor(white) base(0)) plotregion(margin(zero))

gr export "${plots}/forestloss_trend_by_polcomposition.pdf", as(pdf) replace

*-------------------------------------------------------------------------------
* Reduced form & First stage
*-------------------------------------------------------------------------------
eststo clear

eststo s0: areg director_gob_law if dmdn_politics==0 & carcode_master!=14, a(year) vce(cl coddane)
eststo s1: areg director_gob_law if dmdn_politics==1 & carcode_master!=14, a(year) vce(cl coddane)
eststo s2: areg floss_prim_ideam_area_v2 if dmdn_politics==0 & carcode_master!=14, a(year) vce(cl coddane)
eststo s3: areg floss_prim_ideam_area_v2 if dmdn_politics==1 & carcode_master!=14, a(year) vce(cl coddane)

coefplot (s2, axis(1) color("gs9")) (s3, axis(1) color("gs6")) ///
(s0, axis(2) color("gs9") legend(off)) (s1, axis(2) color("gs6") legend(off)), ///
vert recast(bar) barwidth(0.12) ciopts(recast(rcap) lcolor("black")) citop ///
mlabcolor("black") mlabsize(medsmall) coeflabels(_cons=" ") ///
mlabel(string(@b, "%9.2fc")) mlabposition(11) mlabgap(*2) ///
ytitle("Share of REPAs with Governor as Head by Law", axis(2)) ytitle("Primary Forest Loss (%)", axis(1)) ///
xline(1, lc(gray) lp(dash)) legend(on order(1 "Politicians minority" 3 "Politicians majority"))

gr export "${plots}/reduce_and_firststage.pdf", as(pdf) replace

*-------------------------------------------------------------------------------
* Means per seat margin
*-------------------------------------------------------------------------------
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

*-------------------------------------------------------------------------------
* Trends of Cormacarena
*-------------------------------------------------------------------------------
mean floss_prim_ideam_area_v2 if carcode_master==14, over(year)
mat B=e(b)
mat coln B = 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20

coefplot (mat(B[1]), label("Macarena") mcolor("gs9")), vert noci recast(connected) xline(4, lp(dash)) xline(8, lp(dash)) xline(12, lp(dash)) xline(16, lp(dash)) xline(20, lp(dash))  l2title("Primary Forest Loss (%)", size(medsmall)) b2title("Years", size(medsmall)) addplot(scatteri 26 12 26 13 26 14 26 15 26 16, recast(area) color(gs5%20) lcolor(white) base(0)) plotregion(margin(zero))

gr export "${plots}/forestloss_trend_cormacarena.pdf", as(pdf) replace

*-------------------------------------------------------------------------------
* Effect of majority on deforestation per seat margin
*-------------------------------------------------------------------------------
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
esttab est_1 est_2 est_3 est_4 est_5 using "${tables}/rd_seatmargin.tex", ///
se star(* 0.10 ** 0.05 *** 0.01) ///
label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
prehead(`"\begin{tabular}{@{}l*{5}{c}}"' ///
            `"\hline \toprule"'                     ///
            `" & \multicolumn{5}{c}{Primary Forest Loss (\%)} \\ \cmidrule(l){2-6}"'                   ///
            `" & (1) & (2) & (3) & (4) & (5) \\"'                       ///
            `" \toprule"')  ///
    postfoot(`" Control mean & ${meany_1} & ${meany_2} & ${meany_3} & ${meany_4} & ${meany_4} \\"' ///
		`" & & & & & \\"' ///
		`" Bandwidth & .04 & .05 & .08 & .1 & All \\"' ///
	`"\bottomrule \end{tabular}"') 

*-------------------------------------------------------------------------------
* Effect of majority and alignment on deforestation per seat margin
*-------------------------------------------------------------------------------
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
esttab est_1 est_2 est_3 est_4 est_5 using "${tables}/rd_seatmargin_hetalignment.tex", ///
se star(* 0.10 ** 0.05 *** 0.01) ///
label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
prehead(`"\begin{tabular}{@{}l*{5}{c}}"' ///
            `"\hline \toprule"'                     ///
            `" & \multicolumn{5}{c}{Primary Forest Loss (\%)} \\ \cmidrule(l){2-6}"'                   ///
            `" & (1) & (2) & (3) & (4) & (5) \\"'                       ///
            `" \toprule"')  ///
    postfoot(`" Control mean & ${meany_1} & ${meany_2} & ${meany_3} & ${meany_4} & ${meany_4} \\"' ///
		`" & & & & & \\"' ///
		`" Bandwidth & .04 & .05 & .08 & .1 & All \\"' ///
	`"\bottomrule \end{tabular}"') 

*PLot
local h=0.04
gl if "if abs(z_sh_politics2_law)<`h'"
cap drop tweights
gen tweights=(1-abs(z_sh_politics2_law/`h')) ${if}

mat C=J(4,4,.)
mat coln C= "Mayor-Board Pols Aligned" "Mayor-Board Pols not Aligned" "Mayor in Green Party" "Mayor in Non-Green Party"

reghdfe floss_prim_ideam_area_v2 dmdn_politics [aw=tweights] ${if} & mayorallied_wanypol==1 , abs(year) vce(robust)
lincom dmdn_politics
mat C[1,1]= r(estimate) 
mat C[2,1]= r(lb)
mat C[3,1]= r(ub)
mat C[4,1]= r(p)

reghdfe floss_prim_ideam_area_v2 dmdn_politics [aw=tweights] ${if} & mayorallied_wanypol==0, abs(year) vce(robust)
lincom dmdn_politics
mat C[1,2]= r(estimate) 
mat C[2,2]= r(lb)
mat C[3,2]= r(ub)
mat C[4,2]= r(p)

reghdfe floss_prim_ideam_area_v2 dmdn_politics [aw=tweights] ${if} & green_party_v2_alc==1 , abs(year) vce(robust)
lincom dmdn_politics
mat C[1,3]= r(estimate) 
mat C[2,3]= r(lb)
mat C[3,3]= r(ub)
mat C[4,3]= r(p)

reghdfe floss_prim_ideam_area_v2 dmdn_politics [aw=tweights] ${if} & green_party_v2_alc==0, abs(year) vce(robust)
lincom dmdn_politics
mat C[1,4]= r(estimate) 
mat C[2,4]= r(lb)
mat C[3,4]= r(ub)
mat C[4,4]= r(p)

coefplot (mat(C[1]), ci((2 3)) aux(4)), xline(0, lp(dash) lc("maroon")) b2title("Effect of Politicians Majority in REPA's Board on Forest Loss (%)", size(medsmall)) ciopts(recast(rcap)) ylab(, labsize(small)) ///
mlabel(cond(@aux1<=.01, string(@b, "%9.2fc") +"***", cond(@aux1<=.05, string(@b, "%9.2fc") +"**", cond(@aux1<=.1, string(@b, "%9.2fc") +"*", string(@b, "%9.2fc"))))) mlabposition(12) mlabgap(*2)
gr export "${plots}/coefplot_rd_seatmargin_hetalignment.pdf", as(pdf) replace	
	
*-------------------------------------------------------------------------------
* Placebo of green preferences vs alignment
*-------------------------------------------------------------------------------	
local h=0.04
gl if "if abs(z_sh_politics2_law)<`h'"
cap drop tweights
gen tweights=(1-abs(z_sh_politics2_law/`h')) ${if}

mat C=J(4,2,.)
mat coln C= "Mayor Green + Aligned" "Mayor Green + Not Aligned" 

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
	
*-------------------------------------------------------------------------------
* Heterogeneity per mayor in board and electoral years
*-------------------------------------------------------------------------------	
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
	
*-------------------------------------------------------------------------------
* Economic characteristics and effect of majority in board
*-------------------------------------------------------------------------------
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
	
*-------------------------------------------------------------------------------
* Economic characteristics and effect of majority in board when alignment
*-------------------------------------------------------------------------------
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

