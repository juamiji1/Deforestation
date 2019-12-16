/*------------------------------------------------------------------------------
Topic: Estimations for deforestation project

Date: July-1st-2019
Author: JMJR

NOTE: No manipulation test (Cattaneo, 2017). Source
https://sites.google.com/site/rdpackages/rddensity
net install rddensity, from(https://sites.google.com/site/rdpackages/rddensity/stata) replace
net install lpdensity, from(https://sites.google.com/site/nppackages/lpdensity/stata) replace
------------------------------------------------------------------------------*/

clear all 

*Set monochrome scheme
set scheme s2mono
grstyle init
grstyle color background white

*Open data set 
use forestloss_00_18_races.dta, clear


*-------------------------------------------------------------------------------
* 							Proof of assumptions
*
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*No manipulation of the running variable
*-------------------------------------------------------------------------------
*Density of the forcing variable
kdensity sh_votes_left, xline(0) graphregion(color(white))  title("") xtitle("Share of votes for the left")
gr export ${plots}/kden_left.pdf, replace as(pdf)

*No manipulation test (Cattaneo, 2017)
cap rddensity sh_votes_left, p(2) kernel(triangular) bwselect(diff)
rddensity sh_votes_left, p(2) kernel(triangular) bwselect(diff) plot graph_options(xtitle("Share of votes for the left") note(Bw: `: di %4.3f `e(h_l)'' "" p-val: `: di %4.3f `e(pv_q)''))
gr export ${plots}/test_kden_left.pdf, replace as(pdf)


*-------------------------------------------------------------------------------
*Local continuity
*-------------------------------------------------------------------------------
gl vars "indrural altura disbogota discapital sh_coca km2_coca area00 permits" 

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
filefilter `X' ${tables}\ttest_lc_left.tex, from("r}\BS\BS") to("r}") replace 

*Difference of means using rdd
local k=1
foreach var of global vars{
	eststo est`k': rdrobust `var' sh_votes_left, all p(1) kernel(tri)
	local ++k
}

*Nice Results with rdd 
esttab est1 est2 est3 est4 est5 est6 est7 est8 using ${tables}/rdd_lc_left.tex, se keep(Robust) stats(N N_h_l h_l p kernel, labels(N "N eff." Bw Poly Kernel)) star(* 0.1 ** 0.05 *** 0.01) booktabs replace


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

eststo est2: rdrobust loss_area00 sh_votes_left, all p(1) kernel(tri) covs(indrural altura sh_coca disbogota area00)
estadd local Covs "Yes"
gl h2=e(h_l) 

*RDD, P=2, Kernel=triangular
eststo est3: rdrobust loss_area00 sh_votes_left, all p(2) kernel(tri)
estadd local Covs "No"
eststo est4: rdrobust loss_area00 sh_votes_left, all p(2) kernel(tri) covs(indrural altura sh_coca disbogota area00)
estadd local Covs "Yes"

*Results 
esttab est1 est2 est3 est4 using ${tables}/rd_left.tex, se keep(Robust) stats(N N_h_l h_l p kernel Covs, labels(N "N eff." Bw Poly Kernel Covs.)) star(* 0.1 ** 0.05 *** 0.01) booktabs replace

*Plots
rdplot loss_area00 sh_votes_left if abs(sh_votes_left)<=$h1, h(${h1}) p(1) nbins(50 50) graph_options(graphregion(color(white)) subtitle("No covariates") xtitle("Share of votes for the left") legend(off) name(rd1, replace)) 

rdplot loss_area00 sh_votes_left if abs(sh_votes_left)<=$h2, h($h2) p(1) covs(indrural altura sh_coca disbogota area00) nbins(50 50) graph_options(graphregion(color(white)) subtitle("With covariates") xtitle("Share of votes for the left") legend(off) name(rd2, replace))  

gr combine rd1 rd2, title("Share of forest loss") graphregion(color(white))
gr export ${plots}/rdplot_left.pdf, replace as(pdf)


*-------------------------------------------------------------------------------
*loss_km2:
*-------------------------------------------------------------------------------

*RDD, P=1, Kernel=triangular
eststo est1: rdrobust loss_km2 sh_votes_left, all p(1) kernel(tri)
estadd local Covs "No"
gl h1=e(h_l) 

eststo est2: rdrobust loss_km2 sh_votes_left, all p(1) kernel(tri) covs(indrural altura km2_coca disbogota area00)
estadd local Covs "Yes"
gl h2=e(h_l) 

*RDD, P=2, Kernel=triangular
eststo est3: rdrobust loss_km2 sh_votes_left, all p(2) kernel(tri)
estadd local Covs "No"
eststo est4: rdrobust loss_km2 sh_votes_left, all p(2) kernel(tri) covs(indrural altura km2_coca disbogota area00)
estadd local Covs "Yes"

*Results 
esttab est1 est2 est3 est4 using ${tables}/rd_left_km2.tex, se keep(Robust) stats(N N_h_l h_l p kernel Covs, labels(N "N eff." Bw Poly Kernel Covs.)) star(* 0.1 ** 0.05 *** 0.01) booktabs replace

*PLots 
rdplot loss_km2 sh_votes_left if abs(sh_votes_left)<=$h1, h(${h1}) p(1) nbins(50 50) graph_options(graphregion(color(white)) subtitle("No covariates") xtitle("Share of votes for the left") legend(off) name(rd1, replace)) 

rdplot loss_km2 sh_votes_left if abs(sh_votes_left)<=$h2, h($h2) p(1) covs(indrural altura sh_coca disbogota area00) nbins(50 50) graph_options(graphregion(color(white)) subtitle("With covariates") xtitle("Share of votes for the left") legend(off) name(rd2, replace))  

gr combine rd1 rd2, title("Forest loss (Km 2)") graphregion(color(white))
gr export ${plots}/rdplot_left_km2.pdf, replace as(pdf)







/*Uniform weighted regression
reg loss_km2 i.winner_left##c.sh_votes_left if abs(sh_votes_left)<=$h

rdrobust loss_km2 sh_votes_left, all p(1) kernel(uni) 
rdrobust loss_area00 sh_votes_left, all p(1) kernel(uni)

*Covariates
rdrobust loss_km2 sh_votes_left, all p(1) kernel(uni) covs(indrural altura coca disbogota area00)
rdrobust loss_area00 sh_votes_left, all p(1) kernel(uni) covs(indrural altura sh_coca disbogota area00)

*Covariates & polinomial 2
rdrobust loss_km2 sh_votes_left, all p(2) kernel(uni) covs(indrural altura coca disbogota area00)
rdrobust loss_area00 sh_votes_left, all p(2) kernel(uni) covs(indrural altura coca disbogota area00)

*Triangular weighted regression
gen weights=(1-abs(sh_votes_left/$h)) if sh_votes_left<0 & sh_votes_left>=-$h
replace weights=(1-abs(sh_votes_left/$h)) if sh_votes_left>=0 & sh_votes_left<=$h

reg loss_km2 i.winner_left##c.sh_votes_left [aw=weights] if abs(sh_votes_left)<=$h, r

rdrobust loss_km2 sh_votes_left, all p(1) kernel(tri) 
rdrobust loss_area00 sh_votes_left, all p(1) kernel(tri)

*Covariates
rdrobust loss_km2 sh_votes_left, all p(1) kernel(tri) covs(indrural altura sh_coca disbogota area00)
rdrobust loss_area00 sh_votes_left, all p(1) kernel(tri) h(0.037) covs(indrural altura sh_coca disbogota)

*Covariates & polinomial 2
rdrobust loss_km2 sh_votes_left, all p(2) kernel(tri) covs(indrural altura coca disbogota area00)
rdrobust loss_area00 sh_votes_left, all p(2) kernel(tri) covs(indrural altura sh_coca disbogota area00)

*Covariates & polinomial 3
rdrobust loss_km2 sh_votes_left, all p(3) kernel(tri) covs(indrural altura coca disbogota area00)
rdrobust loss_area00 sh_votes_left, all p(3) kernel(tri) covs(indrural altura sh_coca disbogota area00)

*Graphs 
rdplot loss_area00 sh_votes_left if abs(sh_votes_left)<=$h, h($h) p(1) covs(indrural altura sh_coca disbogota area00) nbins(100 100)
rdplot loss_area00 sh_votes_left if abs(sh_votes_left)<=$h, h($h) p(2) covs(indrural altura coca disbogota area00)
rdplot loss_area00 sh_votes_left if abs(sh_votes_left)<=$h, h($h) p(3) covs(indrural altura coca disbogota area00)
*/


*-------------------------------------------------------------------------------
* 							Proof of assumptions
*
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*No manipulation of the running variable
*-------------------------------------------------------------------------------
*Density of the forcing variable
kdensity sh_votes_right, xline(0) graphregion(color(white)) title("") xtitle("Share of votes for the right")
gr export ${plots}/kden_right.pdf, replace as(pdf)

*No manipulation test (Cattaneo, 2017)
cap rddensity sh_votes_right, p(2) kernel(triangular) bwselect(diff) 
rddensity sh_votes_right, p(2) kernel(triangular) bwselect(diff) plot graph_options(xtitle("Share of votes for the right") note(Bw: `: di %4.3f `e(h_l)'' "" p-val: `: di %4.3f `e(pv_q)''))
gr export ${plots}/test_kden_right.pdf, replace as(pdf)

*-------------------------------------------------------------------------------
*Local continuity
*-------------------------------------------------------------------------------
*Ttests to test local continuity
gl vars "indrural altura disbogota discapital sh_coca coca area00 permits" 

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
filefilter `X' ${tables}\ttest_lc_right.tex, from("r}\BS\BS") to("r}") replace 

*Difference of means using rdd
local k=1
foreach var of global vars{
	eststo est`k': rdrobust `var' sh_votes_right, all p(1) kernel(tri)
	local ++k
}

*Nice Results with rdd 
esttab est1 est2 est3 est4 est5 est6 est7 est8 using ${tables}/rdd_lc_right.tex, se keep(Robust) stats(N N_h_l h_l p kernel, labels(N "N eff." Bw Poly Kernel)) star(* 0.1 ** 0.05 *** 0.01) booktabs replace


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

eststo est2: rdrobust loss_area00 sh_votes_right, all p(1) kernel(tri) covs(indrural altura sh_coca disbogota area00)
estadd local Covs "Yes"
gl h2=e(h_l) 

*RDD, P=2, Kernel=triangular
eststo est3: rdrobust loss_area00 sh_votes_right, all p(2) kernel(tri)
estadd local Covs "No"
eststo est4: rdrobust loss_area00 sh_votes_right, all p(2) kernel(tri) covs(indrural altura sh_coca disbogota area00)
estadd local Covs "Yes"

*Results 
esttab est1 est2 est3 est4 using ${tables}/rd_right.tex, se keep(Robust) stats(N N_h_l h_l p kernel Covs, labels(N "N eff." Bw Poly Kernel Covs.)) star(* 0.1 ** 0.05 *** 0.01) booktabs replace

*Plots
rdplot loss_area00 sh_votes_right if abs(sh_votes_right)<=$h1, h(${h1}) p(1) nbins(50 50) graph_options(graphregion(color(white)) subtitle("No covariates") xtitle("Share of votes for the right") legend(off) name(rd1, replace)) 

rdplot loss_area00 sh_votes_right if abs(sh_votes_right)<=$h2, h($h2) p(1) covs(indrural altura sh_coca disbogota area00) nbins(50 50) graph_options(graphregion(color(white)) subtitle("With covariates") xtitle("Share of votes for the right") legend(off) name(rd2, replace))  

gr combine rd1 rd2, title("Share of forest loss") graphregion(color(white))
gr export ${plots}/rdplot_right.pdf, replace as(pdf)


*-------------------------------------------------------------------------------
*loss_km2:
*-------------------------------------------------------------------------------

*RDD, P=1, Kernel=triangular
eststo est1: rdrobust loss_km2 sh_votes_right, all p(1) kernel(tri)
estadd local Covs "No"
gl h1=e(h_l) 

eststo est2: rdrobust loss_km2 sh_votes_right, all p(1) kernel(tri) covs(indrural altura km2_coca disbogota area00)
estadd local Covs "Yes"
gl h2=e(h_l) 

*RDD, P=2, Kernel=triangular
eststo est3: rdrobust loss_km2 sh_votes_right, all p(2) kernel(tri)
estadd local Covs "No"
eststo est4: rdrobust loss_km2 sh_votes_right, all p(2) kernel(tri) covs(indrural altura km2_coca disbogota area00)
estadd local Covs "Yes"

*Results 
esttab est1 est2 est3 est4 using ${tables}/rd_right_km2.tex, se keep(Robust) stats(N N_h_l h_l p kernel Covs, labels(N "N eff." Bw Poly Kernel Covs.)) star(* 0.1 ** 0.05 *** 0.01) booktabs replace

*PLots 
rdplot loss_km2 sh_votes_right if abs(sh_votes_right)<=$h1, h(${h1}) p(1) nbins(50 50) graph_options(graphregion(color(white)) subtitle("No covariates") xtitle("Share of votes for the right") legend(off) name(rd1, replace)) 

rdplot loss_km2 sh_votes_right if abs(sh_votes_right)<=$h2, h($h2) p(1) covs(indrural altura sh_coca disbogota area00) nbins(50 50) graph_options(graphregion(color(white)) subtitle("With covariates") xtitle("Share of votes for the right") legend(off) name(rd2, replace))  

gr combine rd1 rd2, title("Forest loss (Km 2)") graphregion(color(white))
gr export ${plots}/rdplot_right_km2.pdf, replace as(pdf)







/*Uniform weighted regression
reg loss_km2 i.winner_right##c.sh_votes_right if abs(sh_votes_right)<=$h

rdrobust loss_km2 sh_votes_right, all p(1) kernel(uni) 
rdrobust loss_area00 sh_votes_right, all p(1) kernel(uni) 

*Covariates
rdrobust loss_km2 sh_votes_right, all p(1) kernel(uni) covs(indrural altura sh_coca disbogota area00)
rdrobust loss_area00 sh_votes_right, all p(1) kernel(uni) covs(indrural altura sh_coca disbogota area00)

*Covariates & polinomial 2
rdrobust loss_km2 sh_votes_right, all p(2) kernel(uni) covs(indrural altura coca disbogota area00)
rdrobust loss_area00 sh_votes_right, all p(2) kernel(uni) covs(indrural altura sh_coca disbogota area00)

*Triangular weighted regression
gen weights=(1-abs(sh_votes_right/$h)) if sh_votes_right<0 & sh_votes_right>=-$h
replace weights=(1-abs(sh_votes_right/$h)) if sh_votes_right>=0 & sh_votes_right<=$h

reg loss_km2 i.winner_right##c.sh_votes_right [aw=weights] if abs(sh_votes_right)<=$h, r

rdrobust loss_km2 sh_votes_right, all p(1) kernel(tri)
rdrobust loss_area00 sh_votes_right, all p(1) kernel(tri) 

*Covariates
rdrobust loss_km2 sh_votes_right, all p(1) kernel(tri) covs(indrural altura coca disbogota area00)
rdrobust loss_area00 sh_votes_right, all p(1) kernel(tri) covs(indrural altura sh_coca disbogota area00)

*Covariates & polinomial 2
rdrobust loss_km2 sh_votes_right, all p(2) kernel(tri) covs(indrural altura coca disbogota area00)
rdrobust loss_area00 sh_votes_right, all p(2) kernel(tri) covs(indrural altura sh_coca disbogota area00)

*Graphs 
rdplot loss_area00 sh_votes_right if abs(sh_votes_right)<=$h, h($h) p(1) covs(indrural altura coca disbogota area00) 
rdplot loss_area00 sh_votes_right if abs(sh_votes_right)<=$h, h($h) p(2) covs(indrural altura coca disbogota area00)
rdplot loss_area00 sh_votes_right if abs(sh_votes_right)<=$h, h($h) p(3) covs(indrural altura coca disbogota area00)





*MORE

rdrobust elec_loss sh_votes_right, all p(1) kernel(tri) 
rdrobust elec_area00 sh_votes_right, all p(1) kernel(tri) 



