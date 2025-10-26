use "${data}/Interim\defo_caralc.dta", clear


*-------------------------------------------------------------------------------
* Main Results with Controls
*
*-------------------------------------------------------------------------------
egen mean_sut_crops = rowmean(sut_cof sut_banana sut_cocoa sut_rice sut_oil)
replace mean_sut_crops=mean_sut_crops /10000 //Normalizing by max
gen sh_paarea      = pa_area/area

gl controls "mayorallied i.mayorallied#c.z_sh_votes_alc z_sh_votes_alc"
gl fes      "region year"

rdrobust floss_prim_ideam_area_v2 z_sh_votes_alc, all kernel(triangular) covs(${fes})
gl h  = e(h_l)
gl ht = round(${h}, .001)
gl if "if abs(z_sh_votes_alc)<=${h}"

cap drop tweights
gen tweights = (1-abs(z_sh_votes_alc/${h})) ${if}

gl X_lc "altura mean_sut_crops sh_paarea pobl_tot93"
   
eststo clear

*All municipalities 
eststo r1: reghdfe floss_prim_ideam_area_v2 ${controls} ${X_lc} [aw=tweights] ${if} & director_gob_law_v2!=., abs(${fes}) vce(robust)

summ floss_prim_ideam_area if e(sample)==1, d
gl mean_y1=round(r(mean), .01)

*Municipalities under a CAR in which Gobernor is mandated as director 
eststo r2: reghdfe floss_prim_ideam_area_v2 ${controls} ${X_lc} [aw=tweights] ${if} & director_gob_law_v2==1, abs(${fes}) vce(robust)

summ floss_prim_ideam_area if e(sample)==1, d
gl mean_y2=round(r(mean), .01)

*Municipalities under a CAR in which Gobernor is NOT mandated as director 
eststo r3: reghdfe floss_prim_ideam_area_v2 ${controls} ${X_lc} [aw=tweights] ${if} & director_gob_law_v2==0, abs(${fes}) vce(robust)

summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_y3=round(r(mean), .01)

coefplot (r1, label(All)) (r2, label(Governor is head)) (r3, label(Governor not head)), keep(mayorallied) ///
coeflabels(mayorallied = " ") ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(cols(3)) xtitle("Primary Forest Loss (%)", size(medsmall)) ytitle("Partisan Alignment Between Mayor and Governor", size(medsmall)) ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2)

gr export "${plots}\rdplot_main_results_lccontrols.pdf", as(pdf) replace 
 
*-------------------------------------------------------------------------------
* RDplots
*-------------------------------------------------------------------------------
*All municipalities 
cap drop rdplot_*
rdplot floss_prim_ideam_area_v2 z_sh_votes_alc if abs(z_sh_votes_alc)<=${h}, all kernel(triangular) h(${h}) p(1) ci(95) genvars covs(${X_lc} ${fes})

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
	l2title("Primary Forest Loss (%)", size(medsmall)) b2title("Vote Margin", size(medsmall)) ///
	xtitle("") name(`var', replace)
	
	gr export "${plots}\rdplot_main_sample_lccontrols_all.pdf", as(pdf) replace 
restore 

*Municipalities under a CAR in which Gobernor is mandated as director 
cap drop rdplot_*
rdplot floss_prim_ideam_area_v2 z_sh_votes_alc if abs(z_sh_votes_alc)<=${h} & director_gob_law_v2==1, all kernel(triangular) h(${h}) p(1) ci(95) genvars covs(${X_lc} ${fes})

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
	l2title("Primary Forest Loss (%)", size(medsmall)) b2title("Vote Margin", size(medsmall)) ///
	xtitle("") name(`var', replace)
	
	gr export "${plots}\rdplot_main_sample_lccontrols_govheadyes.pdf", as(pdf) replace 
restore 

*Municipalities under a CAR in which Gobernor is NOT mandated as director 
cap drop rdplot_*
rdplot floss_prim_ideam_area_v2 z_sh_votes_alc if abs(z_sh_votes_alc)<${h} & director_gob_law_v2==0 & floss_prim_ideam_area_v2!=., all kernel(triangular) h(${h}) p(1) ci(95) genvars covs(${X_lc} ${fes}) nbins(15)

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
	l2title("Primary Forest Loss (%)", size(medsmall)) b2title("Vote Margin", size(medsmall)) ///
	xtitle("") name(`var', replace)
		
	gr export "${plots}\rdplot_main_sample_lccontrols_govheadno.pdf", as(pdf) replace 
restore 



*END
