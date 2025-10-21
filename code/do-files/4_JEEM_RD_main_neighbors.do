*-------------------------------------------------------------------------------
* Building the dataset for neighbor analysis
*
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
* Defo of neighbors
*-------------------------------------------------------------------------------
use "${data}/Interim\defo_caralc.dta", clear 

keep coddane year floss_prim_ideam_area_v2 floss_prim_legal_area_v2 floss_prim_ilegal_area_v2 mayorallied codepto carcode_master
ren (coddane floss_prim_ideam_area_v2 floss_prim_legal_area_v2 floss_prim_ilegal_area_v2 mayorallied codepto carcode_master) (coddane_nbr floss_prim_ideam_area_v2_nbr floss_prim_legal_area_v2_nbr floss_prim_ilegal_area_v2_nbr mayorallied_nbr codepto_nbr carcode_master_nbr)

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
		
		merge m:1 coddane_nbr year using `DEFONBR', keep(1 3) nogen keepus(floss_prim_ideam_area_v2_nbr floss_prim_legal_area_v2_nbr floss_prim_ilegal_area_v2_nbr mayorallied_nbr codepto_nbr carcode_master_nbr)
		
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

* Creating intensity of treatment 
bys coddane_nbr year: egen alligned_intensity = mean(mayorallied)
summ alligned_intensity, d

*Selecting sample of neighbors 
gen sample_nbr=1 if mayorallied==0 & alligned_intensity==0
*replace sample_nbr=1 if sample_nbr==. & mayorallied==1 & alligned_intensity>0 & alligned_intensity<.12
*replace sample_nbr=1 if sample_nbr==. & mayorallied==1 & alligned_intensity>.12
replace sample_nbr=1 if sample_nbr==. & mayorallied==1 & alligned_intensity>0


*-------------------------------------------------------------------------------
* Main regression for neighbors (Low intensity of aligned neighbors)
*
*-------------------------------------------------------------------------------
summ z_sh_votes_alc, d

rdrobust floss_prim_ideam_area_v2 z_sh_votes_alc if sample_nbr==1, all kernel(triangular)
gl h = .065
gl ht= round(${h}, .001)
gl p = e(p)
gl k = e(kernel)

gl if "if abs(z_sh_votes_alc)<=${h} & codepto_nbr==codepto & mayorallied_nbr==0 & sample_nbr==1"
*gl if "if abs(z_sh_votes_alc)<=${h} & carcode_master_nbr==carcode_master & mayorallied_nbr==0"

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
coefplot (r1, label(All)) (r2, label(Governor is head)) (r3, label(Governor not head)), keep(mayorallied) ///
coeflabels(mayorallied = " ") ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(cols(3)) xtitle("Primary Forest Loss (%)", size(medsmall)) ytitle("Partisan Alignment Between Mayor and Governor", size(medsmall)) ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2)

gr export "${plots}\rdplot_main_results_neighbors.pdf", as(pdf) replace 

coefplot (r7, label(All)) (r8, label(Governor is head)) (r9, label(Governor not head)), keep(mayorallied) ///
coeflabels(mayorallied = " ") ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(cols(3)) xtitle("Illegal Primary Forest Loss (%)", size(medsmall)) ytitle("Partisan Alignment Between Mayor and Governor", size(medsmall)) ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2)

gr export "${plots}\rdplot_main_results_neighbors_illegal.pdf", as(pdf) replace 

coefplot (r4, label(All)) (r5, label(Governor is head)) (r6, label(Governor not head)), keep(mayorallied) ///
coeflabels(mayorallied = " ") ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(cols(3)) xtitle("Legal Primary Forest Loss (%)", size(medsmall)) ytitle("Partisan Alignment Between Mayor and Governor", size(medsmall)) ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2)

gr export "${plots}\rdplot_main_results_neighbors_legal.pdf", as(pdf) replace 

