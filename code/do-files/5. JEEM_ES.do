*log using "C:\Users\p70089193\OneDrive - United Nations University\RP\Project Deforestation\Logs stata\ES_29may.log", replace
/*Event Study Specification
Lizeth Molina
29 May
Note: Correr por secciones, tener en cuenta cuando se debe abrir la base original or restart Stata. 
*/

{/*1. YEARLY */

*use "C:\Users\p70089193\OneDrive - United Nations University\RP\Project Deforestation\Database\defo_caralc.dta", clear
use "${data}\defo_caralc.dta", clear 

*drop if carcode_master==27 | carcode_master==33 /* CORANTIOQUIA*/


gen ANM=1 if inlist(coddane, 91430, 91405, 88001,94884, 91536, 91263, 91798, 91460, 94888, 97889, 97777, 94886, 94887, 91530, 91407, 94885, 91669, 94883, 97511, 94343)
drop if inlist(coddane, 91430, 91405, 88001,94884, 91536, 91263, 91798, 91460, 94888, 97889, 97777, 94886, 94887, 91530, 91407, 94885, 91669, 94883, 97511, 94343)
*replace mayorallied=1 if mayorallied==0 & inlist(coddane, 91430, 91405, 88001,94884, 91536, 91263, 91798, 91460, 94888, 97889, 97777, 94886, 94887, 91530, 91407, 94885, 91669, 94883, 97511, 94343)

{ /*1.ES Defo por Yearly */
/*Los resultados se replican cuando se corre todo el bloque 1. incluyendo el triming para el estimador de Chaisemartin*/

br coddane year mayorallied
sort coddane year
* Step 1: Identify first treatment year per state (only among treated states)
	cap drop treat*
	sort coddane year
	bys coddane: gen treat1=_n if mayorallied==1
	bys coddane: egen treat_t=min(treat1)
	gen treat_fg=year if treat1==treat_t & treat1!=.
	bys coddane: egen first_ytreat=total(treat_fg)
	replace first_ytreat=. if first_ytreat==0
	cap drop treat*
* Step 2: Create event_time +1 -Chaisemartin where l=0 is pretreat 
	cap drop event_time
	gen event_time=year-first_ytreat+1 
	
*TWFE
	reghdfe floss_prim_ideam_area_v2 mayorallied, a(coddane year) vce(cl coddane)
	reghdfe floss_prim_ideam_area_v2 mayorallied if director_gob_law==1 , a(coddane year) vce(cl coddane)
		reghdfe floss_prim_ideam_area_v2 mayorallied if director_gob_law==1 , a(coddane year) vce(rob)

	reghdfe floss_prim_ideam_area_v2 mayorallied if director_gob_law==0 , a(coddane year) vce(cl coddane)
	outreg2 using "${localpath}\Tables\TWFE.tex", tex(frag) keep(mayorallied) addtext("Year FE", "Yes", "Muni FE", "Yes" ) label nonote nocons replace
	*addstat("Dependent mean", ${mean_y}) 

*Triming
/*0 means-no alieneado*/
	keep if inrange(event_time,-3,4) | event_time==.
	*14.544 obs
		tab event_time, mis
		gen le3= event_time==-3 
		gen le2= event_time==-2 
		gen le1= event_time==-1
		gen le0= event_time==0 
		gen la1= event_time==1 
		gen la2= event_time==2 
		gen la3= event_time==3 
		gen la4= event_time==4 

	sort  coddane year
	reghdfe floss_prim_ideam_area_v2  le3 le2 le1 la1 la2 la3 la4, absorb(coddane year) vce(cluster coddane)  
	*cluster(carcode_master)
	*GRAPH 
	/*Missing -never treated*/
	recode event_time (.=0)
	/*Crea grupos por periodo de tiempo, q son positivos para la grafica, por ej. todos los -2 son grupo 1*/
		egen event_time_nn = group(event_time)
		
		// taking the value of l_nn for whom my relative time was -1
		/*{*/sum event_time_nn if event_time==0
		reghdfe floss_prim_ideam_area_v2 ib`r(mean)'.event_time_nn, absorb(coddane year) vce(cluster coddane)
		est store e1
			sum event_time_nn if event_time==0
		reghdfe floss_prim_ideam_area_v2 ib`r(mean)'.event_time_nn if director_gob_law==1, absorb(coddane year) vce(cluster coddane) 
		est store e2
				sum event_time_nn if event_time==0
		reghdfe floss_prim_ideam_area_v2 ib`r(mean)'.event_time_nn if director_gob_law==0, absorb(coddane year) vce(cluster coddane) 
		est store e3
		/*}*/

		// taking the value of l_nn to place a red dashed line
		sum event_time_nn if event_time==1
		local line = `r(mean)'-.5
		coefplot (e1, ci baselevels yline(0) omitted ///
					msymbol(o) mcolor(blue%70) ///
					recast(scatter) levels(95) ///
					recast(connected) /// 
					ciopts(recast(rcap) lcolor(grey%70) lpattern(solid) lwidth(thin))) ///
					, drop(_cons)  ///
					vertical 	xline(`line', lcolor(red%40) lpattern(dash))  ///
					byopts(yrescale)graphregion(color(white))		///		
					xlabel(1 "-3 " 2 "-2"	3 "-1 " 4 "0" 5 "1"  ///
					6 "2" 7 "3" 8 "4" ///
					, labsize(small) angle(90)) name(twfe1, replace) xtitle (Relative time to last period before treatment changes (t=0))
					
					*legend(order(2 "Deforestation") ring(0) pos(4) col(1)) 
			
		gr export "${localpath}\Graps\ES.pdf", as(pdf) replace	
					
		sum event_time_nn if event_time==1			
		local line = `r(mean)'-.5
		coefplot (e2, ci baselevels yline(0) omitted ///
					msymbol(o) mcolor(blue%70) ///
					recast(scatter) levels(95) ///
					recast(connected) /// 
					ciopts(recast(rcap) lcolor(grey%70) lpattern(solid) lwidth(thin))) ///
					, drop(_cons)  ///
					vertical 	xline(`line', lcolor(red%40) lpattern(dash))  ///
					byopts(yrescale)graphregion(color(white))		///		
					xlabel(1 "-3 " 2 "-2"	3 "-1 " 4 "0" 5 "1"  ///
					6 "2" 7 "3" 8 "4" ///
					, labsize(small) angle(90)) name(twfe1, replace) xtitle (Relative time to last period before treatment changes (t=0))
					
					*legend(order(2 "Deforestation") ring(0) pos(4) col(1)) 
			
		gr export "${localpath}\Graps\ES_gobDir.pdf", as(pdf) replace	
		
		sum event_time_nn if event_time==1			
		local line = `r(mean)'-.5
		coefplot (e3, ci baselevels yline(0) omitted ///
					msymbol(o) mcolor(blue%70) ///
					recast(scatter) levels(95) ///
					recast(connected) /// 
					ciopts(recast(rcap) lcolor(grey%70) lpattern(solid) lwidth(thin))) ///
					, drop(_cons)  ///
					vertical 	xline(`line', lcolor(red%40) lpattern(dash))  ///
					byopts(yrescale)graphregion(color(white))		///		
					xlabel(1 "-3 " 2 "-2"	3 "-1 " 4 "0" 5 "1"  ///
					6 "2" 7 "3" 8 "4" ///
					, labsize(small) angle(90)) name(twfe1, replace) xtitle (Relative time to last period before treatment changes (t=0))
					
					*legend(order(2 "Deforestation") ring(0) pos(4) col(1)) 
			
		gr export "${localpath}\Graps\ES_gobnoDir.pdf", as(pdf) replace	
		
					

}

{ /*1. ES-Chaisemartin: year*/
tab event_time
*14.544

set scheme s2mono
grstyle init
grstyle title color black
grstyle color background white
grstyle color major_grid dimgray

did_multiplegt_dyn floss_prim_ideam_area_v2 coddane year  mayorallied, effects(4) placebo(3) cluster(coddane)   graphoptions(title() xtitle(Relative time to last period before treatment changes (t=0)) legend(off) xlabel(1 "" 2 "-3" 3 "-2" 4 "-1"))

outreg2 using "${localpath}\Tables\ES_Chaisemartin.tex", dec(3) replace 

gr export "${localpath}\Graps\ES_Chaisemartin_p.pdf", as(pdf) replace

*did_multiplegt_dyn floss_prim_ideam_area_v2 coddane year  mayorallied, effects(4) cluster(coddane)  normalized normalized_weights same_switchers effects_equal

did_multiplegt_dyn floss_prim_ideam_area_v2  coddane year  mayorallied if director_gob_law==1, effects(4) placebo(3) cluster(coddane)  graphoptions(title() xtitle(Relative time to last period before treatment changes (t=0)) legend(off) xlabel(1 "" 2 "-3" 3 "-2" 4 "-1"))

outreg2 using "${localpath}\Tables\ES_Chaisemartin.tex", dec(3) append

gr export "${localpath}\Graps\ES_Chaisemartin_gobDir.pdf", as(pdf) replace

did_multiplegt_dyn floss_prim_ideam_area_v2  coddane year  mayorallied if director_gob_law==0, effects(4) placebo(3) cluster(coddane)  graphoptions(title() xtitle(Relative time to last period before treatment changes (t=0)) legend(off) xlabel(1 "" 2 "-3" 3 "-2" 4 "-1"))

outreg2 using "${localpath}\Tables\ES_Chaisemartin.tex", dec(3) append

gr export "${localpath}\Graps\ES_Chaisemartin_gobnoDir.pdf", as(pdf) replace

*did_multiplegt_dyn floss_prim_ideam_area_v2 coddane year  mayorallied if director_gob_law==1, effects(4) cluster(coddane)  normalized normalized_weights same_switchers effects_equal

}

/*The triming base is used for the ES and Chaisemartin stimations*/
}


{/*2. Political cycle */
clear all

use "${data}\defo_caralc.dta", clear

*drop if carcode_master==27 | carcode_master==33 /* CORANTIOQUIA*/


gen ANM=1 if inlist(coddane, 91430, 91405, 88001,94884, 91536, 91263, 91798, 91460, 94888, 97889, 97777, 94886, 94887, 91530, 91407, 94885, 91669, 94883, 97511, 94343)
drop if inlist(coddane, 91430, 91405, 88001,94884, 91536, 91263, 91798, 91460, 94888, 97889, 97777, 94886, 94887, 91530, 91407, 94885, 91669, 94883, 97511, 94343)
*replace mayorallied=1 if mayorallied==0 & inlist(coddane, 91430, 91405, 88001,94884, 91536, 91263, 91798, 91460, 94888, 97889, 97777, 94886, 94887, 91530, 91407, 94885, 91669, 94883, 97511, 94343)


br coddane year mayorallied
sort coddane year

* Step 1: Create political period

	cap drop political_period
	gen political_period=1 if year>=2001 & year<=2003
	replace political_period=2 if year>=2004 & year<=2007
	replace political_period=3 if year>=2008 & year<=2011
	replace political_period=4 if year>=2012 & year<=2015
	replace political_period=5 if year>=2016 & year<=2019
	*No se tiene en cuenta 2020 porque solo se cuenta con un año

	*Se saca el total pero el comando aut pone cero cuando son missing, entonces se remplaza 
	bys coddane political_period: egen floss_prim_ideam_area_v2_pp=total(floss_prim_ideam_area_v2)
	replace floss_prim_ideam_area_v2_pp=. if floss_prim_ideam_area_v2==.

* Step 2. Collapse

	*collapse floss_prim_ideam_area_v2 floss_prim_ideam_area_v2_pp  mayorallied director_gob_law ,by(coddane political_period)
	collapse floss_prim_ideam_area_v2 (mean) floss_prim_ideam_area_v2_pp   (mean) mayorallied (mean) director_gob_law (mean) z_sh_votes_alc codigo_partido_alc ,by(coddane political_period)
	drop if political_period==.
	drop floss_prim_ideam_area_v2
	rename floss_prim_ideam_area_v2_pp floss_prim_ideam_area_v2
	rename political_period year 

* Step 3: Identify first treatment year per state (only among treated states)
	cap drop treat*
	sort coddane year
	bys coddane: gen treat1=_n if mayorallied==1
	bys coddane: egen treat_t=min(treat1)
	gen treat_fg=year if treat1==treat_t & treat1!=.
	bys coddane: egen first_ytreat=total(treat_fg)
	replace first_ytreat=. if first_ytreat==0
	cap drop treat*
* Step 4: Create event_time +1 -Chaisemartin where l=0 is pretreat 
	cap drop event_time
	gen event_time=year-first_ytreat+1 

* Step 5. Triming

	keep if inrange(event_time,-2,2) | event_time==.
		tab event_time, mis

		gen le2= event_time==-2 
		gen le1= event_time==-1
		gen le0= event_time==0 
		gen la1= event_time==1 
		gen la2= event_time==2 

*4440 Obs
{/* 2.1. ES-TWFE: political cycle***/


	reghdfe floss_prim_ideam_area_v2   le2 le1 la1 la2 , absorb(coddane year) vce(cluster coddane)


	*GRAPH 
	recode event_time (.=0)
		egen event_time_nn = group(event_time)
		
		// taking the value of l_nn for whom my relative time was 0
		/*{*/sum event_time_nn if event_time==0
		reghdfe floss_prim_ideam_area_v2 ib`r(mean)'.event_time_nn, absorb(coddane year) vce(cluster coddane)
		est store e1
		
		sum event_time_nn if event_time==0
		reghdfe floss_prim_ideam_area_v2 ib`r(mean)'.event_time_nn if director_gob_law==1, absorb(coddane year) vce(cluster coddane)
		est store e2
		
		sum event_time_nn if event_time==0
		reghdfe floss_prim_ideam_area_v2 ib`r(mean)'.event_time_nn if director_gob_law==0, absorb(coddane year) vce(cluster coddane)
		est store e3
		/*}*/

		// taking the value of l_nn to place a red dashed line
		sum event_time_nn if event_time==1
		local line = `r(mean)'-.5
		coefplot (e1, ci baselevels yline(0) omitted ///
					msymbol(o) mcolor(blue%70) ///
					recast(scatter) levels(95) ///
					recast(connected) /// 
					ciopts(recast(rcap) lcolor(grey%70) lpattern(solid) lwidth(thin))) ///
					, drop(_cons)  ///
					vertical 	xline(`line', lcolor(red%40) lpattern(dash))  ///
					byopts(yrescale)graphregion(color(white))		///		
					xlabel(1 "-2 " 2 "-1"	3 "0 " 4 "1" 5 "2"  ///	
					, labsize(small) angle(90)) name(twfe1, replace) xtitle (Relative time to last period before treatment changes (t=0))
					
					*legend(order(2 "Deforestation") ring(0) pos(4) col(1)) 
			
		gr export "${localpath}\Graps\ES_term.pdf", as(pdf) replace	
			
			
					
		sum event_time_nn if event_time==1
		local line = `r(mean)'-.5
		coefplot (e2, ci baselevels yline(0) omitted ///
					msymbol(o) mcolor(blue%70) ///
					recast(scatter) levels(95) ///
					recast(connected) /// 
					ciopts(recast(rcap) lcolor(grey%70) lpattern(solid) lwidth(thin))) ///
					, drop(_cons)  ///
					vertical 	xline(`line', lcolor(red%40) lpattern(dash))  ///
					byopts(yrescale)graphregion(color(white))		///		
					xlabel(1 "-2 " 2 "-1"	3 "0 " 4 "1" 5 "2"  ///
					, labsize(small) angle(90)) name(twfe1, replace) xtitle (Relative time to last period before treatment changes (t=0))
		
		gr export "${localpath}\Graps\ES_term_gobDir.pdf", as(pdf) replace	
		
		sum event_time_nn if event_time==1
		local line = `r(mean)'-.5
		coefplot (e3, ci baselevels yline(0) omitted ///
					msymbol(o) mcolor(blue%70) ///
					recast(scatter) levels(95) ///
					recast(connected) /// 
					ciopts(recast(rcap) lcolor(grey%70) lpattern(solid) lwidth(thin))) ///
					, drop(_cons)  ///
					vertical 	xline(`line', lcolor(red%40) lpattern(dash))  ///
					byopts(yrescale)graphregion(color(white))		///		
					xlabel(1 "-2 " 2 "-1"	3 "0 " 4 "1" 5 "2"  ///
					, labsize(small) angle(90)) name(twfe1, replace) xtitle (Relative time to last period before treatment changes (t=0))
		
		gr export "${localpath}\Graps\ES_term_gobnoDir.pdf", as(pdf) replace	
					

}

{/* 2.2. ES-Chaisemartin: political cycle*/


did_multiplegt_dyn floss_prim_ideam_area_v2  coddane  year  mayorallied, effects(2) placebo(2) cluster(coddane) graphoptions(title() xtitle(Relative time to last period before treatment changes (t=0)) legend(off))  


gr export "${localpath}\Graps\ES_Chaisemartin_term.pdf", as(pdf) replace

did_multiplegt_dyn floss_prim_ideam_area_v2  coddane  year mayorallied if director_gob_law==1, effects(2) placebo(2) cluster(coddane) graphoptions(title() xtitle(Relative time to last period before treatment changes (t=0)) legend(off))

gr export "${localpath}\Graps\ES_Chaisemartin_gobDir_term.pdf", as(pdf) replace

did_multiplegt_dyn floss_prim_ideam_area_v2  coddane  year mayorallied if director_gob_law==0, effects(2) placebo(2) cluster(coddane) graphoptions(title() xtitle(Relative time to last period before treatment changes (t=0)) legend(off))

gr export "${localpath}\Graps\ES_Chaisemartin_gobnoDir_term.pdf", as(pdf) replace


*save_results(C:\Users\p70089193\OneDrive - United Nations University\RP\Project Deforestation\Tables\ES_Chaisemartin_term.tex)



/*esttab r1  using "C:\Users\p70089193\OneDrive - United Nations University\RP\Project Deforestation\Tables\ES_Chaisemartin_term.tex", keep(mayorallied) ///
se nocons star(* 0.10 ** 0.05 *** 0.01) ///
label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
prehead(`"\begin{tabular}{@{}l*{3}{c}}"' ///
            `"\hline \toprule"'                     ///
            `" & \multicolumn{3}{c}{Primary Forest Loss (\%)} \\ \cmidrule(l){2-4}"'                   ///
            `" & All & Governor is head & Governor not head \\"' ///
            `" & (1) & (2) & (3) \\"'                       ///
            `" \toprule"')  ///
    postfoot(`" Dependent mean & ${mean_y1} & ${mean_y2} & ${mean_y3} \\"' ///
	`" & & &  \\"' ///
	`" Bandwidth & ${ht} & ${ht} & ${ht} \\"' ///
	`" Polynomial & ${p} & ${p} & ${p} \\"' ///
	`" Kernel & ${k} & ${k} & ${k} \\"' ///
	`"\bottomrule \end{tabular}"') 
*/

}

}


{/*3. Event Study over the RD sample*/

clear all

use "${data}\defo_caralc.dta", clear

*drop if carcode_master==27 | carcode_master==33 /* CORANTIOQUIA*/


gen ANM=1 if inlist(coddane, 91430, 91405, 88001,94884, 91536, 91263, 91798, 91460, 94888, 97889, 97777, 94886, 94887, 91530, 91407, 94885, 91669, 94883, 97511, 94343)
drop if inlist(coddane, 91430, 91405, 88001,94884, 91536, 91263, 91798, 91460, 94888, 97889, 97777, 94886, 94887, 91530, 91407, 94885, 91669, 94883, 97511, 94343)
*replace mayorallied=1 if mayorallied==0 & inlist(coddane, 91430, 91405, 88001,94884, 91536, 91263, 91798, 91460, 94888, 97889, 97777, 94886, 94887, 91530, 91407, 94885, 91669, 94883, 97511, 94343)

*-------------------------------------------------------------------------------
* Main Results
*
*-------------------------------------------------------------------------------
summ z_sh_votes_alc, d

rdrobust floss_prim_ideam_area_v2 z_sh_votes_alc, all kernel(triangular)
gl h = e(h_l)
gl ht= round(${h}, .001)
gl p = e(p)
gl k = e(kernel)
gl if "if abs(z_sh_votes_alc)<=${h}"
gl controls "mayorallied i.mayorallied#c.z_sh_votes_alc z_sh_votes_alc"

cap drop tweights
gen tweights=(1-abs(z_sh_votes_alc/${h})) ${if}

eststo clear

*All municipalities 

eststo r1: reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law!=., abs(year) vce(robust)
gen base_RD=e(sample)
summ floss_prim_ideam_area if e(sample)==1, d
summ floss_prim_ideam_area if base_RD==1, d
*gl mean_y1=round(r(mean), .01)

br floss_prim_ideam_area_v2  coddane year  mayorallied   director_gob_law base_RD   if e(sample)==1


*Municipalities under a CAR in which Gobernor is mandated as director 
eststo r2: reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law==1, abs(year) vce(robust)
gen base_RD_gobDir=e(sample)


*Municipalities under a CAR in which Gobernor is NOT mandated as director 
eststo r3: reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law==0, abs(year) vce(robust)
gen base_RD_gobnoDir=e(sample)

save "${data}\defo_caralc_ES_rd.dta",replace

/*Cerrar el stata*/
clear all
use "${data}\\defo_caralc_ES_rd.dta", clear 
*22.040 obs
br  coddane year  mayorallied floss_prim_ideam_area_v2 base*


/*Tome el valor del año +x*/
foreach var of varlist base_RD base_RD_gobDir base_RD_gobnoDir{
	sort coddane year
	gen `var'_e = 0
bys coddane (year): gen lead1 = `var'[_n+1]
bys coddane (year): gen lead2 = `var'[_n+2]
bys coddane (year): gen lead3 = `var'[_n+3]
bys coddane (year): gen lead4 = `var'[_n+4]

replace `var'_e = 1 if lead1==1 | lead2==1 | lead3==1 | lead4==1
drop lead*
replace `var'_e=1 if `var'==1
}
br  coddane year  mayorallied floss_prim_ideam_area_v2 base*
/*Si entra y sale de tratamiento, entonces se pueden traslpar los periodos antes y despues*/


did_multiplegt_dyn floss_prim_ideam_area_v2  coddane year  mayorallied if base_RD_e==1, effects(4) placebo(3) cluster(coddane)  graphoptions(title() xtitle(Relative time to last period before treatment changes (t=0)) legend(off) xlabel(1 "" 2 "-3" 3 "-2" 4 "-1"))
gr export "${localpath}\Graps\ES_Chaisemartin_gobDir_rd.pdf", as(pdf) replace
outreg2 using "${localpath}\Tables\ES_Chaisemartin_rd.tex", dec(3) replace

did_multiplegt_dyn floss_prim_ideam_area_v2  coddane  year mayorallied if director_gob_law==1 & base_RD_gobDir_e==1, effects(4) placebo(3) cluster(coddane) graphoptions(title() xtitle(Relative time to last period before treatment changes (t=0)) legend(off))

gr export "${localpath}\Graps\ES_Chaisemartin_gobDir_rd.pdf", as(pdf) replace
outreg2 using "${localpath}\Tables\ES_Chaisemartin_rd.tex", dec(3) append

did_multiplegt_dyn floss_prim_ideam_area_v2  coddane  year mayorallied if director_gob_law==0 & base_RD_gobnoDir_e==1, effects(4) placebo(3) cluster(coddane) graphoptions(title() xtitle(Relative time to last period before treatment changes (t=0)) legend(off))

gr export "${localpath}\Graps\ES_Chaisemartin_gobnoDir_rd.pdf", as(pdf) replace
outreg2 using "${localpath}\Tables\ES_Chaisemartin_rd.tex", dec(3) append

}


{/*4. Incumbency TWFE-No se ha usado*/

use "${data}\defo_caralc.dta", clear

*drop if carcode_master==27 | carcode_master==33 /* CORANTIOQUIA*/


gen ANM=1 if inlist(coddane, 91430, 91405, 88001,94884, 91536, 91263, 91798, 91460, 94888, 97889, 97777, 94886, 94887, 91530, 91407, 94885, 91669, 94883, 97511, 94343)
drop if inlist(coddane, 91430, 91405, 88001,94884, 91536, 91263, 91798, 91460, 94888, 97889, 97777, 94886, 94887, 91530, 91407, 94885, 91669, 94883, 97511, 94343)
*replace mayorallied=1 if mayorallied==0 & inlist(coddane, 91430, 91405, 88001,94884, 91536, 91263, 91798, 91460, 94888, 97889, 97777, 94886, 94887, 91530, 91407, 94885, 91669, 94883, 97511, 94343)




/*ES-Defo por political cycle*/
cap drop political_period
gen political_period=1 if year>=2001 & year<=2003
replace political_period=2 if year>=2004 & year<=2007
replace political_period=3 if year>=2008 & year<=2011
replace political_period=4 if year>=2012 & year<=2015
replace political_period=5 if year>=2016 & year<=2019
*No se tiene en cuenta 2020 porque solo se cuenta con un año
bys coddane political_period: egen floss_prim_ideam_area_v2_pp=total(floss_prim_ideam_area_v2)


collapse (sum) floss_prim_ideam_area_v2   (mean) mayorallied (mean) director_gob_law (mean) z_sh_votes_alc codigo_partido_alc ,by(coddane political_period)
drop if political_period==.
rename political_period  year 


*Deforestation
/*incluye coddane y se cambia reg*/

eststo s2: reghdfe floss_prim_ideam_area_v2 if mayorallied==0 & director_gob_law==0, a(year coddane) vce(cl coddane)
eststo s3: reghdfe floss_prim_ideam_area_v2 if mayorallied==1 & director_gob_law==0, a(year coddane) vce(cl coddane)
eststo s4: reghdfe floss_prim_ideam_area_v2 if mayorallied==0 & director_gob_law==1, a(year coddane) vce(cl coddane)
eststo s5: reghdfe floss_prim_ideam_area_v2 if mayorallied==1 & director_gob_law==1, a(year coddane) vce(cl coddane)

coefplot (s4, color("gs9")) (s5, color("gs4")) ///
(s2, color("gs9")) (s3, color("gs4")), ///
vert recast(bar) barwidth(0.12) ciopts(recast(rcap) lcolor("black")) citop ///
mlabcolor("black") mlabsize(medium) coeflabels(_cons=" ") ///
mlabel(string(@b, "%9.2fc")) mlabposition(11) mlabgap(*2) ///
l2title("Primary Forest Loss (%)", size(medium)) ///
legend(on order(1 "Mayor-Governor not Aligned" 3 "Mayor-Governor Aligned")) ///
xline(1, lc(gray) lp(dash)) ///
addplot(scatteri .14 .55 (3) "Governor as REPA Head" .14 1.05 (3) "Governor not REPA Head", mcolor(white) mlabsize(medium))

*Incumbency+1

xtset  coddane year 
bys coddane:  gen codigo_partido_alc_lead=F.codigo_partido_alc
format %15.0g codigo_partido_alc_lead
gen incumbent_party_lead=1 if codigo_partido_alc==codigo_partido_alc_lead
replace incumbent_party_lead=0 if incumbent_party_lead==.
drop if codigo_partido_alc_lead==.

ssc install reghdfe, replace

reghdfe incumbent_party_lead mayorallied, a(year coddane) vce(cl coddane)

eststo s2: reghdfe incumbent_party_lead if mayorallied==0 & director_gob_law==0, a(year coddane) vce(cl coddane)
eststo s3: reghdfe incumbent_party_lead if mayorallied==1 & director_gob_law==0, a(year coddane) vce(cl coddane)
eststo s4: reghdfe incumbent_party_lead if mayorallied==0 & director_gob_law==1, a(year coddane) vce(cl coddane)
eststo s5: reghdfe incumbent_party_lead if mayorallied==1 & director_gob_law==1, a(year coddane) vce(cl coddane)

coefplot (s4, color("gs9")) (s5, color("gs4")) ///
(s2, color("gs9")) (s3, color("gs4")), ///
vert recast(bar) barwidth(0.12) ciopts(recast(rcap) lcolor("black")) citop ///
mlabcolor("black") mlabsize(medium) coeflabels(_cons=" ") ///
mlabel(string(@b, "%9.2fc")) mlabposition(11) mlabgap(*2) ///
l2title("Primary Forest Loss (%)", size(medium)) ///
legend(on order(1 "Mayor-Governor not Aligned" 3 "Mayor-Governor Aligned")) ///
xline(1, lc(gray) lp(dash)) ///
addplot(scatteri .14 .55 (3) "Governor as REPA Head" .14 1.05 (3) "Governor not REPA Head", mcolor(white) mlabsize(medium))


}