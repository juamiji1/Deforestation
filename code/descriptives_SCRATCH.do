use "${data}/Interim\defo_caralc.dta", clear

summ floss_prim_ideam_area_v2 , d
replace floss_prim_ideam_area_v2 = . if floss_prim_ideam_area_v2>100 & floss_prim_ideam_area_v2!=.

replace sh_politics=sh_politics2_law
summ sh_politics, d

cap drop dmdn_politics
gen dmdn_politics=(sh_politics>=.5) if sh_politics!=.

summ sh_sameparty_gov, d
gen d_sameparty_gov=(sh_sameparty_gov>=.1) if sh_sameparty_gov!=.
gen d_sameparty_gov2=(sh_sameparty_gov2>=.2) if sh_sameparty_gov2!=.


END

eststo clear

mat C=J(4,5,.)
mat coln C= "All" "Governor is head" "Governor not head" "Gov head + pols her party" "Gov head + pols not her party"

eststo s0: reghdfe floss_prim_ideam_area_v2 dmdn_politics, abs(year) vce(cl coddane)
lincom dmdn_politics
mat C[1,1]= r(estimate) 
mat C[2,1]= r(lb)
mat C[3,1]= r(ub)
mat C[4,1]= r(p)

eststo s1: reghdfe floss_prim_ideam_area_v2 dmdn_politics if director_gob_law==1, abs(year) vce(cl coddane)
lincom dmdn_politics
mat C[1,2]= r(estimate) 
mat C[2,2]= r(lb)
mat C[3,2]= r(ub)
mat C[4,2]= r(p)

eststo s2: reghdfe floss_prim_ideam_area_v2 dmdn_politics if director_gob_law==0, abs(year) vce(cl coddane)
lincom dmdn_politics
mat C[1,3]= r(estimate) 
mat C[2,3]= r(lb)
mat C[3,3]= r(ub)
mat C[4,3]= r(p)

eststo s3: reghdfe floss_prim_ideam_area_v2 dmdn_politics if d_sameparty_gov==1 & director_gob_law==1, abs(year) vce(cl coddane)
lincom dmdn_politics
mat C[1,4]= r(estimate) 
mat C[2,4]= r(lb)
mat C[3,4]= r(ub)
mat C[4,4]= r(p)

eststo s4: reghdfe floss_prim_ideam_area_v2 dmdn_politics if d_sameparty_gov==0 & director_gob_law==1, abs(year) vce(cl coddane)
lincom dmdn_politics
mat C[1,5]= r(estimate) 
mat C[2,5]= r(lb)
mat C[3,5]= r(ub)
mat C[4,5]= r(p)

coefplot (mat(C[1]), ci((2 3)) aux(4)), xline(0, lp(dash) lc("maroon")) b2title("Effect of Politicians Majority in REPA's Board on Deforestation (%)", size(small)) ciopts(recast(rcap)) ylab(, labsize(small)) ///
mlabel(cond(@aux1<=.01, string(@b, "%9.2fc") +"***", cond(@aux1<=.05, string(@b, "%9.2fc") +"**", cond(@aux1<=.1, string(@b, "%9.2fc") +"*", string(@b, "%9.2fc"))))) mlabposition(12) mlabgap(*2)


eststo clear

mat C=J(4,4,.)
mat coln C= " . + pols her party + mayor aligned" ". + pols her party + mayor not aligned" " . + pols not her party + mayor aligned" ". + pols not her party + mayor not aligned"

eststo s5: reghdfe floss_prim_ideam_area_v2 dmdn_politics if d_sameparty_gov==1 & director_gob_law==1 & mayorallied==1, abs(year) vce(robust)
lincom dmdn_politics
mat C[1,1]= r(estimate) 
mat C[2,1]= r(lb)
mat C[3,1]= r(ub)
mat C[4,1]= r(p)

eststo s6: reghdfe floss_prim_ideam_area_v2 dmdn_politics if d_sameparty_gov==1 & director_gob_law==1 & mayorallied==0, abs(year) vce(robust)
lincom dmdn_politics
mat C[1,2]= r(estimate) 
mat C[2,2]= r(lb)
mat C[3,2]= r(ub)
mat C[4,2]= r(p)

eststo s7: reghdfe floss_prim_ideam_area_v2 dmdn_politics if d_sameparty_gov==0 & director_gob_law==1 & mayorallied==1, abs(year) vce(robust)
lincom dmdn_politics
mat C[1,3]= r(estimate) 
mat C[2,3]= r(lb)
mat C[3,3]= r(ub)
mat C[4,3]= r(p)

eststo s8: reghdfe floss_prim_ideam_area_v2 dmdn_politics if d_sameparty_gov==0 & director_gob_law==1 & mayorallied==0, abs(year) vce(robust)
lincom dmdn_politics
mat C[1,4]= r(estimate) 
mat C[2,4]= r(lb)
mat C[3,4]= r(ub)
mat C[4,4]= r(p)

coefplot (mat(C[1]), ci((2 3)) aux(4)), xline(0, lp(dash) lc("maroon")) b2title("Effect of Politicians Majority in REPA's Board on Deforestation (%)", size(small)) ciopts(recast(rcap)) ylab(, labsize(small)) ///
mlabel(cond(@aux1<=.01, string(@b, "%9.2fc") +"***", cond(@aux1<=.05, string(@b, "%9.2fc") +"**", cond(@aux1<=.1, string(@b, "%9.2fc") +"*", string(@b, "%9.2fc"))))) mlabposition(12) mlabgap(*2)



eststo clear

mat C=J(4,4,.)
mat coln C= "Gov head + mayor aligned" "Gov head + mayor not aligned" " Gov not head + mayor aligned" "Gov not head + mayor not aligned"

eststo s5: reghdfe floss_prim_ideam_area_v2 dmdn_politics if director_gob_law==1 & mayorallied==1, abs(year) vce(cl coddane)
lincom dmdn_politics
mat C[1,1]= r(estimate) 
mat C[2,1]= r(lb)
mat C[3,1]= r(ub)
mat C[4,1]= r(p)

eststo s6: reghdfe floss_prim_ideam_area_v2 dmdn_politics if director_gob_law==1 & mayorallied==0, abs(year) vce(cl coddane)
lincom dmdn_politics
mat C[1,2]= r(estimate) 
mat C[2,2]= r(lb)
mat C[3,2]= r(ub)
mat C[4,2]= r(p)

eststo s7: reghdfe floss_prim_ideam_area_v2 dmdn_politics if director_gob_law==0 & mayorallied==1, abs(year) vce(cl coddane)
lincom dmdn_politics
mat C[1,3]= r(estimate) 
mat C[2,3]= r(lb)
mat C[3,3]= r(ub)
mat C[4,3]= r(p)

eststo s8: reghdfe floss_prim_ideam_area_v2 dmdn_politics if director_gob_law==0 & mayorallied==0, abs(year) vce(cl coddane)
lincom dmdn_politics
mat C[1,4]= r(estimate) 
mat C[2,4]= r(lb)
mat C[3,4]= r(ub)
mat C[4,4]= r(p)

coefplot (mat(C[1]), ci((2 3)) aux(4)), xline(0, lp(dash) lc("maroon")) b2title("Effect of Politicians Majority in REPA's Board on Deforestation (%)", size(small)) ciopts(recast(rcap)) ylab(, labsize(small)) ///
mlabel(cond(@aux1<=.01, string(@b, "%9.2fc") +"***", cond(@aux1<=.05, string(@b, "%9.2fc") +"**", cond(@aux1<=.1, string(@b, "%9.2fc") +"*", string(@b, "%9.2fc"))))) mlabposition(12) mlabgap(*2)



reghdfe floss_prim_ideam_area_v2 d_sameparty_gov dmdn_politics 1.d_sameparty_gov#1.dmdn_politics, abs(year) vce(cl coddane)
reghdfe floss_prim_ideam_area_v2 d_sameparty_gov2 dmdn_politics 1.d_sameparty_gov2#1.dmdn_politics, abs(year) vce(cl coddane)


reghdfe floss_prim_ideam_area_v2 d_sameparty_gov dmdn_politics 1.d_sameparty_gov#1.dmdn_politics, abs(year coddane) vce(cl coddane)
reghdfe floss_prim_ideam_area_v2 d_sameparty_gov2 dmdn_politics 1.d_sameparty_gov2#1.dmdn_politics, abs(year coddane) vce(cl coddane)


reghdfe floss_prim_ideam_area_v2 d_sameparty_gov, abs(year coddane) vce(cl coddane)
reghdfe floss_prim_ideam_area_v2 d_sameparty_gov2, abs(year coddane) vce(cl coddane)


hist sh_politics2_law, freq

rdrobust floss_prim_ideam_area_v2 sh_politics2_law, c(.5)

reghdfe floss_prim_ideam_area_v2 dmdn_politics if abs(sh_politics2_law-.5)<=.04

summ sh_politics2_law if e(sample)==1 & sh_politics2_law<.5

tab carcode_master if e(sample)==1 & sh_politics2_law<.5

summ sh_politics2_law if e(sample)==1 & sh_politics2_law>=.5

tab carcode_master if e(sample)==1 & sh_politics2_law>=.5




