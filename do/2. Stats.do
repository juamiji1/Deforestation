/*------------------------------------------------------------------------------
Topic: Stats for deforestation project

Date: July-1st-2019
Author: JMJR
------------------------------------------------------------------------------*/

clear all 

*Open X data set 
use forestloss_00_18_races.dta, clear


*-------------------------------------------------------------------------------
* 							Descriptive Statistics  
*
*-------------------------------------------------------------------------------
*Colombian forest loss trend
tsline col_loss_area00 if codmpio=="05001" & year>2000, graphr(color(white)) title("Colombia") graphr(color(white))
gr export ${work}/col_deforest.pdf, replace as(pdf)

preserve 
	*Collapsing by department
	collapse (sum) loss_km2 (sum) area00, by(codepto depto year) 
	
	*Share of loss on total area at the department level 
	gen loss_area00=loss_km2/area00
	la var loss_area00 "Forest loss share"
	
	*Figure of forest loss by department
	line loss_km2 year if year>2000, by(depto) graphr(color(white))
	line loss_area00 year if year>2000, by(depto) graphr(color(white))
	gr export ${work}/depto_box.pdf, replace as(pdf)
	
	*Ranking of the 6 departments with the most forest loss
	bys codepto: egen mean_loss_area00=mean(loss_area00)
	egen rank=rank(mean_loss_area00) if year==2018, f
	sort rank
	list rank codepto depto mean_loss_area00 in 1/10
	
	*Graph of deforest trend of those 6 departments
	sort codepto year
	#d ;
		twoway (line loss_area00 year if year>2000 & codepto==18) 
		(line loss_area00 year if year>2000 & codepto==86) 
		(line loss_area00 year if year>2000 & codepto==54) 
		(line loss_area00 year if year>2000 & codepto==13) 
		(line loss_area00 year if year>2000 & codepto==5)
		(line loss_area00 year if year>2000 & codepto==68),
		legend(label(1 "Putumayo") label(2 "Norte de Santander") label(3 "Bolivar")
		label(4 "Antioquia") label(5 "Santander") label(6 "Caqueta")) 
		graphr(color(white));	
	#d cr
	gr export ${work}/depto.pdf, replace as(pdf)
	
	*Volatity of forest loss (percentual change)
	sort codepto year
	bys codepto: gen perc_change=(loss_area00-loss_area00[_n-1])/loss_area00[_n-1] 
	line perc_change year if year>2000, by(depto)
restore 

*Ranking of municipalities
egen rank=rank(total_area00) if year==2018, f
sort rank

*Ranking of municipalities by year
forval y=2001(1)2017{ 
	egen rank_`y'=rank(loss_area00) if year==`y', f
}
sort rank_2001

sort codmpio year

*Descriptives by year
tabstat loss_km2, by(year) s(N mean sd min max p50) 
tabstat loss_km2 if loss_km2>0 , by(year) s(N mean sd min max p50)
tabstat loss_area00, by(year) s(N mean sd min max p50) 
tabstat loss_area00 if loss_area00>0 , by(year) s(N mean sd min max p50)

tabstat permits, by(year) s(N mean sd min max p50)
preserve
	collapse (sum) permits, by(year) 
	line permits year
	*, xline(2001 2004 2008 2012 2016, lp(dash))
restore


*-------------------------------------------------------------------------------
* 						Heat maps at municipal level
*
*-------------------------------------------------------------------------------
*NOTE: maps with fixed cutoffs across time
xtset idmap year

sum loss_area00, d
forval y=2001/2018{
	sum loss_area00 if loss_area00>0, d
	
	grmap loss_area00 using municipcoord if loss_area00>0, t(`y') id(idmap) fcolor(GnBu) ///
	clmethod(custom) ndocolor(none) ocolor(none ...) title("Deforestation in year `y'", size(medium)) ///
	subtitle ("Shares at the municipal level", size(small)) ///
	clb(`r(min)' `r(p5)' `r(p25)' `r(p50)' `r(p75)' `r(p95)' `r(p99)' `r(max)') 
	graph export ${work}/deforest_`y'.pdf, replace as(pdf)
}

sum loss_area00, d
foreach y in 2003 2007 2011 2015 2018{
	sum elec_area00 if elec_area00>0, d
	
	grmap elec_area00 using municipcoord if elec_area00>0, t(`y') id(idmap) fcolor(GnBu) ///
	clmethod(custom) ndocolor(none) ocolor(none ...) title("Total deforestation at the electoral period (`y')", size(medium)) ///
	subtitle ("Shares at the municipal level", size(small)) clb(`r(min)' `r(p5)' `r(p25)' `r(p50)' `r(p75)' `r(p95)' `r(p99)' `r(max)') 
	graph export ${work}/deforest_election_`y'.pdf, replace as(pdf)
}

sum total_area00 if year==2018, d
grmap total_area00 using municipcoord, t(2018) id(idmap) fcolor(GnBu) ///
title("Total deforestation (2001-2018)", size(medium)) ///
subtitle ("Shares at the municipal level", size(small)) ///
legtitle("Share (2000 as base year)") legc ///   
clmethod(custom) ndocolor(none) ocolor(none ...) ///
clb(`r(min)' `r(p5)' `r(p25)' `r(p50)' `r(p75)' `r(p95)' `r(p99)' `r(max)') 
graph export ${work}/deforest_total.pdf, replace as(pdf)


*-------------------------------------------------------------------------------
* 								Stats
*
*-------------------------------------------------------------------------------
use forestloss_00_18_races.dta, clear

*Stats about winners and races
tabstat winner_left, by(year) s(sum) save
tabstatmat L 
tabstat winner_right, by(year) s(sum) save
tabstatmat R

mat A=L,R

tabstat race_left, by(year) s(sum) save
tabstatmat L 
tabstat race_right, by(year) s(sum) save
tabstatmat R

mat A=A,L,R
mat coln A= "Left winner" "Right winner" "Left in race" "Right in race"
mat l A

frmttable using ${work}\elections.tex, s(A) sdec(0) title("Statistics on elections (2001-2015)") tex fragment nocenter replace

*Difference of means program 
do ${do}/my_ttest.do

*Difference of deforestation between left and non-left winners
my_ttest loss_km2 loss_area00 permits, by(winner_left)
mat T=e(est)
mat S=e(stars)
frmttable using ${work}/ttest_left.tex, statmat(T) varlabels replace substat(1) annotate(S) asymbol(*,**,***) ///
ctitle("Variables", "Non-left", "Left", , "Difference" \ "", "Mean", "Mean", "of means" \ ///
" ", "(ED)", "(ED)", "(p-value)†") fragment tex nocenter sdec(4)

*Difference of deforestation between right and non-right winners
my_ttest loss_km2 loss_area00 permits, by(winner_right)
mat T=e(est)
mat S=e(stars)
frmttable using ${work}/ttest_right.tex, statmat(T) varlabels replace substat(1) annotate(S) asymbol(*,**,***) ///
ctitle("Variables", "Non-Right", "Right", , "Difference" \ "", "Mean", "Mean", "of means" \ ///
" ", "(ED)", "(ED)", "(p-value)†") fragment tex nocenter sdec(4)


*-------------------------------------------------------------------------------
* 							Regressions for left races
*
*-------------------------------------------------------------------------------

*Density of the forcing variable
kdensity sh_votes_left, xline(0, lp(dash)) graphregion(color(white)) xtitle("Share of votes for the left")
gr export ${work}/kden_left.pdf, replace as(pdf)

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
frmttable using ${work}/ttest_lc_left.tex, statmat(T) varlabels replace substat(1) annotate(S) asymbol(*,**,***) ///
ctitle("Variables", "Control", "Treatment", , "Difference" \ "", "Mean", "Mean", "of means" \ ///
" ", "(ED)", "(ED)", "(p-value)†") fragment tex nocenter

*Erasing files
cap nois erase ${work}/rd_left.tex
cap nois erase ${work}/rd_left.doc
cap nois erase ${work}/rd_left.txt
cap nois erase ${work}/rd_left_km2.tex
cap nois erase ${work}/rd_left_km2.doc
cap nois erase ${work}/rd_left_km2.txt


*-------------------------------------------------------------------------------
*loss_area00:
*-------------------------------------------------------------------------------

*RDD, P=1, Kernel=triangular
rdrobust loss_area00 sh_votes_left, all p(1) kernel(tri)
outreg2 using ${work}/rd_left.tex, append addstat(Bw, e(h_l), Poly, e(p)) addtext(Covs, No) tex(fragment)
gl h=e(h_l) 
rdplot loss_area00 sh_votes_left if abs(sh_votes_left)<=$h, h($h) p(1) nbins(50 50) ///
graph_options(graphregion(color(white)) ///
subtitle("No covariates") xtitle("Share of votes for the left") legend(off) name(rd1, replace)) 

rdrobust loss_area00 sh_votes_left, all p(1) kernel(tri) covs(indrural altura sh_coca disbogota area00)
outreg2 using ${work}/rd_left.tex, append addstat(Bw, e(h_l), Poly, e(p)) addtext(Covs, Yes) tex(fragment)
gl h=e(h_l) 
rdplot loss_area00 sh_votes_left if abs(sh_votes_left)<=$h, h($h) p(1) ///
covs(indrural altura sh_coca disbogota area00) nbins(50 50) ///
graph_options(graphregion(color(white)) ///
subtitle("With covariates") xtitle("Share of votes for the left") legend(off) name(rd2, replace))  

gr combine rd1 rd2, title("Share of forest loss") graphregion(color(white))
gr export ${work}/rdplot_left.pdf, replace as(pdf)

graph close

*RDD, P=2, Kernel=triangular
rdrobust loss_area00 sh_votes_left, all p(2) kernel(tri)
outreg2 using ${work}/rd_left.tex, append addstat(Bw, e(h_l), Poly, e(p)) addtext(Covs, No) tex(fragment)

rdrobust loss_area00 sh_votes_left, all p(2) kernel(tri) covs(indrural altura sh_coca disbogota area00)
outreg2 using ${work}/rd_left.tex, append addstat(Bw, e(h_l), Poly, e(p)) addtext(Covs, Yes) tex(fragment)

*-------------------------------------------------------------------------------
*loss_km2:
*-------------------------------------------------------------------------------

*RDD, P=1, Kernel=triangular
rdrobust loss_km2 sh_votes_left, all p(1) kernel(tri)
outreg2 using ${work}/rd_left_km2.tex, append addstat(Bw, e(h_l), Poly, e(p)) addtext(Covs, No) tex(fragment)
gl h=e(h_l) 
rdplot loss_km2 sh_votes_left if abs(sh_votes_left)<=$h, h($h) p(1) nbins(50 50) ///
graph_options(graphregion(color(white)) ///
subtitle("No covariates") xtitle("Share of votes for the left") legend(off) name(rd1, replace)) 

rdrobust loss_km2 sh_votes_left, all p(1) kernel(tri) covs(indrural altura km2_coca disbogota area00)
outreg2 using ${work}/rd_left_km2.tex, append addstat(Bw, e(h_l), Poly, e(p)) addtext(Covs, Yes) tex(fragment)
gl h=e(h_l) 
rdplot loss_km2 sh_votes_left if abs(sh_votes_left)<=$h, h($h) p(1) ///
covs(indrural altura sh_coca disbogota area00) nbins(50 50) ///
graph_options(graphregion(color(white)) ///
subtitle("With covariates") xtitle("Share of votes for the left") legend(off) name(rd2, replace))  

gr combine rd1 rd2, title("Share of forest loss") graphregion(color(white))
gr export ${work}/rdplot_left_km2.pdf, replace as(pdf)

graph close

*RDD, P=2, Kernel=triangular
rdrobust loss_km2 sh_votes_left, all p(2) kernel(tri)
outreg2 using ${work}/rd_left_km2.tex, append addstat(Bw, e(h_l), Poly, e(p)) addtext(Covs, No) tex(fragment)

rdrobust loss_km2 sh_votes_left, all p(2) kernel(tri) covs(indrural altura km2_coca disbogota area00)
outreg2 using ${work}/rd_left_km2.tex, append addstat(Bw, e(h_l), Poly, e(p)) addtext(Covs, Yes) tex(fragment)






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
gr export ${work}/kden_right.pdf, replace as(pdf)

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

*Nice results
frmttable using ${work}/ttest_lc_right.tex, statmat(T) varlabels replace substat(1) annotate(S) asymbol(*,**,***) ///
ctitle("Variables", "Control", "Treatment", , "Difference" \ "", "Mean", "Mean", "of means" \ ///
" ", "(ED)", "(ED)", "(p-value)†") fragment tex nocenter

*Erasing files
cap nois erase ${work}/rd_right.tex
cap nois erase ${work}/rd_right.doc
cap nois erase ${work}/rd_right.txt
cap nois erase ${work}/rd_right_km2.tex
cap nois erase ${work}/rd_right_km2.doc
cap nois erase ${work}/rd_right_km2.txt

*-------------------------------------------------------------------------------
*loss_area00:
*-------------------------------------------------------------------------------

*RDD, P=1, Kernel=triangular
rdrobust loss_area00 sh_votes_right, all p(1) kernel(tri)
outreg2 using ${work}/rd_right.tex, append addstat(Bw, e(h_l), Poly, e(p)) addtext(Covs, No) tex(fragment)
gl h=e(h_l) 
rdplot loss_area00 sh_votes_right if abs(sh_votes_right)<=$h, h($h) p(1) nbins(50 50) ///
graph_options(graphregion(color(white)) ///
subtitle("No covariates") xtitle("Share of votes for the right") legend(off) name(rd1, replace)) 

rdrobust loss_area00 sh_votes_right, all p(1) kernel(tri) covs(indrural altura sh_coca disbogota area00)
outreg2 using ${work}/rd_right.tex, append addstat(Bw, e(h_l), Poly, e(p)) addtext(Covs, Yes) tex(fragment)
gl h=e(h_l) 
rdplot loss_area00 sh_votes_right if abs(sh_votes_right)<=$h, h($h) p(1) ///
covs(indrural altura sh_coca disbogota area00) nbins(50 50) ///
graph_options(graphregion(color(white)) ///
subtitle("With covariates") xtitle("Share of votes for the right") legend(off) name(rd2, replace))  

gr combine rd1 rd2, title("Share of forest loss") graphregion(color(white))
gr export ${work}/rdplot_right.pdf, replace as(pdf)

graph close 

*RDD, P=2, Kernel=triangular
rdrobust loss_area00 sh_votes_right, all p(2) kernel(tri)
outreg2 using ${work}/rd_right.tex, append addstat(Bw, e(h_l), Poly, e(p)) addtext(Covs, No) tex(fragment)

rdrobust loss_area00 sh_votes_right, all p(2) kernel(tri) covs(indrural altura sh_coca disbogota area00)
outreg2 using ${work}/rd_right.tex, append addstat(Bw, e(h_l), Poly, e(p)) addtext(Covs, Yes) tex(fragment)

*-------------------------------------------------------------------------------
*loss_km2:
*-------------------------------------------------------------------------------

*RDD, P=1, Kernel=triangular
rdrobust loss_km2 sh_votes_right, all p(1) kernel(tri)
outreg2 using ${work}/rd_right_km2.tex, append addstat(Bw, e(h_l), Poly, e(p)) addtext(Covs, No) tex(fragment)
gl h=e(h_l) 
rdplot loss_km2 sh_votes_right if abs(sh_votes_right)<=$h, h($h) p(1) nbins(50 50) ///
graph_options(graphregion(color(white)) ///
subtitle("No covariates") xtitle("Share of votes for the right") legend(off) name(rd1, replace)) 

rdrobust loss_km2 sh_votes_right, all p(1) kernel(tri) covs(indrural altura km2_coca disbogota area00)
outreg2 using ${work}/rd_right_km2.tex, append addstat(Bw, e(h_l), Poly, e(p)) addtext(Covs, Yes) tex(fragment)
gl h=e(h_l) 
rdplot loss_km2 sh_votes_right if abs(sh_votes_right)<=$h, h($h) p(1) ///
covs(indrural altura sh_coca disbogota area00) nbins(50 50) ///
graph_options(graphregion(color(white)) ///
subtitle("With covariates") xtitle("Share of votes for the right") legend(off) name(rd2, replace))  

gr combine rd1 rd2, title("Share of forest loss") graphregion(color(white))
gr export ${work}/rdplot_right_km2.pdf, replace as(pdf)

graph close 

*RDD, P=2, Kernel=triangular
rdrobust loss_km2 sh_votes_right, all p(2) kernel(tri)
outreg2 using ${work}/rd_right_km2.tex, append addstat(Bw, e(h_l), Poly, e(p)) addtext(Covs, No) tex(fragment)

rdrobust loss_km2 sh_votes_right, all p(2) kernel(tri) covs(indrural altura km2_coca disbogota area00)
outreg2 using ${work}/rd_right_km2.tex, append addstat(Bw, e(h_l), Poly, e(p)) addtext(Covs, Yes) tex(fragment)







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





















