/*------------------------------------------------------------------------------
PROGRAM: my_ttest
AUTHOR: Juan Miguel Jimenez R
TOPIC: Nice ttest table 
DATE: mar-21-2019
------------------------------------------------------------------------------*/

cap program drop my_ttest
program my_ttest, eclass
	version 15
	syntax varlist(fv) [if] [in], by(varlist fv)
	cap mat drop T S
	
	scalar n=wordcount("`varlist'")
	dis n
	
	mat T = J(n,10,.)
	local final=0
	foreach var of local varlist{
		ttest `var' `if', by(`by')
		local inicial = 1 + `final'
		mat T[`inicial',1] = r(mu_1)
		mat T[`inicial',2] = r(sd_1) 
		mat T[`inicial',3] = r(mu_2)
		mat T[`inicial',4] = r(sd_2) 
		mat T[`inicial',5] = r(mu_2) - r(mu_1) 
		mat T[`inicial',6] = r(p)
		mat T[`inicial',7] = r(N_1)
		mat T[`inicial',9] = r(N_2)
		
		local final = `inicial'
	}	

	mata: stars_MATA(st_matrix("T"),st_numscalar("n"))

	mat T=T[.,1..10]
	mat rown T= `varlist'
	
	ereturn mat est=T 
	ereturn mat stars=S
	
end

mata 
	function stars_MATA(T,n){
		numeric matrix S
		S=(T[.,6]:<=0.1)+(T[.,6]:<=0.05)+(T[.,6]:<=0.01)
		S=(J(n,4,0),S,J(n,1,0))
		st_matrix("T",T)
		st_matrix("S",S)
	}
end mata 


/*AFTER

my_ttest registered_total registered_male registered_female, by(treatment)
mat T=e(est)
mat S=e(stars)

*Nice results
cap erase ${work}/ttest.doc
frmttable using ${work}/ttest.tex, statmat(T) varlabels replace substat(1) annotate(S) asymbol(*,**,***) ///
ctitle("Variables", "Control", "Treatment", , "Difference" \ "", "Mean", "Mean", "of means" \ ///
" ", "(ED)", "(ED)", "(p-value)†") fragment tex nocenter


REFERENCES:
	- Programming an estimation command in Stata: Mata 101
	https://blog.stata.com/2015/12/15/programming-an-estimation-command-in-stata-mata-101/
	
	- Programming an estimation command in Stata: Mata functions
	https://blog.stata.com/2015/12/22/programming-an-estimation-command-in-stata-mata-functions/
