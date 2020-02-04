/*------------------------------------------------------------------------------
Topic: Estimations for deforestation project at the election year level

Date: July-1st-2019
Author: JMJR

NOTE:
------------------------------------------------------------------------------*/

clear all 

*Set monochrome scheme
set scheme s2mono
grstyle init
grstyle color background white

*Open data set 
use elections_forestloss_00_18_races.dta, clear

tab year_election, g(year_)



*-------------------------------------------------------------------------------
* 					Proof of assumptions ofr left races 
*
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*No manipulation of the running variable
*-------------------------------------------------------------------------------
*Density of the forcing variable
kdensity sh_votes_left, xline(0) graphregion(color(white))  title("") xtitle("Share of votes for the left")
gr export ${plots}/kden_left_elections.pdf, replace as(pdf)

*No manipulation test (Cattaneo, 2017)
cap rddensity sh_votes_left, p(2) kernel(triangular) bwselect(diff)
rddensity sh_votes_left, p(2) kernel(triangular) bwselect(diff) plot graph_options(xtitle("Share of votes for the left") note(Bw: `: di %4.3f `e(h_l)'' "" p-val: `: di %4.3f `e(pv_q)''))
gr export ${plots}/test_kden_left_elections.pdf, replace as(pdf)


*-------------------------------------------------------------------------------
*Local continuity
*-------------------------------------------------------------------------------
gl vars "indrural altura disbogota discapital sh_coca km2_coca area00 dismdo gcaribe gandina gpacifica gorinoquia gamazonia" 

rdbwselect loss_area00 sh_votes_left, p(1) kernel(tri)
gl h=e(h_mserd)
gl b= e(b_mserd) 

*Difference of means program (ttest)
my_ttest $vars if abs(sh_votes_left)<=$h, by(winner_left)
mat T=e(est)
mat S=e(stars)

*Nice results of ttest
tempfile X
frmttable using `X', statmat(T) varlabels replace substat(1) annotate(S) asymbol(*,**,***) ctitle("Variables", "Control", "Treatment", , "Difference" \ "", "Mean", "Mean", "of means" \ " ", "(ED)", "(ED)", "(p-value)†") fragment tex nocenter
filefilter `X' ${tables}\ttest_lc_left_elections.tex, from("r}\BS\BS") to("r}") replace 

*Difference of means using rdd
local k=1
foreach var of global vars{
	eststo est`k': rdrobust `var' sh_votes_left, all p(1) kernel(tri)
	local ++k
}

*Nice Results with rdd 
esttab est1 est2 est3 est4 est5 est6 est7 est8 est9 est10 est11 est12 est13 using ${tables}/rdd_lc_left_elections.tex, se keep(Robust) stats(N N_h_l h_l p kernel, labels(N "N eff." Bw Poly Kernel)) star(* 0.1 ** 0.05 *** 0.01) booktabs replace


*-------------------------------------------------------------------------------
* 							Regressions for left races
*
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*loss_area00:
*-------------------------------------------------------------------------------

*RDD, P=1, Kernel=triangular
eststo est1: rdrobust loss_area00 sh_votes_left, all p(1) kernel(tri)
estadd local Covs "No"
gl h1=e(h_l) 

eststo est2: rdrobust loss_area00 sh_votes_left, all p(1) kernel(tri)covs(altura discapital dismdo gandina gpacifica gorinoquia gamazonia sh_coca indrural area00)
estadd local Covs "Yes"
gl h2=e(h_l) 

*RDD, P=2, Kernel=triangular
eststo est3: rdrobust loss_area00 sh_votes_left, all p(2) kernel(tri)
estadd local Covs "No"
eststo est4: rdrobust loss_area00 sh_votes_left, all p(2) kernel(tri) covs(altura discapital dismdo gandina gpacifica gorinoquia gamazonia sh_coca indrural area00)
estadd local Covs "Yes"

*Results 
esttab est1 est2 est3 est4 using ${tables}/rd_left_elections.tex, se keep(Robust) stats(N N_h_l h_l p kernel Covs, labels(N "N eff." Bw Poly Kernel Covs.)) star(* 0.1 ** 0.05 *** 0.01) booktabs replace

*-------------------------------------------------------------------------------
*loss_km2:
*-------------------------------------------------------------------------------

*RDD, P=1, Kernel=triangular
eststo est1: rdrobust loss_km2 sh_votes_left, all p(1) kernel(tri) h(0.1)
estadd local Covs "No"
gl h1=e(h_l) 

eststo est2: rdrobust loss_km2 sh_votes_left, all p(1) kernel(tri) covs(altura discapital dismdo gandina gpacifica gorinoquia gamazonia sh_coca indrural area00)
estadd local Covs "Yes"
gl h2=e(h_l) 

*RDD, P=2, Kernel=triangular
eststo est3: rdrobust loss_km2 sh_votes_left, all p(2) kernel(tri)
estadd local Covs "No"
eststo est4: rdrobust loss_km2 sh_votes_left, all p(2) kernel(tri) covs(altura discapital dismdo gandina gpacifica gorinoquia gamazonia sh_coca indrural area00)
estadd local Covs "Yes"

*Results 
esttab est1 est2 est3 est4 using ${tables}/rd_left_km2_elections.tex, se keep(Robust) stats(N N_h_l h_l p kernel Covs, labels(N "N eff." Bw Poly Kernel Covs.)) star(* 0.1 ** 0.05 *** 0.01) booktabs replac


*-------------------------------------------------------------------------------
* 						Proof of assumptions for right races
*
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*No manipulation of the running variable
*-------------------------------------------------------------------------------
*Density of the forcing variable
kdensity sh_votes_right, xline(0) graphregion(color(white)) title("") xtitle("Share of votes for the right")
gr export ${plots}/kden_right_elections.pdf, replace as(pdf)

*No manipulation test (Cattaneo, 2017)
cap rddensity sh_votes_right, p(2) kernel(triangular) bwselect(diff) 
rddensity sh_votes_right, p(2) kernel(triangular) bwselect(diff) plot graph_options(xtitle("Share of votes for the right") note(Bw: `: di %4.3f `e(h_l)'' "" p-val: `: di %4.3f `e(pv_q)''))
gr export ${plots}/test_kden_right_elections.pdf, replace as(pdf)

*-------------------------------------------------------------------------------
*Local continuity
*-------------------------------------------------------------------------------
*Ttests to test local continuity
gl vars "indrural altura disbogota discapital sh_coca km2_coca area00 dismdo gcaribe gandina gpacifica gorinoquia gamazonia" 

rdbwselect loss_area00 sh_votes_right
gl h=e(h_mserd)
gl b= e(b_mserd) 

*Difference of means program 
*do ${do}/my_ttest.do

my_ttest $vars if abs(sh_votes_right)<=$h, by(winner_right)
mat T=e(est)
mat S=e(stars)

tempfile X
frmttable using `X', statmat(T) varlabels replace substat(1) annotate(S) asymbol(*,**,***) ctitle("Variables", "Control", "Treatment", , "Difference" \ "", "Mean", "Mean", "of means" \ " ", "(ED)", "(ED)", "(p-value)†") fragment tex nocenter
filefilter `X' ${tables}\ttest_lc_right_elections.tex, from("r}\BS\BS") to("r}") replace 

*Difference of means using rdd
local k=1
foreach var of global vars{
	eststo est`k': rdrobust `var' sh_votes_right, all p(1) kernel(tri)
	local ++k
}

*Nice Results with rdd 
esttab est1 est2 est3 est4 est5 est6 est7 est8 est9 est10 est11 est12 est13 using ${tables}/rdd_lc_right_elections.tex, se keep(Robust) stats(N N_h_l h_l p kernel, labels(N "N eff." Bw Poly Kernel)) star(* 0.1 ** 0.05 *** 0.01) booktabs replace

*-------------------------------------------------------------------------------
* 							Regressions for right races
*
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*loss_area00:
*-------------------------------------------------------------------------------

*RDD, P=1, Kernel=triangular
eststo est1: rdrobust loss_area00 sh_votes_right, all p(1) kernel(tri)
estadd local Covs "No"
gl h1=e(h_l) 

eststo est2: rdrobust loss_area00 sh_votes_right, all p(1) kernel(tri) covs(altura discapital dismdo gandina gpacifica gorinoquia gamazonia sh_coca indrural area00)
estadd local Covs "Yes"
gl h2=e(h_l) 

*RDD, P=2, Kernel=triangular
eststo est3: rdrobust loss_area00 sh_votes_right, all p(2) kernel(tri)
estadd local Covs "No"
eststo est4: rdrobust loss_area00 sh_votes_right, all p(2) kernel(tri) covs(altura discapital dismdo gandina gpacifica gorinoquia gamazonia sh_coca indrural area00)
estadd local Covs "Yes"

*Results 
esttab est1 est2 est3 est4 using ${tables}/rd_right_elections.tex, se keep(Robust) stats(N N_h_l h_l p kernel Covs, labels(N "N eff." Bw Poly Kernel Covs.)) star(* 0.1 ** 0.05 *** 0.01) booktabs replace


*-------------------------------------------------------------------------------
*loss_km2:
*-------------------------------------------------------------------------------

*RDD, P=1, Kernel=triangular
eststo est1: rdrobust loss_km2 sh_votes_right, all p(1) kernel(tri)
estadd local Covs "No"
gl h1=e(h_l) 

eststo est2: rdrobust loss_km2 sh_votes_right, all p(1) kernel(tri) covs(altura discapital dismdo gandina gpacifica gorinoquia gamazonia sh_coca indrural area00)
estadd local Covs "Yes"
gl h2=e(h_l) 

*RDD, P=2, Kernel=triangular
eststo est3: rdrobust loss_km2 sh_votes_right, all p(2) kernel(tri)
estadd local Covs "No"
eststo est4: rdrobust loss_km2 sh_votes_right, all p(2) kernel(tri) covs(altura discapital dismdo gandina gpacifica gorinoquia gamazonia sh_coca indrural area00)

estadd local Covs "Yes"

*Results 
esttab est1 est2 est3 est4 using ${tables}/rd_right_km2_elections.tex, se keep(Robust) stats(N N_h_l h_l p kernel Covs, labels(N "N eff." Bw Poly Kernel Covs.)) star(* 0.1 ** 0.05 *** 0.01) booktabs replace


*-------------------------------------------------------------------------------
* 					Regressions for left races (without 2015)
*
*-------------------------------------------------------------------------------

drop if year_election==2015


*-------------------------------------------------------------------------------
*loss_area00:
*-------------------------------------------------------------------------------

*RDD, P=1, Kernel=triangular
eststo est1: rdrobust loss_area00 sh_votes_left, all p(1) kernel(tri)
estadd local Covs "No"
gl h1=e(h_l) 

eststo est2: rdrobust loss_area00 sh_votes_left, all p(1) kernel(tri)covs(altura discapital dismdo gandina gpacifica gorinoquia gamazonia sh_coca indrural area00)
estadd local Covs "Yes"
gl h2=e(h_l) 

*RDD, P=2, Kernel=triangular
eststo est3: rdrobust loss_area00 sh_votes_left, all p(2) kernel(tri)
estadd local Covs "No"
eststo est4: rdrobust loss_area00 sh_votes_left, all p(2) kernel(tri) covs(altura discapital dismdo gandina gpacifica gorinoquia gamazonia sh_coca indrural area00)
estadd local Covs "Yes"

*Results 
esttab est1 est2 est3 est4 using ${tables}/rd_left_elections_no2015.tex, se keep(Robust) stats(N N_h_l h_l p kernel Covs, labels(N "N eff." Bw Poly Kernel Covs.)) star(* 0.1 ** 0.05 *** 0.01) booktabs replace

*-------------------------------------------------------------------------------
*loss_km2:
*-------------------------------------------------------------------------------

*RDD, P=1, Kernel=triangular
eststo est1: rdrobust loss_km2 sh_votes_left, all p(1) kernel(tri)
estadd local Covs "No"
gl h1=e(h_l) 

eststo est2: rdrobust loss_km2 sh_votes_left, all p(1) kernel(tri) covs(altura discapital dismdo gandina gpacifica gorinoquia gamazonia sh_coca indrural area00)
estadd local Covs "Yes"
gl h2=e(h_l) 

*RDD, P=2, Kernel=triangular
eststo est3: rdrobust loss_km2 sh_votes_left, all p(2) kernel(tri)
estadd local Covs "No"
eststo est4: rdrobust loss_km2 sh_votes_left, all p(2) kernel(tri) covs(altura discapital dismdo gandina gpacifica gorinoquia gamazonia sh_coca indrural area00)
estadd local Covs "Yes"

*Results 
esttab est1 est2 est3 est4 using ${tables}/rd_left_km2_elections_no2015.tex, se keep(Robust) stats(N N_h_l h_l p kernel Covs, labels(N "N eff." Bw Poly Kernel Covs.)) star(* 0.1 ** 0.05 *** 0.01) booktabs replac


*-------------------------------------------------------------------------------
* 					Regressions for right races (without 2015)
*
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*loss_area00:
*-------------------------------------------------------------------------------

*RDD, P=1, Kernel=triangular
eststo est1: rdrobust loss_area00 sh_votes_right, all p(1) kernel(tri)
estadd local Covs "No"
gl h1=e(h_l) 

eststo est2: rdrobust loss_area00 sh_votes_right, all p(1) kernel(tri) covs(altura discapital dismdo gandina gpacifica gorinoquia gamazonia sh_coca indrural area00)
estadd local Covs "Yes"
gl h2=e(h_l) 

*RDD, P=2, Kernel=triangular
eststo est3: rdrobust loss_area00 sh_votes_right, all p(2) kernel(tri)
estadd local Covs "No"
eststo est4: rdrobust loss_area00 sh_votes_right, all p(2) kernel(tri) covs(altura discapital dismdo gandina gpacifica gorinoquia gamazonia sh_coca indrural area00)
estadd local Covs "Yes"

*Results 
esttab est1 est2 est3 est4 using ${tables}/rd_right_elections_no2015.tex, se keep(Robust) stats(N N_h_l h_l p kernel Covs, labels(N "N eff." Bw Poly Kernel Covs.)) star(* 0.1 ** 0.05 *** 0.01) booktabs replace


*-------------------------------------------------------------------------------
*loss_km2:
*-------------------------------------------------------------------------------

*RDD, P=1, Kernel=triangular
eststo est1: rdrobust loss_km2 sh_votes_right, all p(1) kernel(tri)
estadd local Covs "No"
gl h1=e(h_l) 

eststo est2: rdrobust loss_km2 sh_votes_right, all p(1) kernel(tri) covs(altura discapital dismdo gandina gpacifica gorinoquia gamazonia sh_coca indrural area00)
estadd local Covs "Yes"
gl h2=e(h_l) 

*RDD, P=2, Kernel=triangular
eststo est3: rdrobust loss_km2 sh_votes_right, all p(2) kernel(tri)
estadd local Covs "No"
eststo est4: rdrobust loss_km2 sh_votes_right, all p(2) kernel(tri) covs(altura discapital dismdo gandina gpacifica gorinoquia gamazonia sh_coca indrural area00)

estadd local Covs "Yes"

*Results 
esttab est1 est2 est3 est4 using ${tables}/rd_right_km2_elections_no2015.tex, se keep(Robust) stats(N N_h_l h_l p kernel Covs, labels(N "N eff." Bw Poly Kernel Covs.)) star(* 0.1 ** 0.05 *** 0.01) booktabs replace


*-------------------------------------------------------------------------------
* 				Regressions for left races with Leopoldo data
*
*-------------------------------------------------------------------------------

use "RDD_BL_fco.dta", clear
rename (muni_code year) (codmpio year_elections) 
merge 1:1 codmpio year_elections using elections_forestloss_00_18.dta, keep(1 3) nogen


eststo est1: rdrobust loss_area00 vote_share, all p(1) bwselect(mserd) kernel(tri)
estadd local Covs "No"
gl h1=e(h_l) 
eststo est2: rdrobust loss_area00 vote_share, all p(1) bwselect(mserd) kernel(tri) covs(altura discapital dismdo gandina goriente gpacifica coca94d)
estadd local Covs "Yes"
gl h2=e(h_l) 
eststo est3: rdrobust loss_area00 vote_share, all p(2) bwselect(mserd)  kernel(tri)
estadd local Covs "No"
eststo est4: rdrobust loss_area00 vote_share, all p(2) bwselect(mserd)  kernel(tri) covs(altura discapital dismdo gandina goriente gpacifica coca94d)
estadd local Covs "Yes"`'

esttab est1 est2 est3 est4 using ${tables}/rd_left_elections_RWC.tex, se keep(Robust) stats(N N_h_l h_l p kernel Covs, labels(N "N eff." Bw Poly Kernel Covs.)) star(* 0.1 ** 0.05 *** 0.01) booktabs replace



eststo est1: rdrobust loss_km2 vote_share, all p(1) bwselect(mserd) kernel(tri)
estadd local Covs "No"
gl h1=e(h_l) 
eststo est2: rdrobust loss_km2 vote_share, all p(1) bwselect(mserd) kernel(tri) covs(altura discapital dismdo gandina goriente gpacifica coca94d)
estadd local Covs "Yes"
gl h2=e(h_l) 
eststo est3: rdrobust loss_km2 vote_share, all p(2) bwselect(mserd)  kernel(tri)
estadd local Covs "No"
eststo est4: rdrobust loss_km2 vote_share, all p(2) bwselect(mserd)  kernel(tri) covs(altura discapital dismdo gandina goriente gpacifica coca94d)
estadd local Covs "Yes"

esttab est1 est2 est3 est4 using ${tables}/rd_left_km2_elections_RWC.tex, se keep(Robust) stats(N N_h_l h_l p kernel Covs, labels(N "N eff." Bw Poly Kernel Covs.)) star(* 0.1 ** 0.05 *** 0.01) booktabs replace




*END
