
use "${data}/Interim\defo_caralc.dta", clear 

*-------------------------------------------------------------------------------
* Creating placebo running variables	
*
*-------------------------------------------------------------------------------
gen z_sh_votes_alc_neg10=z_sh_votes_alc-.15
gen z_sh_votes_alc_pos10=z_sh_votes_alc+.15

gen d_won_neg10=(z_sh_votes_alc_neg10>=0) if z_sh_votes_alc_neg10!=.
gen d_won_pos10=(z_sh_votes_alc_pos10>=0) if z_sh_votes_alc_pos10!=.


*-------------------------------------------------------------------------------
* Main Results for +15 Placebo
*
*-------------------------------------------------------------------------------
gl fes "region year"
gl controls "d_won_pos10 i.d_won_pos10#c.z_sh_votes_alc_pos10 z_sh_votes_alc_pos10"

rdrobust floss_prim_ideam_area_v2 z_sh_votes_alc, all kernel(triangular) covs(${fes})
gl h = e(h_l)
gl if "if abs(z_sh_votes_alc_pos10)<=${h}"

cap drop tweights
gen tweights=(1-abs(z_sh_votes_alc_pos10/${h})) ${if}

eststo clear

*All municipalities 
eststo r1: reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2!=., abs(year) vce(robust)

*Municipalities under a CAR in which Gobernor is mandated as director 
eststo r2: reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==1, abs(year) vce(robust)

*Municipalities under a CAR in which Gobernor is NOT mandated as director 
eststo r3: reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==0, abs(year) vce(robust)

coefplot (r1, label(All)) (r2, label(Governor is head)) (r3, label(Governor not head)), keep(d_won_pos10) ///
coeflabels(d_won_pos10 = " ") ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(cols(3)) xtitle("Primary Forest Loss (%)", size(medsmall)) ytitle("Partisan Alignment Between Mayor and Governor", size(medsmall)) ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2)

gr export "${plots}\rdplot_main_results_placebo_pos10.pdf", as(pdf) replace 
 

*-------------------------------------------------------------------------------
* Main Results for +15 Placebo
*
*-------------------------------------------------------------------------------
gl fes "region year"
gl controls "d_won_neg10 i.d_won_neg10#c.z_sh_votes_alc_neg10 z_sh_votes_alc_neg10"

rdrobust floss_prim_ideam_area_v2 z_sh_votes_alc, all kernel(triangular) covs(${fes})
gl h = e(h_l)
gl if "if abs(z_sh_votes_alc_neg10)<=${h}"

cap drop tweights
gen tweights=(1-abs(z_sh_votes_alc_neg10/${h})) ${if}

eststo clear

*All municipalities 
eststo r1: reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2!=., abs(year) vce(robust)

*Municipalities under a CAR in which Gobernor is mandated as director 
eststo r2: reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==1, abs(year) vce(robust)

*Municipalities under a CAR in which Gobernor is NOT mandated as director 
eststo r3: reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==0, abs(year) vce(robust)

coefplot (r1, label(All)) (r2, label(Governor is head)) (r3, label(Governor not head)), keep(d_won_neg10) ///
coeflabels(d_won_neg10 = " ") ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(cols(3)) xtitle("Primary Forest Loss (%)", size(medsmall)) ytitle("Partisan Alignment Between Mayor and Governor", size(medsmall)) ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2)

gr export "${plots}\rdplot_main_results_placebo_neg10.pdf", as(pdf) replace 


*-------------------------------------------------------------------------------
* Placebo on Yvar not controlled by REPAs
*
*-------------------------------------------------------------------------------
use "${data}/Interim\defo_caralc.dta", clear 

gl fes "region year"
gl controls "mayorallied i.mayorallied#c.z_sh_votes_alc z_sh_votes_alc"

*-------------------------------------------------------------------------------
* Main Results of alignment vs not alignment
*
*-------------------------------------------------------------------------------
summ z_sh_votes_alc, d

rdrobust floss_prim_ideam_area_v2 z_sh_votes_alc, all kernel(triangular) covs(${fes})
gl h = e(h_l)
gl ht= round(${h}, .001)
gl if "if abs(z_sh_votes_alc)<=${h} & floss_prim_ideam_area_v2!=."

cap drop tweights
gen tweights=(1-abs(z_sh_votes_alc/${h})) ${if}

eststo clear

*All municipalities 
eststo r1: reghdfe tot_ppm ${controls} [aw=tweights] ${if} & director_gob_law_v2!=., abs(${fes}) vce(robust) keepsing

summ tot_ppm if e(sample)==1, d
gl mean_y1=round(r(mean), .01)

*Municipalities under a CAR in which Gobernor is mandated as director 
eststo r2: reghdfe tot_ppm ${controls} [aw=tweights] ${if} & director_gob_law_v2==1, abs(${fes}) vce(robust) keepsing

summ tot_ppm if e(sample)==1, d
gl mean_y2=round(r(mean), .01)

*Municipalities under a CAR in which Gobernor is NOT mandated as director 
eststo r3: reghdfe tot_ppm ${controls} [aw=tweights] ${if} & director_gob_law_v2==0, abs(${fes}) vce(robust) keepsing

summ tot_ppm if e(sample)==1, d
gl mean_y3=round(r(mean), .01)

*-------------------------------------------------------------------------------
* Table and coefplot
*-------------------------------------------------------------------------------
*Exporting results 
esttab r1 r2 r3 using "${tables}/rdd_placebo_lluvia.tex", keep(mayorallied) ///
se nocons star(* 0.10 ** 0.05 *** 0.01) ///
label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
prehead(`"\begin{tabular}{@{}l*{3}{c}}"' ///
            `"\hline \toprule"'                     ///
            `" & \multicolumn{3}{c}{Precipitation (mm)} \\ \cmidrule(l){2-4}"'                   ///
            `" & All & Governor is head & Governor not head \\"' ///
            `" & (1) & (2) & (3) \\"'                       ///
            `" \toprule"')  ///
    postfoot(`" Dependent mean & ${mean_y1} & ${mean_y2} & ${mean_y3} \\"' ///
	`" & & &  \\"' ///
	`" Bandwidth & ${ht} & ${ht} & ${ht} \\"' ///
	`"\bottomrule \end{tabular}"') 
	
	
	
*END
