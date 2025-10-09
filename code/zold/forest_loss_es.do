/*------------------------------------------------------------------------------
PROJECT: 
AUTHOR: JMJR
TOPIC: ES
DATE:

NOTES:
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
*bys codepto year: egen dcarcode=mean(carcode)
*bys dcarcode year: egen dsh_politics=mean(sh_politics)
*bys dcarcode year: egen dsh_party=mean(sh_same_party)

*FIX THIS WITH STATUTORY DEFAULT
*sort coddane year, stable
*bys coddane: replace dsh_politics=dsh_politics[_n-1] if dsh_politics==.

*Dummy if politics have the power in the CAR
gen dsh_politics=sh_politics
summ dsh_politics, d
gen dmdn_politics = (sh_politics>=`r(p50)') if dsh_politics!=.

summ sh_same_party_gob, d
gen dmdn_sameparty_gob = (sh_same_party_gob>=`r(p50)') if sh_same_party_gob!=.

*Creating linear trends
tab year, g(dyear) 

forval i=1/20{

	gen fprim00_p1_dyear_`i'=fprim00_p1*dyear`i'
	gen area_dyear_`i'=area*dyear`i'
	
}

*-------------------------------------------------------------------------------
* Clustering by CAR
*-------------------------------------------------------------------------------
global dyn = 3
global pla = 3
global nboot = 50

*floss_area floss_prim00p1
foreach var in floss {

	*Results for all 
	did_multiplegt `var' coddane year mayorallied, average_effect robust_dynamic dynamic(${dyn}) placebo(${pla}) breps(${nboot}) trends_nonparam(fprim00_p1 area) longdiff_placebo covariances seed(783) cluster(carcode_master)

	*Table for Average Effect
	mat AE1 = J(6,1,.)
	mat AE1[1,1]=e(effect_average)
	mat AE1[2,1]=e(se_effect_average)
	mat AE1[3,1]=e(effect_average)-1.96*e(se_effect_average)
	mat AE1[4,1]=e(effect_average)+1.96*e(se_effect_average)
	mat AE1[5,1]=e(N_effect_average)
	mat AE1[6,1]=e(N_switchers_effect_average)
	mat AE1= AE1'

	mat rown AE1 = "`var'"
	mat coln AE1 =  "ATE" "SE" "LB CI" "UB CI" "N" "Switchers"

	mat SAE1 = J(1,6,0)
	local p = 2*(1-(normal(abs(AE1[1,1]/AE1[1,2]))))
	mat SAE1[1,1] =(`p'<=0.15)+ (`p'<=0.1)+(`p'<=0.05)+(`p'<=0.01)

	tempfile X
	frmttable using `X', statmat(AE1) varlabels replace annotate(SAE1) asymbol(†,*,**,***) fragment tex nocenter sdec(4,4,4,4,0,0) 
	filefilter `X' "${tables}/`var'_ate_es_cl.tex", from("r}\BS\BS") to("r}") replace 

	qui{
		
		mat E1 = J(6,${dyn}+${pla}+2,0)

		forval l=1/$pla {
			
			mat E1[1,`l']=e(placebo_`l')
			mat E1[2,`l']=e(se_placebo_`l')
			mat E1[3,`l']=e(placebo_`l')-1.96*e(se_placebo_`l')
			mat E1[4,`l']=e(placebo_`l')+1.96*e(se_placebo_`l')
			mat E1[5,`l']=e(N_placebo_`l')
			mat E1[6,`l']=e(N_switchers_placebo_`l')

		}
				
		local s=${pla}+2
		forval l=0/$dyn {
			
			mat E1[1,`s']=e(effect_`l')
			mat E1[2,`s']=e(se_effect_`l')
			mat E1[3,`s']=e(effect_`l')-1.96*e(se_effect_`l')
			mat E1[4,`s']=e(effect_`l')+1.96*e(se_effect_`l')
			mat E1[5,`s']=e(N_effect_`l')
			mat E1[6,`s']=e(N_switchers_effect_`l')
			
			local ++s
		}

	}

	mat coln E1 = "-4" "-3" "-2" "-1" "0" "1" "2" "3"
	mat rown E1 =  "Estimate" "SE" "LB CI" "UB CI" "N" "Switchers"
	mat l E1

	*ES plot
	local label : variable label `var'
	coefplot (mat(E1[1]), ci((3 4)) label("Party alignment")), vert yline(0, lp(dash)) recast(connected) xline(4, lp(dash)) l2title("`label'", size(medsmall)) b2title(Relative Time to Treatment, size(small)) ciopts(recast(rcap))
	gr export "${plots}/`var'_plot_es_cl.pdf", as(pdf) replace

	*Table of leads and lags estimates 
	mat E1 = E1'
	mat SE1 = J(${dyn}+${pla}+2,6,0)

	local I=${dyn}+${pla}+2
	forval i=1/`I' {
		local p = 2*(1-(normal(abs(E1[`i',1]/E1[`i',2]))))
		mat SE1[`i',1] =(`p'<=0.15)+(`p'<=0.1)+(`p'<=0.05)+(`p'<=0.01)
	}

	tempfile X
	frmttable using `X', statmat(E1) varlabels replace annotate(SE1) asymbol(†,*,**,***) fragment tex nocenter sdec(4,4,4,4,0,0) 
	filefilter `X' "${tables}/`var'_leadslags_es_cl.tex", from("r}\BS\BS") to("r}") replace 

}

foreach var in floss {

	*Results for all 
	did_multiplegt `var' coddane year mayorallied if dmdn_politics==1, average_effect robust_dynamic dynamic(${dyn}) placebo(${pla}) breps(${nboot}) trends_nonparam(fprim00_p1 area) longdiff_placebo covariances seed(783) cluster(carcode_master)

	*Table for Average Effect
	mat AE1 = J(6,1,.)
	mat AE1[1,1]=e(effect_average)
	mat AE1[2,1]=e(se_effect_average)
	mat AE1[3,1]=e(effect_average)-1.96*e(se_effect_average)
	mat AE1[4,1]=e(effect_average)+1.96*e(se_effect_average)
	mat AE1[5,1]=e(N_effect_average)
	mat AE1[6,1]=e(N_switchers_effect_average)
	mat AE1= AE1'

	mat rown AE1 = "`var'"
	mat coln AE1 =  "ATE" "SE" "LB CI" "UB CI" "N" "Switchers"

	mat SAE1 = J(1,6,0)
	local p = 2*(1-(normal(abs(AE1[1,1]/AE1[1,2]))))
	mat SAE1[1,1] =(`p'<=0.15)+ (`p'<=0.1)+(`p'<=0.05)+(`p'<=0.01)

	tempfile X
	frmttable using `X', statmat(AE1) varlabels replace annotate(SAE1) asymbol(†,*,**,***) fragment tex nocenter sdec(4,4,4,4,0,0) 
	filefilter `X' "${tables}/`var'_ate_es_pol1_cl.tex", from("r}\BS\BS") to("r}") replace 

	qui{
		
		mat E1 = J(6,${dyn}+${pla}+2,0)

		forval l=1/$pla {
			
			mat E1[1,`l']=e(placebo_`l')
			mat E1[2,`l']=e(se_placebo_`l')
			mat E1[3,`l']=e(placebo_`l')-1.96*e(se_placebo_`l')
			mat E1[4,`l']=e(placebo_`l')+1.96*e(se_placebo_`l')
			mat E1[5,`l']=e(N_placebo_`l')
			mat E1[6,`l']=e(N_switchers_placebo_`l')

		}
				
		local s=${pla}+2
		forval l=0/$dyn {
			
			mat E1[1,`s']=e(effect_`l')
			mat E1[2,`s']=e(se_effect_`l')
			mat E1[3,`s']=e(effect_`l')-1.96*e(se_effect_`l')
			mat E1[4,`s']=e(effect_`l')+1.96*e(se_effect_`l')
			mat E1[5,`s']=e(N_effect_`l')
			mat E1[6,`s']=e(N_switchers_effect_`l')
			
			local ++s
		}

	}

	mat coln E1 = "-4" "-3" "-2" "-1" "0" "1" "2" "3"
	mat rown E1 =  "Estimate" "SE" "LB CI" "UB CI" "N" "Switchers"
	mat l E1

	*ES plot
	local label : variable label `var'
	coefplot (mat(E1[1]), ci((3 4)) label("Party alignment")), vert yline(0, lp(dash)) recast(connected) xline(4, lp(dash)) l2title("`label'", size(medsmall)) b2title(Relative Time to Treatment, size(small)) ciopts(recast(rcap))
	gr export "${plots}/`var'_plot_es_pol1_cl.pdf", as(pdf) replace

	*Table of leads and lags estimates 
	mat E1 = E1'
	mat SE1 = J(${dyn}+${pla}+2,6,0)

	local I=${dyn}+${pla}+2
	forval i=1/`I' {
		local p = 2*(1-(normal(abs(E1[`i',1]/E1[`i',2]))))
		mat SE1[`i',1] =(`p'<=0.15)+(`p'<=0.1)+(`p'<=0.05)+(`p'<=0.01)
	}

	tempfile X
	frmttable using `X', statmat(E1) varlabels replace annotate(SE1) asymbol(†,*,**,***) fragment tex nocenter sdec(4,4,4,4,0,0) 
	filefilter `X' "${tables}/`var'_leadslags_es_pol1_cl.tex", from("r}\BS\BS") to("r}") replace 

}


foreach var in floss{

	*Results for all 
	did_multiplegt `var' coddane year mayorallied if dmdn_politics==0, average_effect robust_dynamic dynamic(${dyn}) placebo(${pla}) breps(${nboot}) trends_nonparam(fprim00_p1 area) longdiff_placebo covariances seed(783) cluster(carcode_master)

	*Table for Average Effect
	mat AE1 = J(6,1,.)
	mat AE1[1,1]=e(effect_average)
	mat AE1[2,1]=e(se_effect_average)
	mat AE1[3,1]=e(effect_average)-1.96*e(se_effect_average)
	mat AE1[4,1]=e(effect_average)+1.96*e(se_effect_average)
	mat AE1[5,1]=e(N_effect_average)
	mat AE1[6,1]=e(N_switchers_effect_average)
	mat AE1= AE1'

	mat rown AE1 = "`var'"
	mat coln AE1 =  "ATE" "SE" "LB CI" "UB CI" "N" "Switchers"

	mat SAE1 = J(1,6,0)
	local p = 2*(1-(normal(abs(AE1[1,1]/AE1[1,2]))))
	mat SAE1[1,1] =(`p'<=0.15)+ (`p'<=0.1)+(`p'<=0.05)+(`p'<=0.01)

	tempfile X
	frmttable using `X', statmat(AE1) varlabels replace annotate(SAE1) asymbol(†,*,**,***) fragment tex nocenter sdec(4,4,4,4,0,0) 
	filefilter `X' "${tables}/`var'_ate_es_pol0_cl.tex", from("r}\BS\BS") to("r}") replace 

	qui{
		mat E1 = J(6,${dyn}+${pla}+2,0)

		forval l=1/$pla {
			
			mat E1[1,`l']=e(placebo_`l')
			mat E1[2,`l']=e(se_placebo_`l')
			mat E1[3,`l']=e(placebo_`l')-1.96*e(se_placebo_`l')
			mat E1[4,`l']=e(placebo_`l')+1.96*e(se_placebo_`l')
			mat E1[5,`l']=e(N_placebo_`l')
			mat E1[6,`l']=e(N_switchers_placebo_`l')

		}
				
		local s=${pla}+2
		forval l=0/$dyn {
			
			mat E1[1,`s']=e(effect_`l')
			mat E1[2,`s']=e(se_effect_`l')
			mat E1[3,`s']=e(effect_`l')-1.96*e(se_effect_`l')
			mat E1[4,`s']=e(effect_`l')+1.96*e(se_effect_`l')
			mat E1[5,`s']=e(N_effect_`l')
			mat E1[6,`s']=e(N_switchers_effect_`l')
			
			local ++s
		}

	}

	mat coln E1 = "-4" "-3" "-2" "-1" "0" "1" "2" "3"
	mat rown E1 =  "Estimate" "SE" "LB CI" "UB CI" "N" "Switchers"
	mat l E1

	*ES plot
	local label : variable label `var'
	coefplot (mat(E1[1]), ci((3 4)) label("Party alignment")), vert yline(0, lp(dash)) recast(connected) xline(4, lp(dash)) l2title("`label'", size(medsmall)) b2title(Relative Time to Treatment, size(small)) ciopts(recast(rcap))
	gr export "${plots}/`var'_plot_es_pol0_cl.pdf", as(pdf) replace

	*Table of leads and lags estimates 
	mat E1 = E1'
	mat SE1 = J(${dyn}+${pla}+2,6,0)

	local I=${dyn}+${pla}+2
	forval i=1/`I' {
		local p = 2*(1-(normal(abs(E1[`i',1]/E1[`i',2]))))
		mat SE1[`i',1] =(`p'<=0.15)+(`p'<=0.1)+(`p'<=0.05)+(`p'<=0.01)
	}

	tempfile X
	frmttable using `X', statmat(E1) varlabels replace annotate(SE1) asymbol(†,*,**,***) fragment tex nocenter sdec(4,4,4,4,0,0) 
	filefilter `X' "${tables}/`var'_leadslags_es_pol0_cl.tex", from("r}\BS\BS") to("r}") replace 

}


*-------------------------------------------------------------------------------
* Regressions of Mayor allied (Chaisemartin and D'Haultfoeuille)
*-------------------------------------------------------------------------------
foreach var in floss {

	*Results for all 
	did_multiplegt `var' coddane year mayorallied, average_effect robust_dynamic dynamic(${dyn}) placebo(${pla}) breps(${nboot}) trends_nonparam(fprim00_p1 area) longdiff_placebo covariances seed(783)

	*Table for Average Effect
	mat AE1 = J(6,1,.)
	mat AE1[1,1]=e(effect_average)
	mat AE1[2,1]=e(se_effect_average)
	mat AE1[3,1]=e(effect_average)-1.96*e(se_effect_average)
	mat AE1[4,1]=e(effect_average)+1.96*e(se_effect_average)
	mat AE1[5,1]=e(N_effect_average)
	mat AE1[6,1]=e(N_switchers_effect_average)
	mat AE1= AE1'

	mat rown AE1 = "`var'"
	mat coln AE1 =  "ATE" "SE" "LB CI" "UB CI" "N" "Switchers"

	mat SAE1 = J(1,6,0)
	local p = 2*(1-(normal(abs(AE1[1,1]/AE1[1,2]))))
	mat SAE1[1,1] =(`p'<=0.15)+ (`p'<=0.1)+(`p'<=0.05)+(`p'<=0.01)

	tempfile X
	frmttable using `X', statmat(AE1) varlabels replace annotate(SAE1) asymbol(†,*,**,***) fragment tex nocenter sdec(4,4,4,4,0,0) 
	filefilter `X' "${tables}/`var'_ate_es.tex", from("r}\BS\BS") to("r}") replace 

	qui{
		
		mat E1 = J(6,${dyn}+${pla}+2,0)

		forval l=1/$pla {
			
			mat E1[1,`l']=e(placebo_`l')
			mat E1[2,`l']=e(se_placebo_`l')
			mat E1[3,`l']=e(placebo_`l')-1.96*e(se_placebo_`l')
			mat E1[4,`l']=e(placebo_`l')+1.96*e(se_placebo_`l')
			mat E1[5,`l']=e(N_placebo_`l')
			mat E1[6,`l']=e(N_switchers_placebo_`l')

		}
				
		local s=${pla}+2
		forval l=0/$dyn {
			
			mat E1[1,`s']=e(effect_`l')
			mat E1[2,`s']=e(se_effect_`l')
			mat E1[3,`s']=e(effect_`l')-1.96*e(se_effect_`l')
			mat E1[4,`s']=e(effect_`l')+1.96*e(se_effect_`l')
			mat E1[5,`s']=e(N_effect_`l')
			mat E1[6,`s']=e(N_switchers_effect_`l')
			
			local ++s
		}

	}

	mat coln E1 = "-4" "-3" "-2" "-1" "0" "1" "2" "3"
	mat rown E1 =  "Estimate" "SE" "LB CI" "UB CI" "N" "Switchers"
	mat l E1

	*ES plot
	local label : variable label `var'
	coefplot (mat(E1[1]), ci((3 4)) label("Party alignment")), vert yline(0, lp(dash)) recast(connected) xline(4, lp(dash)) l2title("`label'", size(medsmall)) b2title(Relative Time to Treatment, size(small)) ciopts(recast(rcap))
	gr export "${plots}/`var'_plot_es.pdf", as(pdf) replace

	*Table of leads and lags estimates 
	mat E1 = E1'
	mat SE1 = J(${dyn}+${pla}+2,6,0)

	local I=${dyn}+${pla}+2
	forval i=1/`I' {
		local p = 2*(1-(normal(abs(E1[`i',1]/E1[`i',2]))))
		mat SE1[`i',1] =(`p'<=0.15)+(`p'<=0.1)+(`p'<=0.05)+(`p'<=0.01)
	}

	tempfile X
	frmttable using `X', statmat(E1) varlabels replace annotate(SE1) asymbol(†,*,**,***) fragment tex nocenter sdec(4,4,4,4,0,0) 
	filefilter `X' "${tables}/`var'_leadslags_es.tex", from("r}\BS\BS") to("r}") replace 

}

foreach var in floss {

	*Results for all 
	did_multiplegt `var' coddane year mayorallied if dmdn_politics==1, average_effect robust_dynamic dynamic(${dyn}) placebo(${pla}) breps(${nboot}) trends_nonparam(fprim00_p1 area) longdiff_placebo covariances seed(783)

	*Table for Average Effect
	mat AE1 = J(6,1,.)
	mat AE1[1,1]=e(effect_average)
	mat AE1[2,1]=e(se_effect_average)
	mat AE1[3,1]=e(effect_average)-1.96*e(se_effect_average)
	mat AE1[4,1]=e(effect_average)+1.96*e(se_effect_average)
	mat AE1[5,1]=e(N_effect_average)
	mat AE1[6,1]=e(N_switchers_effect_average)
	mat AE1= AE1'

	mat rown AE1 = "`var'"
	mat coln AE1 =  "ATE" "SE" "LB CI" "UB CI" "N" "Switchers"

	mat SAE1 = J(1,6,0)
	local p = 2*(1-(normal(abs(AE1[1,1]/AE1[1,2]))))
	mat SAE1[1,1] =(`p'<=0.15)+ (`p'<=0.1)+(`p'<=0.05)+(`p'<=0.01)

	tempfile X
	frmttable using `X', statmat(AE1) varlabels replace annotate(SAE1) asymbol(†,*,**,***) fragment tex nocenter sdec(4,4,4,4,0,0) 
	filefilter `X' "${tables}/`var'_ate_es_pol1.tex", from("r}\BS\BS") to("r}") replace 

	qui{
		
		mat E1 = J(6,${dyn}+${pla}+2,0)

		forval l=1/$pla {
			
			mat E1[1,`l']=e(placebo_`l')
			mat E1[2,`l']=e(se_placebo_`l')
			mat E1[3,`l']=e(placebo_`l')-1.96*e(se_placebo_`l')
			mat E1[4,`l']=e(placebo_`l')+1.96*e(se_placebo_`l')
			mat E1[5,`l']=e(N_placebo_`l')
			mat E1[6,`l']=e(N_switchers_placebo_`l')

		}
				
		local s=${pla}+2
		forval l=0/$dyn {
			
			mat E1[1,`s']=e(effect_`l')
			mat E1[2,`s']=e(se_effect_`l')
			mat E1[3,`s']=e(effect_`l')-1.96*e(se_effect_`l')
			mat E1[4,`s']=e(effect_`l')+1.96*e(se_effect_`l')
			mat E1[5,`s']=e(N_effect_`l')
			mat E1[6,`s']=e(N_switchers_effect_`l')
			
			local ++s
		}

	}

	mat coln E1 = "-4" "-3" "-2" "-1" "0" "1" "2" "3"
	mat rown E1 =  "Estimate" "SE" "LB CI" "UB CI" "N" "Switchers"
	mat l E1

	*ES plot
	local label : variable label `var'
	coefplot (mat(E1[1]), ci((3 4)) label("Party alignment")), vert yline(0, lp(dash)) recast(connected) xline(4, lp(dash)) l2title("`label'", size(medsmall)) b2title(Relative Time to Treatment, size(small)) ciopts(recast(rcap))
	gr export "${plots}/`var'_plot_es_pol1.pdf", as(pdf) replace

	*Table of leads and lags estimates 
	mat E1 = E1'
	mat SE1 = J(${dyn}+${pla}+2,6,0)

	local I=${dyn}+${pla}+2
	forval i=1/`I' {
		local p = 2*(1-(normal(abs(E1[`i',1]/E1[`i',2]))))
		mat SE1[`i',1] =(`p'<=0.15)+(`p'<=0.1)+(`p'<=0.05)+(`p'<=0.01)
	}

	tempfile X
	frmttable using `X', statmat(E1) varlabels replace annotate(SE1) asymbol(†,*,**,***) fragment tex nocenter sdec(4,4,4,4,0,0) 
	filefilter `X' "${tables}/`var'_leadslags_es_pol1.tex", from("r}\BS\BS") to("r}") replace 

}


foreach var in floss{

	*Results for all 
	did_multiplegt `var' coddane year mayorallied if dmdn_politics==0, average_effect robust_dynamic dynamic(${dyn}) placebo(${pla}) breps(${nboot}) trends_nonparam(fprim00_p1 area) longdiff_placebo covariances seed(783)

	*Table for Average Effect
	mat AE1 = J(6,1,.)
	mat AE1[1,1]=e(effect_average)
	mat AE1[2,1]=e(se_effect_average)
	mat AE1[3,1]=e(effect_average)-1.96*e(se_effect_average)
	mat AE1[4,1]=e(effect_average)+1.96*e(se_effect_average)
	mat AE1[5,1]=e(N_effect_average)
	mat AE1[6,1]=e(N_switchers_effect_average)
	mat AE1= AE1'

	mat rown AE1 = "`var'"
	mat coln AE1 =  "ATE" "SE" "LB CI" "UB CI" "N" "Switchers"

	mat SAE1 = J(1,6,0)
	local p = 2*(1-(normal(abs(AE1[1,1]/AE1[1,2]))))
	mat SAE1[1,1] =(`p'<=0.15)+ (`p'<=0.1)+(`p'<=0.05)+(`p'<=0.01)

	tempfile X
	frmttable using `X', statmat(AE1) varlabels replace annotate(SAE1) asymbol(†,*,**,***) fragment tex nocenter sdec(4,4,4,4,0,0) 
	filefilter `X' "${tables}/`var'_ate_es_pol0.tex", from("r}\BS\BS") to("r}") replace 

	qui{
		mat E1 = J(6,${dyn}+${pla}+2,0)

		forval l=1/$pla {
			
			mat E1[1,`l']=e(placebo_`l')
			mat E1[2,`l']=e(se_placebo_`l')
			mat E1[3,`l']=e(placebo_`l')-1.96*e(se_placebo_`l')
			mat E1[4,`l']=e(placebo_`l')+1.96*e(se_placebo_`l')
			mat E1[5,`l']=e(N_placebo_`l')
			mat E1[6,`l']=e(N_switchers_placebo_`l')

		}
				
		local s=${pla}+2
		forval l=0/$dyn {
			
			mat E1[1,`s']=e(effect_`l')
			mat E1[2,`s']=e(se_effect_`l')
			mat E1[3,`s']=e(effect_`l')-1.96*e(se_effect_`l')
			mat E1[4,`s']=e(effect_`l')+1.96*e(se_effect_`l')
			mat E1[5,`s']=e(N_effect_`l')
			mat E1[6,`s']=e(N_switchers_effect_`l')
			
			local ++s
		}

	}

	mat coln E1 = "-4" "-3" "-2" "-1" "0" "1" "2" "3"
	mat rown E1 =  "Estimate" "SE" "LB CI" "UB CI" "N" "Switchers"
	mat l E1

	*ES plot
	local label : variable label `var'
	coefplot (mat(E1[1]), ci((3 4)) label("Party alignment")), vert yline(0, lp(dash)) recast(connected) xline(4, lp(dash)) l2title("`label'", size(medsmall)) b2title(Relative Time to Treatment, size(small)) ciopts(recast(rcap))
	gr export "${plots}/`var'_plot_es_pol0.pdf", as(pdf) replace

	*Table of leads and lags estimates 
	mat E1 = E1'
	mat SE1 = J(${dyn}+${pla}+2,6,0)

	local I=${dyn}+${pla}+2
	forval i=1/`I' {
		local p = 2*(1-(normal(abs(E1[`i',1]/E1[`i',2]))))
		mat SE1[`i',1] =(`p'<=0.15)+(`p'<=0.1)+(`p'<=0.05)+(`p'<=0.01)
	}

	tempfile X
	frmttable using `X', statmat(E1) varlabels replace annotate(SE1) asymbol(†,*,**,***) fragment tex nocenter sdec(4,4,4,4,0,0) 
	filefilter `X' "${tables}/`var'_leadslags_es_pol0.tex", from("r}\BS\BS") to("r}") replace 

}



















/*
gen myrallied_dsh_politics=mayorallied*dsh_politics
gen myrallied_dmdn_politics=mayorallied*dmdn_politics

la var mayorallied "Party alignment"
la var myrallied_dsh_politics "Alignment \times Politicians share"
la var myrallied_dmdn_politics "Alignment \times I(Politicians majority)"

foreach var in floss floss_area floss_prim00p1{

	*Results for all 
	did_multiplegt `var' coddane year mayorallied, average_effect robust_dynamic dynamic(2) placebo(2) breps(70) trends_nonparam(fprim00_p1 area) longdiff_placebo covariances seed(12345)

	*Table for Average Effect
	mat AE1 = J(6,1,.)
	mat AE1[1,1]=e(effect_average)
	mat AE1[2,1]=e(se_effect_average)
	mat AE1[3,1]=e(effect_average)-1.96*e(se_effect_average)
	mat AE1[4,1]=e(effect_average)+1.96*e(se_effect_average)
	mat AE1[5,1]=e(N_effect_average)
	mat AE1[6,1]=e(N_switchers_effect_average)
	mat AE1= AE1'

	mat rown AE1 = "`var'"
	mat coln AE1 =  "ATE" "SE" "LB CI" "UB CI" "N" "Switchers"

	mat SAE1 = J(1,6,0)
	local p = 2*(1-(normal(abs(AE1[1,1]/AE1[1,2]))))
	mat SAE1[1,1] =(`p'<=0.15)+(`p'<=0.1)+(`p'<=0.05)+(`p'<=0.01)

	tempfile X
	frmttable using `X', statmat(AE1) varlabels replace annotate(SAE1) asymbol(†,*,**,***) fragment tex nocenter sdec(4,4,4,4,0,0) 
	filefilter `X' "${tables}/`var'_ate_es.tex", from("r}\BS\BS") to("r}") replace 

	qui{
		mat E1 = J(6,6,.)

		mat E1[1,1]=e(placebo_2)
		mat E1[1,2]=e(placebo_1)
		mat E1[1,3]=0
		mat E1[1,4]=e(effect_0)
		mat E1[1,5]=e(effect_1)
		mat E1[1,6]=e(effect_2)

		mat E1[2,1]=e(se_placebo_2)
		mat E1[2,2]=e(se_placebo_1)
		mat E1[2,3]=.
		mat E1[2,4]=e(se_effect_0)
		mat E1[2,5]=e(se_effect_1)
		mat E1[2,6]=e(se_effect_2)

		mat E1[3,1]=e(placebo_2)-1.96*e(se_placebo_2)
		mat E1[3,2]=e(placebo_1)-1.96*e(se_placebo_1)
		mat E1[3,3]=.
		mat E1[3,4]=e(effect_0)-1.96*e(se_effect_0)
		mat E1[3,5]=e(effect_1)-1.96*e(se_effect_1)
		mat E1[3,6]=e(effect_2)-1.96*e(se_effect_2)

		mat E1[4,1]=e(placebo_2)+1.96*e(se_placebo_2)
		mat E1[4,2]=e(placebo_1)+1.96*e(se_placebo_1)
		mat E1[4,3]=.
		mat E1[4,4]=e(effect_0)+1.96*e(se_effect_0)
		mat E1[4,5]=e(effect_1)+1.96*e(se_effect_1)
		mat E1[4,6]=e(effect_2)+1.96*e(se_effect_2)

		mat E1[5,1]=e(N_placebo_2)
		mat E1[5,2]=e(N_placebo_1)
		mat E1[5,3]=.
		mat E1[5,4]=e(N_effect_0)
		mat E1[5,5]=e(N_effect_1)
		mat E1[5,6]=e(N_effect_2)

		mat E1[6,1]=e(N_switchers_placebo_2)
		mat E1[6,2]=e(N_switchers_placebo_1)
		mat E1[6,3]=.
		mat E1[6,4]=e(N_switchers_effect_0)
		mat E1[6,5]=e(N_switchers_effect_1)
		mat E1[6,6]=e(N_switchers_effect_2)
	}

	mat coln E1 = "-2" "-1" "0" "1" "2" "3"
	mat rown E1 =  "Estimate" "SE" "LB CI" "UB CI" "N" "Switchers"
	mat l E1

	*ES plot
	local label : variable label `var'
	coefplot (mat(E1[1]), ci((3 4)) label("Party alignment")), vert yline(0, lp(dash)) recast(connected) xline(3, lp(dash)) l2title("`label'", size(medsmall)) b2title(Relative Time to Treatment, size(small)) ciopts(recast(rcap))
	gr export "${plots}/`var'_plot_es.pdf", as(pdf) replace

	*Table of leads and lags estimates 
	mat E1 = E1'
	mat SE1 = J(6,6,0)

	forval i=1/6{
		local p = 2*(1-(normal(abs(E1[`i',1]/E1[`i',2]))))
		mat SE1[`i',1] =(`p'<=0.15)+(`p'<=0.1)+(`p'<=0.05)+(`p'<=0.01)
	}

	tempfile X
	frmttable using `X', statmat(E1) varlabels replace annotate(SE1) asymbol(†,*,**,***) fragment tex nocenter sdec(4,4,4,4,0,0) 
	filefilter `X' "${tables}/`var'_leadslags_es.tex", from("r}\BS\BS") to("r}") replace 

}

*-------------------------------------------------------------------------------
* Regressions of Mayor allied - Disaggregating by Politicians Power
*-------------------------------------------------------------------------------
foreach var in floss floss_area floss_prim00p1{

	*Results for all 
	did_multiplegt `var' coddane year mayorallied if dmdn_politics==0, average_effect robust_dynamic dynamic(2) placebo(2) breps(70) trends_nonparam(fprim00_p1 area) longdiff_placebo covariances seed(12345)

	*Table for Average Effect
	mat AE1 = J(6,1,.)
	mat AE1[1,1]=e(effect_average)
	mat AE1[2,1]=e(se_effect_average)
	mat AE1[3,1]=e(effect_average)-1.96*e(se_effect_average)
	mat AE1[4,1]=e(effect_average)+1.96*e(se_effect_average)
	mat AE1[5,1]=e(N_effect_average)
	mat AE1[6,1]=e(N_switchers_effect_average)
	mat AE1= AE1'

	mat rown AE1 = "`var'"
	mat coln AE1 =  "ATE" "SE" "LB CI" "UB CI" "N" "Switchers"

	mat SAE1 = J(1,6,0)
	local p = 2*(1-(normal(abs(AE1[1,1]/AE1[1,2]))))
	mat SAE1[1,1] =(`p'<=0.15)+ (`p'<=0.1)+(`p'<=0.05)+(`p'<=0.01)

	tempfile X
	frmttable using `X', statmat(AE1) varlabels replace annotate(SAE1) asymbol(†,*,**,***) fragment tex nocenter sdec(4,4,4,4,0,0) 
	filefilter `X' "${tables}/`var'_ate_es_pol0.tex", from("r}\BS\BS") to("r}") replace 

	qui{
		mat E1 = J(6,6,.)

		mat E1[1,1]=e(placebo_2)
		mat E1[1,2]=e(placebo_1)
		mat E1[1,3]=0
		mat E1[1,4]=e(effect_0)
		mat E1[1,5]=e(effect_1)
		mat E1[1,6]=e(effect_2)

		mat E1[2,1]=e(se_placebo_2)
		mat E1[2,2]=e(se_placebo_1)
		mat E1[2,3]=.
		mat E1[2,4]=e(se_effect_0)
		mat E1[2,5]=e(se_effect_1)
		mat E1[2,6]=e(se_effect_2)

		mat E1[3,1]=e(placebo_2)-1.96*e(se_placebo_2)
		mat E1[3,2]=e(placebo_1)-1.96*e(se_placebo_1)
		mat E1[3,3]=.
		mat E1[3,4]=e(effect_0)-1.96*e(se_effect_0)
		mat E1[3,5]=e(effect_1)-1.96*e(se_effect_1)
		mat E1[3,6]=e(effect_2)-1.96*e(se_effect_2)

		mat E1[4,1]=e(placebo_2)+1.96*e(se_placebo_2)
		mat E1[4,2]=e(placebo_1)+1.96*e(se_placebo_1)
		mat E1[4,3]=.
		mat E1[4,4]=e(effect_0)+1.96*e(se_effect_0)
		mat E1[4,5]=e(effect_1)+1.96*e(se_effect_1)
		mat E1[4,6]=e(effect_2)+1.96*e(se_effect_2)

		mat E1[5,1]=e(N_placebo_2)
		mat E1[5,2]=e(N_placebo_1)
		mat E1[5,3]=.
		mat E1[5,4]=e(N_effect_0)
		mat E1[5,5]=e(N_effect_1)
		mat E1[5,6]=e(N_effect_2)

		mat E1[6,1]=e(N_switchers_placebo_2)
		mat E1[6,2]=e(N_switchers_placebo_1)
		mat E1[6,3]=.
		mat E1[6,4]=e(N_switchers_effect_0)
		mat E1[6,5]=e(N_switchers_effect_1)
		mat E1[6,6]=e(N_switchers_effect_2)
	}

	mat coln E1 = "-2" "-1" "0" "1" "2" "3"
	mat rown E1 =  "Estimate" "SE" "LB CI" "UB CI" "N" "Switchers"
	mat l E1

	*ES plot
	local label : variable label `var'
	coefplot (mat(E1[1]), ci((3 4)) label("Party alignment")), vert yline(0, lp(dash)) recast(connected) xline(3, lp(dash)) l2title("`label'", size(medsmall)) b2title(Relative Time to Treatment, size(small)) ciopts(recast(rcap))
	gr export "${plots}/`var'_plot_es_pol0.pdf", as(pdf) replace

	*Table of leads and lags estimates 
	mat E1 = E1'
	mat SE1 = J(6,6,0)

	forval i=1/6{
		local p = 2*(1-(normal(abs(E1[`i',1]/E1[`i',2]))))
		mat SE1[`i',1] =(`p'<=0.15)+(`p'<=0.1)+(`p'<=0.05)+(`p'<=0.01)
	}

	tempfile X
	frmttable using `X', statmat(E1) varlabels replace annotate(SE1) asymbol(†,*,**,***) fragment tex nocenter sdec(4,4,4,4,0,0) 
	filefilter `X' "${tables}/`var'_leadslags_es_pol0.tex", from("r}\BS\BS") to("r}") replace 

}

foreach var in floss floss_area floss_prim00p1{

	*Results for all 
	did_multiplegt `var' coddane year mayorallied if dmdn_politics==1, average_effect robust_dynamic dynamic(2) placebo(2) breps(70) trends_nonparam(fprim00_p1 area) longdiff_placebo covariances seed(12345)

	*Table for Average Effect
	mat AE1 = J(6,1,.)
	mat AE1[1,1]=e(effect_average)
	mat AE1[2,1]=e(se_effect_average)
	mat AE1[3,1]=e(effect_average)-1.96*e(se_effect_average)
	mat AE1[4,1]=e(effect_average)+1.96*e(se_effect_average)
	mat AE1[5,1]=e(N_effect_average)
	mat AE1[6,1]=e(N_switchers_effect_average)
	mat AE1= AE1'

	mat rown AE1 = "`var'"
	mat coln AE1 =  "ATE" "SE" "LB CI" "UB CI" "N" "Switchers"

	mat SAE1 = J(1,6,0)
	local p = 2*(1-(normal(abs(AE1[1,1]/AE1[1,2]))))
	mat SAE1[1,1] =(`p'<=0.15)+ (`p'<=0.1)+(`p'<=0.05)+(`p'<=0.01)

	tempfile X
	frmttable using `X', statmat(AE1) varlabels replace annotate(SAE1) asymbol(†,*,**,***) fragment tex nocenter sdec(4,4,4,4,0,0)  
	filefilter `X' "${tables}/`var'_ate_es_pol1.tex", from("r}\BS\BS") to("r}") replace 

	qui{
		mat E1 = J(6,6,.)

		mat E1[1,1]=e(placebo_2)
		mat E1[1,2]=e(placebo_1)
		mat E1[1,3]=0
		mat E1[1,4]=e(effect_0)
		mat E1[1,5]=e(effect_1)
		mat E1[1,6]=e(effect_2)

		mat E1[2,1]=e(se_placebo_2)
		mat E1[2,2]=e(se_placebo_1)
		mat E1[2,3]=.
		mat E1[2,4]=e(se_effect_0)
		mat E1[2,5]=e(se_effect_1)
		mat E1[2,6]=e(se_effect_2)

		mat E1[3,1]=e(placebo_2)-1.96*e(se_placebo_2)
		mat E1[3,2]=e(placebo_1)-1.96*e(se_placebo_1)
		mat E1[3,3]=.
		mat E1[3,4]=e(effect_0)-1.96*e(se_effect_0)
		mat E1[3,5]=e(effect_1)-1.96*e(se_effect_1)
		mat E1[3,6]=e(effect_2)-1.96*e(se_effect_2)

		mat E1[4,1]=e(placebo_2)+1.96*e(se_placebo_2)
		mat E1[4,2]=e(placebo_1)+1.96*e(se_placebo_1)
		mat E1[4,3]=.
		mat E1[4,4]=e(effect_0)+1.96*e(se_effect_0)
		mat E1[4,5]=e(effect_1)+1.96*e(se_effect_1)
		mat E1[4,6]=e(effect_2)+1.96*e(se_effect_2)

		mat E1[5,1]=e(N_placebo_2)
		mat E1[5,2]=e(N_placebo_1)
		mat E1[5,3]=.
		mat E1[5,4]=e(N_effect_0)
		mat E1[5,5]=e(N_effect_1)
		mat E1[5,6]=e(N_effect_2)

		mat E1[6,1]=e(N_switchers_placebo_2)
		mat E1[6,2]=e(N_switchers_placebo_1)
		mat E1[6,3]=.
		mat E1[6,4]=e(N_switchers_effect_0)
		mat E1[6,5]=e(N_switchers_effect_1)
		mat E1[6,6]=e(N_switchers_effect_2)
	}

	mat coln E1 = "-2" "-1" "0" "1" "2" "3"
	mat rown E1 =  "Estimate" "SE" "LB CI" "UB CI" "N" "Switchers"
	mat l E1

	*ES plot
	local label : variable label `var'
	coefplot (mat(E1[1]), ci((3 4)) label("Party alignment")), vert yline(0, lp(dash)) recast(connected) xline(3, lp(dash)) l2title("`label'", size(medsmall)) b2title(Relative Time to Treatment, size(small)) ciopts(recast(rcap))
	gr export "${plots}/`var'_plot_es_pol1.pdf", as(pdf) replace

	*Table of leads and lags estimates 
	mat E1 = E1'
	mat SE1 = J(6,6,0)

	forval i=1/6{
		local p = 2*(1-(normal(abs(E1[`i',1]/E1[`i',2]))))
		mat SE1[`i',1] =(`p'<=0.15)+(`p'<=0.1)+(`p'<=0.05)+(`p'<=0.01)
	}

	tempfile X
	frmttable using `X', statmat(E1) varlabels replace annotate(SE1) asymbol(†,*,**,***) fragment tex nocenter sdec(4,4,4,4,0,0) 
	filefilter `X' "${tables}/`var'_leadslags_es_pol1.tex", from("r}\BS\BS") to("r}") replace 

}






*END