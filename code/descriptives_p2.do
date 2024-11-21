
use "${data}/Interim\defo_caralc.dta", clear

gen mayorallied=(codigo_partido==codigo_partido_cargob) if codigo_partido_cargob!=.

*DESCRIPTIVE

*Composition by CAR
hist sh_politics, frac xtitle("Share of politicians in the board")
gr export "${plots}/hist_share_politicians.pdf", as(pdf) replace

tabstat sh_politics if sh_politics!=., by(carcode_master) s(N mean sd min p25 p50 p75 max) save
tabstatmat S

mata: st_matrix("R", st_matrix("S")); st_matrixrowstripe("S", J(0,2,""))

mat colnames R = "N" "Mean" "SD" "Min" "p25" "p50" "p75" "Max"
mat rownames R = "CAM" "CAR" "CARDER" "CDA" "CORANTIOQUIA" "CORMACARENA" "CORNARE" "CORPOAMAZONIA" "CORPOCESAR" "CORPORINOQUIA" "CORTOLIMA" "CVC" "Total"

tempfile X X1
frmttable using `X', statmat(R) sdec(0,3) fragment tex nocenter 
filefilter `X' "${tables}\Share_politicians_per_CAR.tex", from("r}\BS\BS") to("r}") replace 

*Deforestation by CAR
foreach var in floss_area floss_prim00p1{

	tabstat `var' if sh_politics!=., by(carcode_master) s(N mean sd min p25 p50 p75 max) save
	tabstatmat S

	mata: st_matrix("R", st_matrix("S")); st_matrixrowstripe("S", J(0,2,""))

	mat colnames R = "N" "Mean" "SD" "Min" "p25" "p50" "p75" "Max"
	mat rownames R = "CAM" "CAR" "CARDER" "CDA" "CORANTIOQUIA" "CORMACARENA" "CORNARE" "CORPOAMAZONIA" "CORPOCESAR" "CORPORINOQUIA" "CORTOLIMA" "CVC" "Total"

	tempfile X X1
	frmttable using `X', statmat(R) sdec(0,3) fragment tex nocenter 
	filefilter `X' "${tables}/`var'_per_CAR.tex", from("r}\BS\BS") to("r}") replace 

}

*Scatter plot 	
label var floss_area "Share of Forest Loss (%)"
label var floss_prim00p1 "Share of Primary Forest Loss (%)"

reghdfe sh_politics, a(i.year i.coddane) vce(robust) resid
predict sh_politics_u, residuals 

foreach var in floss_area floss_prim00p1 {
	
	cap drop `var'_u
	
	local varlabel : variable label `var'	
	
	reghdfe `var', a(i.year i.coddane) vce(robust) resid
	predict `var'_u, residuals 
	
	binscatter `var'_u sh_politics_u, nbins(100) mcolor(%50) lcolor(black) legend(order(1 "Scatter" 2 "Linear Fit") position(6) col(2)) ytitle("`varlabel'", size(medium)) xtitle("Share of politicians in the board", size(medium))
	gr export "${plots}/binscatter_`var'_shpolitics_resid.pdf", as(pdf) replace
	
}

*Trend by CAR
collapse (sum) floss area fprim00_p1 fprim00_p50 (mean) sh_politics, by(carcode_master year)

format %8.0g floss

gen floss_area=floss*100/area    
gen floss_prim00p1=floss*100/fprim00_p1

label var floss_area "Share of Forest Loss (%)"
label var floss_prim00p1 "Share of Primary Forest Loss (%)"

tsset carcode_master year 

foreach var in floss_area floss_prim00p1{
	
	local label : variable label `var'
	
	line `var' year if year>2000 & year<2021 & sh_politics!=., by(carcode_master, note("")) ytitle(`label') xtitle(Year) note("")
	gr export "${plots}/`var'_cartrend.pdf", as(pdf) replace
}

reghdfe sh_politics, a(i.year i.carcode_master) vce(robust) resid
predict sh_politics_u, residuals 

foreach var in floss_area floss_prim00p1 {
	
	cap drop `var'_u
	
	local varlabel : variable label `var'	
	
	reghdfe `var', a(i.year i.carcode_master) vce(robust) resid
	predict `var'_u, residuals 
	
	binscatter `var'_u sh_politics_u, nbins(100) mcolor(%50) lcolor(black) legend(order(1 "Scatter" 2 "Linear Fit") position(6) col(2)) ytitle("`varlabel'", size(medium)) xtitle("Share of politicians in the board", size(medium))
	gr export "${plots}/binscatter_`var'_shpolitics_resid_carlvl.pdf", as(pdf) replace
	
}

tabstat sh_politics if sh_politics!=., by(carcode_master) s(N mean sd min p25 p50 p75 max) save
tabstatmat S

mata: st_matrix("R", st_matrix("S")); st_matrixrowstripe("S", J(0,2,""))

mat colnames R = "N" "Mean" "SD" "Min" "p25" "p50" "p75" "Max"
mat rownames R = "CAM" "CAR" "CARDER" "CDA" "CORANTIOQUIA" "CORMACARENA" "CORNARE" "CORPOAMAZONIA" "CORPOCESAR" "CORPORINOQUIA" "CORTOLIMA" "CVC" "Total"

tempfile X X1
frmttable using `X', statmat(R) sdec(0,3) fragment tex nocenter 
filefilter `X' "${tables}\Share_politicians_per_CAR.tex", from("r}\BS\BS") to("r}") replace 

br if sh_politics>.8 & sh_politics!=. 

*Dummy if politics have the power in the CAR
gen dsh_politics=sh_politics
summ dsh_politics, d
*gen dmdn_politics = (dsh_politics>=`r(p50)') if dsh_politics!=.

gen dmdn_politics = (dsh_politics>=.5) if dsh_politics!=.

tab carcode dmdn_politics

*Mira corpocesar 


*END


