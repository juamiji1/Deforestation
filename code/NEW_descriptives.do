
*-------------------------------------------------------------------------------
* Descriptives
*
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
* Maps
*-------------------------------------------------------------------------------
*Hansen deforestation conditioning to pixels with primary forest from IDEAM
forval y=1/20{
	import delimited "${data}/Deforestation\forestloss_primary_IDEAM\ForestLoss_IDEAM_Year`y'.csv", encoding(UTF-8)  clear 

	rename (codmpio lossarea`y') (coddane floss_prim_ideam)
	gen year=2000+`y'
	replace floss_prim_ideam=floss_prim_ideam/1000000

	keep coddane year floss_prim_ideam

	tempfile F`y'
	save `F`y'', replace 
}

use `F1', clear

append using `F2' `F3' `F4' `F5' `F6' `F7' `F8' `F9' `F10' `F11' `F12' `F13' `F14' `F15' `F16' `F17' `F18' `F19' `F20'
sort coddane year 

tempfile FLOSS_PRIMARY_IDEAM
save `FLOSS_PRIMARY_IDEAM', replace 

use "${data}/Gis\workinprogress\muniShp_defoinfo_sp.dta", clear
spset

*Renaming vars
rename _all, low
ren (nmg id_espa floss01 floss02 floss03 floss04 floss05 floss06 floss07 floss08 floss09 fcv00_1 fc00_50 fcovr01) (muni_name coddane floss1 floss2 floss3 floss4 floss5 floss6 floss7 floss8 floss9 fprim00_p1 fprim00_p50 fprim_01)

keep _id _cx _cy objecti muni_name coddane area-fprim_01 
ren _id _cx _cy, up

*Reshaping the data 
destring coddane, replace
duplicates drop coddane, force

reshape long floss, i(coddane) j(year)
replace year=2000+year
keep if year<2021

*Merging pimary forest data 
merge 1:1 coddane year using `FLOSS_PRIMARY_IDEAM', keep(1 3)

*Calculating different normalizations of the forest loss
by coddane: egen tfloss_ideam=sum(floss_prim_ideam)

gen tfloss_ideam_area=tfloss_ideam*100/area 

*Total in share
keep if year==2019

grmap tfloss_ideam_area, fcolor(GnBu) legc clmethod(q) ndocolor(none) ocolor(none ...) clnumber(9) legend(off)
gr export "${plots}/tfloss_ideam_area_map.png", as(png) replace

*-------------------------------------------------------------------------------
* Likelihood of Politicians choosing Governor as Director
*-------------------------------------------------------------------------------
use "${data}/Interim\defo_caralc.dta", clear

la var mayorallied "Partisan alignment"
la var floss_prim_ideam_area "Primary Forest Loss (%)"

*Table
tabstat sh_politics_law, by(director_gob_law) s(mean sd N) save
tabstatmat S

mata: st_matrix("R", st_matrix("S")); st_matrixrowstripe("S", J(0,2,""))

mat N=J(3,1,.)

distinct coddane if sh_politics_law!=. 
mat N[3,1]=`r(ndistinct)'

distinct coddane if sh_politics_law!=. & director_gob_law==0
mat N[1,1]=`r(ndistinct)'

distinct coddane if sh_politics_law!=. & director_gob_law==1
mat N[2,1]=`r(ndistinct)'

mat R=R,N

mat colnames R = "Mean" "SD" "Observations" "Municipalities"
mat rownames R = "Governor not head" "Governor is head" "All"

mat l R

tempfile X X1
frmttable using `X', statmat(R) sdec(3,3 ,0) fragment tex nocenter 
filefilter `X' "${tables}\diff_sh_politics_law_by_govhead.tex", from("r}\BS\BS") to("r}") replace 

*Plot 
unique carcode_master if dmdn_politics==0
unique carcode_master if dmdn_politics==1

eststo clear

eststo s0: areg director_gob_law if dmdn_politics==0, a(year) vce(cl coddane)
eststo s1: areg director_gob_law if dmdn_politics==1, a(year) vce(cl coddane)

coefplot (s0, label(Politicians minority)) (s1, label(Politicians majority)), ///
vert recast(bar) ciopts(recast(rcap) lcolor("black")) citop mlabcolor("black") ///
mlabsize(medsmall) barwidth(0.3) coeflabels(_cons=" ") mlabel(string(@b, "%9.3fc")) ///
mlabposition(11) mlabgap(*2) l2title("Likelihood of choosing governor as head") 
*note("12 out 28 REPAs have a majority of politicians" )
 
gr export "${plots}/prob_govhead_dmdnpoliticians.pdf", as(pdf) replace

*-------------------------------------------------------------------------------
* Plot of the seat distribution between politicians vs non-politicians in the board
*-------------------------------------------------------------------------------
*Kdensity
egen sh_other=rowtotal(sh_ethnias sh_private sh_envngo sh_academics), m

two (kdensity sh_politics if sh_politics>.2 & sh_politics<.7) (kdensity sh_other if sh_politics>.2 & sh_politics<.7), ///
legend(order(1 "Politicians" 2 "Non-Politicians")) l2title("Kdensity Estimator", size(medsmall)) xtitle("") ///
b2title("Share of each member type on the board", size(medsmall))

gr export "${plots}/kdensity_sh_memberstype.pdf", as(pdf) replace

*Correlations
eststo clear

eststo r1: reg floss_prim_ideam_area mayorallied if dmdn_politics!=., r
summ floss_prim_ideam_area if e(sample)==1, d
gl mean_y=round(r(mean), .01)

eststo r2: reg floss_prim_ideam_area mayorallied if dmdn_politics==1, r
eststo r3: reg floss_prim_ideam_area mayorallied if dmdn_politics==1 & director_gob_law==1, r
eststo r4: reg floss_prim_ideam_area mayorallied if dmdn_politics==1 & director_gob_law==0, r

eststo r5: reg floss_prim_ideam_area mayorallied if dmdn_politics==0, r
eststo r6: reg floss_prim_ideam_area mayorallied if dmdn_politics==0 & director_gob_law==1, r
eststo r7: reg floss_prim_ideam_area mayorallied if dmdn_politics==0 & director_gob_law==0, r

*Exporting results 
esttab r1 r2 r3 r4 r5 r6 r7 using "${tables}/corrs_floss_boards.tex", keep(mayorallied) ///
se nocons star(* 0.10 ** 0.05 *** 0.01) ///
label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
prehead(`"\begin{tabular}{@{}l*{7}{c}}"' ///
            `"\hline \toprule"'                     ///
            `" & \multicolumn{7}{c}{Primary Forest Loss (\%)} \\ \cmidrule(l){2-8}"'                   ///
            `" & All & \multicolumn{3}{c}{Politicians majority} & \multicolumn{3}{c}{Politicians minority} \\ \cmidrule(l){3-5} \cmidrule(l){6-8}"' ///
            `" &  &  & Governor is director & Governor not director &  & Governor is director & Governor not director\\"' ///			
            `" & (1) & (2) & (3) & (4) & (5) & (6) & (7) \\"'                       ///
            `" \toprule"')  ///
    postfoot(`" Dependent mean & ${mean_y} & ${mean_y} & ${mean_y} & ${mean_y} & ${mean_y} & ${mean_y} & ${mean_y} \\"' ///
	`"\bottomrule \end{tabular}"') 

coefplot (r1, label(All)) (r2, label(Majority)) (r3, label("Majority + Governor is head")) (r4, label("Majority + Governor not head")) (r5, label("Minority")), ///
keep(mayorallied) coeflabels(mayorallied = " ") ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(cols(3) size(medsmall)) /// 
b2title("Primary Forest Loss (%)", size(medsmall)) ylab(, labsize(small)) l2title("Partisan Alignment Between Mayor and Governor", size(medsmall)) ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2)

gr export "${plots}/coefplot_floss_boards.pdf", as(pdf) replace

*Calculating magnitud of deorestation
gen sh_fprim=fprim_01/area
summ fprim_01 sh_fprim floss_prim_ideam_area, d
dis (577.2514*.03)-(577.2514*.02) // around 5kms2

dis 5.7*1000000/11000

*-------------------------------------------------------------------------------
* Partisan alignment trends
*-------------------------------------------------------------------------------
sort coddane year, stable

* Sorting data set relative to when treatment happened (mayorallied)
by coddane: egen xt=max(mayorallied)
by coddane: gen dt=d.mayorallied
gen t=1 if (mayorallied==1 & year==2001) | dt==1
by coddane: replace t=t[_n-1]+1 if t==. & mayorallied==1

gsort coddane -year
gen t2=1 if t==1
by coddane: replace t2=t2[_n-1]+1 if t==. & mayorallied==0
replace t2=-(t2-2)

replace t=t2 if t==. & mayorallied==0
drop t2 dt

sort coddane year

*Creating fake time FE
tab t, g(t_)
drop t_1-t_14 
drop t_24-t_34

*Plots for when governor is head 
forval v=0/1{
	
	local var ="floss_prim_ideam_area"
	
	reghdfe `var' if director_gob_law==`v', a(i.year i.coddane) vce(robust) resid
	predict `var'_u, residuals 

	*t19 is -1  and t20 is the change
	reg `var'_u t_16 t_17 t_18 t_20 t_21 t_22 t_23 if xt==1 & director_gob_law==`v', r
	mat bf1=e(b)[1,1..3],0,e(b)[1,4..7]
	mat coln bf1= "-4" "-3" "-2" "-1" "0" "1" "2" "3"

	local label : variable label `var'

	coefplot (mat(bf1[1]), label("Party alignment")), vert yline(0, lp(dash) lc(maroon)) noci recast(connected) xline(4, lp(dash)) l2title("`label' - residuals", size(medsmall)) b2title("Relative Time to Treatment", size(small)) 
	gr export "${plots}/`var'_u_treatedtrends_mayorallied_director`v'.pdf", as(pdf) replace

	drop `var'_u
	
}
	
*Plots for when there is a majority of politicians
forval v=0/1{
	
	local var ="floss_prim_ideam_area"
	
	reghdfe `var' if dmdn_politics==`v', a(i.year i.coddane) vce(robust) resid
	predict `var'_u, residuals 

	*t19 is -1  and t20 is the change
	reg `var'_u t_16 t_17 t_18 t_20 t_21 t_22 t_23 if xt==1 & dmdn_politics==`v', r
	mat bf1=e(b)[1,1..3],0,e(b)[1,4..7]
	mat coln bf1= "-4" "-3" "-2" "-1" "0" "1" "2" "3"

	local label : variable label `var'

	coefplot (mat(bf1[1]), label("Party alignment")), vert yline(0, lp(dash) lc(maroon)) noci recast(connected) xline(4, lp(dash)) l2title("`label' - residuals", size(medsmall)) b2title("Relative Time to Treatment", size(small)) 
	gr export "${plots}/`var'_u_treatedtrends_mayorallied_politicians`v'.pdf", as(pdf) replace

	drop `var'_u
	
}

*-------------------------------------------------------------------------------
* Deforestation cycles by politicians power
*-------------------------------------------------------------------------------
cap drop *_u2

local var ="floss_prim_ideam_area"

reghdfe `var' , a(i.year i.coddane) vce(robust) resid
predict `var'_u2, residuals 

mean `var'_u2 if mayorallied==0 & year>2000 & year<2020, over(year)
mat b1=e(b)
mat coln b1 = 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19

mean `var'_u2 if mayorallied==1 & director_gob_law==1 & year>2000 & year<2020, over(year)
mat b2=e(b)
mat coln b2 = 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19

local label : variable label `var'

coefplot (mat(b1[1]), label("No Party alignment")) (mat(b2[1]), label("Party alignment + Governor is head")), vert noci recast(connected) xline(3, lp(dash)) xline(7, lp(dash)) xline(11, lp(dash)) xline(15, lp(dash)) xline(19, lp(dash))  l2title("`label' - residuals", size(medsmall)) b2title("Years", size(medsmall)) 
gr export "${plots}/floss_prim_ideam_area_u2_yeartrend_het_mayorallied.pdf", as(pdf) replace




* ONGOING WORK
use "${data}/Interim\defo_caralc.dta", clear

replace sh_politics=sh_politics2_law
summ sh_politics, d

gen diff_sh_politics= sh_politics-sh_politics2_law
egen std_diff_sh_politics= std(diff_sh_politics)
summ std_diff_sh_politics, d

gen d_crazy =(abs(std_diff_sh_politics)>1) if std_diff_sh_politics!=.
tab d_crazy

drop if d_crazy==1

*+sh_private

summ floss_prim_ideam_area_v2 , d
replace floss_prim_ideam_area_v2 = . if floss_prim_ideam_area_v2>100 & floss_prim_ideam_area_v2!=.
replace floss_prim_ideam_area_v2 = . if floss_prim_ideam_area_v2>100 & floss_prim_ideam_area_v2!=.

cap drop dmdn_politics
gen dmdn_politics=(sh_politics>=.5) if sh_politics!=.

two (scatter floss_prim_ideam_area_v2 sh_politics) (qfit floss_prim_ideam_area_v2 sh_politics)

areg director_gob_law if dmdn_politics==0, a(year) vce(cl coddane)
areg director_gob_law if dmdn_politics==1, a(year) vce(cl coddane)

areg floss_prim_ideam_area_v2 if dmdn_politics==0, a(year) vce(cl coddane)
areg floss_prim_ideam_area_v2 if dmdn_politics==1, a(year) vce(cl coddane)

areg floss_prim_ideam_area_v2 dmdn_politics director_gob_law i1.dmdn_politics#i1.director_gob_law, a(year) vce(cl coddane)


reg floss_prim_ideam_area_v2 director_gob_law if dmdn_politics!=.
ivreghdfe floss_prim_ideam_area_v2 (director_gob_law=dmdn_politics), a(year) first


ivreghdfe floss_prim_ideam_area_v2 (director_gob_law=dmdn_politics) if mayorallied==1, a(year) first
ivreghdfe floss_prim_ideam_area_v2 (director_gob_law=dmdn_politics) if mayorallied==0, a(year) first



replace floss_prim_ideam_area_v2=0 if floss_prim_ideam_area_v2==.









eststo clear

eststo s0: areg floss_prim_ideam_area_v2 if dmdn_politics==1 & director_gob_law==0, a(year) vce(robust)
eststo s1: areg floss_prim_ideam_area_v2 if dmdn_politics==1 & director_gob_law==1, a(year) vce(robust)
eststo s2: areg floss_prim_ideam_area_v2 if dmdn_politics==0 & director_gob_law==0, a(year) vce(robust)
eststo s3: areg floss_prim_ideam_area_v2 if dmdn_politics==0 & director_gob_law==1, a(year) vce(robust)

coefplot (s0, label(s0)) (s1, label(s1)) ///
 (s2, label(s2)) (s3, label(s3)), ///
vert recast(bar) ciopts(recast(rcap) lcolor("black")) citop mlabcolor("black") ///
mlabsize(medsmall) barwidth(0.3) coeflabels(_cons=" ") mlabel(string(@b, "%9.3fc")) ///
mlabposition(11) mlabgap(*2) l2title("Likelihood of choosing governor as head") 



gen diff_sh_politics= sh_politics-sh_politics_law
egen std_diff_sh_politics= std(diff_sh_politics)

gen d_crazy =(abs(diff_sh_politics)>.25) if diff_sh_politics!=.


tabstat d_crazy, by(sh_politics) s(mean sd N min max)


summ std_diff_sh_politics, d

drop if d_crazy==1


tab carcode_master if sh_politics<.3, nol 




cap drop dmdn_politics
gen dmdn_politics=(sh_politics_law>=.4) if sh_politics_law!=.


two (scatter director_gob_law sh_politics if dmdn_politics==0) (scatter director_gob_law sh_politics if dmdn_politics==1)

two (scatter floss_prim_ideam_area_v2 sh_politics_law if dmdn_politics==0) (scatter floss_prim_ideam_area_v2 sh_politics_law if dmdn_politics==1) (qfit floss_prim_ideam_area_v2 sh_politics_law)







two (scatter floss_prim_ideam_area_v2 sh_politics if dmdn_politics==0) (scatter floss_prim_ideam_area_v2 sh_politics if dmdn_politics==1)  (scatter floss_prim_ideam_area_v2 sh_politics if dmdn_politics==1 &   director_gob_law==1)  (scatter floss_prim_ideam_area_v2 sh_politics if dmdn_politics==1  & director_gob_law==0)


reg floss_prim_ideam_area_v2 sh_politics c.sh_politics#c.sh_politics


two (scatter floss_prim_ideam_area_v2 sh_politics ) (qfit floss_prim_ideam_area_v2 sh_politics )





collapse (sum) floss_prim_ideam primary_forest01 (mean) sh_politics*, by(year carcode_master)

gen floss_prim_ideam_area_v2= floss_prim_ideam*100/primary_forest01
summ floss_prim_ideam_area_v2, d


two (scatter floss_prim_ideam_area_v2 sh_politics if dmdn_politics==0) (scatter floss_prim_ideam_area_v2 sh_politics if dmdn_politics==1) (qfit floss_prim_ideam_area_v2 sh_politics)

cap drop dmdn_politics
gen dmdn_politics=(sh_politics>=.4) if sh_politics!=.

reg floss_prim_ideam_area_v2 if dmdn_politics==0 & sh_politics >.25
reg floss_prim_ideam_area_v2 if dmdn_politics==1 & sh_politics >.25









