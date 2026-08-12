use "${data}/Interim\defo_caralc.dta", clear 


*-------------------------------------------------------------------------------
* Preparing data at electoral term level 
*
*-------------------------------------------------------------------------------
*Defo por political cycle
cap drop political_period
gen political_period=1 if year>=2001 & year<=2003
replace political_period=2 if year>=2004 & year<=2007
replace political_period=3 if year>=2008 & year<=2011
replace political_period=4 if year>=2012 & year<=2015
replace political_period=5 if year>=2016 & year<=2019

*Se saca el total pero el comando aut pone cero cuando son missing, entonces se remplaza 
bys coddane political_period: egen floss_prim_ideam_area_v2_pp=total(floss_prim_ideam_area_v2)
replace floss_prim_ideam_area_v2_pp=. if floss_prim_ideam_area_v2==.

sort coddane political_period year

collapse (mean) floss_prim_ideam_area_v2_pp mayorallied director_gob_law_v2 codigo_partido_alc region (first) z_sh_votes_alc, by(coddane political_period)

drop if political_period==.
rename (political_period floss_prim_ideam_area_v2_pp) (year floss_prim_ideam_area_v2)


*-------------------------------------------------------------------------------
* Main Results electoral term on Forest Loss
*
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
* With optimal BW
*-------------------------------------------------------------------------------
gl controls "mayorallied i.mayorallied#c.z_sh_votes_alc z_sh_votes_alc"
gl fes "region year"

*RD -Extract the bandwith
rdrobust floss_prim_ideam_area_v2 z_sh_votes_alc, all kernel(triangular) covs(${fes})
gl h = e(h_l)
gl ht= round(${h}, .001)
gl if "if abs(z_sh_votes_alc)<=${h}"

cap drop tweights

gen tweights=(1-abs(z_sh_votes_alc/${h})) ${if}
eststo clear

*All municipalities 
eststo r1: reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2!=., abs(${fes}) vce(robust)

summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_y1=round(r(mean), .01)

*Municipalities under a CAR in which Gobernor is mandated as director 
eststo r2: reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==1, abs(${fes}) vce(robust)

summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_y2=round(r(mean), .01)

*Municipalities under a CAR in which Gobernor is NOT mandated as director 
eststo r3: reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==0, abs(${fes}) vce(robust)

summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_y3=round(r(mean), .01)

*-------------------------------------------------------------------------------
* Table and coefplot
*-------------------------------------------------------------------------------
*Exporting results 
esttab r1 r2 r3 using "${tables}/rdd_main_results_term.tex", keep(mayorallied) ///
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

gr export "${plots}\rdd_main_results_term.pdf", as(pdf) replace

*-------------------------------------------------------------------------------
* With BW=0.1
*-------------------------------------------------------------------------------
*RD -Extract the bandwith
gl h = 0.098
gl if "if abs(z_sh_votes_alc)<=${h}"

cap drop tweights
gen tweights=(1-abs(z_sh_votes_alc/${h})) ${if}

eststo clear

*All municipalities 
eststo r1: reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2!=., abs(${fes}) vce(robust)

summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_y1=round(r(mean), .01)

*Municipalities under a CAR in which Gobernor is mandated as director 
eststo r2: reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==1, abs(${fes}) vce(robust)

summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_y2=round(r(mean), .01)

*Municipalities under a CAR in which Gobernor is NOT mandated as director 
eststo r3: reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==0, abs(${fes}) vce(robust)

summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_y3=round(r(mean), .01)

*-------------------------------------------------------------------------------
* Table and coefplot
*-------------------------------------------------------------------------------
*Exporting results 
esttab r1 r2 r3 using "${tables}/rdd_main_results_term_bh.tex", keep(mayorallied) ///
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
coeflabels(mayorallied = " ") ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(cols(3)) xtitle("Primary Forest Loss (%)", size(medsmall)) ytitle("Partisan Alignment Between Mayor and Governor", size(medsmall)) ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2)

gr export "${plots}\rdd_main_results_term_bh.pdf", as(pdf) replace


*-------------------------------------------------------------------------------
* Main Results electoral term on Incumbency
*
*-------------------------------------------------------------------------------
xtset  coddane year 
bys coddane:  gen codigo_partido_alc_lead=F.codigo_partido_alc
format %15.0g codigo_partido_alc_lead
gen incumbent_party_lead=1 if codigo_partido_alc==codigo_partido_alc_lead
replace incumbent_party_lead=0 if incumbent_party_lead==.

*Drop last period because it does not have +1
drop if codigo_partido_alc_lead==.

*-------------------------------------------------------------------------------
* With optimal BW
*-------------------------------------------------------------------------------
*RD -Extract the bandwith
rdrobust incumbent_party_lead z_sh_votes_alc, all kernel(triangular) covs(${fes})
gl h = e(h_l)
gl if "if abs(z_sh_votes_alc)<=${h}"

cap drop tweights
gen tweights=1-(abs(z_sh_votes_alc/${h})) ${if}

eststo clear

*All municipalities 
eststo r1: reghdfe  incumbent_party_lead ${controls} [aw=tweights] ${if} & director_gob_law_v2!=., abs(${fes}) vce(robust)

*Municipalities under a CAR in which Gobernor is mandated as director 
eststo r2: reghdfe incumbent_party_lead ${controls} [aw=tweights] ${if} & director_gob_law_v2==1, abs(${fes}) vce(robust)

*Municipalities under a CAR in which Gobernor is NOT mandated as director 
eststo r3: reghdfe incumbent_party_lead  ${controls} [aw=tweights] ${if} & director_gob_law_v2==0, abs(${fes}) vce(robust)

*Plot
coefplot (r1, label(All)) (r2, label(Governor is head)) (r3, label(Governor not head)), keep(mayorallied) ///
coeflabels(mayorallied = " ") ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(cols(3)) xtitle("Incumbency from the same party in the next period", size(medsmall)) ytitle("Partisan Alignment Between Mayor and Governor", size(medsmall)) ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2)

gr export "${plots}\rdplot_incumbency_term.pdf", as(pdf) replace

*-------------------------------------------------------------------------------
* With optimal BW
*------------------------------------------------------------------------------- 
gl h = .098
gl if "if abs(z_sh_votes_alc)<=${h}"

cap drop tweights
gen tweights=(1-abs(z_sh_votes_alc/${h})) ${if}

eststo clear

*All municipalities 
eststo r1: reghdfe  incumbent_party_lead ${controls} [aw=tweights] ${if} & director_gob_law_v2!=., abs(${fes}) vce(robust)

*Municipalities under a CAR in which Gobernor is mandated as director 
eststo r2: reghdfe incumbent_party_lead ${controls} [aw=tweights] ${if} & director_gob_law_v2==1, abs(${fes}) vce(robust)

*Municipalities under a CAR in which Gobernor is NOT mandated as director 
eststo r3: reghdfe incumbent_party_lead  ${controls} [aw=tweights] ${if} & director_gob_law_v2==0, abs(${fes}) vce(robust)

*Plot
coefplot (r1, label(All)) (r2, label(Governor is head)) (r3, label(Governor not head)), keep(mayorallied) ///
coeflabels(mayorallied = " ") ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(cols(3)) xtitle("Incumbency from the same party in the next period", size(medsmall)) ytitle("Partisan Alignment Between Mayor and Governor", size(medsmall)) ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2)

gr export "${plots}\rdplot_incumbency_term_bh.pdf", as(pdf) replace



*END