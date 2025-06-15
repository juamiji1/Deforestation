
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

rdrobust bii z_sh_votes_alc, all kernel(triangular)
gl h = .1
gl ht= round(${h}, .001)
gl p = e(p)
gl k = e(kernel)
gl if "if abs(z_sh_votes_alc)<=${h} & floss_prim_ideam_area_v2!=."
gl controls "mayorallied i.mayorallied#c.z_sh_votes_alc z_sh_votes_alc"

cap drop tweights
gen tweights=(1-abs(z_sh_votes_alc/${h})) ${if}

eststo clear

*All municipalities 
eststo r1: reghdfe bii ${controls} [aw=tweights] ${if} & director_gob_law!=., abs(year) vce(robust)

summ bii if e(sample)==1, d
gl mean_y1=round(r(mean), .01)

*Municipalities under a CAR in which Gobernor is mandated as director 
eststo r2: reghdfe bii ${controls} [aw=tweights] ${if} & director_gob_law==1, abs(year) vce(robust)

summ bii if e(sample)==1, d
gl mean_y2=round(r(mean), .01)

*Municipalities under a CAR in which Gobernor is NOT mandated as director 
eststo r3: reghdfe bii ${controls} [aw=tweights] ${if} & director_gob_law==0, abs(year) vce(robust)

summ bii if e(sample)==1, d
gl mean_y3=string(round(r(mean), .01))

*-------------------------------------------------------------------------------
* Table and coefplot
*-------------------------------------------------------------------------------
*Exporting results 
esttab r1 r2 r3 using "${tables}/rdd_bii_results.tex", keep(mayorallied) ///
se nocons star(* 0.10 ** 0.05 *** 0.01) ///
label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
prehead(`"\begin{tabular}{@{}l*{3}{c}}"' ///
            `"\hline \toprule"'                     ///
            `" & \multicolumn{3}{c}{Biodiversity Intactness Index (\%)} \\ \cmidrule(l){2-4}"'                   ///
            `" & All & Governor is head & Governor not head \\"' ///
            `" & (1) & (2) & (3) \\"'                       ///
            `" \toprule"')  ///
    postfoot(`" Dependent mean & ${mean_y1} & ${mean_y2} & ${mean_y3} \\"' ///
	`" & & &  \\"' ///
	`" Bandwidth & ${ht} & ${ht} & ${ht} \\"' ///
	`"\bottomrule \end{tabular}"') 

coefplot (r1, label(All)) (r2, label(Governor is head)) (r3, label(Governor not head)), keep(mayorallied) ///
coeflabels(mayorallied = " ") ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(cols(3)) xtitle("Biodiversity Intactness (%)", size(medsmall)) ytitle("Partisan Alignment Between Mayor and Governor", size(medsmall)) ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2)

gr export "${plots}\rdplot_bii_results.pdf", as(pdf) replace 
 
*-------------------------------------------------------------------------------
* RDplots
*-------------------------------------------------------------------------------
*All municipalities 
cap drop rdplot_*
rdplot bii z_sh_votes_alc ${if}, all kernel(triangular) h(${h}) p(1) ci(95) genvars 

preserve
	collapse (mean) rdplot_mean_y rdplot_N, by(rdplot_mean_x)
	
	local var "rdplot_mean_y"
	ren rdplot_mean_x x
	ren rdplot_N n
	
	two (scatter `var' x if abs(x)<=${h}, mcolor(gs6) xline(0, lc(maroon) lp(dash))) ///
	(lfitci `var' x [aw = n] if x<0 & abs(x)<=${h}, clc(gs2%90) clw(medthick) acolor(gs6%30) alw(vvthin)) ///
	(lfitci `var' x [aw = n] if x>=0 & abs(x)<=${h}, clc(gs2%90) clw(medthick) acolor(gs6%30) alw(vvthin)), ///
	legend(off) ///
	l2title("Biodiversity Intactness (%)", size(medsmall)) b2title("Vote Margin", size(medsmall)) ///
	xtitle("") name(`var', replace)
	
	gr export "${plots}\rdplot_bii_sample_all.pdf", as(pdf) replace 
restore 

*Municipalities under a CAR in which Gobernor is mandated as director 
cap drop rdplot_*
rdplot bii z_sh_votes_alc ${if} & director_gob_law==1, all kernel(triangular) h(${h}) p(1) ci(95) genvars

preserve
	collapse (mean) rdplot_mean_y rdplot_N, by(rdplot_mean_x)
	
	local var "rdplot_mean_y"
	ren rdplot_mean_x x
	ren rdplot_N n
	
	two (scatter `var' x if abs(x)<=${h}, mcolor(gs6) xline(0, lc(maroon) lp(dash))) ///
	(lfitci `var' x [aw = n] if x<0 & abs(x)<=${h}, clc(gs2%90) clw(medthick) acolor(gs6%30) alw(vvthin)) ///
	(lfitci `var' x [aw = n] if x>=0 & abs(x)<=${h}, clc(gs2%90) clw(medthick) acolor(gs6%30) alw(vvthin)), ///
	legend(off) ///
	l2title("Biodiversity Intactness (%)", size(medsmall)) b2title("Vote Margin", size(medsmall)) ///
	xtitle("") name(`var', replace)
	
	gr export "${plots}\rdplot_bii_sample_govheadyes.pdf", as(pdf) replace 
restore 

*Municipalities under a CAR in which Gobernor is NOT mandated as director 
cap drop rdplot_*
rdplot bii z_sh_votes_alc ${if} & director_gob_law==0, all kernel(triangular) h(${h}) p(1) ci(95) genvars

preserve
	collapse (mean) rdplot_mean_y rdplot_N, by(rdplot_mean_x)
	
	local var "rdplot_mean_y"
	ren rdplot_mean_x x
	ren rdplot_N n
	
	two (scatter `var' x if abs(x)<=${h}, mcolor(gs6) xline(0, lc(maroon) lp(dash))) ///
	(lfitci `var' x [aw = n] if x<0 & abs(x)<=${h}, clc(gs2%90) clw(medthick) acolor(gs6%30) alw(vvthin)) ///
	(lfitci `var' x [aw = n] if x>=0 & abs(x)<=${h}, clc(gs2%90) clw(medthick) acolor(gs6%30) alw(vvthin)), ///
	legend(off) ///
	l2title("Biodiversity Intactness (%)", size(medsmall)) b2title("Vote Margin", size(medsmall)) ///
	xtitle("") name(`var', replace)
		
	gr export "${plots}\rdplot_bii_sample_govheadno.pdf", as(pdf) replace 
restore 

*-------------------------------------------------------------------------------
* Robustness of All sample
*-------------------------------------------------------------------------------
*Dependent's var mean
summ z_sh_votes_alc, d

*Creating matrix to export estimates
mat coef=J(3,30,.)

*Estimations
local h=0.01
forval c=1/30{

	*Conditional for all specifications
	gl if "if abs(z_sh_votes_alc)<=`h' & floss_prim_ideam_area_v2!=."

	*Replicating triangular weights
	cap drop tweights
	gen tweights=(1-abs(z_sh_votes_alc/`h')) ${if}
	
	*Total Households
	reghdfe bii ${controls} [aw=tweights] ${if}, abs(year) vce(robust)
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
 
gr export "${plots}\rdplot_bii_results_bwrobust.pdf", as(pdf) replace 
 
*-------------------------------------------------------------------------------
* Robustness of Gob director sample 
*-------------------------------------------------------------------------------
*Dependent's var mean
summ z_sh_votes_alc, d

*Creating matrix to export estimates
mat coef=J(3,29,.)

*Estimations
local h=0.02
forval c=1/29{

	*Conditional for all specifications
	gl if "if abs(z_sh_votes_alc)<=`h' & floss_prim_ideam_area_v2!=."

	*Replicating triangular weights
	cap drop tweights
	gen tweights=(1-abs(z_sh_votes_alc/`h')) ${if}
	
	*Total Households
	reghdfe bii ${controls} [aw=tweights] ${if} & director_gob_law==1, abs(year) vce(robust)
	lincom mayorallied	
	mat coef[1,`c']= r(estimate) 
	mat coef[2,`c']= r(lb)
	mat coef[3,`c']= r(ub)
	
	local h=`h'+0.01	
}
	
*Labeling coef matrix rows according to each bw
mat coln coef= .02 .03 .04 .05 .06 .07 .08 .09 .1 .11 .12 .13 .14 .15 .16 .17 .18 .19 .2 .21 .22 .23 .24 .25 .26 .27 .28 .29 .3

*Plotting estimates 
coefplot (mat(coef[1]), ci((2 3)) label("X")), vert recast(line) lwidth(*2) color(gs2%70) ///
ciopts(recast(rarea) color(gs6%40) acolor(gs6%30) alw(vvthin)) yline(0, lp(dash) lcolor(maroon)) ///
xline(6.5, lp(dash) lc(gs2%70)) ylabel(,labsize(small)) xlabel(,labsize(vsmall)) ///
b2title("Bandwidth of Vote Margin", size(medsmall)) l2title("Effect of Partisan Alignment on Primary Forest Loss (%)", size(medsmall))
 
gr export "${plots}\rdplot_bii_results_bwrobust_gobhead.pdf", as(pdf) replace 
 
*-------------------------------------------------------------------------------
* Robustness of director not Gob sample 
*-------------------------------------------------------------------------------
*Dependent's var mean
summ z_sh_votes_alc, d

*Creating matrix to export estimates
mat coef=J(3,29,.)

*Estimations
local h=0.02
forval c=1/29{

	*Conditional for all specifications
	gl if "if abs(z_sh_votes_alc)<=`h' & floss_prim_ideam_area_v2!=."

	*Replicating triangular weights
	cap drop tweights
	gen tweights=(1-abs(z_sh_votes_alc/`h')) ${if}
	
	*Total Households
	reghdfe bii ${controls} [aw=tweights] ${if} & director_gob_law==0, abs(year) vce(robust)
	lincom mayorallied	
	mat coef[1,`c']= r(estimate) 
	mat coef[2,`c']= r(lb)
	mat coef[3,`c']= r(ub)
	
	local h=`h'+0.01	
}
	
*Labeling coef matrix rows according to each bw
mat coln coef= .02 .03 .04 .05 .06 .07 .08 .09 .1 .11 .12 .13 .14 .15 .16 .17 .18 .19 .2 .21 .22 .23 .24 .25 .26 .27 .28 .29 .3

*Plotting estimates 
coefplot (mat(coef[1]), ci((2 3)) label("X")), vert recast(line) lwidth(*2) color(gs2%70) ///
ciopts(recast(rarea) color(gs6%40) acolor(gs6%30) alw(vvthin)) yline(0, lp(dash) lcolor(maroon)) ///
xline(6.5, lp(dash) lc(gs2%70)) ylabel(,labsize(small)) xlabel(,labsize(vsmall)) ///
b2title("Bandwidth of Vote Margin", size(medsmall)) l2title("Effect of Partisan Alignment on Primary Forest Loss (%)", size(medsmall))
 
gr export "${plots}\rdplot_bii_results_bwrobust_gobnothead.pdf", as(pdf) replace 

