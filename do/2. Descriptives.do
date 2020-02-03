/*------------------------------------------------------------------------------
Topic: Descriptives for deforestation project

Date: July-1st-2019
Author: JMJR
------------------------------------------------------------------------------*/

clear all 

*Open data set 
use forestloss_00_18_races.dta, clear


*-------------------------------------------------------------------------------
* 							Descriptive Statistics  
*
*-------------------------------------------------------------------------------
*Total Colombian forest loss trend
tsline col_loss if codmpio=="05001" & year>2000, graphr(color(white)) title("Colombia") graphr(color(white)) xline(2003 2007 2011 2015, lp(dash) lc(maroon)) tlabel(2001 (2) 2018)
gr export ${plots}/col_deforest_km2.pdf, replace as(pdf)


tsline col_loss_area00 if codmpio=="05001" & year>2000, graphr(color(white)) title("Colombia") graphr(color(white))  xline(2003 2007 2011 2015, lp(dash) lc(maroon)) tlabel(2001 (2) 2018)
gr export ${plots}/col_deforest_sh.pdf, replace as(pdf)

*Departamental Forest loss trend 
preserve 
	*Collapsing by department
	collapse (sum) loss_km2 (sum) area00, by(codepto depto year) 
	
	*Share of loss on total area at the department level 
	gen loss_area00=loss_km2/area00
	la var loss_area00 "Forest loss share"
	
	*Figure of forest loss by department
	line loss_km2 year if year>2000, by(depto) graphr(color(white))
	gr export ${plots}/depto_box_km2.pdf, replace as(pdf)
	
	line loss_area00 year if year>2000, by(depto) graphr(color(white))
	gr export ${plots}/depto_box_sh.pdf, replace as(pdf)
	
	*Ranking of the 6 departments with the most forest loss in km2
	bys codepto: egen mean_loss_km2=mean(loss_km2)
	egen rank1=rank(mean_loss_km2) if year==2018, f
	sort rank1
	list rank1 codepto depto mean_loss_km2 in 1/10
	
	*Ranking of the 6 departments with the most forest loss as a share
	bys codepto: egen mean_loss_area00=mean(loss_area00)
	egen rank2=rank(mean_loss_area00) if year==2018, f
	sort rank2
	list rank2 codepto depto mean_loss_area00 in 1/10
	
	*Graph of deforest trend of the 6 departments with most deforestatioin in Km2
	sort codepto year
	#d ;
		twoway (line loss_km2 year if year>2000 & codepto==18) 
		(line loss_km2 year if year>2000 & codepto==86) 
		(line loss_km2 year if year>2000 & codepto==54) 
		(line loss_km2 year if year>2000 & codepto==13) 
		(line loss_km2 year if year>2000 & codepto==5)
		(line loss_km2 year if year>2000 & codepto==68),
		legend(label(1 "Putumayo") label(2 "Norte de Santander") label(3 "Bolivar")
		label(4 "Antioquia") label(5 "Santander") label(6 "Caqueta"))
		graphr(color(white)) xline(2003 2007 2011 2015, lp(dash) lc(maroon));	
	#d cr
	gr export ${plots}/depto_km2.pdf, replace as(pdf)
	
	*Graph of deforest trend of the 6 departments with most deforestatioin as a share 
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
	gr export ${plots}/depto_sh.pdf, replace as(pdf)
	
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
	
	grmap loss_area00 using municipcoord if loss_area00>0, t(`y') id(idmap) fcolor(GnBu) clmethod(custom) ndocolor(none) ocolor(none ...) title("Deforestation in year `y'", size(medium)) subtitle ("Shares at the municipal level", size(small)) clb(`r(min)' `r(p5)' `r(p25)' `r(p50)' `r(p75)' `r(p95)' `r(p99)' `r(max)') 
	graph export ${plots}/deforest_`y'.pdf, replace as(pdf)
}

/*sum loss_area00, d
foreach y in 2003 2007 2011 2015 2018{
	sum elec_area00 if elec_area00>0, d
	
	grmap elec_area00 using municipcoord if elec_area00>0, t(`y') id(idmap) fcolor(GnBu) clmethod(custom) ndocolor(none) ocolor(none ...) title("Total deforestation at the electoral period (`y')", size(medium)) subtitle ("Shares at the municipal level", size(small)) clb(`r(min)' `r(p5)' `r(p25)' `r(p50)' `r(p75)' `r(p95)' `r(p99)' `r(max)') 
	graph export ${plots}/deforest_election_`y'.pdf, replace as(pdf)
}*/

*Total in share
sum total_area00 if year==2018, d
grmap total_area00 using municipcoord, t(2018) id(idmap) fcolor(GnBu) title("Total deforestation (2001-2018)", size(medium)) ///
subtitle ("Shares at the municipal level", size(small)) legtitle("Share (2000 as base year)") legc clmethod(custom) ndocolor(none) ocolor(none ...) clb(`r(min)' `r(p5)' `r(p25)' `r(p50)' `r(p75)' `r(p95)' `r(p99)' `r(max)') 
graph export ${plots}/deforest_total.pdf, replace as(pdf)

*Total in Km2 
sum total_loss if year==2018, d
grmap total_loss using municipcoord, t(2018) id(idmap) fcolor(GnBu) title("Total deforestation (2001-2018)", size(medium)) ///
subtitle ("Km2 at the municipal level", size(small)) legtitle("Km2 (2000 as base year)") legc clmethod(custom) ndocolor(none) ocolor(none ...) clb(`r(min)' `r(p5)' `r(p25)' `r(p50)' `r(p75)' `r(p95)' `r(p99)' `r(max)') 
graph export ${plots}/deforest_total_km2.pdf, replace as(pdf)




*-------------------------------------------------------------------------------
* 								Stats
*
*-------------------------------------------------------------------------------
use forestloss_00_18_races.dta, clear

*Stats about left winners and left races
tabstat winner_left if (year==2001 | year==2004 | year==2008 | year==2012 | year==2016), by(year) s(sum) save
cap tabstatmat L 
tabstat winner_right if (year==2001 | year==2004 | year==2008 | year==2012 | year==2016), by(year) s(sum) save
cap tabstatmat R
mat A=L,R

*Stats about right winners and right races
tabstat race_left if (year==2001 | year==2004 | year==2008 | year==2012 | year==2016), by(year) s(sum) save
cap tabstatmat L 
tabstat race_right if (year==2001 | year==2004 | year==2008 | year==2012 | year==2016), by(year) s(sum) save
cap tabstatmat R
mat A=A,L,R

*Reseting the names since tabstat command is in MATA
local rowname : roweq A
mata: st_matrixrowstripe("A", J(rows(st_matrix("A")),2," "))
mat rown A=2000 2003 2007 2011 2015 Total

*Clean output
tempfile X
frmttable using `X', s(A) sdec(0) ctitle("Elections", "Left winner", "Right winner", "Left in race", "Right in race") tex fragment nocenter replace
filefilter `X' ${tables}\elections.tex, from("r}\BS\BS") to("r}") replace 		// Deleting the "\\" in the TeX file

*Difference of means program 
do ${do}/my_ttest.do

*Difference of deforestation between left and non-left winners
my_ttest loss_km2 loss_area00 permits, by(winner_left)
mat T=e(est)
mat S=e(stars)

tempfile X
frmttable using `X', statmat(T) varlabels replace substat(1) annotate(S) asymbol(*,**,***) ctitle("Variables", "Non-left", "Left", , "Difference" \ "", "Mean", "Mean", "of means" \ " ", "(ED)", "(ED)", "(p-value)†") fragment tex nocenter sdec(4)

filefilter `X' ${tables}\ttest_left.tex, from("r}\BS\BS") to("r}") replace 

*Difference of deforestation between right and non-right winners
my_ttest loss_km2 loss_area00 permits, by(winner_right)
mat T=e(est)
mat S=e(stars)
 
tempfile X
frmttable using `X', statmat(T) varlabels replace substat(1) annotate(S) asymbol(*,**,***) ctitle("Variables", "Non-Right", "Right", , "Difference" \ "", "Mean", "Mean", "of means" \ " ", "(ED)", "(ED)", "(p-value)†") fragment tex nocenter sdec(4)
filefilter `X' ${tables}\ttest_right.tex, from("r}\BS\BS") to("r}") replace 




gr close 















