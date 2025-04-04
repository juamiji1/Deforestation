
use "${data}/Interim\defo_caralc.dta", clear 

*-------------------------------------------------------------------------------
* Labels
*
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
* Main Results
*
*-------------------------------------------------------------------------------
summ z_sh_votes_alc, d

rdrobust floss_prim_ideam_area z_sh_votes_alc, all kernel(triangular)
gl h = e(h_l)
gl ht= round(${h}, .001)
gl p = e(p)
gl k = e(kernel)
gl if "if abs(z_sh_votes_alc)<=${h}"
gl controls "mayorallied i.mayorallied#c.z_sh_votes_alc z_sh_votes_alc"

cap drop tweights
gen tweights=(1-abs(z_sh_votes_alc/${h})) ${if}

eststo clear

*All municipalities 
eststo r1: reghdfe floss_prim_ideam_area ${controls} [aw=tweights] ${if} & director_gob_law!=., abs(year) vce(robust)

summ floss_prim_ideam_area if e(sample)==1, d
gl mean_y1=round(r(mean), .01)

*Municipalities under a CAR in which Gobernor is mandated as director 
eststo r2: reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law==1, abs(year) vce(robust)

summ floss_prim_ideam_area if e(sample)==1, d
gl mean_y2=round(r(mean), .01)

*Municipalities under a CAR in which Gobernor is NOT mandated as director 
eststo r3: reghdfe floss_prim_ideam_area ${controls} [aw=tweights] ${if} & director_gob_law==0, abs(year) vce(robust)

summ floss_prim_ideam_area if e(sample)==1, d
gl mean_y3=round(r(mean), .01)

*-------------------------------------------------------------------------------
* Table and coefplot
*-------------------------------------------------------------------------------
*Exporting results 
esttab r1 r2 r3 using "${tables}/rdd_main_results.tex", keep(mayorallied) ///
se nocons star(* 0.10 ** 0.05 *** 0.01) ///
label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
prehead(`"\begin{tabular}{@{}l*{3}{c}}"' ///
            `"\hline \toprule"'                     ///
            `" & \multicolumn{3}{c}{Primary Forest Loss (\%)} \\ \cmidrule(l){2-4}"'                   ///
            `" & All & Governor is head & Governor not head \\"' ///
            `" & (1) & (2) & (3) \\"'                       ///
            `" \toprule"')  ///
    postfoot(`" Dependent mean & ${mean_y1} & ${mean_y2} & ${mean_y3} \\"' ///
	`" & & &  \\"' ///
	`" Bandwidth & ${ht} & ${ht} & ${ht} \\"' ///
	`" Polynomial & ${p} & ${p} & ${p} \\"' ///
	`" Kernel & ${k} & ${k} & ${k} \\"' ///
	`"\bottomrule \end{tabular}"') 

coefplot (r1, label(All)) (r2, label(Governor is head)) (r3, label(Governor not head)), keep(mayorallied) ///
coeflabels(mayorallied = " ") ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(cols(3)) xtitle("Primary Forest Loss (%)", size(medsmall)) ytitle("Partisan Alignment Between Mayor and Governor", size(small)) ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2)

gr export "${plots}\rdplot_main_results.pdf", as(pdf) replace 
 
*-------------------------------------------------------------------------------
* RDplots
*-------------------------------------------------------------------------------
*All municipalities 
cap drop rdplot_*
rdplot floss_prim_ideam_area z_sh_votes_alc if abs(z_sh_votes_alc)<=.1, all kernel(triangular) h(.1) p(1) ci(95) genvars 

preserve
	collapse (mean) rdplot_mean_y rdplot_N, by(rdplot_mean_x)
	
	local var "rdplot_mean_y"
	ren rdplot_mean_x x
	ren rdplot_N n
	
	two (scatter `var' x if abs(x)<.1, mcolor(gs6) xline(0, lc(maroon) lp(dash))) ///
	(lfitci `var' x [aw = n] if x<0 & abs(x)<.1, clc(gs2%90) clw(medthick) acolor(gs6%30) alw(vvthin)) ///
	(lfitci `var' x [aw = n] if x>=0 & abs(x)<.1, clc(gs2%90) clw(medthick) acolor(gs6%30) alw(vvthin)), ///
	legend(off) ///
	l2title("Primary Forest Loss (%)", size(medsmall)) b2title("Vote Margin", size(medsmall)) ///
	xtitle("") name(`var', replace)
	
	gr export "${plots}\rdplot_main_sample_all.pdf", as(pdf) replace 
restore 

*Municipalities under a CAR in which Gobernor is mandated as director 
cap drop rdplot_*
rdplot floss_prim_ideam_area z_sh_votes_alc if abs(z_sh_votes_alc)<=.1 & director_gob_law==1, all kernel(triangular) h(.1) p(1) ci(95) genvars

preserve
	collapse (mean) rdplot_mean_y rdplot_N, by(rdplot_mean_x)
	
	local var "rdplot_mean_y"
	ren rdplot_mean_x x
	ren rdplot_N n
	
	two (scatter `var' x if abs(x)<.1, mcolor(gs6) xline(0, lc(maroon) lp(dash))) ///
	(lfitci `var' x [aw = n] if x<0 & abs(x)<.1, clc(gs2%90) clw(medthick) acolor(gs6%30) alw(vvthin)) ///
	(lfitci `var' x [aw = n] if x>=0 & abs(x)<.1, clc(gs2%90) clw(medthick) acolor(gs6%30) alw(vvthin)), ///
	legend(off) ///
	l2title("Primary Forest Loss (%)", size(medsmall)) b2title("Vote margin", size(medsmall)) ///
	xtitle("") name(`var', replace)
	
	gr export "${plots}\rdplot_main_sample_govheadyes.pdf", as(pdf) replace 
restore 

*Municipalities under a CAR in which Gobernor is NOT mandated as director 
cap drop rdplot_*
rdplot floss_prim_ideam_area z_sh_votes_alc if abs(z_sh_votes_alc)<=.1 & director_gob_law==0, all kernel(triangular) h(.1) p(1) ci(95) genvars

preserve
	collapse (mean) rdplot_mean_y rdplot_N, by(rdplot_mean_x)
	
	local var "rdplot_mean_y"
	ren rdplot_mean_x x
	ren rdplot_N n
	
	two (scatter `var' x if abs(x)<.1, mcolor(gs6) xline(0, lc(maroon) lp(dash))) ///
	(lfitci `var' x [aw = n] if x<0 & abs(x)<.1, clc(gs2%90) clw(medthick) acolor(gs6%30) alw(vvthin)) ///
	(lfitci `var' x [aw = n] if x>=0 & abs(x)<.1, clc(gs2%90) clw(medthick) acolor(gs6%30) alw(vvthin)), ///
	legend(off) ///
	l2title("Primary Forest Loss (%)", size(medsmall)) b2title("Vote Margin", size(medsmall)) ///
	xtitle("") name(`var', replace)
		
	gr export "${plots}\rdplot_main_sample_govheadno.pdf", as(pdf) replace 
restore 
 
*-------------------------------------------------------------------------------
* McCrary test
*-------------------------------------------------------------------------------
rddensity z_sh_votes_alc, c(0) noplot
gl pval=round(`e(pv_q)', .01)

rddensity z_sh_votes_alc, c(0) plot h(.085) plot_range(-.1 .1) cirl_opt(acolor(gs6%30) alw(vvthin)) esll_opt(clc(gs2%90) clw(medthick)) cirr_opt(acolor(gs6%30) alw(vvthin)) eslr_opt(clc(gs2%90) clw(medthick)) nohist graph_opt(title("") xline(0, lc(maroon) lp(dash)) legend(off) b2title("Vote Margin", size(medsmall)) xtitle("") ytitle("Frequency") note("p-value=${pval}"))

gr export "${plots}\mccraryplot_z_sh_votes_alc.pdf", as(pdf) replace 

*-------------------------------------------------------------------------------
* Robustness of 
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
	reghdfe floss_prim_ideam_area ${controls} [aw=tweights] ${if} & director_gob_law!=., abs(year) vce(robust)
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
xline(8.5, lp(dash) lc(gs2%70)) ylabel(,labsize(small)) xlabel(,labsize(vsmall)) ///
b2title("Bandwidth of Vote Margin", size(medsmall)) l2title("Effect of Partisan Alignment on Primary Forest Loss (%)", size(small))
 
gr export "${plots}\rdplot_main_results_bwrobust.pdf", as(pdf) replace 
 
 

/*-------------------------------------------------------------------------------
* Observations and sample 
*-------------------------------------------------------------------------------
reghdfe floss_prim_ideam_area mayorallied if director_gob_law!=., noabs vce(robust)
reghdfe floss_prim_ideam_area mayorallied if z_sh_votes_alc!=. & director_gob_law!=., noabs vce(robust)
reghdfe floss_prim_ideam_area ${controls} [aw=tweights] ${if} & director_gob_law!=., noabs vce(robust)

reghdfe floss_prim_ideam_area ${controls} [aw=tweights] ${if} & director_gob_law!=., abs(year) vce(robust)


reghdfe floss_prim_ideam_area ${controls} [aw=tweights] ${if}, noabs vce(robust)
tab green_party if e(sample)==1
tab green_party_v2 if e(sample)==1
tab partido_votogreen if e(sample)==1




levelsof  codigo_partido_gob if e(sample)==1



reghdfe floss_prim_ideam_area ${controls} [aw=tweights] ${if}, noabs vce(cluster coddane)
reghdfe floss_prim_ideam_area ${controls} [aw=tweights] ${if} & director_gob_law==1, noabs vce(cluster coddane)


reghdfe floss_prim_ideam_area ${controls} [aw=tweights] ${if}, abs(coddane) vce(cluster coddane)
reghdfe floss_prim_ideam_area ${controls} [aw=tweights] ${if} & director_gob_law==1, abs(coddane) vce(cluster coddane)



reghdfe floss_prim_ideam_area ${controls} [aw=tweights] ${if}, noabs vce(robust)

tab year mayorallied if e(sample)==1

tab coddane mayorallied if election==2000 & e(sample)==1

collapse (mean) mayorallied if e(sample)==1, by(coddane election codigo_partido_gob)
sort coddane election codigo_partido_gob
duplicates tag coddane codigo_partido_gob mayorallied, g(dup1)
duplicates tag coddane mayorallied, g(dup2)

tab dup1
tab dup2







*END
 
/*Sample
rdrobust floss_prim_ideam_area z_sh_votes_alc if dmdn_politics!=., all kernel(triangular)
gl h= e(h_l)
gl if "if abs(z_sh_votes_alc)<=${h}"
gl controls "mayorallied i.mayorallied#c.z_sh_votes_alc z_sh_votes_alc"

cap drop tweights
gen tweights=(1-abs(z_sh_votes_alc/${h})) ${if}

reghdfe floss_prim_ideam_area ${controls} [aw=tweights] ${if} & dmdn_politics!=., noabs vce(robust)
reghdfe floss_prim_ideam_area ${controls} [aw=tweights] ${if} & dmdn_politics==0, noabs vce(robust)
reghdfe floss_prim_ideam_area ${controls} [aw=tweights] ${if} & dmdn_politics==1, noabs vce(robust)


reghdfe floss_prim_ideam_area ${controls} [aw=tweights] ${if}, a(coddane) vce(robust)
reghdfe floss_prim_ideam_area ${controls} [aw=tweights] ${if}, a(year coddane) vce(robust)
reghdfe floss_prim_ideam_area ${control} [aw=tweights] ${if}, a(i.carcode_master#i.year coddane) vce(robust)

reghdfe floss_prim_ideam_area ${controls} dmdn_politics i.dmdn_politics#c.z_sh_votes_alc 1.mayorallied#1.dmdn_politics [aw=tweights] ${if}, noabs vce(robust)
reghdfe floss_prim_ideam_area ${controls} [aw=tweights] ${if} & dmdn_politics==0, noabs vce(robust)
reghdfe floss_prim_ideam_area ${controls} [aw=tweights] ${if} & dmdn_politics==1, noabs vce(robust)


reghdfe floss_prim_ideam_area ${controls} [aw=tweights] ${if} & dmdn_politics!=., a(year coddane) vce(robust)
reghdfe floss_prim_ideam_area ${controls} [aw=tweights] ${if} & dmdn_politics==0, a(year coddane) vce(robust)
reghdfe floss_prim_ideam_area ${controls} [aw=tweights] ${if} & dmdn_politics==1, a(year coddane) vce(robust)
reghdfe floss_prim_ideam_area ${controls} dmdn_politics i.dmdn_politics#c.z_sh_votes_alc 1.mayorallied#1.dmdn_politics [aw=tweights] ${if}, a(year coddane) vce(robust)




rdplot floss_prim_ideam_area z_sh_votes_alc ${if}, all kernel(triangular) h(${h}) p(1) ci(95)

cap drop tweights
gen tweights=(1-abs(z_sh_votes_alc/${h})) ${if}

reghdfe floss_prim_ideam_area ${controls} [aw=tweights] ${if}, noabs vce(robust) resid
cap drop floss_prim_ideam_area_r
predict floss_prim_ideam_area_r, resid
	
reghdfe floss_prim_ideam_area ${controls} [aw=tweights] ${if} & dmdn_politics!=., noabs vce(robust)
reghdfe floss_prim_ideam_area ${controls} [aw=tweights] ${if} & dmdn_politics==0, noabs vce(robust)
reghdfe floss_prim_ideam_area ${controls} [aw=tweights] ${if} & dmdn_politics==1, noabs vce(robust)


summ z_sh_votes_alc, d

rdrobust floss_prim_ideam_area z_sh_votes_alc, all kernel(triangular)
gl h= e(h_l)
gl if "if abs(z_sh_votes_alc)<=${h}"
gl controls "mayorallied i.mayorallied#c.z_sh_votes_alc z_sh_votes_alc"

cap drop tweights
gen tweights=(1-abs(z_sh_votes_alc/${h})) ${if}

reghdfe floss_prim_ideam_area ${controls} [aw=tweights] ${if} & director_gob_law!=., noabs vce(robust)
reghdfe floss_prim_ideam_area ${controls} [aw=tweights] ${if} & director_gob_law==0, noabs vce(robust)
reghdfe floss_prim_ideam_area ${controls} [aw=tweights] ${if} & director_gob_law==1, noabs vce(robust)

reghdfe floss_prim_ideam_area ${controls} [aw=tweights] ${if} & director_gob_law==1 & dmdn_politics_law==0, noabs vce(robust)
reghdfe floss_prim_ideam_area ${controls} [aw=tweights] ${if} & director_gob_law==1 & dmdn_politics_law==1, noabs vce(robust)

reghdfe floss_prim_ideam_area ${controls} [aw=tweights] ${if} & director_gob_law==1 & dmdn_politics==0, noabs vce(robust)
reghdfe floss_prim_ideam_area ${controls} [aw=tweights] ${if} & director_gob_law==1 & dmdn_politics==1, noabs vce(robust)

reghdfe floss_prim_ideam_area ${controls} [aw=tweights] ${if} & director_gob_law==0 & dmdn_politics_law==0, noabs vce(robust)
reghdfe floss_prim_ideam_area ${controls} [aw=tweights] ${if} & director_gob_law==0 & dmdn_politics_law==1, noabs vce(robust)

reghdfe floss_prim_ideam_area ${controls} [aw=tweights] ${if} & director_gob_law==0 & dmdn_politics==0, noabs vce(robust)
reghdfe floss_prim_ideam_area ${controls} [aw=tweights] ${if} & director_gob_law==0 & dmdn_politics==1, noabs vce(robust)


summ floss_prim_ideam_area if z_sh_votes_alc!=., d
gen y_trimm= floss_prim_ideam_area if floss_prim_ideam_area>=`r(p5)' & floss_prim_ideam_area<=`r(p95)'

reghdfe y_trimm ${controls} [aw=tweights] ${if} & director_gob_law!=., noabs vce(robust)
reghdfe y_trimm ${controls} [aw=tweights] ${if} & director_gob_law==0, noabs vce(robust)
reghdfe y_trimm ${controls} [aw=tweights] ${if} & director_gob_law==1, noabs vce(robust)



reghdfe floss_prim_ideam_area ${controls} ${if}, noabs vce(robust) resid
cap drop floss_prim_ideam_area_r
predict floss_prim_ideam_area_r, resid



cap drop rdplot_*
rdplot floss_prim_ideam_area z_sh_votes_alc if abs(z_sh_votes_alc)<=.1 & director_gob_law==0, all kernel(triangular) h(.1) p(1) ci(95) genvars

preserve
	collapse (mean) rdplot_mean_y rdplot_N, by(rdplot_mean_x)
	
	local var "rdplot_mean_y"
	ren rdplot_mean_x x
	ren rdplot_N n
	
	two (scatter `var' x if abs(x)<.1, mcolor(gs6) xline(0, lc(maroon) lp(dash))) ///
	(lfitci `var' x [aw = n] if x<0 & abs(x)<.1, clc(gs2%90) clw(medthick) acolor(gs6%30) alw(vvthin)) ///
	(lfitci `var' x [aw = n] if x>=0 & abs(x)<.1, clc(gs2%90) clw(medthick) acolor(gs6%30) alw(vvthin)), ///
	legend(off) ///
	l2title("Estimate magnitud", size(medsmall)) b2title("Vote margin", size(medsmall)) ///
	xtitle("") name(`var', replace)
		
restore 


cap drop rdplot_*
rdplot floss_prim_ideam_area z_sh_votes_alc if abs(z_sh_votes_alc)<=.1 & director_gob_law==1, all kernel(triangular) h(.1) p(1) ci(95) genvars

preserve
	collapse (mean) rdplot_mean_y rdplot_N, by(rdplot_mean_x)
	
	local var "rdplot_mean_y"
	ren rdplot_mean_x x
	ren rdplot_N n
	
	two (scatter `var' x if abs(x)<.1, mcolor(gs6) xline(0, lc(maroon) lp(dash))) ///
	(lfitci `var' x [aw = n] if x<0 & abs(x)<.1, clc(gs2%90) clw(medthick) acolor(gs6%30) alw(vvthin)) ///
	(lfitci `var' x [aw = n] if x>=0 & abs(x)<.1, clc(gs2%90) clw(medthick) acolor(gs6%30) alw(vvthin)), ///
	legend(off) ///
	l2title("Estimate magnitud", size(medsmall)) b2title("Vote margin", size(medsmall)) ///
	xtitle("") name(`var', replace)
		
restore 
