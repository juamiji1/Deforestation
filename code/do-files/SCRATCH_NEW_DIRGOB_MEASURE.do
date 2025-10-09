
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

rdrobust floss_prim_ideam_area_v2 z_sh_votes_alc, all kernel(triangular)
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
eststo r1: reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2!=., abs(year) vce(robust)

summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_y1=round(r(mean), .01)

*Municipalities under a CAR in which Gobernor is mandated as director 
eststo r2: reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==1, abs(year) vce(robust)

summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_y2=round(r(mean), .01)

*Municipalities under a CAR in which Gobernor is NOT mandated as director 
eststo r3: reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==0, abs(year) vce(robust)

summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_y3=round(r(mean), .01)

*-------------------------------------------------------------------------------
* Table and coefplot
*-------------------------------------------------------------------------------
*Exporting results 
esttab r1 r2 r3 using "${tables}/rdd_main_results_rev.tex", keep(mayorallied) ///
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
	`"\bottomrule \end{tabular}"') 

coefplot (r1, label(All)) (r2, label(Governor is head)) (r3, label(Governor not head)), keep(mayorallied) ///
coeflabels(mayorallied = " ") ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(cols(3)) xtitle("Primary Forest Loss (%)", size(medsmall)) ytitle("Partisan Alignment Between Mayor and Governor", size(medsmall)) ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2)

gr export "${plots}\rdplot_main_results_rev.pdf", as(pdf) replace 
 
*-------------------------------------------------------------------------------
* RDplots
*-------------------------------------------------------------------------------
*All municipalities 
cap drop rdplot_*
rdplot floss_prim_ideam_area_v2 z_sh_votes_alc if abs(z_sh_votes_alc)<=${h}, all kernel(triangular) h(${h}) p(1) ci(95) genvars 

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
	
	gr export "${plots}\rdplot_main_sample_all_rev.pdf", as(pdf) replace 
restore 

*Municipalities under a CAR in which Gobernor is mandated as director 
cap drop rdplot_*
rdplot floss_prim_ideam_area_v2 z_sh_votes_alc if abs(z_sh_votes_alc)<=${h} & director_gob_law_v2==1, all kernel(triangular) h(${h}) p(1) ci(95) genvars

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
	
	gr export "${plots}\rdplot_main_sample_govheadyes_rev.pdf", as(pdf) replace 
restore 

*Municipalities under a CAR in which Gobernor is NOT mandated as director 
cap drop rdplot_*
rdplot floss_prim_ideam_area_v2 z_sh_votes_alc if abs(z_sh_votes_alc)<${h} & director_gob_law_v2==0, all kernel(triangular) h(${h}) p(1) ci(95) genvars

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
		
	gr export "${plots}\rdplot_main_sample_govheadno_rev.pdf", as(pdf) replace 
restore 


*-------------------------------------------------------------------------------
* RD on Legal vs Ilegal Deforestation given Gov is head
*-------------------------------------------------------------------------------
*All municipalities 
eststo r1: reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==1, abs(region##year) vce(robust)

summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_y1=round(r(mean), .01)

*Municipalities under a CAR in which Gobernor is mandated as director 
eststo r2: reghdfe floss_prim_legal_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==1, abs(region##year) vce(robust)

summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_y2=round(r(mean), .01)

*Municipalities under a CAR in which Gobernor is NOT mandated as director 
eststo r3: reghdfe floss_prim_ilegal_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==1, abs(region##year) vce(robust)

summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_y3=round(r(mean), .01)

coefplot (r1, label("Both")) (r2, label("Legal")) (r3, label("Illegal")), keep(mayorallied) ///
coeflabels(mayorallied = " ") ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(cols(3)) xtitle("Primary Forest Loss (%)", size(medsmall)) ytitle("Partisan Alignment Between Mayor and Governor", size(medsmall)) ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2)

gr export "${plots}\rdplot_legal_results_gobhead.pdf", as(pdf) replace 
		
*-------------------------------------------------------------------------------
* RD on Legal vs Ilegal Deforestation given Gov not head
*-------------------------------------------------------------------------------
*All municipalities 
eststo r4: reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==0, abs(region##year) vce(robust)

summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_y1=round(r(mean), .01)

*Municipalities under a CAR in which Gobernor is mandated as director 
eststo r5: reghdfe floss_prim_legal_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==0, abs(region##year) vce(robust)

summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_y2=round(r(mean), .01)

*Municipalities under a CAR in which Gobernor is NOT mandated as director 
eststo r6: reghdfe floss_prim_ilegal_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==0, abs(region##year) vce(robust)

summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_y3=round(r(mean), .01)

coefplot (r4, label("Both")) (r5, label("Legal")) (r6, label("Illegal")), keep(mayorallied) ///
coeflabels(mayorallied = " ") ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(cols(3)) xtitle("Primary Forest Loss (%)", size(medsmall)) ytitle("Partisan Alignment Between Mayor and Governor", size(medsmall)) ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2)

gr export "${plots}\rdplot_legal_results_gobnothead.pdf", as(pdf) replace 

		
*-------------------------------------------------------------------------------
* Pooling plots
*-------------------------------------------------------------------------------
coefplot (r2, label("Legal + Gov. Head")) (r3, label("Illegal + Gov. Head")) (r5, label("Legal + Gov.  Not Head")) (r6, label("Illegal + Gov. Not Head")), keep(mayorallied) ///
coeflabels(mayorallied = " ") ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(cols(2)) xtitle("Primary Forest Loss (%)", size(medsmall)) ytitle("Partisan Alignment Between Mayor and Governor", size(medsmall)) ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2)

gr export "${plots}\rdplot_legal_results_bygobhead.pdf", as(pdf) replace 





eststo r1: reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2!=., abs(year) vce(robust)
eststo r1: reghdfe sh_floss_prim_ilegal ${controls} [aw=tweights] ${if} & director_gob_law_v2!=., abs(year) vce(robust)

eststo r1: reghdfe sh_floss_prim_ilegal ${controls} [aw=tweights] ${if} & director_gob_law_v2==1, abs(year) vce(robust)
eststo r1: reghdfe sh_floss_prim_ilegal ${controls} [aw=tweights] ${if} & director_gob_law_v2==0, abs(year) vce(robust)




*END