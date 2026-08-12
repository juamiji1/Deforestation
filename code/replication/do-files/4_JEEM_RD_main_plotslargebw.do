use "${data}/Interim\defo_caralc.dta", clear 


*-------------------------------------------------------------------------------
* Main Results
*
*-------------------------------------------------------------------------------
gl controls "mayorallied i.mayorallied#c.z_sh_votes_alc z_sh_votes_alc"
gl fes "region year"

rdrobust floss_prim_ideam_area_v2 z_sh_votes_alc, all kernel(triangular) covs(${fes})
gl h0 = e(h_l)

*-------------------------------------------------------------------------------
* RDplots
*-------------------------------------------------------------------------------
gl h = .3
gl if "if abs(z_sh_votes_alc)<=${h}"

cap drop tweights
gen tweights=(1-abs(z_sh_votes_alc/${h})) ${if}

*All municipalities 
cap drop rdplot_*
rdplot floss_prim_ideam_area_v2 z_sh_votes_alc if abs(z_sh_votes_alc)<=${h} & floss_prim_ideam_area_v2!=., all kernel(triangular) h(${h}) p(1) ci(95) genvars nbins(60) covs(${fes})

preserve
	collapse (mean) rdplot_mean_y rdplot_N tweights, by(rdplot_mean_x)
	
	local var "rdplot_mean_y"
	ren rdplot_mean_x x
	ren rdplot_N n
	gen ntweights=n*tweights
	
	two (scatter `var' x if abs(x)<=${h}, mcolor(gs6) xline(0, lc(maroon) lp(dash)) xline(-${h0} ${h0}, lc(gray%70) lp(dash))) ///
	(lfitci `var' x [aw = ntweights] if x<0 & abs(x)<=${h}, clc(gs2%90) clw(medthick) acolor(gs6%30) alw(vvthin)) ///
	(lfitci `var' x [aw = ntweights] if x>=0 & abs(x)<=${h}, clc(gs2%90) clw(medthick) acolor(gs6%30) alw(vvthin)), ///
	legend(off) ///
	l2title("Primary Forest Loss (%)", size(medsmall)) b2title("Vote Margin", size(medsmall)) ///
	xtitle("") name(`var', replace) xlabel(-.3 (.1) .3)
	
	gr export "${plots}\rdplot_main_sample_all_largerange.pdf", as(pdf) replace 
restore 

*Municipalities under a CAR in which Gobernor is mandated as director 
cap drop rdplot_*
rdplot floss_prim_ideam_area_v2 z_sh_votes_alc if abs(z_sh_votes_alc)<=${h} & director_gob_law_v2==1 & floss_prim_ideam_area_v2!=., all kernel(triangular) h(${h}) p(1) ci(95) genvars nbins(60) covs(${fes})

preserve
	collapse (mean) rdplot_mean_y rdplot_N tweights, by(rdplot_mean_x)
	
	local var "rdplot_mean_y"
	ren rdplot_mean_x x
	ren rdplot_N n
	gen ntweights=n*tweights
	
	two (scatter `var' x if abs(x)<=${h}, mcolor(gs6) xline(0, lc(maroon) lp(dash)) xline(-${h0} ${h0}, lc(gray%70) lp(dash))) ///
	(lfitci `var' x [aw = ntweights] if x<0 & abs(x)<=${h}, clc(gs2%90) clw(medthick) acolor(gs6%30) alw(vvthin)) ///
	(lfitci `var' x [aw = ntweights] if x>=0 & abs(x)<=${h}, clc(gs2%90) clw(medthick) acolor(gs6%30) alw(vvthin)), ///
	legend(off) ///
	l2title("Primary Forest Loss (%)", size(medsmall)) b2title("Vote Margin", size(medsmall)) ///
	xtitle("") name(`var', replace) xlabel(-.3 (.1) .3)
	
	gr export "${plots}\rdplot_main_sample_govheadyes_largerange.pdf", as(pdf) replace 
restore 

*Municipalities under a CAR in which Gobernor is NOT mandated as director 
cap drop rdplot_*
rdplot floss_prim_ideam_area_v2 z_sh_votes_alc if abs(z_sh_votes_alc)<${h} & director_gob_law_v2==0 & floss_prim_ideam_area_v2!=., all kernel(triangular) h(${h}) p(1) ci(95) genvars nbins(65) covs(${fes})

preserve
	collapse (mean) rdplot_mean_y rdplot_N tweights, by(rdplot_mean_x)
	
	local var "rdplot_mean_y"
	ren rdplot_mean_x x
	ren rdplot_N n
	gen ntweights=n*tweights
	
	two (scatter `var' x if abs(x)<=${h}, mcolor(gs6) xline(0, lc(maroon) lp(dash)) xline(-${h0} ${h0}, lc(gray%70) lp(dash))) ///
	(lfitci `var' x [aw = ntweights] if x<0 & abs(x)<=${h}, clc(gs2%90) clw(medthick) acolor(gs6%30) alw(vvthin)) ///
	(lfitci `var' x [aw = ntweights] if x>=0 & abs(x)<=${h}, clc(gs2%90) clw(medthick) acolor(gs6%30) alw(vvthin)), ///
	legend(off) ///
	l2title("Primary Forest Loss (%)", size(medsmall)) b2title("Vote Margin", size(medsmall)) ///
	xtitle("") name(`var', replace) xlabel(-.3 (.1) .3)
		
	gr export "${plots}\rdplot_main_sample_govheadno_largerange.pdf", as(pdf) replace 
restore 



*END