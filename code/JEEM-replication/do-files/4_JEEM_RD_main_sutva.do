*-------------------------------------------------------------------------------
* Building the dataset for neighbor analysis
*
*-------------------------------------------------------------------------------

gl controls "mayorallied i.mayorallied#c.z_sh_votes_alc z_sh_votes_alc"
gl fes "region year"

*-------------------------------------------------------------------------------
* Defo of neighbors
*-------------------------------------------------------------------------------
use "${data}/Interim\defo_caralc.dta", clear 

rdrobust floss_prim_ideam_area_v2 z_sh_votes_alc, all kernel(triangular) covs(${fes})
gl h = e(h_l)
gl if "if abs(z_sh_votes_alc)<=${h}"

cap drop tweights
gen tweights=(1-abs(z_sh_votes_alc/${h})) ${if}

reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2!=., abs(${fes}) vce(robust)
gen rdsample=1 if e(sample)==1

keep coddane year floss_prim_ideam_area_v2 floss_prim_legal_area_v2 floss_prim_ilegal_area_v2 mayorallied codepto carcode_master rdsample z_sh_votes_alc mayorallied
ren (coddane floss_prim_ideam_area_v2 floss_prim_legal_area_v2 floss_prim_ilegal_area_v2 mayorallied codepto carcode_master rdsample z_sh_votes_alc) (coddane_nbr floss_prim_ideam_area_v2_nbr floss_prim_legal_area_v2_nbr floss_prim_ilegal_area_v2_nbr mayorallied_nbr codepto_nbr carcode_master_nbr rdsample_nbr z_sh_votes_alc_nbr) 

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
		
		merge m:1 coddane_nbr year using `DEFONBR', keep(1 3) nogen keepus(floss_prim_ideam_area_v2_nbr floss_prim_legal_area_v2_nbr floss_prim_ilegal_area_v2_nbr mayorallied_nbr codepto_nbr carcode_master_nbr rdsample_nbr z_sh_votes_alc_nbr)
		
		tempfile MUNINBR_`y'
		save `MUNINBR_`y'', replace 
	restore
}

*-------------------------------------------------------------------------------
* RD sample 
*-------------------------------------------------------------------------------
use "${data}/Interim\defo_caralc.dta", clear 

rdrobust floss_prim_ideam_area_v2 z_sh_votes_alc, all kernel(triangular) covs(${fes})
gl h = e(h_l)
gl if "if abs(z_sh_votes_alc)<=${h}"

cap drop tweights
gen tweights=(1-abs(z_sh_votes_alc/${h})) ${if}

reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2!=., abs(${fes}) vce(robust)
gen rdsample=1 if e(sample)==1

*-------------------------------------------------------------------------------
* Merging all together
*-------------------------------------------------------------------------------
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
* Flagging Neighbor Munis in the RD-sample
*-------------------------------------------------------------------------------
keep if rdsample==1 & rdsample_nbr==1

sort  year coddane coddane_nbr  

*br coddane coddane_nbr year mayorallied mayorallied_nbr rdsample rdsample_nbr z_sh_votes_alc z_sh_votes_alc_nbr

gen sutva_out=1 if (mayorallied==0 & mayorallied_nbr==1)
replace sutva_out=0 if sutva_out==.

preserve
	keep if sutva_out==1
	collapse sutva_out, by(coddane year) 

	isid coddane year

	tempfile OUTLIST
	save `OUTLIST', replace 
restore 

gen sutva_out_ext=1 if (mayorallied_nbr==0 & mayorallied==1) | (mayorallied_nbr==1 & mayorallied==0)	

keep if sutva_out_ext==1
collapse sutva_out_ext, by(coddane year) 

isid coddane year

tempfile OUTLIST2
save `OUTLIST2', replace 


*-------------------------------------------------------------------------------
* Main Results without Negihbors
*
*-------------------------------------------------------------------------------
use "${data}/Interim\defo_caralc.dta", clear 

merge 1:1 coddane year using `OUTLIST', keep(1 3) nogen
merge 1:1 coddane year using `OUTLIST2', keep(1 3) nogen

rdrobust floss_prim_ideam_area_v2 z_sh_votes_alc, all kernel(triangular) covs(${fes})
gl h = e(h_l)
gl if "if abs(z_sh_votes_alc)<=${h}"

cap drop tweights
gen tweights=(1-abs(z_sh_votes_alc/${h})) ${if}

*-------------------------------------------------------------------------------
* Possible violation of SUTVA - UNITS OUT
*-------------------------------------------------------------------------------
gl if "if abs(z_sh_votes_alc)<=${h} & sutva_out!=1"

eststo clear

*Results taking out nbrs from the rdsample 
eststo r1: reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2!=., abs(${fes}) vce(robust)
eststo r2: reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==1, abs(${fes}) vce(robust)
eststo r3: reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==0, abs(${fes}) vce(robust)

coefplot (r1, label(All)) (r2, label(Governor is head)) (r3, label(Governor not head)), keep(mayorallied) ///
coeflabels(mayorallied = " ") ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(cols(3)) xtitle("Primary Forest Loss (%)", size(medsmall)) ytitle("Partisan Alignment Between Mayor and Governor", size(medsmall)) ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2)

gr export "${plots}\rdplot_main_results_sutvaout.pdf", as(pdf) replace 


eststo r1: reghdfe floss_prim_ilegal_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2!=., abs(${fes}) vce(robust)
eststo r2: reghdfe floss_prim_ilegal_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==1, abs(${fes}) vce(robust)
eststo r3: reghdfe floss_prim_ilegal_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==0, abs(${fes}) vce(robust)

coefplot (r1, label(All)) (r2, label(Governor is head)) (r3, label(Governor not head)), keep(mayorallied) ///
coeflabels(mayorallied = " ") ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(cols(3)) xtitle("Illegal Primary Forest Loss (%)", size(medsmall)) ytitle("Partisan Alignment Between Mayor and Governor", size(medsmall)) ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2)

gr export "${plots}\rdplot_main_results_illegal_sutvaout.pdf", as(pdf) replace 

eststo r1: reghdfe floss_prim_legal_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2!=., abs(${fes}) vce(robust)
eststo r2: reghdfe floss_prim_legal_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==1, abs(${fes}) vce(robust)
eststo r3: reghdfe floss_prim_legal_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==0, abs(${fes}) vce(robust)

coefplot (r1, label(All)) (r2, label(Governor is head)) (r3, label(Governor not head)), keep(mayorallied) ///
coeflabels(mayorallied = " ") ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(cols(3)) xtitle("Legal Primary Forest Loss (%)", size(medsmall)) ytitle("Partisan Alignment Between Mayor and Governor", size(medsmall)) ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2)

gr export "${plots}\rdplot_main_results_legal_sutvaout.pdf", as(pdf) replace 

*-------------------------------------------------------------------------------
* Possible violation of SUTVA - UNITS OUT (Extreme sample)
*-------------------------------------------------------------------------------
gl if "if abs(z_sh_votes_alc)<=${h} & sutva_out_ext!=1"

eststo clear

*Results taking out nbrs from the rdsample 
eststo r1: reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2!=., abs(${fes}) vce(robust)
eststo r2: reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==1, abs(${fes}) vce(robust)
eststo r3: reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==0, abs(${fes}) vce(robust)

coefplot (r1, label(All)) (r2, label(Governor is head)) (r3, label(Governor not head)), keep(mayorallied) ///
coeflabels(mayorallied = " ") ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(cols(3)) xtitle("Primary Forest Loss (%)", size(medsmall)) ytitle("Partisan Alignment Between Mayor and Governor", size(medsmall)) ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2)

gr export "${plots}\rdplot_main_results_sutvaoutext.pdf", as(pdf) replace 


eststo r1: reghdfe floss_prim_ilegal_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2!=., abs(${fes}) vce(robust)
eststo r2: reghdfe floss_prim_ilegal_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==1, abs(${fes}) vce(robust)
eststo r3: reghdfe floss_prim_ilegal_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==0, abs(${fes}) vce(robust)

coefplot (r1, label(All)) (r2, label(Governor is head)) (r3, label(Governor not head)), keep(mayorallied) ///
coeflabels(mayorallied = " ") ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(cols(3)) xtitle("Illegal Primary Forest Loss (%)", size(medsmall)) ytitle("Partisan Alignment Between Mayor and Governor", size(medsmall)) ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2)

gr export "${plots}\rdplot_main_results_illegal_sutvaoutext.pdf", as(pdf) replace 

eststo r1: reghdfe floss_prim_legal_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2!=., abs(${fes}) vce(robust)
eststo r2: reghdfe floss_prim_legal_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==1, abs(${fes}) vce(robust)
eststo r3: reghdfe floss_prim_legal_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2==0, abs(${fes}) vce(robust)

coefplot (r1, label(All)) (r2, label(Governor is head)) (r3, label(Governor not head)), keep(mayorallied) ///
coeflabels(mayorallied = " ") ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(cols(3)) xtitle("Legal Primary Forest Loss (%)", size(medsmall)) ytitle("Partisan Alignment Between Mayor and Governor", size(medsmall)) ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2)

gr export "${plots}\rdplot_main_results_legal_sutvaoutext.pdf", as(pdf) replace 





*END