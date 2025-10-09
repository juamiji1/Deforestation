/*------------------------------------------------------------------------------
PROJECT: 
AUTHOR: JMJR
TOPIC: 
DATE:

NOTES: I HAVE TO CREATE  MEASURE OF ALLIANCE WITH THE MOST POWERFUL PARTY!!!!!!!!
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
* TWFE Estimation
*
*-------------------------------------------------------------------------------
use "${data}/Interim\defo_caralc.dta", clear

*Labels
label var floss "Total Forest Loss (Km2)"
label var floss_area "Share of Forest Loss"
label var floss_prim00p1 "Share of Primary Forest Loss"

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

*-------------------------------------------------------------------------------
* Preparing vars of interest
*-------------------------------------------------------------------------------
sort coddane year, stable

*Creating variable of mayor in the CAR's board 
gen mayorinbrd=(codigo_partido_caralc!=.)

*Creating variable of mayor allied with the gobernor in CAR's board
gen mayorallied=(codigo_partido==codigo_partido_cargob) if codigo_partido_cargob!=.

*Extending to other municipalities under the same CAR
bys codepto year: egen dcarcode=mean(carcode)
*bys dcarcode year: egen dsh_politics=mean(sh_politics)
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
* Regressions of Mayor allied
*-------------------------------------------------------------------------------
gen myrallied_dsh_politics=mayorallied*dsh_politics
gen myrallied_dmdn_politics=mayorallied*dmdn_politics

gen myrallied_dsh_sameparty_gob=mayorallied*sh_same_party_gob
gen myrallied_dmdn_sameparty_gob=mayorallied*dmdn_sameparty_gob

la var dsh_politics "Share of Politicians"
la var dmdn_politics "I(Politicians majority)"
la var mayorallied "Party alignment"
la var myrallied_dsh_politics "Alignment $\times$ Politicians share"
la var myrallied_dmdn_politics "Alignment $\times$ I(Politicians majority)"

la var nfiresbosque "Total Area with Fire (km2)"
la var pct_areafirebosque "Share of Area with Fire"

la var crime_environment "Total Environmental Crimes"
la var crime_environment_cond "Environmental Convictions"
la var sh_crime_env_cond "Share of Env. Convictions"

la var bovinos "Total Head Cattle"
la var perm_n_resol "Total Forestry Permits"

*Erasing files 
cap erase "${tables}\fire_mayorallied.tex"
cap erase "${tables}\fire_mayorallied.txt"

foreach var in nfiresbosque pct_areafirebosque {
		
	*TWFE + share of politicians in comitte (dichotomous)
	reghdfe `var' mayorallied dmdn_politics myrallied_dmdn_politics c.fprim00_p1#i.year c.area#i.year, a(year coddane) vce(robust)
	summ `var' if e(sample)==1, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}/fire_mayorallied.tex", tex(frag) keep(mayorallied dmdn_politics myrallied_dmdn_politics) addtext("Year FE", "Yes", "Muni FE", "Yes" ) addstat("Dependent mean", ${mean_y}) label nonote nocons append 
	
}

*Erasing files 
cap erase "${tables}\crime_mayorallied.tex"
cap erase "${tables}\crime_mayorallied.txt"

foreach var in sh_crime_env_cond crime_environment crime_environment_cond {
		
	*TWFE + share of politicians in comitte (dichotomous)
	reghdfe `var' mayorallied dmdn_politics myrallied_dmdn_politics c.fprim00_p1#i.year c.area#i.year, a(year coddane) vce(robust)
	summ `var' if e(sample)==1, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}/crime_mayorallied.tex", tex(frag) keep(mayorallied dmdn_politics myrallied_dmdn_politics) addtext("Year FE", "Yes", "Muni FE", "Yes" ) addstat("Dependent mean", ${mean_y}) label nonote nocons append 
	
}

*Erasing files 
cap erase "${tables}\cattle_mayorallied.tex"
cap erase "${tables}\cattle_mayorallied.txt"

foreach var in bovinos {
		
	*TWFE + share of politicians in comitte (dichotomous)
	reghdfe `var' mayorallied dmdn_politics myrallied_dmdn_politics c.fprim00_p1#i.year c.area#i.year, a(year coddane) vce(robust)
	summ `var' if e(sample)==1, d
	gl mean_y=round(r(mean), .01)
	
	outreg2 using "${tables}/cattle_mayorallied.tex", tex(frag) keep(mayorallied dmdn_politics myrallied_dmdn_politics) addtext("Year FE", "Yes", "Muni FE", "Yes" ) addstat("Dependent mean", ${mean_y}) label nonote nocons append 
	
}


*-------------------------------------------------------------------------------
* Permits 
*-------------------------------------------------------------------------------
do ${do}/my_ttest.do

*Difference of deforestation using alignment
my_ttest perm_n_resol, by(mayorallied)
mat T=e(est)
mat S=e(stars)

tempfile X
frmttable using `X', statmat(T) varlabels replace substat(1) annotate(S) asymbol(*,**,***) ctitle("Variables", "Mayor not aligned", "Mayor aligned", "Difference", "Obs. Mayor", "Obs. Mayor" \ "", "Mean", "Mean", "of means", "not aligned", "aligned" \ " ", "(SE)", "(SE)", "(P-value)") fragment tex nocenter sdec(4,4,4,0,0) 
filefilter `X' ${tables}\ttest_perms_mayorallied.tex, from("r}\BS\BS") to("r}") replace 



