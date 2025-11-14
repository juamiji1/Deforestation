
*-------------------------------------------------------------------------------
* Descriptives
*
*-------------------------------------------------------------------------------
use "${data}/Interim\defo_caralc.dta", clear

gl fes "region year"

*-------------------------------------------------------------------------------
* Plot of the seat distribution between local politicians vs non-politicians
*-------------------------------------------------------------------------------
*Kdensity
summ sh_politics if floss_prim_ideam_area_v2!=., d
replace sh_politics=. if sh_politics>`r(p95)' | sh_politics<`r(p5)' 

gen sh_other=1-sh_politics

two (kdensity sh_politics) (kdensity sh_other), ///
legend(order(1 "Politicians" 2 "Non-Politicians")) l2title("Kdensity Estimator", size(medsmall)) xtitle("") ///
b2title("Share of members per type on the board", size(medsmall))

gr export "${plots}/kdensity_sh_memberstype.pdf", as(pdf) replace

tab director_gob_law if floss_prim_ideam_area_v2!=.

*-------------------------------------------------------------------------------
* Maps
*-------------------------------------------------------------------------------
preserve

	collapse (mean) primary_forest01 director_gob_law dmdn_politics_law sh_politics_law* (sum) floss_prim_ideam, by(coddane)
	gen floss_prim_ideam_area_v2=floss_prim_ideam*100/primary_forest01 
	
	export delimited "${data}/interim\map_inputs.csv", replace
restore 

*-------------------------------------------------------------------------------
* Aggregate effect 
*-------------------------------------------------------------------------------
eststo clear

eststo s0: reghdfe floss_prim_ideam_area_v2 if mayorallied==0, abs(region##year) vce(robust)
eststo s1: reghdfe floss_prim_ideam_area_v2 if mayorallied==1, abs(region##year) vce(robust)

coefplot (s0, color("gs9")) (s1, color("gs4")), ///
vert recast(bar) barwidth(0.12) ciopts(recast(rcap) lcolor("black")) citop ///
mlabcolor("black") mlabsize(medsmall) coeflabels(_cons=" ") ///
mlabel(string(@b, "%9.2fc")) mlabposition(11) mlabgap(*2) ///
l2title("Yearly Primary Forest Loss (%)", size(medium)) ///
legend(on order(1 "Mayor-Governor not Aligned" 3 "Mayor-Governor Aligned")) ///
ylabel(0 (.05).16)

gr export "${plots}/desc_OLS_plot.pdf", as(pdf) replace

eststo s2: reghdfe floss_prim_ideam_area_v2 if mayorallied==0 & director_gob_law_v2==0, abs(${fes}) vce(robust)
eststo s3: reghdfe floss_prim_ideam_area_v2 if mayorallied==1 & director_gob_law_v2==0, abs(${fes}) vce(robust)
eststo s4: reghdfe floss_prim_ideam_area_v2 if mayorallied==0 & director_gob_law_v2==1, abs(${fes}) vce(robust)
eststo s5: reghdfe floss_prim_ideam_area_v2 if mayorallied==1 & director_gob_law_v2==1, abs(${fes}) vce(robust)

coefplot (s4, color("gs9")) (s5, color("gs4")) ///
(s2, color("gs9")) (s3, color("gs4")), ///
vert recast(bar) barwidth(0.12) ciopts(recast(rcap) lcolor("black")) citop ///
mlabcolor("black") mlabsize(medium) coeflabels(_cons=" ") ///
mlabel(string(@b, "%9.2fc")) mlabposition(11) mlabgap(*2) ///
l2title("Yearly Primary Forest Loss (%)", size(medium)) ///
legend(on order(1 "Mayor-Governor not Aligned" 3 "Mayor-Governor Aligned")) ///
xline(1, lc(gray) lp(dash)) ///
addplot(scatteri .17 .55 (3) "Governor as REPA Head" .17 1.05 (3) "Governor not REPA Head", mcolor(white) mlabsize(medium)) ///
ylabel(0 (.05).17)


gr export "${plots}/desc_OLS_plot_bygovhead.pdf", as(pdf) replace

*-------------------------------------------------------------------------------
* Year time trends 
*-------------------------------------------------------------------------------
*All sample and Amazon (CORPORINOQUIA 27 CDA 9 CORMACARENA 14 CORPOAMAZONIA 17)
mean floss_prim_ideam_area_v2 if year>2000 & year<2021, over(year)
mat A=e(b)
mat coln A = 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19

mean floss_prim_ideam_area_v2 if year>2000 & year<2021 & inlist(carcode_master, 9, 14, 17, 27), over(year)
mat B=e(b)
mat coln B = 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19

cap drop perm_x
gen perm_x=perm_area/(perm_n_resol*1000)

summ perm_x  if inlist(carcode_master,9, 17), d  			// .5 or 3 Km2 per permit
replace perm_x = . if perm_x>`r(p95)' & inlist(carcode_master,9, 17)

mean perm_x if year>2010 & year<2020 & inlist(carcode_master,9, 17), over(year)
mat C=e(b)
mat coln C =  11 12 13 14 15 16 17 18 19

coefplot (mat(A[1]), mcolor("gs2") label("National")) ///
(mat(B[1]), mcolor("gs6") label("Amazon")), ///
vert noci recast(connected) xline(4, lp(dash)) xline(8, lp(dash)) xline(12, lp(dash)) xline(16, lp(dash)) l2title("Yearly Primary Forest Loss (%)", size(medium)) b2title("Years", size(medium)) addplot(scatteri .2 12 .2 13 .2 14 .2 15 .2 16, recast(area) color(gs5%15) lcolor(white) base(0.02)) plotregion(margin(zero)) legend(cols(3))

gr export "${plots}/desc_all_yearly_trend.pdf", as(pdf) replace

*Governor head or not
mean floss_prim_ideam_area_v2 if mayorallied==0 & year>2000 & year<2021, over(year)
mat b0=e(b)
mat coln b0 = 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19

mean floss_prim_ideam_area_v2 if mayorallied==1 & year>2000 & year<2021, over(year)
mat b1=e(b)
mat coln b1 = 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19

coefplot (mat(b0[1]), label("Mayor-Governor not Aligned") mcolor("gs9")) (mat(b1[1]), label("Mayor-Governor Aligned") color("gs4")), vert noci recast(connected) xline(4, lp(dash)) xline(8, lp(dash)) xline(12, lp(dash)) xline(16, lp(dash)) l2title("Yearly Primary Forest Loss (%)", size(medium)) b2title("Years", size(medium)) addplot(scatteri .25 12 .25 13 .25 14 .25 15 .25 16, recast(area) color(gs5%15) lcolor(white) base(0.02)) plotregion(margin(zero))

gr export "${plots}/desc_all_yearly_trend_bygovhead.pdf", as(pdf) replace

*-------------------------------------------------------------------------------
* BII
*-------------------------------------------------------------------------------
eststo s0: reghdfe bii if mayorallied==0 & floss_prim_ideam_area_v2!=. & inlist(year, 2000, 2005, 2010, 2015, 2020), abs(${fes}) vce(robust)
eststo s1: reghdfe bii if mayorallied==1 & floss_prim_ideam_area_v2!=. & inlist(year, 2000, 2005, 2010, 2015, 2020), abs(${fes}) vce(robust)

coefplot (s0, color("gs9")) (s1, color("gs4")), ///
vert recast(bar) barwidth(0.12) ciopts(recast(rcap) lcolor("black")) citop ///
mlabcolor("black") mlabsize(medsmall) coeflabels(_cons=" ") ///
mlabel(string(@b, "%9.2fc")) mlabposition(11) mlabgap(*2) ///
l2title("Yearly Primary Forest Loss (%)", size(medium)) ///
legend(on order(1 "Mayor-Governor not Aligned" 3 "Mayor-Governor Aligned")) ///
ylabel(0 (10) 70)

gr export "${plots}/desc_OLS_bii_plot.pdf", as(pdf) replace

eststo s2: reghdfe bii if mayorallied==0 & director_gob_law_v2==0 & floss_prim_ideam_area_v2!=. & inlist(year, 2000, 2005, 2010, 2015, 2020), abs(${fes}) vce(robust)
eststo s3: reghdfe bii if mayorallied==1 & director_gob_law_v2==0 & floss_prim_ideam_area_v2!=. & inlist(year, 2000, 2005, 2010, 2015, 2020), abs(${fes}) vce(robust)
eststo s4: reghdfe bii if mayorallied==0 & director_gob_law_v2==1 & floss_prim_ideam_area_v2!=. & inlist(year, 2000, 2005, 2010, 2015, 2020), abs(${fes}) vce(robust)
eststo s5: reghdfe bii if mayorallied==1 & director_gob_law_v2==1 & floss_prim_ideam_area_v2!=. & inlist(year, 2000, 2005, 2010, 2015, 2020), abs(${fes}) vce(robust)

coefplot (s4, color("gs9")) (s5, color("gs4")) ///
(s2, color("gs9")) (s3, color("gs4")), ///
vert recast(bar) barwidth(0.12) ciopts(recast(rcap) lcolor("black")) citop ///
mlabcolor("black") mlabsize(medium) coeflabels(_cons=" ") ///
mlabel(string(@b, "%9.2fc")) mlabposition(11) mlabgap(*2) ///
l2title("Yearly Primary Forest Loss (%)", size(medium)) ///
legend(on order(1 "Mayor-Governor not Aligned" 3 "Mayor-Governor Aligned")) ///
xline(1, lc(gray) lp(dash)) ///
addplot(scatteri 95 .55 (3) "Governor as REPA Head" 95 1.05 (3) "Governor not REPA Head", mcolor(white) mlabsize(medium)) ///
ylabel(0 (10) 95)

gr export "${plots}/desc_OLS_bii_plot_bygovhead.pdf", as(pdf) replace

*-------------------------------------------------------------------------------
* Forest Permits
*-------------------------------------------------------------------------------
eststo s2: reghdfe pforest_n if mayorallied==0 & director_gob_law_v2==0 & year>=2011,  abs(${fes})  vce(robust)
eststo s3: reghdfe pforest_n if mayorallied==1 & director_gob_law_v2==0 & year>=2011,  abs(${fes})  vce(robust)
eststo s4: reghdfe pforest_n if mayorallied==0 & director_gob_law_v2==1 & year>=2011,  abs(${fes})  vce(robust)
eststo s5: reghdfe pforest_n if mayorallied==1 & director_gob_law_v2==1 & year>=2011,  abs(${fes})  vce(robust)

coefplot (s4, color("gs9")) (s5, color("gs4")) ///
(s2, color("gs9")) (s3, color("gs4")), ///
vert recast(bar) barwidth(0.12) ciopts(recast(rcap) lcolor("black")) citop ///
mlabcolor("black") mlabsize(medium) coeflabels(_cons=" ") ///
mlabel(string(@b, "%9.2fc")) mlabposition(11) mlabgap(*2) ///
l2title("Granted Forestry Permits", size(medium)) ///
legend(on order(1 "Mayor-Governor not Aligned" 3 "Mayor-Governor Aligned")) ///
xline(1, lc(gray) lp(dash)) ///
addplot(scatteri 60 .55 (3) "Governor as REPA Head" 60 1.05 (3) "Governor not REPA Head", mcolor(white) mlabsize(medium)) ///
ylabel(0 (10) 60)

gr export "${plots}\desc_forestpermits.pdf", as(pdf) replace 

*-------------------------------------------------------------------------------
* Stats for states by governor head
*-------------------------------------------------------------------------------
*My ttest program
cap program drop my_ttest
program my_ttest, eclass
	version 15
	syntax varlist(fv) [if] [in], by(varlist fv)
	cap mat drop T S
	
	scalar n=wordcount("`varlist'")
	dis n
	
	mat T = J(n,9,.)
	local final=0
	foreach var of local varlist{
		ttest `var' `if', by(`by')
		local inicial = 1 + `final'
		mat T[`inicial',1] = r(mu_1)
		mat T[`inicial',2] = r(sd_1) 
		mat T[`inicial',3] = r(mu_2)
		mat T[`inicial',4] = r(sd_2) 
		mat T[`inicial',5] = r(mu_1) - r(mu_2)
		mat T[`inicial',6] = r(se)
		mat T[`inicial',7] = r(N_1)
		mat T[`inicial',8] = r(N_2)
		mat T[`inicial',9] = r(p)
		local final = `inicial'
	}	

	mata: stars_MATA(st_matrix("T"),st_numscalar("n"))

	mat T=T[.,1..6]
	mat rown T= `varlist'
	
	ereturn mat est=T 
	ereturn mat stars=S
	
end

mata 
	function stars_MATA(T,n){
		numeric matrix S
		S=(T[.,9]:<=0.1)+(T[.,9]:<=0.05)+(T[.,9]:<=0.01)
		S=(J(n,4,0),S,J(n,1,0))
		st_matrix("T",T)
		st_matrix("S",S)
	}
end mata 

*Ttest table 
use "${data}/Interim\Desc_vars90.dta", clear 

la var depto_ln_pobl_tot93 "Log(Total population) - 1993"
la var depto_sh_displaced93_lc90 "Log(Displaced population) - 1993"
la var depto_gini93_lc90 "Gini index - 1993"
la var depto_nbi93_lc90 "Unsatisfied basic needs - 1993"
la var depto_sh_forestcov90 "Forest cover share (\%) - 1990"
la var depto_forest_change_90_00 "Forest change - 1990 to 2000"
la var depto_ln_crop_prod90 "Log(Crop production) - 1990"
la var depto_crop_yield1990 "Crop yield - 1990"
la var depto_ln_pib90 "Log(Total GDP) - 1990"
la var depto_ln_agg_va90 "Log(Agriculture value) - 1990"
la var depto_ln_min_va90 "Log(Mining value) - 1990"

gl popvars "depto_ln_pobl_tot93 depto_sh_displaced93_lc90 depto_gini93_lc90 depto_nbi93_lc90"
gl geovars "depto_sh_forestcov90 depto_forest_change_90_00  depto_ln_crop_prod90 depto_crop_yield1990"
gl prodvars "depto_ln_pib90  depto_ln_agg_va90 depto_ln_min_va90"

gen d_director_gob_law_v2=(m_director_gob_law_v2>0) 

drop if codepto==11 // Dropping Bogota
my_ttest ${popvars} ${geovars} ${prodvars}, by(d_director_gob_law_v2)
mat T=e(est)
mat S=e(stars)
mat N = J(2,3,.)
mat N[2,1]=8
mat N[2,2]=23
mat N[2,3]=31

*Nice results
tempfile X X0 X1 
frmttable, statmat(T) varlabels replace substat(1) annotate(S) asymbol(*,**,***) ///
ctitle("Variables", "Governor not REPA head", "Governor is REPA head", , "Difference" \ "", "Mean", "Mean", "of means" \ ///
" ", "(SD)", "(SD)", "(SE)") fragment tex nocenter
frmttable using `X', statmat(N) varlabels append ///
rtitle("" \ "State observations") fragment tex nocenter sdec(0)

filefilter `X' `X0', from("r}\BS\BS") to("r}") replace 
filefilter `X0' `X1', from("\BSbegin{footnotesize}") to("") replace 
filefilter `X1' "${tables}\ttest_states.tex", from("\BSend{footnotesize}") to("") replace 



*END