/*------------------------------------------------------------------------------
Topic: Estimations for deforestation project

Date: July-1st-2019
Author: JMJR
------------------------------------------------------------------------------*/

clear all 

*Open data set 
use forestloss_00_18_races.dta, clear


*-------------------------------------------------------------------------------
* 							Regressions for left races
*
*-------------------------------------------------------------------------------

*Density of the forcing variable
kdensity sh_votes_left, xline(0, lp(dash)) graphregion(color(white)) xtitle("Share of votes for the left")
gr export ${plots}/kden_left.pdf, replace as(pdf)

*Ttests to test local continuity
gl vars "indrural altura disbogota discapital sh_coca km2_coca area00 permits" 

rdbwselect loss_area00 sh_votes_left, p(1) kernel(tri)
gl h=e(h_mserd)
gl b= e(b_mserd) 

*Difference of means program 
do ${do}/my_ttest.do

my_ttest $vars if abs(sh_votes_left)<=$h, by(winner_left)
mat T=e(est)
mat S=e(stars)

*Nice results
tempfile X
frmttable using `X', statmat(T) varlabels replace substat(1) annotate(S) asymbol(*,**,***) ctitle("Variables", "Control", "Treatment", , "Difference" \ "", "Mean", "Mean", "of means" \ " ", "(ED)", "(ED)", "(p-value)†") fragment tex nocenter
filefilter `X' ${tables}\ttest_lc_left.tex, from("r}\BS\BS") to("r}") replace 

*Erasing files
cap nois erase ${tables}/rd_left.tex
cap nois erase ${tables}/rd_left.doc
cap nois erase ${tables}/rd_left.txt
cap nois erase ${tables}/rd_left_km2.tex
cap nois erase ${tables}/rd_left_km2.doc
cap nois erase ${tables}/rd_left_km2.txt


*-------------------------------------------------------------------------------
*loss_area00:
*-------------------------------------------------------------------------------

*RDD, P=1, Kernel=triangular
rdrobust loss_area00 sh_votes_left, all p(1) kernel(tri)
outreg2 using ${tables}/rd_left.tex, append addstat(Bw, e(h_l), Poly, e(p)) addtext(Covs, No) tex(fragment)
gl h=e(h_l) 
rdplot loss_area00 sh_votes_left if abs(sh_votes_left)<=$h, h($h) p(1) nbins(50 50) graph_options(graphregion(color(white)) subtitle("No covariates") xtitle("Share of votes for the left") legend(off) name(rd1, replace)) 

rdrobust loss_area00 sh_votes_left, all p(1) kernel(tri) covs(indrural altura sh_coca disbogota area00)
outreg2 using ${tables}/rd_left.tex, append addstat(Bw, e(h_l), Poly, e(p)) addtext(Covs, Yes) tex(fragment)
gl h=e(h_l) 
rdplot loss_area00 sh_votes_left if abs(sh_votes_left)<=$h, h($h) p(1) covs(indrural altura sh_coca disbogota area00) nbins(50 50) graph_options(graphregion(color(white)) subtitle("With covariates") xtitle("Share of votes for the left") legend(off) name(rd2, replace))  

gr combine rd1 rd2, title("Share of forest loss") graphregion(color(white))
gr export ${tables}/rdplot_left.pdf, replace as(pdf)

graph close

*RDD, P=2, Kernel=triangular
rdrobust loss_area00 sh_votes_left, all p(2) kernel(tri)
outreg2 using ${tables}/rd_left.tex, append addstat(Bw, e(h_l), Poly, e(p)) addtext(Covs, No) tex(fragment)

rdrobust loss_area00 sh_votes_left, all p(2) kernel(tri) covs(indrural altura sh_coca disbogota area00)
outreg2 using ${tables}/rd_left.tex, append addstat(Bw, e(h_l), Poly, e(p)) addtext(Covs, Yes) tex(fragment)

*-------------------------------------------------------------------------------
*loss_km2:
*-------------------------------------------------------------------------------

*RDD, P=1, Kernel=triangular
rdrobust loss_km2 sh_votes_left, all p(1) kernel(tri)
outreg2 using ${tables}/rd_left_km2.tex, append addstat(Bw, e(h_l), Poly, e(p)) addtext(Covs, No) tex(fragment)
gl h=e(h_l) 
rdplot loss_km2 sh_votes_left if abs(sh_votes_left)<=$h, h($h) p(1) nbins(50 50) graph_options(graphregion(color(white)) subtitle("No covariates") xtitle("Share of votes for the left") legend(off) name(rd1, replace)) 

rdrobust loss_km2 sh_votes_left, all p(1) kernel(tri) covs(indrural altura km2_coca disbogota area00)
outreg2 using ${tables}/rd_left_km2.tex, append addstat(Bw, e(h_l), Poly, e(p)) addtext(Covs, Yes) tex(fragment)
gl h=e(h_l) 
rdplot loss_km2 sh_votes_left if abs(sh_votes_left)<=$h, h($h) p(1) covs(indrural altura sh_coca disbogota area00) nbins(50 50) graph_options(graphregion(color(white)) subtitle("With covariates") xtitle("Share of votes for the left") legend(off) name(rd2, replace))  

gr combine rd1 rd2, title("Share of forest loss") graphregion(color(white))
gr export ${tables}/rdplot_left_km2.pdf, replace as(pdf)

graph close

*RDD, P=2, Kernel=triangular
rdrobust loss_km2 sh_votes_left, all p(2) kernel(tri)
outreg2 using ${tables}/rd_left_km2.tex, append addstat(Bw, e(h_l), Poly, e(p)) addtext(Covs, No) tex(fragment)

rdrobust loss_km2 sh_votes_left, all p(2) kernel(tri) covs(indrural altura km2_coca disbogota area00)
outreg2 using ${tables}/rd_left_km2.tex, append addstat(Bw, e(h_l), Poly, e(p)) addtext(Covs, Yes) tex(fragment)






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
* 							Regressions for right races
*
*-------------------------------------------------------------------------------

*Density of the forcing variable
kdensity sh_votes_right, xline(0, lp(dash)) graphregion(color(white)) xtitle("Share of votes for the right")
gr export ${plots}/kden_right.pdf, replace as(pdf)

*Ttests to test local continuity
gl vars "indrural altura disbogota discapital sh_coca coca area00 permits" 

rdbwselect loss_area00 sh_votes_right
gl h=e(h_mserd)
gl b= e(b_mserd) 

*Difference of means program 
do ${do}/my_ttest.do

my_ttest $vars if abs(sh_votes_right)<=$h, by(winner_right)
mat T=e(est)
mat S=e(stars)

tempfile X
frmttable using `X', statmat(T) varlabels replace substat(1) annotate(S) asymbol(*,**,***) ctitle("Variables", "Control", "Treatment", , "Difference" \ "", "Mean", "Mean", "of means" \ " ", "(ED)", "(ED)", "(p-value)†") fragment tex nocenter
filefilter `X' ${tables}\ttest_lc_right.tex, from("r}\BS\BS") to("r}") replace 

*Erasing files
cap nois erase ${tables}/rd_right.tex
cap nois erase ${tables}/rd_right.doc
cap nois erase ${tables}/rd_right.txt
cap nois erase ${tables}/rd_right_km2.tex
cap nois erase ${tables}/rd_right_km2.doc
cap nois erase ${tables}/rd_right_km2.txt

*-------------------------------------------------------------------------------
*loss_area00:
*-------------------------------------------------------------------------------

*RDD, P=1, Kernel=triangular
rdrobust loss_area00 sh_votes_right, all p(1) kernel(tri)
outreg2 using ${tables}/rd_right.tex, append addstat(Bw, e(h_l), Poly, e(p)) addtext(Covs, No) tex(fragment)
gl h=e(h_l) 
rdplot loss_area00 sh_votes_right if abs(sh_votes_right)<=$h, h($h) p(1) nbins(50 50) graph_options(graphregion(color(white)) subtitle("No covariates") xtitle("Share of votes for the right") legend(off) name(rd1, replace)) 

rdrobust loss_area00 sh_votes_right, all p(1) kernel(tri) covs(indrural altura sh_coca disbogota area00)
outreg2 using ${tables}/rd_right.tex, append addstat(Bw, e(h_l), Poly, e(p)) addtext(Covs, Yes) tex(fragment)
gl h=e(h_l) 
rdplot loss_area00 sh_votes_right if abs(sh_votes_right)<=$h, h($h) p(1) covs(indrural altura sh_coca disbogota area00) nbins(50 50)graph_options(graphregion(color(white)) subtitle("With covariates") xtitle("Share of votes for the right") legend(off) name(rd2, replace))  

gr combine rd1 rd2, title("Share of forest loss") graphregion(color(white))
gr export ${tables}/rdplot_right.pdf, replace as(pdf)

graph close 

*RDD, P=2, Kernel=triangular
rdrobust loss_area00 sh_votes_right, all p(2) kernel(tri)
outreg2 using ${tables}/rd_right.tex, append addstat(Bw, e(h_l), Poly, e(p)) addtext(Covs, No) tex(fragment)

rdrobust loss_area00 sh_votes_right, all p(2) kernel(tri) covs(indrural altura sh_coca disbogota area00)
outreg2 using ${tables}/rd_right.tex, append addstat(Bw, e(h_l), Poly, e(p)) addtext(Covs, Yes) tex(fragment)

*-------------------------------------------------------------------------------
*loss_km2:
*-------------------------------------------------------------------------------

*RDD, P=1, Kernel=triangular
rdrobust loss_km2 sh_votes_right, all p(1) kernel(tri)
outreg2 using ${tables}/rd_right_km2.tex, append addstat(Bw, e(h_l), Poly, e(p)) addtext(Covs, No) tex(fragment)
gl h=e(h_l) 
rdplot loss_km2 sh_votes_right if abs(sh_votes_right)<=$h, h($h) p(1) nbins(50 50) graph_options(graphregion(color(white)) subtitle("No covariates") xtitle("Share of votes for the right") legend(off) name(rd1, replace)) 

rdrobust loss_km2 sh_votes_right, all p(1) kernel(tri) covs(indrural altura km2_coca disbogota area00)
outreg2 using ${tables}/rd_right_km2.tex, append addstat(Bw, e(h_l), Poly, e(p)) addtext(Covs, Yes) tex(fragment)
gl h=e(h_l) 
rdplot loss_km2 sh_votes_right if abs(sh_votes_right)<=$h, h($h) p(1) covs(indrural altura sh_coca disbogota area00) nbins(50 50) graph_options(graphregion(color(white)) subtitle("With covariates") xtitle("Share of votes for the right") legend(off) name(rd2, replace))  

gr combine rd1 rd2, title("Share of forest loss") graphregion(color(white))
gr export ${plots}/rdplot_right_km2.pdf, replace as(pdf)

graph close 

*RDD, P=2, Kernel=triangular
rdrobust loss_km2 sh_votes_right, all p(2) kernel(tri)
outreg2 using ${tables}/rd_right_km2.tex, append addstat(Bw, e(h_l), Poly, e(p)) addtext(Covs, No) tex(fragment)

rdrobust loss_km2 sh_votes_right, all p(2) kernel(tri) covs(indrural altura km2_coca disbogota area00)
outreg2 using ${tables}/rd_right_km2.tex, append addstat(Bw, e(h_l), Poly, e(p)) addtext(Covs, Yes) tex(fragment)







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



