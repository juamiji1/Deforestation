did_multiplegt floss coddane year mayorallied if dmdn_politics==1, average_effect robust_dynamic dynamic(3) placebo(3) breps(70) longdiff_placebo covariances seed(12345) cluster(carcode_master)

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
	*filefilter `X' "${tables}/`var'_ate_es_pol1_cl.tex", from("r}\BS\BS") to("r}") replace 


global dyn = 3
global pla = 3

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

mat coln E1 = "-3" "-2" "-1" "0" "1" "2" "3" "4"
mat rown E1 =  "Estimate" "SE" "LB CI" "UB CI" "N" "Switchers"
mat l E1

*ES plot
local label : variable label floss
coefplot (mat(E1[1]), ci((3 4)) label("Party alignment")), vert yline(0, lp(dash)) recast(connected) xline(4, lp(dash)) l2title("`label'", size(medsmall)) b2title(Relative Time to Treatment, size(small)) ciopts(recast(rcap))
	
	
		local I=${dyn}+${pla}+2
	forval i=1/`I' {
		dis "`i'"
	}

	