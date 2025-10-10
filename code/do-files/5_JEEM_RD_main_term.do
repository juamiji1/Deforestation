
*use "${data}/Interim\defo_caralc.dta", clear 
use "${data}\defo_caralc.dta", clear

*-------------------------------------------------------------------------------
* Labels
*
*-------------------------------------------------------------------------------


/*Defo por political cycle*/
br coddane year  mayorallied z_sh_votes_alc
cap drop political_period
gen political_period=1 if year>=2001 & year<=2003
replace political_period=2 if year>=2004 & year<=2007
replace political_period=3 if year>=2008 & year<=2011
replace political_period=4 if year>=2012 & year<=2015
replace political_period=5 if year>=2016 & year<=2019
*No se tiene en cuenta 2020 porque solo se cuenta con un año
*bys coddane political_period: egen floss_prim_ideam_area_v2_pp=total(floss_prim_ideam_area_v2)

*collapse (sum) floss_prim_ideam_area_v2   (mean) mayorallied (mean) director_gob_law (mean) z_sh_votes_alc codigo_partido_alc ,by(coddane political_period)

*Se saca el total pero el comando aut pone cero cuando son missing, entonces se remplaza 
bys coddane political_period: egen floss_prim_ideam_area_v2_pp=total(floss_prim_ideam_area_v2)
replace floss_prim_ideam_area_v2_pp=. if floss_prim_ideam_area_v2==.
*preserve 
*collapse floss_prim_ideam_area_v2 floss_prim_ideam_area_v2_pp  mayorallied director_gob_law ,by(coddane political_period)
collapse floss_prim_ideam_area_v2 (mean) floss_prim_ideam_area_v2_pp   (mean) mayorallied (mean) director_gob_law (mean) z_sh_votes_alc codigo_partido_alc ,by(coddane political_period)
br 
drop if political_period==.
drop floss_prim_ideam_area_v2
rename floss_prim_ideam_area_v2_pp floss_prim_ideam_area_v2
rename political_period  year 

summ z_sh_votes_alc, d
*-------------------------------------------------------------------------------
{/*1.  Main Results-electoral term*/
*
*-------------------------------------------------------------------------------
*RD -Extract the bandwith
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
eststo r1: reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law!=., abs(year) vce(robust)

summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_y1=round(r(mean), .01)

*Municipalities under a CAR in which Gobernor is mandated as director 
eststo r2: reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law==1, abs(year) vce(robust)

summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_y2=round(r(mean), .01)

*Municipalities under a CAR in which Gobernor is NOT mandated as director 
eststo r3: reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law==0, abs(year) vce(robust)

summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_y3=round(r(mean), .01)

*-------------------------------------------------------------------------------
* Table and coefplot
*-------------------------------------------------------------------------------
*Exporting results 
esttab r1 r2 r3 using "${localpath}\Tables\rdd_main_results_term.tex", keep(mayorallied) ///
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

gr export "${localpath}\Graps\rdd_main_results_term.pdf", as(pdf) replace

}

{/*2.  Main Results-electoral term. Bandwidth RD main: 0.065*/

*
*-------------------------------------------------------------------------------
*RD -Extract the bandwith
rdrobust floss_prim_ideam_area_v2 z_sh_votes_alc, all kernel(triangular)
*gl h = e(h_l)
gl h = 0.065
gl ht= round(${h}, .001)
gl p = e(p)
gl k = e(kernel)
gl if "if abs(z_sh_votes_alc)<=${h}"
gl controls "mayorallied i.mayorallied#c.z_sh_votes_alc z_sh_votes_alc"

cap drop tweights

gen tweights=(1-abs(z_sh_votes_alc/${h})) ${if}
eststo clear

*All municipalities 
eststo r1: reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law!=., abs(year) vce(robust)

summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_y1=round(r(mean), .01)

*Municipalities under a CAR in which Gobernor is mandated as director 
eststo r2: reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law==1, abs(year) vce(robust)

summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_y2=round(r(mean), .01)

*Municipalities under a CAR in which Gobernor is NOT mandated as director 
eststo r3: reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law==0, abs(year) vce(robust)

summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_y3=round(r(mean), .01)

*-------------------------------------------------------------------------------
* Table and coefplot
*-------------------------------------------------------------------------------
*Exporting results 
esttab r1 r2 r3 using "${localpath}\Tables\rdd_main_results_term_bh.tex", keep(mayorallied) ///
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

gr export "${localpath}\Graps\rdd_main_results_term_bh.pdf", as(pdf) replace

}

{/*3.  Local Assumption-incumbent */
*i estar alineado aumenta la probabilidad de que en las siguientes elecciones el partido gane (creo que si sería en el municipio)
*Y= Wint+1
xtset  coddane year 
bys coddane:  gen codigo_partido_alc_lead=F.codigo_partido_alc
format %15.0g codigo_partido_alc_lead
gen incumbent_party_lead=1 if codigo_partido_alc==codigo_partido_alc_lead
replace incumbent_party_lead=0 if incumbent_party_lead==.

*Drop last period because it does not have +1
drop if codigo_partido_alc_lead==.

*RD -Extract the bandwith
rdrobust incumbent_party_lead z_sh_votes_alc, all kernel(triangular)
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
eststo r1: reghdfe  incumbent_party_lead ${controls} [aw=tweights] ${if} & director_gob_law!=., abs(year) vce(robust)

summ incumbent_party_lead if e(sample)==1, d
gl mean_y1=round(r(mean), .01)

*Municipalities under a CAR in which Gobernor is mandated as director 
eststo r2: reghdfe incumbent_party_lead ${controls} [aw=tweights] ${if} & director_gob_law==1, abs(year) vce(robust)

summ incumbent_party_lead if e(sample)==1, d
gl mean_y2=round(r(mean), .01)

*Municipalities under a CAR in which Gobernor is NOT mandated as director 
eststo r3: reghdfe incumbent_party_lead  ${controls} [aw=tweights] ${if} & director_gob_law==0, abs(year) vce(robust)

summ incumbent_party_lead if e(sample)==1, d
gl mean_y3=round(r(mean), .01)

*-------------------------------------------------------------------------------
* Table and coefplot
*-------------------------------------------------------------------------------
*Exporting results 
esttab r1 r2 r3 using "${localpath}\Tables\rdd_incumbency_term.tex", keep(mayorallied) ///
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
coeflabels(mayorallied = " ") ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(cols(3)) xtitle("Incumbency from the same party in the next period", size(medsmall)) ytitle("Partisan Alignment Between Mayor and Governor", size(medsmall)) ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2)


gr export "${localpath}\Graps\rdplot_incumbency_term.pdf", as(pdf) replace
 

}

{/*4.  Local Assumption-incumbent. Bandwidth RD main: 0.065**/
*i estar alineado aumenta la probabilidad de que en las siguientes elecciones el partido gane (creo que si sería en el municipio)
*Y= Wint+1
*La media se calcula sobre la sample cada unas de las regresiones con el bandwith fijo

*RD -Extract the bandwith
rdrobust incumbent_party_lead z_sh_votes_alc, all kernel(triangular)
gl h = 0.065
*gl ht= round(${h}, .001)
*gl p = e(p)
*gl k = e(kernel)
/*Da igual sin guardar "p, k"*/
gl if "if abs(z_sh_votes_alc)<=${h}"
gl controls "mayorallied i.mayorallied#c.z_sh_votes_alc z_sh_votes_alc"

cap drop tweights

gen tweights=(1-abs(z_sh_votes_alc/${h})) ${if}
eststo clear

*All municipalities 
eststo r1: reghdfe  incumbent_party_lead ${controls} [aw=tweights] ${if} & director_gob_law!=., abs(year) vce(robust)

summ incumbent_party_lead if e(sample)==1, d
gl mean_y1=round(r(mean), .01)

*Municipalities under a CAR in which Gobernor is mandated as director 
eststo r2: reghdfe incumbent_party_lead ${controls} [aw=tweights] ${if} & director_gob_law==1, abs(year) vce(robust)

summ incumbent_party_lead if e(sample)==1, d
gl mean_y2=round(r(mean), .01)

*Municipalities under a CAR in which Gobernor is NOT mandated as director 
eststo r3: reghdfe incumbent_party_lead  ${controls} [aw=tweights] ${if} & director_gob_law==0, abs(year) vce(robust)

summ incumbent_party_lead if e(sample)==1, d
gl mean_y3=round(r(mean), .01)

*-------------------------------------------------------------------------------
* Table and coefplot
*-------------------------------------------------------------------------------
*Exporting results 
esttab r1 r2 r3 using "${localpath}\Tables\rdd_incumbency_term_bh.tex", keep(mayorallied) ///
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
coeflabels(mayorallied = " ") ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(cols(3)) xtitle("Incumbency from the same party in the next period", size(medsmall)) ytitle("Partisan Alignment Between Mayor and Governor", size(medsmall)) ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2)

gr export "${localpath}\Graps\rdplot_incumbency_term_bh.pdf", as(pdf) replace

 

}