
use "${data}/Interim\defo_caralc.dta", clear

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