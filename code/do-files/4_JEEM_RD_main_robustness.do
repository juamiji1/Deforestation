use "${data}/Interim\defo_caralc.dta", clear 

eststo clear


*-------------------------------------------------------------------------------
* ROBUSTNESSS CHECKS
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
gl fes "region year"

cap drop tweights
gen tweights=(1-abs(z_sh_votes_alc/${h})) ${if}

*-------------------------------------------------------------------------------
* Robustness of errors - Cluster at municipality lvl
*-------------------------------------------------------------------------------
*All municipalities 
eststo r1: reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2!=., abs(${fes}) vce(cl coddane)

summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_y1=round(r(mean), .01)

*Municipalities under a CAR in which Gobernor is mandated as director 
eststo r2: reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==1, abs(${fes}) vce(cl coddane)

summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_y2=round(r(mean), .01)

*Municipalities under a CAR in which Gobernor is NOT mandated as director 
eststo r3: reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==0, abs(${fes}) vce(cl coddane)

summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_y3=round(r(mean), .01)

coefplot (r1, label(All)) (r2, label(Governor is head)) (r3, label(Governor not head)), keep(mayorallied) ///
coeflabels(mayorallied = " ") ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(cols(3)) xtitle("Primary Forest Loss (%)", size(medsmall)) ytitle("Partisan Alignment Between Mayor and Governor", size(medsmall)) ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2)

gr export "${plots}\rdplot_main_results_cl_coddane.pdf", as(pdf) replace 

*-------------------------------------------------------------------------------
* Robustness of errors - Cluster at REPA lvl
*-------------------------------------------------------------------------------
*All municipalities 
eststo r1: reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2!=., abs(${fes}) vce(cl i.carcode_master#i.election)

summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_y1=round(r(mean), .01)

*Municipalities under a CAR in which Gobernor is mandated as director 
eststo r2: reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==1, abs(${fes}) vce(cl i.carcode_master#i.election)

summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_y2=round(r(mean), .01)

*Municipalities under a CAR in which Gobernor is NOT mandated as director 
eststo r3: reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==0, abs(${fes}) vce(cl i.carcode_master#i.election)

summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_y3=round(r(mean), .01)

coefplot (r1, label(All)) (r2, label(Governor is head)) (r3, label(Governor not head)), keep(mayorallied) ///
coeflabels(mayorallied = " ") ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(cols(3)) xtitle("Primary Forest Loss (%)", size(medsmall)) ytitle("Partisan Alignment Between Mayor and Governor", size(medsmall)) ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2)

gr export "${plots}\rdplot_main_results_cl_carcode.pdf", as(pdf) replace 

*-------------------------------------------------------------------------------
* Robustness of BWs for All sample
*-------------------------------------------------------------------------------
*Dependent's var mean
summ z_sh_votes_alc, d

*Creating matrix to export estimates
mat coef=J(3,30,.)

*Estimations
local h=0.01
forval c=1/30{

	*Conditional for all specifications
	gl if "if abs(z_sh_votes_alc)<=`h'"

	*Replicating triangular weights
	cap drop tweights
	gen tweights=(1-abs(z_sh_votes_alc/`h')) ${if}
	
	*Total Households
	reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if}, abs(${fes}) vce(robust)
	lincom mayorallied	
	mat coef[1,`c']= r(estimate) 
	mat coef[2,`c']= r(lb)
	mat coef[3,`c']= r(ub)
	
	local h=`h'+0.01	
}
	
*Labeling coef matrix rows according to each bw
mat coln coef= .01 .02 .03 .04 .05 .06 .07 .08 .09 .1 .11 .12 .13 .14 .15 .16 .17 .18 .19 .2 .21 .22 .23 .24 .25 .26 .27 .28 .29 .3

*Plotting estimates 
coefplot (mat(coef[1]), ci((2 3)) label("X")), vert recast(line) lwidth(*2) color(gs2%70) ///
ciopts(recast(rarea) color(gs6%40) acolor(gs6%30) alw(vvthin)) yline(0, lp(dash) lcolor(maroon)) ///
xline(6.5, lp(dash) lc(gs2%70)) ylabel(,labsize(small)) xlabel(,labsize(vsmall)) ///
b2title("Bandwidth of Vote Margin", size(medsmall)) l2title("Effect of Partisan Alignment on Primary Forest Loss (%)", size(medsmall))
 
gr export "${plots}\rdplot_main_results_bwrobust.pdf", as(pdf) replace 
 
*-------------------------------------------------------------------------------
* Robustness of BWs for Gob director sample 
*-------------------------------------------------------------------------------
*Dependent's var mean
summ z_sh_votes_alc, d

*Creating matrix to export estimates
mat coef=J(3,30,.)

*Estimations
local h=0.01
forval c=1/30{

	*Conditional for all specifications
	gl if "if abs(z_sh_votes_alc)<=`h'"

	*Replicating triangular weights
	cap drop tweights
	gen tweights=(1-abs(z_sh_votes_alc/`h')) ${if}
	
	*Total Households
	reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==1, abs(${fes}) vce(robust)
	lincom mayorallied	
	mat coef[1,`c']= r(estimate) 
	mat coef[2,`c']= r(lb)
	mat coef[3,`c']= r(ub)
	
	local h=`h'+0.01	
}
	
*Labeling coef matrix rows according to each bw
mat coln coef= .01 .02 .03 .04 .05 .06 .07 .08 .09 .1 .11 .12 .13 .14 .15 .16 .17 .18 .19 .2 .21 .22 .23 .24 .25 .26 .27 .28 .29 .3

*Plotting estimates 
coefplot (mat(coef[1]), ci((2 3)) label("X")), vert recast(line) lwidth(*2) color(gs2%70) ///
ciopts(recast(rarea) color(gs6%40) acolor(gs6%30) alw(vvthin)) yline(0, lp(dash) lcolor(maroon)) ///
xline(6.5, lp(dash) lc(gs2%70)) ylabel(,labsize(small)) xlabel(,labsize(vsmall)) ///
b2title("Bandwidth of Vote Margin", size(medsmall)) l2title("Effect of Partisan Alignment on Primary Forest Loss (%)", size(medsmall))
 
gr export "${plots}\rdplot_main_results_bwrobust_gobhead.pdf", as(pdf) replace 
 
*-------------------------------------------------------------------------------
* Robustness of BWs for director not Gob sample 
*-------------------------------------------------------------------------------
*Dependent's var mean
summ z_sh_votes_alc, d

*Creating matrix to export estimates
mat coef=J(3,30,.)

*Estimations
local h=0.01
forval c=1/30{

	*Conditional for all specifications
	gl if "if abs(z_sh_votes_alc)<=`h'"

	*Replicating triangular weights
	cap drop tweights
	gen tweights=(1-abs(z_sh_votes_alc/`h')) ${if}
	
	*Total Households
	reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==0, abs(${fes}) vce(robust)
	lincom mayorallied	
	mat coef[1,`c']= r(estimate) 
	mat coef[2,`c']= r(lb)
	mat coef[3,`c']= r(ub)
	
	local h=`h'+0.01	
}
	
*Labeling coef matrix rows according to each bw
mat coln coef= .01 .02 .03 .04 .05 .06 .07 .08 .09 .1 .11 .12 .13 .14 .15 .16 .17 .18 .19 .2 .21 .22 .23 .24 .25 .26 .27 .28 .29 .3

*Plotting estimates 
coefplot (mat(coef[1]), ci((2 3)) label("X")), vert recast(line) lwidth(*2) color(gs2%70) ///
ciopts(recast(rarea) color(gs6%40) acolor(gs6%30) alw(vvthin)) yline(0, lp(dash) lcolor(maroon)) ///
xline(6.5, lp(dash) lc(gs2%70)) ylabel(,labsize(small)) xlabel(,labsize(vsmall)) ///
b2title("Bandwidth of Vote Margin", size(medsmall)) l2title("Effect of Partisan Alignment on Primary Forest Loss (%)", size(medsmall))
 
gr export "${plots}\rdplot_main_results_bwrobust_gobnothead.pdf", as(pdf) replace 




*END
