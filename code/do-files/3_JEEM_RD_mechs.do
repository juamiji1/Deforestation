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
* Mechanisms Results on all deforestation
*
*-------------------------------------------------------------------------------
gl controls "mayorallied i.mayorallied#c.z_sh_votes_alc z_sh_votes_alc"
gl fes "region year"

rdrobust floss_prim_ideam_area_v2 z_sh_votes_alc, all kernel(triangular) covs(${fes})
gl h = e(h_l)
gl ht= round(${h}, .001)
gl if "if abs(z_sh_votes_alc)<=${h} & floss_prim_ideam_area_v2!=. & floss_prim_legal_area_v2!=. & floss_prim_ilegal_area_v2!=."

cap drop tweights
gen tweights=(1-abs(z_sh_votes_alc/${h})) ${if}

eststo clear

*-------------------------------------------------------------------------------
* All
*-------------------------------------------------------------------------------
*Municipalities under a green vs non-green governor 
eststo x1: reghdfe floss_prim_ideam_area_v2 ${controls} dmdn_politics2 [aw=tweights] ${if} & green_party_v2_gov==1, abs(${fes}) vce(robust) keepsing
summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_x1 = round(r(mean), .01)

eststo x2: reghdfe floss_prim_ideam_area_v2 ${controls} dmdn_politics2 [aw=tweights] ${if} & green_party_v2_gov==0, abs(${fes}) vce(robust) keepsing
summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_x2 = round(r(mean), .01)

*Municipalities under governor as director in an election year
eststo x3: reghdfe floss_prim_ideam_area_v2 ${controls} green_party_v2_gov [aw=tweights] ${if} & dmdn_politics2==1, abs(${fes}) vce(robust) keepsing
summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_x3 = round(r(mean), .01)

eststo x4: reghdfe floss_prim_ideam_area_v2 ${controls} green_party_v2_gov [aw=tweights] ${if} & dmdn_politics2==0, abs(${fes}) vce(robust) keepsing
summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_x4 = round(r(mean), .01)

*Election year split
eststo x5: reghdfe floss_prim_ideam_area_v2 ${controls} dmdn_politics2 green_party_v2_gov [aw=tweights] ${if} & election_year==1, abs(${fes}) vce(robust) keepsing
summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_x5 = round(r(mean), .01)

eststo x6: reghdfe floss_prim_ideam_area_v2 ${controls} dmdn_politics2 green_party_v2_gov [aw=tweights] ${if} & election_year==0, abs(${fes}) vce(robust) keepsing
summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_x6 = round(r(mean), .01)

* Table
esttab x1 x2 x3 x4 x5 x6 using "${tables}/rdd_mechs_results_alldefo_combined.tex", keep(mayorallied) ///
se nocons star(* 0.10 ** 0.05 *** 0.01) ///
label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
prehead(`"\begin{tabular}{@{}l*{6}{c}}"' ///
            `"\hline \toprule"'                     ///
            `"\multicolumn{7}{l}{\textit{Panel A: All municipalities}} \\ \midrule"' ///			
            `" & \multicolumn{6}{c}{Primary Forest Loss (\%)} \\ \cmidrule(l){2-7}"' ///
            `" & Green & Non-green & Politicians & Politicians & Election & Non-election \\"' ///
            `" & governor & governor & majority & minority & year & year\\"' ///
            `" & (1) & (2) & (3) & (4) & (5) & (6) \\"' ///
            `" \midrule"')  ///
postfoot(`" Dependent mean & ${mean_x1} & ${mean_x2} & ${mean_x3} & ${mean_x4} & ${mean_x5} & ${mean_x6} \\"' ///
         `" Bandwidth & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} \\"' ///
         `"\bottomrule \end{tabular}"')
		 
*-------------------------------------------------------------------------------
* Governor is board head
*-------------------------------------------------------------------------------
*Municipalities under a green vs non-green governor 
eststo r1: reghdfe floss_prim_ideam_area_v2 ${controls} dmdn_politics2 [aw=tweights] ${if} & director_gob_law_v2==1 & green_party_v2_gov==1, abs(${fes}) vce(robust) keepsing
summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_r1 = round(r(mean), .01)

eststo r2: reghdfe floss_prim_ideam_area_v2 ${controls} dmdn_politics2 [aw=tweights] ${if} & director_gob_law_v2==1 & green_party_v2_gov==0, abs(${fes}) vce(robust) keepsing
summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_r2 = round(r(mean), .01)

*Municipalities under governor as director in an election year
eststo r3: reghdfe floss_prim_ideam_area_v2 ${controls} green_party_v2_gov [aw=tweights] ${if} & director_gob_law_v2==1 & dmdn_politics2==1, abs(${fes}) vce(robust) keepsing
summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_r3 = round(r(mean), .01)

eststo r4: reghdfe floss_prim_ideam_area_v2 ${controls} green_party_v2_gov [aw=tweights] ${if} & director_gob_law_v2==1 & dmdn_politics2==0, abs(${fes}) vce(robust) keepsing
summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_r4 = round(r(mean), .01)

*Election year split
eststo r5: reghdfe floss_prim_ideam_area_v2 ${controls} dmdn_politics2 green_party_v2_gov [aw=tweights] ${if} & director_gob_law_v2==1 & election_year==1, abs(${fes}) vce(robust) keepsing
summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_r5 = round(r(mean), .01)

eststo r6: reghdfe floss_prim_ideam_area_v2 ${controls} dmdn_politics2 green_party_v2_gov [aw=tweights] ${if} & director_gob_law_v2==1 & election_year==0, abs(${fes}) vce(robust) keepsing
summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_r6 = round(r(mean), .01)

coefplot ///
    (r1, keep(mayorallied) rename(mayorallied = gparty)) ///
    (r2, keep(mayorallied) rename(mayorallied = nogreen) offset(.3)) ///
    (r3, keep(mayorallied) rename(mayorallied = polsmaj)) ///
    (r4, keep(mayorallied) rename(mayorallied = polsmin) offset(.3)) ///
    (r5, keep(mayorallied) rename(mayorallied = elect)) ///
    (r6, keep(mayorallied) rename(mayorallied = nonelect) offset(.3)), ///
    keep(*) ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(off) ///
    order(gparty nogreen polsmaj polsmin elect nonelect) ///
    xtitle("Primary Forest Loss (%)", size(medium)) ///
    ytitle("Partisan Alignment Between Mayor and Governor", size(medium)) ///
	ylabel(1 `""Green" "governor""' 1.7 `""No green" "governor""' 3 `""Politicians" "majority""' 3.7 `""Politicians" "minority""' 5 `""Electoral" "year""' 5.7 `""Non-electoral" "year""', labsize(small)) ///
    mlabel(cond(@pval<=.01, string(@b, "%9.3fc")+"***", ///
           cond(@pval<=.05, string(@b, "%9.3fc")+"**", ///
           cond(@pval<=.1,  string(@b, "%9.3fc")+"*",  ///
           cond(@pval<=.15, string(@b, "%9.3fc")+"†", string(@b, "%9.3fc")))))) ///
    mlabposition(12) mlabgap(*2) 
	
gr export "${plots}\rdplot_mechs_results_alldefo.pdf", as(pdf) replace 

*-------------------------------------------------------------------------------
* Governor is NOT board head
*-------------------------------------------------------------------------------
*Municipalities under a green vs non-green governor 
eststo r7: reghdfe floss_prim_ideam_area_v2 ${controls} dmdn_politics2 [aw=tweights] ${if} & director_gob_law_v2==0 & green_party_v2_gov==1, abs(${fes}) vce(robust) keepsing
summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_r7 = round(r(mean), .01)

eststo r8: reghdfe floss_prim_ideam_area_v2 ${controls} dmdn_politics2 [aw=tweights] ${if} & director_gob_law_v2==0 & green_party_v2_gov==0, abs(${fes}) vce(robust) keepsing
summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_r8 = round(r(mean), .01)

*Election politics split
eststo r9: reghdfe floss_prim_ideam_area_v2 ${controls} green_party_v2_gov [aw=tweights] ${if} & director_gob_law_v2==0 & dmdn_politics2==1, abs(${fes}) vce(robust) keepsing
summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_r9 = round(r(mean), .01)

eststo r10: reghdfe floss_prim_ideam_area_v2 ${controls} green_party_v2_gov [aw=tweights] ${if} & director_gob_law_v2==0 & dmdn_politics2==0, abs(${fes}) vce(robust) keepsing
summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_r10 = round(r(mean), .01)

*Election year split
eststo r11: reghdfe floss_prim_ideam_area_v2 ${controls} dmdn_politics2 green_party_v2_gov [aw=tweights] ${if} & director_gob_law_v2==0 & election_year==1, abs(${fes}) vce(robust) keepsing
summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_r11 = round(r(mean), .01)

eststo r12: reghdfe floss_prim_ideam_area_v2 ${controls} dmdn_politics2 green_party_v2_gov [aw=tweights] ${if} & director_gob_law_v2==0 & election_year==0, abs(${fes}) vce(robust) keepsing
summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_r12 = round(r(mean), .01)

*-------------------------------------------------------------------------------
* Table and coefplot
*-------------------------------------------------------------------------------
* Panel A table
esttab r1 r2 r3 r4 r5 r6 using "${tables}/rdd_mechs_results_alldefo.tex", keep(mayorallied) ///
se nocons star(* 0.10 ** 0.05 *** 0.01) ///
label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
prehead(`"\begin{tabular}{@{}l*{6}{c}}"' ///
            `"\hline \toprule"'                     ///
            `"\multicolumn{7}{l}{\textit{Panel A: Governor is head of REPA}} \\ \midrule"' ///			
            `" & \multicolumn{6}{c}{Primary Forest Loss (\%)} \\ \cmidrule(l){2-7}"' ///
            `" & Green & Non-green & Politicians & Politicians & Election & Non-election \\"' ///
            `" & governor & governor & majority & minority & year & year\\"' ///
            `" & (1) & (2) & (3) & (4) & (5) & (6) \\"' ///
            `" \midrule"')  ///
postfoot(`" Dependent mean & ${mean_r1} & ${mean_r2} & ${mean_r3} & ${mean_r4} & ${mean_r5} & ${mean_r6} \\"' ///
         `"\toprule"' ///
         `"\multicolumn{7}{l}{\textit{Panel B: Governor is not head of REPA}} \\ \midrule"' ///			
         `" & \multicolumn{6}{c}{Primary Forest Loss (\%)} \\ \cmidrule(l){2-7}"' ///
         `" & Green & Non-green & Politicians & Politicians & Election & Non-election \\"' ///
         `" & governor & governor & majority & minority & year & year\\"' ///
         `" & (7) & (8) & (9) & (10) & (11) & (12) \\"' ///
         `" \midrule"')

* Panel B table
esttab r7 r8 r9 r10 r11 r12 using "${tables}/rdd_mechs_results_alldefo.tex", keep(mayorallied) ///
se nocons star(* 0.10 ** 0.05 *** 0.01) ///
label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) append ///
postfoot(`" Dependent mean & ${mean_r7} & ${mean_r8} & ${mean_r9} & ${mean_r10} & ${mean_r11} & ${mean_r12} \\ \midrule"' ///
         `" Bandwidth & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} \\"' ///
         `"\bottomrule \end{tabular}"')


*-------------------------------------------------------------------------------
* Mechanisms Results on illegal deforestation
*
*-------------------------------------------------------------------------------
eststo clear

*-------------------------------------------------------------------------------
* Governor is board head
*-------------------------------------------------------------------------------
*Municipalities under a green vs non-green governor 
eststo r1: reghdfe floss_prim_ilegal_area_v2 ${controls} dmdn_politics2 [aw=tweights] ${if} & director_gob_law_v2==1 & green_party_v2_gov==1, abs(${fes}) vce(robust) keepsing
summ floss_prim_ilegal_area_v2 if e(sample)==1, d
gl mean_r1 = round(r(mean), .01)

eststo r2: reghdfe floss_prim_ilegal_area_v2 ${controls} dmdn_politics2 [aw=tweights] ${if} & director_gob_law_v2==1 & green_party_v2_gov==0, abs(${fes}) vce(robust) keepsing
summ floss_prim_ilegal_area_v2 if e(sample)==1, d
gl mean_r2 = round(r(mean), .01)

*Municipalities under governor as director in an election year
eststo r3: reghdfe floss_prim_ilegal_area_v2 ${controls} green_party_v2_gov [aw=tweights] ${if} & director_gob_law_v2==1 & dmdn_politics2==1, abs(${fes}) vce(robust) keepsing
summ floss_prim_ilegal_area_v2 if e(sample)==1, d
gl mean_r3 = round(r(mean), .01)

eststo r4: reghdfe floss_prim_ilegal_area_v2 ${controls} green_party_v2_gov [aw=tweights] ${if} & director_gob_law_v2==1 & dmdn_politics2==0, abs(${fes}) vce(robust) keepsing
summ floss_prim_ilegal_area_v2 if e(sample)==1, d
gl mean_r4 = round(r(mean), .01)

*Election year split
eststo r5: reghdfe floss_prim_ilegal_area_v2 ${controls} dmdn_politics2 green_party_v2_gov [aw=tweights] ${if} & director_gob_law_v2==1 & election_year==1, abs(${fes}) vce(robust) keepsing
summ floss_prim_ilegal_area_v2 if e(sample)==1, d
gl mean_r5 = round(r(mean), .01)

eststo r6: reghdfe floss_prim_ilegal_area_v2 ${controls} dmdn_politics2 green_party_v2_gov [aw=tweights] ${if} & director_gob_law_v2==1 & election_year==0, abs(${fes}) vce(robust) keepsing
summ floss_prim_ilegal_area_v2 if e(sample)==1, d
gl mean_r6 = round(r(mean), .01)

coefplot ///
    (r1, keep(mayorallied) rename(mayorallied = gparty)) ///
    (r2, keep(mayorallied) rename(mayorallied = nogreen) offset(.3)) ///
    (r3, keep(mayorallied) rename(mayorallied = polsmaj)) ///
    (r4, keep(mayorallied) rename(mayorallied = polsmin) offset(.3)) ///
    (r5, keep(mayorallied) rename(mayorallied = elect)) ///
    (r6, keep(mayorallied) rename(mayorallied = nonelect) offset(.3)), ///
    keep(*) ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(off) ///
    order(gparty nogreen polsmaj polsmin elect nonelect) ///
    xtitle("Illegal Primary Forest Loss (%)", size(medium)) ///
    ytitle("Partisan Alignment Between Mayor and Governor", size(medium)) ///
	ylabel(1 `""Green" "governor""' 1.7 `""No green" "governor""' 3 `""Politicians" "majority""' 3.7 `""Politicians" "minority""' 5 `""Electoral" "year""' 5.7 `""Non-electoral" "year""', labsize(small)) ///
    mlabel(cond(@pval<=.01, string(@b, "%9.3fc")+"***", ///
           cond(@pval<=.05, string(@b, "%9.3fc")+"**", ///
           cond(@pval<=.1,  string(@b, "%9.3fc")+"*",  ///
           cond(@pval<=.15, string(@b, "%9.3fc")+"†", string(@b, "%9.3fc")))))) ///
    mlabposition(12) mlabgap(*2) 
	
gr export "${plots}\rdplot_mechs_results_illdefo.pdf", as(pdf) replace 

*-------------------------------------------------------------------------------
* Governor is NOT board head
*-------------------------------------------------------------------------------
*Municipalities under a green vs non-green governor 
eststo r7: reghdfe floss_prim_ilegal_area_v2 ${controls} dmdn_politics2 [aw=tweights] ${if} & director_gob_law_v2==0 & green_party_v2_gov==1, abs(${fes}) vce(robust) keepsing
summ floss_prim_ilegal_area_v2 if e(sample)==1, d
gl mean_r7 = round(r(mean), .01)

eststo r8: reghdfe floss_prim_ilegal_area_v2 ${controls} dmdn_politics2 [aw=tweights] ${if} & director_gob_law_v2==0 & green_party_v2_gov==0, abs(${fes}) vce(robust) keepsing
summ floss_prim_ilegal_area_v2 if e(sample)==1, d
gl mean_r8 = round(r(mean), .01)

*Election politics split
eststo r9: reghdfe floss_prim_ilegal_area_v2 ${controls} green_party_v2_gov [aw=tweights] ${if} & director_gob_law_v2==0 & dmdn_politics2==1, abs(${fes}) vce(robust) keepsing
summ floss_prim_ilegal_area_v2 if e(sample)==1, d
gl mean_r9 = round(r(mean), .01)

eststo r10: reghdfe floss_prim_ilegal_area_v2 ${controls} green_party_v2_gov [aw=tweights] ${if} & director_gob_law_v2==0 & dmdn_politics2==0, abs(${fes}) vce(robust) keepsing
summ floss_prim_ilegal_area_v2 if e(sample)==1, d
gl mean_r10 = round(r(mean), .01)

*Election year split
eststo r11: reghdfe floss_prim_ilegal_area_v2 ${controls} dmdn_politics2 green_party_v2_gov [aw=tweights] ${if} & director_gob_law_v2==0 & election_year==1, abs(${fes}) vce(robust) keepsing
summ floss_prim_ilegal_area_v2 if e(sample)==1, d
gl mean_r11 = round(r(mean), .01)

eststo r12: reghdfe floss_prim_ilegal_area_v2 ${controls} dmdn_politics2 green_party_v2_gov [aw=tweights] ${if} & director_gob_law_v2==0 & election_year==0, abs(${fes}) vce(robust) keepsing
summ floss_prim_ilegal_area_v2 if e(sample)==1, d
gl mean_r12 = round(r(mean), .01)

*-------------------------------------------------------------------------------
* Table and coefplot
*-------------------------------------------------------------------------------
* Panel A table
esttab r1 r2 r3 r4 r5 r6 using "${tables}/rdd_mechs_results_illdefo.tex", keep(mayorallied) ///
se nocons star(* 0.10 ** 0.05 *** 0.01) ///
label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
prehead(`"\begin{tabular}{@{}l*{6}{c}}"' ///
            `"\hline \toprule"'                     ///
            `"\multicolumn{7}{l}{\textit{Panel A: Governor is head of REPA}} \\ \midrule"' ///			
            `" & \multicolumn{6}{c}{Illegal Forest Loss (\%)} \\ \cmidrule(l){2-7}"' ///
            `" & Green & Non-green & Politicians & Politicians & Election & Non-election \\"' ///
            `" & governor & governor & majority & minority & year & year\\"' ///
            `" & (1) & (2) & (3) & (4) & (5) & (6) \\"' ///
            `" \midrule"')  ///
postfoot(`" Dependent mean & ${mean_r1} & ${mean_r2} & ${mean_r3} & ${mean_r4} & ${mean_r5} & ${mean_r6} \\"' ///
         `"\toprule"' ///
         `"\multicolumn{7}{l}{\textit{Panel B: Governor is not head of REPA}} \\ \midrule"' ///			
         `" & \multicolumn{6}{c}{Illegal Forest Loss (\%)} \\ \cmidrule(l){2-7}"' ///
         `" & Green & Non-green & Politicians & Politicians & Election & Non-election \\"' ///
         `" & governor & governor & majority & minority & year & year\\"' ///
         `" & (7) & (8) & (9) & (10) & (11) & (12) \\"' ///
         `" \midrule"')

* Panel B table
esttab r7 r8 r9 r10 r11 r12 using "${tables}/rdd_mechs_results_illdefo.tex", keep(mayorallied) ///
se nocons star(* 0.10 ** 0.05 *** 0.01) ///
label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) append ///
postfoot(`" Dependent mean & ${mean_r7} & ${mean_r8} & ${mean_r9} & ${mean_r10} & ${mean_r11} & ${mean_r12} \\ \midrule"' ///
         `" Bandwidth & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} \\"' ///
         `"\bottomrule \end{tabular}"')



*-------------------------------------------------------------------------------
* Mechanisms Results on legal deforestation
*
*-------------------------------------------------------------------------------
eststo clear

*-------------------------------------------------------------------------------
* Governor is board head
*-------------------------------------------------------------------------------
*Municipalities under a green vs non-green governor 
eststo r1: reghdfe floss_prim_legal_area_v2 ${controls} dmdn_politics2 [aw=tweights] ${if} & director_gob_law_v2==1 & green_party_v2_gov==1, abs(${fes}) vce(robust) keepsing
summ floss_prim_legal_area_v2 if e(sample)==1, d
gl mean_r1 = round(r(mean), .01)

eststo r2: reghdfe floss_prim_legal_area_v2 ${controls} dmdn_politics2 [aw=tweights] ${if} & director_gob_law_v2==1 & green_party_v2_gov==0, abs(${fes}) vce(robust) keepsing
summ floss_prim_legal_area_v2 if e(sample)==1, d
gl mean_r2 = round(r(mean), .01)

*Municipalities under governor an board composition
eststo r3: reghdfe floss_prim_legal_area_v2 ${controls} green_party_v2_gov [aw=tweights] ${if} & director_gob_law_v2==1 & dmdn_politics2==1, abs(${fes}) vce(robust) keepsing
summ floss_prim_legal_area_v2 if e(sample)==1, d
gl mean_r3 = round(r(mean), .01)

eststo r4: reghdfe floss_prim_legal_area_v2 ${controls} green_party_v2_gov [aw=tweights] ${if} & director_gob_law_v2==1 & dmdn_politics2==0, abs(${fes}) vce(robust) keepsing
summ floss_prim_legal_area_v2 if e(sample)==1, d
gl mean_r4 = round(r(mean), .01)

*Election year split
eststo r5: reghdfe floss_prim_legal_area_v2 ${controls} dmdn_politics2 green_party_v2_gov [aw=tweights] ${if} & director_gob_law_v2==1 & election_year==1, abs(${fes}) vce(robust) keepsing
summ floss_prim_legal_area_v2 if e(sample)==1, d
gl mean_r5 = round(r(mean), .01)

eststo r6: reghdfe floss_prim_legal_area_v2 ${controls} dmdn_politics2 green_party_v2_gov [aw=tweights] ${if} & director_gob_law_v2==1 & election_year==0, abs(${fes}) vce(robust) keepsing
summ floss_prim_legal_area_v2 if e(sample)==1, d
gl mean_r6 = round(r(mean), .01)

coefplot ///
    (r1, keep(mayorallied) rename(mayorallied = gparty)) ///
    (r2, keep(mayorallied) rename(mayorallied = nogreen) offset(.3)) ///
    (r3, keep(mayorallied) rename(mayorallied = polsmaj)) ///
    (r4, keep(mayorallied) rename(mayorallied = polsmin) offset(.3)) ///
    (r5, keep(mayorallied) rename(mayorallied = elect)) ///
    (r6, keep(mayorallied) rename(mayorallied = nonelect) offset(.3)), ///
    keep(*) ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(off) ///
    order(gparty nogreen polsmaj polsmin elect nonelect) ///
    xtitle("Legal Primary Forest Loss (%)", size(medium)) ///
    ytitle("Partisan Alignment Between Mayor and Governor", size(medium)) ///
	ylabel(1 `""Green" "governor""' 1.7 `""No green" "governor""' 3 `""Politicians" "majority""' 3.7 `""Politicians" "minority""' 5 `""Electoral" "year""' 5.7 `""Non-electoral" "year""', labsize(small)) ///
    mlabel(cond(@pval<=.01, string(@b, "%9.3fc")+"***", ///
           cond(@pval<=.05, string(@b, "%9.3fc")+"**", ///
           cond(@pval<=.1,  string(@b, "%9.3fc")+"*",  ///
           cond(@pval<=.15, string(@b, "%9.3fc")+"†", string(@b, "%9.3fc")))))) ///
    mlabposition(12) mlabgap(*2) 
	
gr export "${plots}\rdplot_mechs_results_legdefo.pdf", as(pdf) replace 

*-------------------------------------------------------------------------------
* Governor is NOT board head
*-------------------------------------------------------------------------------
*Municipalities under a green vs non-green governor 
eststo r7: reghdfe floss_prim_legal_area_v2 ${controls} dmdn_politics2 [aw=tweights] ${if} & director_gob_law_v2==0 & green_party_v2_gov==1, abs(${fes}) vce(robust) keepsing
summ floss_prim_legal_area_v2 if e(sample)==1, d
gl mean_r7 = round(r(mean), .01)

eststo r8: reghdfe floss_prim_legal_area_v2 ${controls} dmdn_politics2 [aw=tweights] ${if} & director_gob_law_v2==0 & green_party_v2_gov==0, abs(${fes}) vce(robust) keepsing
summ floss_prim_legal_area_v2 if e(sample)==1, d
gl mean_r8 = round(r(mean), .01)

*Election politics split
eststo r9: reghdfe floss_prim_legal_area_v2 ${controls} green_party_v2_gov [aw=tweights] ${if} & director_gob_law_v2==0 & dmdn_politics2==1, abs(${fes}) vce(robust) keepsing
summ floss_prim_legal_area_v2 if e(sample)==1, d
gl mean_r9 = round(r(mean), .01)

eststo r10: reghdfe floss_prim_legal_area_v2 ${controls} green_party_v2_gov [aw=tweights] ${if} & director_gob_law_v2==0 & dmdn_politics2==0, abs(${fes}) vce(robust) keepsing
summ floss_prim_legal_area_v2 if e(sample)==1, d
gl mean_r10 = round(r(mean), .01)

*Election year split
eststo r11: reghdfe floss_prim_legal_area_v2 ${controls} dmdn_politics2 green_party_v2_gov [aw=tweights] ${if} & director_gob_law_v2==0 & election_year==1, abs(${fes}) vce(robust) keepsing
summ floss_prim_legal_area_v2 if e(sample)==1, d
gl mean_r11 = round(r(mean), .01)

eststo r12: reghdfe floss_prim_legal_area_v2 ${controls} dmdn_politics2 green_party_v2_gov [aw=tweights] ${if} & director_gob_law_v2==0 & election_year==0, abs(${fes}) vce(robust) keepsing
summ floss_prim_legal_area_v2 if e(sample)==1, d
gl mean_r12 = round(r(mean), .01)

*-------------------------------------------------------------------------------
* Table and coefplot
*-------------------------------------------------------------------------------
* Panel A table
esttab r1 r2 r3 r4 r5 r6 using "${tables}/rdd_mechs_results_legdefo.tex", keep(mayorallied) ///
se nocons star(* 0.10 ** 0.05 *** 0.01) ///
label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
prehead(`"\begin{tabular}{@{}l*{6}{c}}"' ///
            `"\hline \toprule"'                     ///
            `"\multicolumn{7}{l}{\textit{Panel A: Governor is head of REPA}} \\ \midrule"' ///			
            `" & \multicolumn{6}{c}{Legal Forest Loss (\%)} \\ \cmidrule(l){2-7}"' ///
            `" & Green & Non-green & Politicians & Politicians & Election & Non-election \\"' ///
            `" & governor & governor & majority & minority & year & year\\"' ///
            `" & (1) & (2) & (3) & (4) & (5) & (6) \\"' ///
            `" \midrule"')  ///
postfoot(`" Dependent mean & ${mean_r1} & ${mean_r2} & ${mean_r3} & ${mean_r4} & ${mean_r5} & ${mean_r6} \\"' ///
         `"\toprule"' ///
         `"\multicolumn{7}{l}{\textit{Panel B: Governor is not head of REPA}} \\ \midrule"' ///			
         `" & \multicolumn{6}{c}{Legal Forest Loss (\%)} \\ \cmidrule(l){2-7}"' ///
         `" & Green & Non-green & Politicians & Politicians & Election & Non-election \\"' ///
         `" & governor & governor & majority & minority & year & year\\"' ///
         `" & (7) & (8) & (9) & (10) & (11) & (12) \\"' ///
         `" \midrule"')

* Panel B table
esttab r7 r8 r9 r10 r11 r12 using "${tables}/rdd_mechs_results_legdefo.tex", keep(mayorallied) ///
se nocons star(* 0.10 ** 0.05 *** 0.01) ///
label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) append ///
postfoot(`" Dependent mean & ${mean_r7} & ${mean_r8} & ${mean_r9} & ${mean_r10} & ${mean_r11} & ${mean_r12} \\ \midrule"' ///
         `" Bandwidth & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} \\"' ///
         `"\bottomrule \end{tabular}"')

*-------------------------------------------------------------------------------
* Private gains test (fixing also mayors parties)
*-------------------------------------------------------------------------------
*Municipalities under a green vs non-green governor 
eststo r1: reghdfe floss_prim_ideam_area_v2 ${controls} dmdn_politics2 [aw=tweights] ${if} & director_gob_law_v2==1 & green_party_v2_gov==1 & green_party_v2_alc==1, abs(${fes}) vce(robust) keepsing
summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_r1 = round(r(mean), .01)

eststo r2: reghdfe floss_prim_ideam_area_v2 ${controls} dmdn_politics2 [aw=tweights] ${if} & director_gob_law_v2==1 & green_party_v2_gov==0 & green_party_v2_alc==0, abs(${fes}) vce(robust) keepsing
summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_r2 = round(r(mean), .01)

eststo r3: reghdfe floss_prim_ilegal_area_v2 ${controls} dmdn_politics2 [aw=tweights] ${if} & director_gob_law_v2==1 & green_party_v2_gov==1 & green_party_v2_alc==1, abs(${fes}) vce(robust) keepsing
summ floss_prim_ilegal_area_v2 if e(sample)==1, d
gl mean_r3 = round(r(mean), .01)

eststo r4: reghdfe floss_prim_ilegal_area_v2 ${controls} dmdn_politics2 [aw=tweights] ${if} & director_gob_law_v2==1 & green_party_v2_gov==0 & green_party_v2_alc==0, abs(${fes}) vce(robust) keepsing
summ floss_prim_ilegal_area_v2 if e(sample)==1, d
gl mean_r4 = round(r(mean), .01)

eststo r5: reghdfe floss_prim_legal_area_v2 ${controls} dmdn_politics2 [aw=tweights] ${if} & director_gob_law_v2==1 & green_party_v2_gov==1 & green_party_v2_alc==1, abs(${fes}) vce(robust) keepsing
summ floss_prim_legal_area_v2 if e(sample)==1, d
gl mean_r5 = round(r(mean), .01)

eststo r6: reghdfe floss_prim_legal_area_v2 ${controls} dmdn_politics2 [aw=tweights] ${if} & director_gob_law_v2==1 & green_party_v2_gov==0 & green_party_v2_alc==0, abs(${fes}) vce(robust) keepsing
summ floss_prim_legal_area_v2 if e(sample)==1, d
gl mean_r6 = round(r(mean), .01)

*-------------------------------------------------------------------------------
* Table and coefplot
*-------------------------------------------------------------------------------
*Exporting results 
esttab r1 r2 r3 r4 r5 r6 using "${tables}/rdd_mechs_results_privgains.tex", keep(mayorallied) ///
se nocons star(* 0.10 ** 0.05 *** 0.01) ///
label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
prehead(`"\begin{tabular}{@{}l*{6}{c}}"' ///
            `"\hline \toprule"'                     ///
            `" & \multicolumn{2}{c}{Primary Forest Loss (\%)} & \multicolumn{2}{c}{Illegal Forest Loss (\%)} & \multicolumn{2}{c}{Legal Forest Loss (\%)} \\ \cmidrule(l){2-3} \cmidrule(l){4-5} \cmidrule(l){6-7}"' ///
            `" & Only green & Only non-green & Only green & Only non-green & Only green & Only non-green \\"' ///
            `" & parties & parties & parties & parties & parties & parties \\"' ///
            `" & (1) & (2) & (3) & (4) & (5) & (6) \\"'                       ///
            `" \toprule"')  ///
    postfoot(`" Dependent mean & ${mean_r1} & ${mean_r2} & ${mean_r3} & ${mean_r4} & ${mean_r5} & ${mean_r6} \\\\"' ///
	`" Bandwidth & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} & ${ht} \\"' ///
	`"\bottomrule \end{tabular}"') 



	


	
/*END













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
eststo r12: reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==1 & election_year==0, abs(${fes}) vce(robust)


*Municipalities under a non-green governor 
eststo r4: reghdfe floss_prim_ideam_area_v2 green_party_v2_gov i1.green_party_v2_gov#c.z_sh_votes_alc z_sh_votes_alc [aw=tweights] ${if} & director_gob_law_v2==1 & mayorallied==1, abs(${fes}) vce(robust)

reghdfe floss_prim_ideam_area_v2 ${controls} i1.mayorallied#i1.green_party_v2_gov green_party_v2_gov [aw=tweights] ${if} & director_gob_law_v2==1 & dmdn_politics2==1, abs(${fes}) vce(robust)

reghdfe floss_prim_ideam_area_v2 ${controls} i1.mayorallied#i1.dmdn_politics2 dmdn_politics2 [aw=tweights] ${if} & director_gob_law_v2==1, abs(${fes}) vce(robust)



reghdfe floss_prim_ideam_area_v2 ${controls} i1.mayorallied#i1.green_party_v2_gov green_party_v2_gov if director_gob_law_v2==1 & dmdn_politics2==1, abs(${fes}) vce(robust)
reghdfe floss_prim_ideam_area_v2 ${controls} i1.mayorallied#i1.dmdn_politics2 dmdn_politics2 if director_gob_law_v2==1 & green_party_v2_gov==1, abs(${fes}) vce(robust)


reghdfe floss_prim_ideam_area_v2 ${controls} i1.mayorallied#i1.dmdn_politics2 dmdn_politics2 [aw=tweights] ${if} & director_gob_law_v2==1 & green_party_v2_gov==1, abs(${fes}) vce(robust)


*XXXX
reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==1 & green_party_v2_gov==1 & dmdn_politics2==1, abs(${fes}) vce(robust)
reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==1 & green_party_v2_gov==0 & dmdn_politics2==1, abs(${fes}) vce(robust)

reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==1 & green_party_v2_gov==1, abs(${fes}) vce(robust)
reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==1 & green_party_v2_gov==0, abs(${fes}) vce(robust)

*YYYY
reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==1 & green_party_v2_gov==1 & dmdn_politics2==1, abs(${fes}) vce(robust)
reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==1 & green_party_v2_gov==1 & dmdn_politics2==0, abs(${fes}) vce(robust)

reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==1 & dmdn_politics2==1, abs(${fes}) vce(robust)
reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==1 & dmdn_politics2==0, abs(${fes}) vce(robust)




END


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