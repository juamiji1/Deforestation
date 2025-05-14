
*-------------------------------------------------------------------------------
* Descriptives
*
*-------------------------------------------------------------------------------
use "${data}/Interim\defo_caralc.dta", clear

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

eststo s0: areg floss_prim_ideam_area_v2 if mayorallied==0, a(year) vce(cl coddane)
eststo s1: areg floss_prim_ideam_area_v2 if mayorallied==1, a(year) vce(cl coddane)

coefplot (s0, color("gs9")) (s1, color("gs4")), ///
vert recast(bar) barwidth(0.12) ciopts(recast(rcap) lcolor("black")) citop ///
mlabcolor("black") mlabsize(medsmall) coeflabels(_cons=" ") ///
mlabel(string(@b, "%9.2fc")) mlabposition(11) mlabgap(*2) ///
l2title("Primary Forest Loss (%)", size(medium)) ///
legend(on order(1 "Mayor-Governor not Aligned" 3 "Mayor-Governor Aligned"))

gr export "${plots}/desc_OLS_plot.pdf", as(pdf) replace

eststo s2: areg floss_prim_ideam_area_v2 if mayorallied==0 & director_gob_law==0, a(year) vce(cl coddane)
eststo s3: areg floss_prim_ideam_area_v2 if mayorallied==1 & director_gob_law==0, a(year) vce(cl coddane)
eststo s4: areg floss_prim_ideam_area_v2 if mayorallied==0 & director_gob_law==1, a(year) vce(cl coddane)
eststo s5: areg floss_prim_ideam_area_v2 if mayorallied==1 & director_gob_law==1, a(year) vce(cl coddane)

coefplot (s4, color("gs9")) (s5, color("gs4")) ///
(s2, color("gs9")) (s3, color("gs4")), ///
vert recast(bar) barwidth(0.12) ciopts(recast(rcap) lcolor("black")) citop ///
mlabcolor("black") mlabsize(medium) coeflabels(_cons=" ") ///
mlabel(string(@b, "%9.2fc")) mlabposition(11) mlabgap(*2) ///
l2title("Primary Forest Loss (%)", size(medium)) ///
legend(on order(1 "Mayor-Governor not Aligned" 3 "Mayor-Governor Aligned")) ///
xline(1, lc(gray) lp(dash)) ///
addplot(scatteri .14 .55 (3) "Governor as REPA Head" .14 1.05 (3) "Governor not REPA Head", mcolor(white) mlabsize(medium))

gr export "${plots}/desc_OLS_plot_bygovhead.pdf", as(pdf) replace

*-------------------------------------------------------------------------------
* Year time trends 
*-------------------------------------------------------------------------------
*All sample and Amazon (CORPORINOQUIA 27 CDA 9 CORMACARENA 14 CORPOAMAZONIA 17)
mean floss_prim_ideam_area_v2 if year>2000 & year<2021, over(year)
mat B=e(b)
mat coln B = 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20

mean floss_prim_ideam_area_v2 if year>2000 & year<2021 & inlist(carcode_master, 9, 14, 17, 27), over(year)
mat A=e(b)
mat coln A = 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20

coefplot (mat(B[1]), mcolor("gs4") label("National")) ///
(mat(A[1]), mcolor("gs8") label("Amazon")), ///
vert noci recast(connected) xline(4, lp(dash)) xline(8, lp(dash)) xline(12, lp(dash)) xline(16, lp(dash)) xline(20, lp(dash)) l2title("Primary Forest Loss (%)", size(medium)) b2title("Years", size(medium)) addplot(scatteri .2 12 .2 13 .2 14 .2 15 .2 16, recast(area) color(gs5%20) lcolor(white) base(0.05)) plotregion(margin(zero))

gr export "${plots}/desc_all_yearly_trend.pdf", as(pdf) replace

*Governor head or not
mean floss_prim_ideam_area_v2 if mayorallied==0 & year>2000 & year<2021, over(year)
mat b0=e(b)
mat coln b0 = 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20

mean floss_prim_ideam_area_v2 if mayorallied==1 & year>2000 & year<2021, over(year)
mat b1=e(b)
mat coln b1 = 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20

coefplot (mat(b0[1]), label("Mayor-Governor not Aligned") mcolor("gs9")) (mat(b1[1]), label("Mayor-Governor Aligned") color("gs4")), vert noci recast(connected) xline(4, lp(dash)) xline(8, lp(dash)) xline(12, lp(dash)) xline(16, lp(dash)) xline(20, lp(dash)) l2title("Primary Forest Loss (%)", size(medium)) b2title("Years", size(medium)) addplot(scatteri .25 12 .25 13 .25 14 .25 15 .25 16, recast(area) color(gs5%20) lcolor(white) base(0.03)) plotregion(margin(zero))

gr export "${plots}/desc_all_yearly_trend_bygovhead.pdf", as(pdf) replace

*-------------------------------------------------------------------------------
* Partisan alignment trends
*-------------------------------------------------------------------------------
sort coddane year, stable

* Sorting data set relative to when treatment happened (mayorallied)
by coddane: egen xt=max(mayorallied)
by coddane: gen dt=d.mayorallied

*Creating fake time FE
gen t=1 if (mayorallied==1 & year==2001) |dt==1
by coddane: replace t=t[_n-1]+1 if t==. & mayorallied==1

gsort coddane -year
gen t2=1 if t==1
by coddane: replace t2=t2[_n-1]+1 if t==. & mayorallied==0
replace t2=-(t2-2)

replace t=t2 if t==. & mayorallied==0
drop t2 dt

*Keeping the sample that I want so it is a fully saturated
drop if (t<-4 | t>3) 
drop if xt!=1
tab t, g(t_)

*Governor is head 
areg floss_prim_ideam_area_v2 t_1 t_2 t_3 t_5 t_6 t_7 t_8 if director_gob_law==1 & carcode_master!=33 & carcode_master!=27, r abs(year)
mat bf1=e(b)[1,1..3],0,e(b)[1,4..7]
mat coln bf1= "-4" "-3" "-2" "-1" "0" "1" "2" "3"
coefplot (mat(bf1[1])), vert yline(0, lp(dash) lc(maroon)) noci recast(connected) xline(4, lp(dash)) l2title("Primary Forest Loss (%)", size(medium)) b2title("Relative Time to Mayor-Governor Alignment", size(medium)) 

gr export "${plots}/desc_relativetime_govhead.pdf", as(pdf) replace

*Governor not head 
areg floss_prim_ideam_area_v2 t_1 t_2 t_3 t_5 t_6 t_7 t_8 if director_gob_law==0 & carcode_master!=33 & carcode_master!=27, r abs(year)

mat bf1=e(b)[1,1..3],0,e(b)[1,4..7]
mat coln bf1= "-4" "-3" "-2" "-1" "0" "1" "2" "3"
coefplot (mat(bf1[1])), vert yline(0, lp(dash) lc(maroon)) noci recast(connected) xline(4, lp(dash)) l2title("Primary Forest Loss (%)", size(medium)) b2title("Relative Time to Mayor-Governor Alignment", size(medium)) 

gr export "${plots}/desc_relativetime_govnothead.pdf", as(pdf) replace


*END