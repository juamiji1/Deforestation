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
gl if "if abs(z_sh_votes_alc)<=${h} & year>=2010"

cap drop tweights
gen tweights=(1-abs(z_sh_votes_alc/${h})) ${if}

eststo clear

*All municipalities 
eststo r1: reghdfe sh_crime_forest ${controls} [aw=tweights] ${if} & director_gob_law_v2!=., abs(${fes}) vce(robust)
eststo r2: reghdfe sh_crime_forest ${controls} [aw=tweights] ${if} & director_gob_law_v2==1, abs(${fes}) vce(robust)
eststo r3: reghdfe sh_crime_forest ${controls} [aw=tweights] ${if} & director_gob_law_v2==0, abs(${fes}) vce(robust)

coefplot (r1, label(All)) (r2, label(Governor is head)) (r3, label(Governor not head)), keep(mayorallied) ///
coeflabels(mayorallied = " ") ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(cols(3)) xtitle("Forest Related Crimes (%)", size(medsmall)) ytitle("Partisan Alignment Between Mayor and Governor", size(medsmall)) ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2)

gr export "${plots}\rdplot_forestcrimes.pdf", as(pdf) replace 




*END