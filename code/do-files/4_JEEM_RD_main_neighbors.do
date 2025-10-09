*-------------------------------------------------------------------------------
* Building the dataset for neighbor analysis
*
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
* Defo of neighbors
*-------------------------------------------------------------------------------
use "${data}/Interim\defo_caralc.dta", clear 

keep coddane year floss_prim_ideam_area_v2 floss_prim_legal_area_v2 floss_prim_ilegal_area_v2
ren (coddane floss_prim_ideam_area_v2 floss_prim_legal_area_v2 floss_prim_ilegal_area_v2) (coddane_nbr floss_prim_ideam_area_v2_nbr floss_prim_legal_area_v2_nbr floss_prim_ilegal_area_v2_nbr)

tempfile DEFONBR
save `DEFONBR', replace 

*-------------------------------------------------------------------------------
* Muni Nbr Table
*-------------------------------------------------------------------------------
import excel "${data}\muniCAR\muni_neighbors.xls", firstrow clear

ren (Municipios_src_IDDANE Municipios_nbr_IDDANE) (coddane coddane_nbr)

keep coddane*

forval y=2001/2019{
	preserve
		gen year=`y'
		
		merge m:1 coddane_nbr year using `DEFONBR', keep(1 3) nogen keepus(floss_prim_ideam_area_v2_nbr floss_prim_legal_area_v2_nbr floss_prim_ilegal_area_v2_nbr)
		
		tempfile MUNINBR_`y'
		save `MUNINBR_`y'', replace 
	restore
}

*-------------------------------------------------------------------------------
* Meging all together
*-------------------------------------------------------------------------------
use "${data}/Interim\defo_caralc.dta", clear 

forval y=2001/2019{
	
	preserve
		keep if year==`y'
		merge 1:m coddane year using `MUNINBR_`y'', keep(1 3) nogen
		
		tempfile DEFO_`y'
		save `DEFO_`y'', replace 		
	restore 
}

use `DEFO_2001', clear 

forval y=2002/2019{
	append using `DEFO_`y''
}

sort year coddane coddane_nbr


*-------------------------------------------------------------------------------
* Main regression for neighbors
*
*-------------------------------------------------------------------------------
summ z_sh_votes_alc, d

rdrobust floss_prim_ideam_area_v2 z_sh_votes_alc, all kernel(triangular)
gl h = .065
gl ht= round(${h}, .001)
gl p = e(p)
gl k = e(kernel)
gl if "if abs(z_sh_votes_alc)<=${h}"
gl controls "mayorallied i.mayorallied#c.z_sh_votes_alc z_sh_votes_alc"
gl fes "region year"

cap drop tweights
gen tweights=(1-abs(z_sh_votes_alc/${h})) ${if}

eststo clear

*-------------------------------------------------------------------------------
* All deforestation
*-------------------------------------------------------------------------------
*All municipalities 
eststo r1: reghdfe floss_prim_ideam_area_v2_nbr ${controls} [aw=tweights] ${if} & director_gob_law_v2!=., abs(${fes}) vce(robust)

*Municipalities under a CAR in which Gobernor is mandated as director 
eststo r2: reghdfe floss_prim_ideam_area_v2_nbr ${controls} [aw=tweights] ${if} & director_gob_law_v2==1, abs(${fes}) vce(robust)

*Municipalities under a CAR in which Gobernor is NOT mandated as director 
eststo r3: reghdfe floss_prim_ideam_area_v2_nbr ${controls} [aw=tweights] ${if} & director_gob_law_v2==0, abs(${fes}) vce(robust)

*-------------------------------------------------------------------------------
* Legal deforestation
*-------------------------------------------------------------------------------
*All municipalities 
eststo r4: reghdfe floss_prim_legal_area_v2_nbr ${controls} [aw=tweights] ${if} & director_gob_law_v2!=., abs(${fes}) vce(robust)

*Municipalities under a CAR in which Gobernor is mandated as director 
eststo r5: reghdfe floss_prim_legal_area_v2_nbr ${controls} [aw=tweights] ${if} & director_gob_law_v2==1, abs(${fes}) vce(robust)

*Municipalities under a CAR in which Gobernor is NOT mandated as director 
eststo r6: reghdfe floss_prim_legal_area_v2_nbr ${controls} [aw=tweights] ${if} & director_gob_law_v2==0, abs(${fes}) vce(robust)

*-------------------------------------------------------------------------------
* Illegal deforestation
*-------------------------------------------------------------------------------
*All municipalities 
eststo r7: reghdfe floss_prim_ilegal_area_v2_nbr ${controls} [aw=tweights] ${if} & director_gob_law_v2!=., abs(${fes}) vce(robust)

*Municipalities under a CAR in which Gobernor is mandated as director 
eststo r8: reghdfe floss_prim_ilegal_area_v2_nbr ${controls} [aw=tweights] ${if} & director_gob_law_v2==1, abs(${fes}) vce(robust)

*Municipalities under a CAR in which Gobernor is NOT mandated as director 
eststo r9: reghdfe floss_prim_ilegal_area_v2_nbr ${controls} [aw=tweights] ${if} & director_gob_law_v2==0, abs(${fes}) vce(robust)

*-------------------------------------------------------------------------------
* Plots
*-------------------------------------------------------------------------------
coefplot (r2, label(Both)) (r5, label(Legal)) (r8, label(Illegal)), keep(mayorallied) ///
coeflabels(mayorallied = " ") ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(cols(3)) xtitle("Primary Forest Loss of Neighbors (%)", size(medsmall)) ytitle("Partisan Alignment Between Mayor and Governor", size(medsmall)) ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2)

gr export "${plots}\rdplot_main_results_neighbors_govhead.pdf", as(pdf) replace 

coefplot (r3, label(Both)) (r6, label(Legal)) (r9, label(Illegal)), keep(mayorallied) ///
coeflabels(mayorallied = " ") ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(cols(3)) xtitle("Primary Forest Loss of Neighbors (%)", size(medsmall)) ytitle("Partisan Alignment Between Mayor and Governor", size(medsmall)) ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2)

gr export "${plots}\rdplot_main_results_neighbors_govnothead.pdf", as(pdf) replace 


*END