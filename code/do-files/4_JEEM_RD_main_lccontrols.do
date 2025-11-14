use "${data}/Interim\defo_caralc.dta", clear

*-------------------------------------------------------------------------------
* Local Continuity Assumption
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

*-------------------------------------------------------------------------------
* Preparing vars
*-------------------------------------------------------------------------------
tab year if H_coca!=.
replace H_coca=0 if H_coca==.
gen sh_area_coca=H_coca/area

egen area_siembra=rowtotal(as_arrozr as_arrozsm as_arrozsme as_palmaa as_palmaam as_palmar as_soya), m
gen sh_area_siembra=area_siembra/area
replace sh_area_siembra=0 if sh_area_siembra==.

egen producto_siembra=rowtotal(p_arrozr p_arrozsm p_arrozsme p_palmaa p_palmaam p_palmar p_soya), m
replace producto_siembra=0 if producto_siembra==.
gen ln_prod_crops=ln(producto_siembra)

gen primary_forest01_nopa=primary_forest01 - primary_forest01_pa

gen sh_area_forest=primary_forest01/area

replace sh_area_forest=0 if primary_forest01_nopa<0

ren SRAingeominasanh_giros_totales giros_totales

egen dist_mcados=rowmean(dismdo)
gen ln_dist_mcados=ln(dist_mcados)

egen mean_sut_crops=rowmean(sut_cof sut_banana sut_cocoa sut_rice sut_oil) 
replace mean_sut_crops=mean_sut_crops/10000

gen ln_area=ln(area)
gen sh_area_agro=areamuniagro/area

replace total_procesos=0 if total_procesos==.
replace crime_environment=0 if crime_environment==.
replace crime_forest=0 if crime_forest==.

gen crime_rate=(total_procesos/pobl_tot)*1000
gen crime_env_rate=(crime_environment/pobl_tot)*1000
gen crime_forest_rate=(crime_forest/pobl_tot)*1000

bys coddane: egen mean_gini=mean(gini)

ren IPM mpi
bys coddane: egen mean_ipm=mean(mpi)

gen ln_pibpc=ln(pib_percapita)
gen ln_regalias=ln(giros_totales)
gen ln_inv_total=ln(inv_total)

gen sh_invenv = inv_ambiental/inv_total

gen desemp_fisc_index=DF_desemp_fisc

gen sh_area_bovino=bovinos/area
gen ln_pobl_tot93=ln(pobl_tot93)

gen pobl_tot93_dens=pobl_tot93/area

gen ln_va=ln(va)
replace ln_va=log(pib_cons) if ln_va==.

summ night_light, d
gen ln_nl=log(night_light)

bys carcode_master: egen cararea = sum(area)
bys carcode_master: egen carpaarea = sum(pa_area)
gen sh_area = area*100/cararea
gen sh_paarea = pa_area*100/carpaarea

*Sample var
reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2!=., abs(${fes}) vce(robust)
gen regsample=e(sample)

*Asigning the pre-treatment var value
gl varst "ln_va ln_nl ln_regalias ln_inv_total sh_invenv sh_area_coca sh_area_bovino floss_prim_ideam_area sh_area_agro indrural crime_rate crime_env_rate crime_forest_rate sh_votes_alc incumbent_gob bii desemp_fisc_index"

preserve 
	bys coddane: egen always=max(regsample)
	
	sort coddane election year, stable
	collapse (mean) ${varst} regsample always, by(election coddane)
	sort coddane election

	replace regsample=. if regsample==0
	by coddane: carryforward regsample, gen(xt)
	replace xt=0 if xt==. & always==1

	keep if always==1
	collapse (mean) ${varst}, by(coddane xt)
	keep if xt==0
	drop xt
	
	ren (${varst}) pre_=
	
	tempfile NONCONSTANTVARS
	save `NONCONSTANTVARS', replace 
restore

merge m:1 coddane using `NONCONSTANTVARS', keep(1 3) nogen 

summ pre_desemp_fisc_index, d
replace pre_desemp_fisc_index=`r(mean)' if pre_desemp_fisc_index==.
summ pre_ln_inv_total, d
replace pre_ln_inv_total=`r(mean)' if pre_ln_inv_total==.

*-------------------------------------------------------------------------------
* Main Results with Controls
*
*-------------------------------------------------------------------------------
gl controls "mayorallied i.mayorallied#c.z_sh_votes_alc z_sh_votes_alc"
gl fes      "region year"

rdrobust floss_prim_ideam_area_v2 z_sh_votes_alc, all kernel(triangular) covs(${fes})
gl h  = e(h_l)
gl ht = round(${h}, .001)
gl if "if abs(z_sh_votes_alc)<=${h}"

cap drop tweights
gen tweights = (1-abs(z_sh_votes_alc/${h})) ${if}

gl X_lc "altura mean_sut_crops ln_pobl_tot93 pre_desemp_fisc_index pre_ln_inv_total"
   
eststo clear

*All municipalities 
eststo r1: reghdfe floss_prim_ideam_area_v2 ${controls} ${X_lc} [aw=tweights] ${if} & director_gob_law_v2!=., abs(${fes}) vce(robust)

summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_y1=round(r(mean), .01)

*Municipalities under a CAR in which Gobernor is mandated as director 
eststo r2: reghdfe floss_prim_ideam_area_v2 ${controls} ${X_lc} [aw=tweights] ${if} & director_gob_law_v2==1, abs(${fes}) vce(robust)

summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_y2=round(r(mean), .01)

*Municipalities under a CAR in which Gobernor is NOT mandated as director 
eststo r3: reghdfe floss_prim_ideam_area_v2 ${controls} ${X_lc} [aw=tweights] ${if} & director_gob_law_v2==0, abs(${fes}) vce(robust)

summ floss_prim_ideam_area_v2 if e(sample)==1, d
gl mean_y3=round(r(mean), .01)

coefplot (r1, label(All)) (r2, label(Governor is head)) (r3, label(Governor not head)), keep(mayorallied) ///
coeflabels(mayorallied = " ") ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(cols(3)) xtitle("Primary Forest Loss (%)", size(medsmall)) ytitle("Partisan Alignment Between Mayor and Governor", size(medsmall)) ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2)

gr export "${plots}\rdplot_main_results_lccontrols.pdf", as(pdf) replace 
 
*-------------------------------------------------------------------------------
* RDplots
*-------------------------------------------------------------------------------
*All municipalities 
cap drop rdplot_*
rdplot floss_prim_ideam_area_v2 z_sh_votes_alc if abs(z_sh_votes_alc)<=${h}, all kernel(triangular) h(${h}) p(1) ci(95) genvars covs(${X_lc} ${fes})

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
	
	gr export "${plots}\rdplot_main_sample_lccontrols_all.pdf", as(pdf) replace 
restore 

*Municipalities under a CAR in which Gobernor is mandated as director 
cap drop rdplot_*
rdplot floss_prim_ideam_area_v2 z_sh_votes_alc if abs(z_sh_votes_alc)<=${h} & director_gob_law_v2==1, all kernel(triangular) h(${h}) p(1) ci(95) genvars covs(${X_lc} ${fes})

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
	
	gr export "${plots}\rdplot_main_sample_lccontrols_govheadyes.pdf", as(pdf) replace 
restore 

*Municipalities under a CAR in which Gobernor is NOT mandated as director 
cap drop rdplot_*
rdplot floss_prim_ideam_area_v2 z_sh_votes_alc if abs(z_sh_votes_alc)<${h} & director_gob_law_v2==0 & floss_prim_ideam_area_v2!=., all kernel(triangular) h(${h}) p(1) ci(95) genvars covs(${X_lc} ${fes}) nbins(15)

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
		
	gr export "${plots}\rdplot_main_sample_lccontrols_govheadno.pdf", as(pdf) replace 
restore 



*END
