use "${data}/Interim\defo_caralc.dta", clear 


*-------------------------------------------------------------------------------
* Labels
*
*-------------------------------------------------------------------------------
*replace floss_prim_ideam_area_v2 = floss_prim_ideam_area_v2*100
gen election_year=1 if year==2000 | year==2003 | year==2007 | year==2011 | year==2015 | year==2019
replace election_year=0 if election_year==.

la var floss_prim_ideam_area_v2 "Primary Forest Loss"
la var mayorallied "Partisan Alignment"


*-------------------------------------------------------------------------------
* Mechanisms Results
*
*-------------------------------------------------------------------------------
gl controls "mayorallied i.mayorallied#c.z_sh_votes_alc z_sh_votes_alc"
gl fes "region year"

rdrobust floss_prim_ideam_area_v2 z_sh_votes_alc, all kernel(triangular) covs(${fes})
gl h = e(h_l)
gl ht= round(${h}, .001)
gl if "if abs(z_sh_votes_alc)<=${h}"

cap drop tweights
gen tweights=(1-abs(z_sh_votes_alc/${h})) ${if}

*All municipalities 
eststo r1: reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2!=., abs(${fes}) vce(robust)

summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_y1=round(r(mean), .01)

*Municipalities under a non-green governor 
eststo r4: reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==1 & green_party_v2_gov==0, abs(${fes}) vce(robust)

summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_y4=round(r(mean), .01)

*Municipalities under a green governor 
eststo r5: reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==1 & green_party_v2_gov==1, abs(${fes}) vce(robust)

summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_y5=round(r(mean), .01)

*Municipalities under governor as director in an election year
eststo r6: reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==1 & election_year==1, abs(${fes}) vce(robust)

summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_y6=round(r(mean), .01)

*Municipalities under other director in an election year
eststo r7: reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==0 & election_year==1, abs(${fes}) vce(robust)

summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_y7=round(r(mean), .01)

*Municipalities under a CAR with gov head by politicians minority vs moajority
eststo r8: reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & dmdn_politics2==1 & director_gob_law_v2==1, abs(${fes}) vce(robust)

summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_y8=round(r(mean), .01)

eststo r9: reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & dmdn_politics2==0 & director_gob_law_v2==1, abs(${fes}) vce(robust)

summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_y9=round(r(mean), .01)

*Municipalities under a CAR with gov head by politicians minority vs moajority
eststo r10: reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & dmdn_politics2==1 & director_gob_law_v2==0, abs(${fes}) vce(robust)

summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_y10=round(r(mean), .01)

eststo r11: reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & dmdn_politics2==0 & director_gob_law_v2==0, abs(${fes}) vce(robust)

summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_y11=round(r(mean), .01)

*-------------------------------------------------------------------------------
* Table and coefplot
*-------------------------------------------------------------------------------
*Exporting results 
esttab r4 r5 r6 r7 using "${tables}/rdd_mechs_results_p1.tex", keep(mayorallied) ///
se nocons star(* 0.10 ** 0.05 *** 0.01) ///
label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
prehead(`"\begin{tabular}{@{}l*{4}{c}}"' ///
            `"\hline \toprule"'                     ///
            `" & \multicolumn{4}{c}{Primary Forest Loss (\%)} \\ \cmidrule(l){2-5}"'                   ///
            `" & Governor is head + & Governor is head + & Governor is head + & Governor not head + \\"' ///
            `" & No green party & Green party & Election year & Election year \\"' ///
            `" & (1) & (2) & (3) & (4) \\"'                       ///
            `" \toprule"')  ///
    postfoot(`" Dependent mean & ${mean_y4} & ${mean_y5} & ${mean_y6} & ${mean_y7} \\"' ///
	`" & & & & \\"' ///
	`" Bandwidth & ${ht} & ${ht} & ${ht} & ${ht} \\"' ///
	`"\bottomrule \end{tabular}"') 

coefplot (r4, label("Governor is head + No green party")) ///
(r5, label("Governor is head + Green party")) (r6, label("Governor is head + Election year")) ///
(r7, label("Governor not head + Election year")), keep(mayorallied) ///
coeflabels(mayorallied = " ") ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(cols(2) size(small)) ///
xtitle("Primary Forest Loss (%)", size(medium)) ytitle("Partisan Alignment Between Mayor and Governor", size(medsmall)) ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2)

gr export "${plots}\rdplot_mechs_results_p1.pdf", as(pdf) replace 

*Exporting results 
esttab r8 r9 r10 r11 using "${tables}/rdd_mechs_results_p2.tex", keep(mayorallied) ///
se nocons star(* 0.10 ** 0.05 *** 0.01) ///
label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
prehead(`"\begin{tabular}{@{}l*{4}{c}}"' ///
            `"\hline \toprule"'                     ///
            `" & \multicolumn{4}{c}{Primary Forest Loss (\%)} \\ \cmidrule(l){2-5}"'                   ///
            `" & Governor is head + & Governor is head + & Governor not head + & Governor not head + \\"' ///
            `" & Pols Majority & Pols Minority & Pols Majority & Pols Minority \\"' ///
            `" & (1) & (2) & (3) & (4) \\"'                       ///
            `" \toprule"')  ///
    postfoot(`" Dependent mean & ${mean_y8} & ${mean_y9} & ${mean_y10} & ${mean_y11} \\"' ///
	`" & & & & \\"' ///
	`" Bandwidth & ${ht} & ${ht} & ${ht} & ${ht} \\"' ///
	`"\bottomrule \end{tabular}"') 

coefplot (r8, label("Gov head + Pols Majority")) ///
(r9, label("Gov head + Pols Minority")) (r10, label("Gov not head + Pols Majority")) ///
(r11, label("Gov not head + Pols Minority")), keep(mayorallied) ///
coeflabels(mayorallied = " ") ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(cols(2) size(small)) ///
xtitle("Primary Forest Loss (%)", size(medium)) ytitle("Partisan Alignment Between Mayor and Governor", size(medsmall)) ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2)

gr export "${plots}\rdplot_mechs_results_p2.pdf", as(pdf) replace 

*-------------------------------------------------------------------------------
* Illegal Deforestation
*-------------------------------------------------------------------------------
*All municipalities 
eststo r1: reghdfe floss_prim_ilegal_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2!=., abs(${fes}) vce(robust)

*Municipalities under a non-green governor 
eststo r4: reghdfe floss_prim_ilegal_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==1 & green_party_v2_gov==0, abs(${fes}) vce(robust)

*Municipalities under a green governor 
eststo r5: reghdfe floss_prim_ilegal_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==1 & green_party_v2_gov==1, abs(${fes}) vce(robust)

*Municipalities under governor as director in an election year
eststo r6: reghdfe floss_prim_ilegal_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==1 & election_year==1, abs(${fes}) vce(robust)

*Municipalities under other director in an election year
eststo r7: reghdfe floss_prim_ilegal_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==0 & election_year==1, abs(${fes}) vce(robust)

*Municipalities under a CAR with gov head by politicians minority vs moajority
eststo r8: reghdfe floss_prim_ilegal_area_v2 ${controls} [aw=tweights] ${if} & dmdn_politics2==1 & director_gob_law_v2==1, abs(${fes}) vce(robust)
eststo r9: reghdfe floss_prim_ilegal_area_v2 ${controls} [aw=tweights] ${if} & dmdn_politics2==0 & director_gob_law_v2==1, abs(${fes}) vce(robust)

*Municipalities under a CAR with gov head by politicians minority vs moajority
eststo r10: reghdfe floss_prim_ilegal_area_v2 ${controls} [aw=tweights] ${if} & dmdn_politics2==1 & director_gob_law_v2==0, abs(${fes}) vce(robust)
eststo r11: reghdfe floss_prim_ilegal_area_v2 ${controls} [aw=tweights] ${if} & dmdn_politics2==0 & director_gob_law_v2==0, abs(${fes}) vce(robust)

coefplot (r4, label("Governor is head + No green party")) ///
(r5, label("Governor is head + Green party")) (r6, label("Governor is head + Election year")) ///
(r7, label("Governor not head + Election year")), keep(mayorallied) ///
coeflabels(mayorallied = " ") ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(cols(2) size(small)) ///
xtitle("Illegal Primary Forest Loss (%)", size(medium)) ytitle("Partisan Alignment Between Mayor and Governor", size(medsmall)) ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2)

gr export "${plots}\rdplot_mechs_results_illegal_p1.pdf", as(pdf) replace 

coefplot (r8, label("Gov head + Pols Majority")) ///
(r9, label("Gov head + Pols Minority")) (r10, label("Gov not head + Pols Majority")) ///
(r11, label("Gov not head + Pols Minority")), keep(mayorallied) ///
coeflabels(mayorallied = " ") ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(cols(2) size(small)) ///
xtitle("Illegal Primary Forest Loss (%)", size(medium)) ytitle("Partisan Alignment Between Mayor and Governor", size(medsmall)) ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2)

gr export "${plots}\rdplot_mechs_results_illegal_p2.pdf", as(pdf) replace 

*For presentation
coefplot (r8, label("Gov head + Pols Majority")) ///
(r9, label("Gov head + Pols Minority")), keep(mayorallied) ///
coeflabels(mayorallied = " ") ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(cols(2) size(medsmall)) ///
xtitle("Illegal Primary Forest Loss (%)", size(medium)) ytitle("Partisan Alignment Between Mayor and Governor", size(medsmall)) ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2)

gr export "${plots}\rdplot_mechs_results_illegal_dpols.pdf", as(pdf) replace 


*-------------------------------------------------------------------------------
* Legal Deforestation
*-------------------------------------------------------------------------------
*All municipalities 
eststo r1: reghdfe floss_prim_legal_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2!=., abs(${fes}) vce(robust)

*Municipalities under a non-green governor 
eststo r4: reghdfe floss_prim_legal_area_v2  ${controls} [aw=tweights] ${if} & director_gob_law_v2==1 & green_party_v2_gov==0, abs(${fes}) vce(robust)

*Municipalities under a green governor 
eststo r5: reghdfe floss_prim_legal_area_v2  ${controls} [aw=tweights] ${if} & director_gob_law_v2==1 & green_party_v2_gov==1, abs(${fes}) vce(robust)

*Municipalities under governor as director in an election year
eststo r6: reghdfe floss_prim_legal_area_v2  ${controls} [aw=tweights] ${if} & director_gob_law_v2==1 & election_year==1, abs(${fes}) vce(robust)

*Municipalities under other director in an election year
eststo r7: reghdfe floss_prim_legal_area_v2  ${controls} [aw=tweights] ${if} & director_gob_law_v2==0 & election_year==1, abs(${fes}) vce(robust)

*Municipalities under a CAR with gov head by politicians minority vs moajority
eststo r8: reghdfe floss_prim_legal_area_v2  ${controls} [aw=tweights] ${if} & dmdn_politics2==1 & director_gob_law_v2==1, abs(${fes}) vce(robust)
eststo r9: reghdfe floss_prim_legal_area_v2  ${controls} [aw=tweights] ${if} & dmdn_politics2==0 & director_gob_law_v2==1, abs(${fes}) vce(robust)

*Municipalities under a CAR with gov head by politicians minority vs moajority
eststo r10: reghdfe floss_prim_legal_area_v2  ${controls} [aw=tweights] ${if} & dmdn_politics2==1 & director_gob_law_v2==0, abs(${fes}) vce(robust)
eststo r11: reghdfe floss_prim_legal_area_v2  ${controls} [aw=tweights] ${if} & dmdn_politics2==0 & director_gob_law_v2==0, abs(${fes}) vce(robust)

coefplot (r4, label("Governor is head + No green party")) ///
(r5, label("Governor is head + Green party")) (r6, label("Governor is head + Election year")) ///
(r7, label("Governor not head + Election year")), keep(mayorallied) ///
coeflabels(mayorallied = " ") ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(cols(2) size(small)) ///
xtitle("Legal Primary Forest Loss (%)", size(medium)) ytitle("Partisan Alignment Between Mayor and Governor", size(medsmall)) ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2)

gr export "${plots}\rdplot_mechs_results_legal_p1.pdf", as(pdf) replace 

coefplot (r8, label("Gov head + Pols Majority")) ///
(r9, label("Gov head + Pols Minority")) (r10, label("Gov not head + Pols Majority")) ///
(r11, label("Gov not head + Pols Minority")), keep(mayorallied) ///
coeflabels(mayorallied = " ") ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(cols(2) size(small)) ///
xtitle("Legal Primary Forest Loss (%)", size(medium)) ytitle("Partisan Alignment Between Mayor and Governor", size(medsmall)) ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2)

gr export "${plots}\rdplot_mechs_results_legal_p2.pdf", as(pdf) replace 

*For presentation
coefplot (r8, label("Gov head + Pols Majority")) ///
(r9, label("Gov head + Pols Minority")), keep(mayorallied) ///
coeflabels(mayorallied = " ") ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(cols(2) size(medsmall)) ///
xtitle("Legal Primary Forest Loss (%)", size(medium)) ytitle("Partisan Alignment Between Mayor and Governor", size(medsmall)) ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2)

gr export "${plots}\rdplot_mechs_results_legal_dpols.pdf", as(pdf) replace 




*MODEL TESTING
reghdfe floss_prim_ideam_area_v2 i1.mayorallied#i1.dmdn_politics2 dmdn_politics2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==1, abs(${fes}) vce(robust)

reghdfe floss_prim_ilegal_area_v2 i1.mayorallied#i1.dmdn_politics2 dmdn_politics2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==1, abs(${fes}) vce(robust)

reghdfe floss_prim_legal_area_v2 i1.mayorallied#i1.dmdn_politics2 dmdn_politics2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==1, abs(${fes}) vce(robust)


*To test for crowding out in levels we have to look at deforestation at the REPA lvl not municipality!!!
reghdfe floss_prim_ideam_area_v2 dmdn_politics2, abs(${fes}) vce(robust)

reghdfe floss_prim_ilegal_area_v2 dmdn_politics2 if director_gob_law_v2==0, abs(${fes}) vce(robust)
reghdfe floss_prim_legal_area_v2 dmdn_politics2 if director_gob_law_v2==0, abs(${fes}) vce(robust)

reghdfe floss_prim_ilegal_area_v2 dmdn_politics2 if director_gob_law_v2==1, abs(${fes}) vce(robust)
reghdfe floss_prim_legal_area_v2 dmdn_politics2 if director_gob_law_v2==1, abs(${fes}) vce(robust)


*END