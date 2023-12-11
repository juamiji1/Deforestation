/*------------------------------------------------------------------------------
PROJECT: 
AUTHOR: JMJR
TOPIC: Master do-file
DATE:

NOTES: DO META!!!!! high deforestation!!!
------------------------------------------------------------------------------*/

clear all 

*Setting directories 
if c(username) == "juami" {
	gl localpath "C:\Users/`c(username)'\Dropbox\My-Research\Deforestation"
	gl overleafpath "C:\Users/`c(username)'\Dropbox\Overleaf\Politicians_Deforestation"
	gl do "C:\Github\Deforestation\code"
	
}
else {
	*gl path "C:\Users/`c(username)'\Dropbox\"
}

gl data "${localpath}\data"
gl tables "${overleafpath}\tables"
gl plots "${overleafpath}\plots"

cd "${data}"

*Setting a pre-scheme for plots
set scheme s2mono
grstyle init
grstyle title color black
grstyle color background white
grstyle color major_grid dimgray


*-------------------------------------------------------------------------------
* Descriptives
*
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
* Maps
*-------------------------------------------------------------------------------
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

*Calculating different normalizations of the forest loss
by coddane: egen tfloss=sum(floss)

gen floss_area=tfloss*100/area    
gen floss_prim00p1=tfloss*100/fprim00_p1
gen floss_prim00p50=tfloss*100/fprim00_p50
gen floss_prim01=tfloss*100/fprim_01

*Total in share
keep if year==2019

summ tfloss, d
grmap tfloss, fcolor(GnBu) legc clmethod(c) ndocolor(none) ocolor(none ...) clb(`r(min)' `r(p5)' `r(p25)' `r(p50)' `r(p75)' `r(p95)' `r(p99)' `r(max)') legend(off)
gr export "${plots}/floss_map.png", as(png) replace

summ floss_area, d
grmap floss_area, fcolor(GnBu) legc clmethod(c) ndocolor(none) ocolor(none ...) clb(`r(min)' `r(p5)' `r(p25)' `r(p50)' `r(p75)' `r(p95)' `r(p99)' `r(max)') legend(off)
gr export "${plots}/floss_area_map.png", as(png) replace

summ floss_prim00p1, d
grmap floss_prim00p1, fcolor(GnBu) legc clmethod(c) ndocolor(none) ocolor(none ...) clb(`r(min)' `r(p5)' `r(p25)' `r(p50)' `r(p75)' `r(p95)' `r(p99)' `r(max)') legend(off)
gr export "${plots}/floss_prim00p1_map.png", as(png) replace

*-------------------------------------------------------------------------------
* Time trends by depto 
*-------------------------------------------------------------------------------
use "${data}/Interim\defo_caralc.dta", clear

label define codepto 5	"ANTIOQUIA" 8	"ATLÁNTICO" 11	"BOGOTA" 13	"BOLIVAR" 15 "BOYACA" 17 "CALDAS" 18 "CAQUETA" 19 "CAUCA" 20 "CESAR" 23	"CORDOBA" 25	"CUNDINAMARCA" 27	"CHOCO" 41	"HUILA" 44	"LA GUAJIRA" 47	"MAGDALENA" 50	"META" 52	"NARIÑO" 54 "NORTE DE SANTANDER" 63	"QUINDIO" 66 "RISARALDA" 68	"SANTANDER" 70	"SUCRE" 73	"TOLIMA" 76	"VALLE DEL CAUCA" 81	"ARAUCA" 85	"CASANARE" 86	"PUTUMAYO" 88 "SAN ANDRES" 91	"AMAZONAS" 94	"GUAINIA" 95	"GUAVIARE" 97	"VAUPES" 99	"VICHADA"
label val codepto codepto
label var codepto "Department"

preserve

	collapse (sum) floss (sum) area fprim00_p1 fprim00_p50, by(year)

	format %8.0g floss
	
	gen floss_area=floss*100/area    
	gen floss_prim00p1=floss*100/fprim00_p1
		
	label var floss "Total Forest Loss (Km2)"
	label var floss_area "Share of Forest Loss (%)"
	label var floss_prim00p1 "Share of Primary Forest Loss (%)"
	
	foreach var in floss floss_area floss_prim00p1{
		
		local label : variable label `var'
		
		line `var' year if year>2000 & year<2021, ytitle(`label') xtitle(Year)
		gr export "${plots}/`var'_coltrend.pdf", as(pdf) replace
	}

restore 

preserve
	duplicates drop codepto carcode_master, force
	tab codepto carcode_master
restore 

keep if merge_carcom==3

collapse (sum) floss area fprim00_p1 fprim00_p50, by(carcode_master year)

format %8.0g floss

gen floss_area=floss*100/area    
gen floss_prim00p1=floss*100/fprim00_p1
gen floss_prim00p50=floss*100/fprim00_p50
		
label var floss "Total Forest Loss (Km2)"
label var floss_area "Share of Forest Loss (%)"
label var floss_prim00p1 "Share of Primary Forest Loss (%)"

tsset carcode_master year 

foreach var in floss floss_area floss_prim00p1{
	
	local label : variable label `var'
	
	line `var' year if year>2000 & year<2021, by(carcode_master) ytitle(`label') xtitle(Year)
	gr export "${plots}/`var'_cartrend.pdf", as(pdf) replace
}

*-------------------------------------------------------------------------------
* Preparing vars of interest
*-------------------------------------------------------------------------------
use "${data}/Interim\defo_caralc.dta", clear

*Keeping the CAR in the south of the country
gen deptokeep=.
levelsof code, local(indeptos)
foreach x of local indeptos{
	dis "`x'"
	replace deptokeep=1 if codepto==`x'
} 
replace deptokeep=0 if deptokeep==.
*keep if deptokeep==1
*keep if year<2016

keep if merge_carcom==3

sort coddane year, stable

*Creating variable of mayor in the CAR's board 
gen mayorinbrd=(codigo_partido_caralc!=.)

*Creating variable of mayor allied with the gobernor in CAR's board
gen mayorallied=(codigo_partido==codigo_partido_cargob) if codigo_partido_cargob!=.

*Extending to other municipalities under the same CAR
bys codepto year: egen dcarcode=mean(carcode)
*bys carcode_master year: egen dsh_politics=mean(sh_politics)
bys dcarcode year: egen dsh_party=mean(sh_same_party)

*FIX THIS WITH STATUTORY DEFAULT
*sort coddane year, stable
*bys coddane: replace dsh_politics=dsh_politics[_n-1] if dsh_politics==.

*Dummy if politics have the power in the CAR
gen dsh_politics=sh_politics
summ dsh_politics, d
gen dmdn_politics = (dsh_politics>=`r(p50)') if dsh_politics!=.

summ sh_same_party_gob, d
gen dmdn_sameparty_gob = (sh_same_party_gob>=`r(p50)') if sh_same_party_gob!=.


*-------------------------------------------------------------------------------
* Simple differences in deforestation
*-------------------------------------------------------------------------------
label var floss "Total Forest Loss Km2"
label var floss_area "Share of Forest Loss"
label var floss_prim00p1 "Share of Primary Forest Loss"

*Difference of deforestation using in board
do ${do}/my_ttest.do

my_ttest floss floss_area floss_prim00p1, by(mayorinbrd)
mat T=e(est)
mat S=e(stars)

tempfile X
frmttable using `X', statmat(T) varlabels replace substat(1) annotate(S) asymbol(*,**,***) ctitle("Variables", "Mayor not in Committee", "Mayor in Committee", "Difference", "Obs. Mayor", "Obs. Mayor" \ "", "Mean", "Mean", "of means", "not in", "in" \ " ", "(SE)", "(SE)", "(p-value)") fragment tex nocenter sdec(4,4,4,0,0) 
filefilter `X' ${tables}\ttest_mayorinbrd.tex, from("r}\BS\BS") to("r}") replace 

*Difference of deforestation using alignment
my_ttest floss floss_area floss_prim00p1, by(mayorallied)
mat T=e(est)
mat S=e(stars)

tempfile X
frmttable using `X', statmat(T) varlabels replace substat(1) annotate(S) asymbol(*,**,***) ctitle("Variables", "Mayor not aligned", "Mayor aligned", "Difference", "Obs. Mayor", "Obs. Mayor" \ "", "Mean", "Mean", "of means", "not aligned", "aligned" \ " ", "(SE)", "(SE)", "(P-value)") fragment tex nocenter sdec(4,4,4,0,0) 
filefilter `X' ${tables}\ttest_mayorallied.tex, from("r}\BS\BS") to("r}") replace 

*-------------------------------------------------------------------------------
* Sorting data set relative to when treatment happened (mayorallied)
*-------------------------------------------------------------------------------
sort coddane year, stable

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

*Calculating residuals 
foreach var in floss floss_area floss_prim00p1{

    reghdfe `var', a(i.year#c.fprim00_p1 i.year#c.area i.year i.coddane) vce(robust) resid
	predict `var'_u, residuals 
	
	*t19 is -1  and t20 is the change
	reg `var'_u t_15 t_16 t_17 t_18 t_20 t_21 t_22 t_23 if xt==1, r
	mat bf1=e(b)[1,1..4],0,e(b)[1,5..8]
	mat coln bf1= "-5" "-4" "-3" "-2" "-1" "0" "1" "2" "3"

	*reg `var'_u t_15 t_16 t_17 t_18 t_20 t_21 t_22 t_23 if xt==1 & dmdn_politics==0, r

	*reg `var'_u t_15 t_16 t_17 t_18 t_20 t_21 t_22 t_23 if xt==1 & dmdn_politics==1, r
	*mat bf2=e(b)[1,1..4],0,e(b)[1,5..8]
	*mat coln bf2= "-5" "-4" "-3" "-2" "-1" "0" "1" "2" "3"
	
	local label : variable label `var'
	
	*coefplot (mat(bf1[1]), label("Party alignment")) (mat(bf2[1]), offset(-0.1) m(T) label("Party alignment plus mayority")) , vert yline(0, lp(dash)) noci recast(connected) xline(5, lp(dash)) l2title("`label' (residuals)", size(medsmall)) b2title("Relative Time to Treatment", size(small)) 
	
	coefplot (mat(bf1[1]), label("Party alignment")), vert yline(0, lp(dash)) noci recast(connected) xline(5, lp(dash)) l2title("`label' (residuals)", size(medsmall)) b2title("Relative Time to Treatment", size(small)) 
	gr export "${plots}/`var'_u_treatedtrends_mayorallied.pdf", as(pdf) replace
	
	drop `var'_u
}


*-------------------------------------------------------------------------------
* Tune trend Heterogeneity by politicians power
*-------------------------------------------------------------------------------
foreach var in floss floss_area floss_prim00p1{
	*reg `var' i.coddane, r
	reghdfe `var', a(i.year#c.fprim00_p1 i.year#c.area i.year i.coddane) vce(robust) resid
	predict `var'_u2, residuals 
}

foreach var in floss floss_area floss_prim00p1{
	
	*mean `var'_u2 if mayorallied==1 & dmdn_politics==0 & year>2001 & year<2016, over(year)
	*mat b0=e(b)
	*mat coln b0 = 02 03 04 05 06 07 08 09 10 11 12 13 14 15

	mean `var'_u2 if mayorallied==0 & year>2001 & year<2016, over(year)
	mat b1=e(b)
	mat coln b1 = 02 03 04 05 06 07 08 09 10 11 12 13 14 15

	mean `var'_u2 if mayorallied==1 & dmdn_politics==1 & year>2001 & year<2016, over(year)
	mat b2=e(b)
	mat coln b2 = 02 03 04 05 06 07 08 09 10 11 12 13 14 15

	*mean `var'_u2 if mayorallied==0 & dmdn_politics==1 & year>2001 & year<2016, over(year)
	*mat b3=e(b)
	*mat coln b3 = 02 03 04 05 06 07 08 09 10 11 12 13 14 15

	local label : variable label `var'
	
	*coefplot (mat(b0[1]), label("Party alignment")) (mat(b1[1]), label("Party alignment plus mayority")) (mat(b2[1]), label("No Party alignment")) (mat(b3[1]), label("No Party alignment plus mayority")), vert noci recast(connected) xline(2, lp(dash)) xline(6, lp(dash)) xline(10, lp(dash)) xline(14, lp(dash)) l2title("`label' (residuals)", size(medsmall)) b2title("Years", size(small)) 
	
	coefplot (mat(b1[1]), label("No Party alignment")) (mat(b2[1]), label("Party alignment plus mayority")), vert noci recast(connected) xline(2, lp(dash)) xline(6, lp(dash)) xline(10, lp(dash)) xline(14, lp(dash)) l2title("`label' (residuals)", size(medsmall)) b2title("Years", size(small)) 
	gr export "${plots}/`var'_u2_yeartrend_het_mayorallied.pdf", as(pdf) replace

}

/*-------------------------------------------------------------------------------
* Sorting data set relative to when treatment happened (mayorinbrd)
*-------------------------------------------------------------------------------
drop t t_* xt

sort coddane year, stable

by coddane: egen xt=max(mayorinbrd)
by coddane: gen dt=d.mayorinbrd
gen t=1 if (mayorinbrd==1 & year==2001) | dt==1
by coddane: replace t=t[_n-1]+1 if t==. & mayorinbrd==1

gsort coddane -year
gen t2=1 if t==1
by coddane: replace t2=t2[_n-1]+1 if t==. & mayorinbrd==0
replace t2=-(t2-2)

replace t=t2 if t==. & mayorinbrd==0
drop t2 dt

sort coddane year

*Creating fake time FE
tab t, g(t_)
drop t_1-t_14 
*drop t_24

*Calculating residuals 
foreach var in floss floss_area floss_prim00p1{

    reg `var' i.year i.coddane, r
	predict `var'_u, residuals 
	
	*t19 is -1  and t20 is the change
	reg `var'_u t_15 t_16 t_17 t_18 t_20 t_21 t_22 t_23 if xt==1, r
	mat bf1=e(b)[1,1..4],0,e(b)[1,5..8]
	mat coln bf1= "-5" "-4" "-3" "-2" "-1" "0" "1" "2" "3"

	reg `var'_u t_15 t_16 t_17 t_18 t_20 t_21 t_22 t_23 if xt==1 & dmdn_politics==0, r

	reg `var'_u t_15 t_16 t_17 t_18 t_20 t_21 t_22 t_23 if xt==1 & dmdn_politics==1, r
	mat bf2=e(b)[1,1..4],0,e(b)[1,5..8]
	mat coln bf2= "-5" "-4" "-3" "-2" "-1" "0" "1" "2" "3"

	coefplot (mat(bf1[1]), label("In Committee")) (mat(bf2[1]), offset(-0.1) m(T) label("In Committee plus mayority")) , vert yline(0, lp(dash)) noci recast(connected) xline(5, lp(dash)) l2title("`label' (residuals)", size(medsmall)) b2title("Relative Time to Treatment", size(small)) 
	gr export "${plots}/`var'_u_treatedtrends_mayorinbrd.pdf", as(pdf) replace

}





*END