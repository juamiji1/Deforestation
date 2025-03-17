
use "${data}/Interim\defo_caralc.dta", clear

la var mayorallied "Partisan alignment"

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

*Kdensity
egen sh_other=rowtotal(sh_ethnias sh_private sh_envngo sh_academics), m

two (kdensity sh_politics if sh_politics>.2 & sh_politics<.7) (kdensity sh_other if sh_politics>.2 & sh_politics<.7), ///
legend(order(1 "Politicians" 2 "Non-Politicians")) l2title("Kdensity Estimator", size(medsmall)) xtitle("") ///
b2title("Share of each member type on the board", size(medsmall))

gr export "${plots}/kdensity_sh_memberstype.pdf", as(pdf) replace


*Correlations
replace floss_prim00p50=floss_prim00p50*100

eststo clear

eststo r1: reg floss_prim00p50 mayorallied, r
summ floss_prim00p50 if e(sample)==1, d
gl mean_y=round(r(mean), .01)

eststo r2: reg floss_prim00p50 mayorallied if dmdn_politics==1, r
eststo r3: reg floss_prim00p50 mayorallied if dmdn_politics==0, r
eststo r4: reg floss_prim00p50 mayorallied if director_gob_law==1, r
eststo r5: reg floss_prim00p50 mayorallied if director_gob_law==0, r

*Exporting results 
esttab r1 r2 r3 r4 r5 using "${tables}/corrs_floss_boards.tex", keep(mayorallied) ///
se nocons star(* 0.10 ** 0.05 *** 0.01) ///
label nolines fragment nomtitle nonumbers obs nodep collabels(none) booktabs b(3) replace ///
prehead(`"\begin{tabular}{@{}l*{5}{c}}"' ///
            `"\hline \toprule"'                     ///
            `" & \multicolumn{5}{c}{Primary Forest Loss (\%)} \\ \cmidrule(l){2-6}"'                   ///
            `" & All & Poiticians majority & Politicians minority & Governor is director & Governor not director \\"' ///
            `" & (1) & (2) & (3) & (4) & (5) \\"'                       ///
            `" \toprule"')  ///
    postfoot(`" Dependent mean & ${mean_y} & ${mean_y} & ${mean_y} & ${mean_y} & ${mean_y} \\"' ///
	`"\bottomrule \end{tabular}"') 

*Calculating magnitud of deorestation
gen sh_fprim=fprim_01/area
summ fprim_01 sh_fprim floss_prim_ideam_area, d
dis (577.2514*.03)-(577.2514*.02) // around 5kms2

dis 5.7*1000000/11000

