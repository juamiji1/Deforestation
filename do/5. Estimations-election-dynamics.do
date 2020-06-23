/*------------------------------------------------------------------------------
Topic: Estimations for deforestation project with IDEAM data 

Date: 
Author: JMJR

NOTE: 
------------------------------------------------------------------------------*/

clear all 


*-------------------------------------------------------------------------------
* 							RD of IDEAM
*
*-------------------------------------------------------------------------------
*Open data set 
use baseIDEAM.dta, clear

ren M_code codmpio

*Dropping not needed years 
drop if year==1990 
drop id

*Forest cover change
sort codmpio year  
bys codmpio: gen forestcover_change_ideam=cobertura-cobertura[_n-1]
gen change_ideam_m2=forestcover_change_ideam/area_m2
tostring codmpio, replace
replace codmpio="0"+codmpio if length(codmpio)==4

save forest_cover_ideam_00_10, replace

use forestloss_00_18_races.dta, clear

*Merging IDEAM data
merge 1:1 codmpio year using forest_cover_ideam_00_10, keep(1 3)

*Forwarding the forest cover change
gsort codmpio -year
bys codmpio: carryforward forestcover_change_ideam, replace 
bys codmpio: carryforward change_ideam_m2, replace 

*-------------------------------------------------------------------------------
* Results for the left
*-------------------------------------------------------------------------------
*RD for forest cover change in m2 using 2004 
eststo est1: rdrobust forestcover_change_ideam sh_votes_left if year==2001 | year==2004 | year==2008, all p(1) kernel(tri)
estadd local Year "2004"

eststo est2: rdrobust forestcover_change_ideam sh_votes_left if year==2001 | year==2004 | year==2008, all p(2) kernel(tri)
estadd local Year "2004"
gl h1=e(h_l) 

eststo est3: rdrobust forestcover_change_ideam sh_votes_left if year==2001 | year==2004 | year==2008, all p(3) kernel(tri)
estadd local Year "2004"

*Table 
esttab est1 est2 est3 using ${tables}/rd_forestcover_04_left.tex, se keep(Robust) stats(N N_h_l h_l p kernel Year, labels(N "N eff." Bw Poly Kernel "2003 election year")) star(* 0.1 ** 0.05 *** 0.01) booktabs replace

*Plot 
rdplot forestcover_change_ideam sh_votes_left if (year==2001 | year==2004 | year==2008) & abs(sh_votes_left)<=${h1}, h(${h1}) all p(2) kernel(tri) nbins(50 50) 
gr export ${plots}/rdplot_forestcover_04_left.pdf, replace as(pdf)

*RD for forest cover change in m2 using 2006
eststo est1: rdrobust forestcover_change_ideam sh_votes_left if year==2001 | year==2006 | year==2008, all p(1) kernel(tri)
estadd local Year "2006"

eststo est2: rdrobust forestcover_change_ideam sh_votes_left if year==2001 | year==2006 | year==2008, all p(2) kernel(tri)
estadd local Year "2006"

eststo est3: rdrobust forestcover_change_ideam sh_votes_left if year==2001 | year==2006 | year==2008, all p(3) kernel(tri)
estadd local Year "2006"

*Table 
esttab est1 est2 est3 using ${tables}/rd_forestcover_06_left.tex, se keep(Robust) stats(N N_h_l h_l p kernel Year, labels(N "N eff." Bw Poly Kernel "2003 election year")) star(* 0.1 ** 0.05 *** 0.01) booktabs replace

*RD for forest cover change in percentage using 2004 
eststo est1: rdrobust change_ideam_m2 sh_votes_left if year==2001 | year==2004 | year==2008, all p(1) kernel(tri)
estadd local Year "2004"

eststo est2: rdrobust change_ideam_m2 sh_votes_left if year==2001 | year==2004 | year==2008, all p(2) kernel(tri)
estadd local Year "2004"
gl h1=e(h_l)

eststo est3: rdrobust change_ideam_m2 sh_votes_left if year==2001 | year==2004 | year==2008, all p(3) kernel(tri)
estadd local Year "2004"

*Table 
esttab est1 est2 est3 using ${tables}/rd_change_04_left.tex, se keep(Robust) stats(N N_h_l h_l p kernel Year, labels(N "N eff." Bw Poly Kernel "2003 election year")) star(* 0.1 ** 0.05 *** 0.01) booktabs replace

*Plot 
rdplot change_ideam_m2  sh_votes_left if (year==2001 | year==2004 | year==2008) & abs(sh_votes_left)<=${h1}, h(${h1}) all p(2) kernel(tri)  nbins(50 50) 
gr export ${plots}/rdplot_change_04_left.pdf, replace as(pdf)

*RD for forest cover change in percentage using 2006
eststo est1: rdrobust change_ideam_m2 sh_votes_left if year==2001 | year==2006 | year==2008, all p(1) kernel(tri)
estadd local Year "2006"

eststo est2: rdrobust change_ideam_m2 sh_votes_left if year==2001 | year==2006 | year==2008, all p(2) kernel(tri)
estadd local Year "2006"

eststo est3: rdrobust change_ideam_m2 sh_votes_left if year==2001 | year==2006 | year==2008, all p(3) kernel(tri)
estadd local Year "2006"

*Table 
esttab est1 est2 est3 using ${tables}/rd_change_06_left.tex, se keep(Robust) stats(N N_h_l h_l p kernel Year, labels(N "N eff." Bw Poly Kernel "2003 election year")) star(* 0.1 ** 0.05 *** 0.01) booktabs replace

*-------------------------------------------------------------------------------
* Results for the right
*-------------------------------------------------------------------------------
*RD for forest cover change in m2 using 2004 
eststo est1: rdrobust forestcover_change_ideam sh_votes_right if year==2001 | year==2004 | year==2008, all p(1) kernel(tri)
estadd local Year "2004"

eststo est2: rdrobust forestcover_change_ideam sh_votes_right if year==2001 | year==2004 | year==2008, all p(2) kernel(tri)
estadd local Year "2004"

eststo est3: rdrobust forestcover_change_ideam sh_votes_right if year==2001 | year==2004 | year==2008, all p(3) kernel(tri)
estadd local Year "2004"

*Table 
esttab est1 est2 est3 using ${tables}/rd_forestcover_04_right.tex, se keep(Robust) stats(N N_h_l h_l p kernel Year, labels(N "N eff." Bw Poly Kernel "2003 election year")) star(* 0.1 ** 0.05 *** 0.01) booktabs replace

*RD for forest cover change in m2 using 2006
eststo est1: rdrobust forestcover_change_ideam sh_votes_right if year==2001 | year==2006 | year==2008, all p(1) kernel(tri)
estadd local Year "2006"

eststo est2: rdrobust forestcover_change_ideam sh_votes_right if year==2001 | year==2006 | year==2008, all p(2) kernel(tri)
estadd local Year "2006"

eststo est3: rdrobust forestcover_change_ideam sh_votes_right if year==2001 | year==2006 | year==2008, all p(3) kernel(tri)
estadd local Year "2006"

*Table 
esttab est1 est2 est3 using ${tables}/rd_forestcover_06_right.tex, se keep(Robust) stats(N N_h_l h_l p kernel Year, labels(N "N eff." Bw Poly Kernel "2003 election year")) star(* 0.1 ** 0.05 *** 0.01) booktabs replace

*RD for forest cover change in percentage using 2004 
eststo est1: rdrobust change_ideam_m2 sh_votes_right if year==2001 | year==2004 | year==2008, all p(1) kernel(tri)
estadd local Year "2004"

eststo est2: rdrobust change_ideam_m2 sh_votes_right if year==2001 | year==2004 | year==2008, all p(2) kernel(tri)
estadd local Year "2004"

eststo est3: rdrobust change_ideam_m2 sh_votes_right if year==2001 | year==2004 | year==2008, all p(3) kernel(tri)
estadd local Year "2004"

*Table 
esttab est1 est2 est3 using ${tables}/rd_change_04_right.tex, se keep(Robust) stats(N N_h_l h_l p kernel Year, labels(N "N eff." Bw Poly Kernel "2003 election year")) star(* 0.1 ** 0.05 *** 0.01) booktabs replace

*RD for forest cover change in percentage using 2006
eststo est1: rdrobust change_ideam_m2 sh_votes_right if year==2001 | year==2006 | year==2008, all p(1) kernel(tri)
estadd local Year "2006"

eststo est2: rdrobust change_ideam_m2 sh_votes_right if year==2001 | year==2006 | year==2008, all p(2) kernel(tri)
estadd local Year "2006"

eststo est3: rdrobust change_ideam_m2 sh_votes_right if year==2001 | year==2006 | year==2008, all p(3) kernel(tri)
estadd local Year "2006"

*Table 
esttab est1 est2 est3 using ${tables}/rd_change_06_right.tex, se keep(Robust) stats(N N_h_l h_l p kernel Year, labels(N "N eff." Bw Poly Kernel "2003 election year")) star(* 0.1 ** 0.05 *** 0.01) booktabs replace


*-------------------------------------------------------------------------------
* 					  FE of political elections cycles
*
*-------------------------------------------------------------------------------
use forestloss_00_18_races.dta, clear

*Merging ideology data
destring codmpio, replace
merge m:1 codmpio year_elections using winner_ideology.dta, keep(1 3)
merge 1:1 codmpio year using permits.dta, keep(1 3) nogen

*Fixing ANLA permits 
replace permits=0 if permits==.

*Declaring the panel 
tsset codmpio year

*Creating elections year dummy 
gen election=1 if inlist(year, 2000, 2003, 2007, 2011, 2015)
replace election=0 if election==.

*Dummy for winner's ideology
gen left=(ideology==1) if ideology!=.
gen right=(ideology==2) if ideology!=. 

*Close race 
summ sh_votes_winner, d
gen close1=(sh_votes_winner<`r(p1)')
gen close5=(sh_votes_winner<`r(p5)')
gen close10=(sh_votes_winner<`r(p10)')
gen close25=(sh_votes_winner<`r(p25)')
gen close50=(sh_votes_winner<`r(p50)')


*-------------------------------------------------------------------------------
* Results for forest loss share 
*-------------------------------------------------------------------------------
*Effect of elections on forest loss share 
reghdfe loss_area00 election sh_coca indrural i.year, a(i.codmpio)
outreg2 using ${tables}/loss_area00_election.tex, keep(election) nocons tex(fragment) replace 

reghdfe loss_area00 election L1.election F1.election L2.election F2.election sh_coca indrural i.year, a(i.codmpio)
outreg2 using ${tables}/loss_area00_election.tex, keep(election L.election F.election L2.election ) nocons tex(fragment) append 


*Effect of elections and incumbent on forest loss share 
reghdfe loss_area00 i.election##i.incumbent sh_coca indrural i.year, a(i.codmpio)
outreg2 using ${tables}/loss_area00_incumbent.tex, keep(1.election 1.incumbent 1.election#1.incumbent ) nocons tex(fragment) replace 

reghdfe loss_area00 election##incumbent L1.election##incumbent F1.election##incumbent L2.election##incumbent F2.election##incumbent sh_coca indrural i.year, a(i.codmpio)
outreg2 using ${tables}/loss_area00_incumbent.tex, keep(1.election 1.incumbent 1.election#1.incumbent 1L.election 1L.election#1.incumbent 1F.election 1F.election#1.incumbent 1L2.election) nocons tex(fragment) append 

*Effect of elections on forest loss share for left winner
reghdfe loss_area00 i.election##i.left sh_coca indrural i.year, a(i.codmpio)
reghdfe loss_area00 election##i.left L1.election##left F1.election##left L2.election##left F2.election##left sh_coca indrural i.year, a(i.codmpio)

*Effect of elections on forest loss share for right winner
reghdfe loss_area00 i.election##i.right sh_coca indrural i.year, a(i.codmpio)
reghdfe loss_area00 election##right L1.election##right F1.election##right L2.election##right F2.election##right sh_coca indrural i.year, a(i.codmpio)

*Effect of close elections on forest loss share 
reghdfe loss_area00 election##i.close1 sh_coca indrural i.year, a(i.codmpio)
reghdfe loss_area00 election##i.close5 sh_coca indrural i.year, a(i.codmpio)
reghdfe loss_area00 election##i.close10 sh_coca indrural i.year, a(i.codmpio)

reghdfe loss_area00 election##close1 L1.election##close1 F1.election##close1 L2.election##close1 F2.election##close1 sh_coca indrural i.year, a(i.codmpio)
reghdfe loss_area00 election##close5 L1.election##close5 F1.election##close5 L2.election##close5 F2.election##close5 sh_coca indrural i.year, a(i.codmpio)
reghdfe loss_area00 election##close10 L1.election##close10 F1.election##close10 L2.election##close10 F2.election##close10 sh_coca indrural i.year, a(i.codmpio)
reghdfe loss_area00 election##close25 L1.election##close25 F1.election##close25 L2.election##close25 F2.election##close25 sh_coca indrural i.year, a(i.codmpio)


*-------------------------------------------------------------------------------
* Results for forest loss in km2  
*-------------------------------------------------------------------------------
*Effect of elections on forest loss in km2 
reghdfe loss_km2 election sh_coca indrural i.year, a(i.codmpio)
outreg2 using ${tables}/loss_km2_election.tex, keep(election) nocons tex(fragment) replace 

reghdfe loss_km2 election L1.election F1.election L2.election F2.election sh_coca indrural i.year, a(i.codmpio)
outreg2 using ${tables}/loss_km2_election.tex, keep(election L.election F.election L2.election ) nocons tex(fragment) append 

*Effect of elections and incumbent on forest loss in km2 
reghdfe loss_km2 i.election##i.incumbent sh_coca indrural i.year, a(i.codmpio)
outreg2 using ${tables}/loss_km2_incumbent.tex, keep(1.election 1.incumbent 1.election#1.incumbent ) nocons tex(fragment) replace 

reghdfe loss_km2 election##incumbent L1.election##incumbent F1.election##incumbent L2.election##incumbent F2.election##incumbent sh_coca indrural i.year, a(i.codmpio)
outreg2 using ${tables}/loss_km2_incumbent.tex, keep(1.election 1.incumbent 1.election#1.incumbent 1L.election 1L.election#1.incumbent 1F.election 1F.election#1.incumbent 1L2.election) nocons tex(fragment) append 

*Effect of elections on forest loss in km2 for left winner
reghdfe loss_km2 i.election##i.left sh_coca indrural i.year, a(i.codmpio)
reghdfe loss_km2 election##i.left L1.election##left F1.election##left L2.election##left F2.election##left sh_coca indrural i.year, a(i.codmpio)

*Effect of elections on forest loss in km2 for right winner
reghdfe loss_km2 i.election##i.right sh_coca indrural i.year, a(i.codmpio)
reghdfe loss_km2 election##right L1.election##right F1.election##right L2.election##right F2.election##right sh_coca indrural i.year, a(i.codmpio)

*Effect of close elections on forest loss share 
reghdfe loss_km2 election##i.close1 sh_coca indrural i.year, a(i.codmpio)
reghdfe loss_km2 election##i.close5 sh_coca indrural i.year, a(i.codmpio)
reghdfe loss_km2 election##i.close10 sh_coca indrural i.year, a(i.codmpio)

reghdfe loss_km2 election##close1 L1.election##close1 F1.election##close1 L2.election##close1 F2.election##close1 sh_coca indrural i.year, a(i.codmpio)
reghdfe loss_km2 election##close5 L1.election##close5 F1.election##close5 L2.election##close5 F2.election##close5 sh_coca indrural i.year, a(i.codmpio)
reghdfe loss_km2 election##close10 L1.election##close10 F1.election##close10 L2.election##close10 F2.election##close10 sh_coca indrural i.year, a(i.codmpio)
reghdfe loss_km2 election##close25 L1.election##close25 F1.election##close25 L2.election##close25 F2.election##close25 sh_coca indrural i.year, a(i.codmpio)


*-------------------------------------------------------------------------------
* Results for ANLA permits 
*-------------------------------------------------------------------------------
*Effect of elections on permits
reghdfe permits election sh_coca indrural i.year, a(i.codmpio)
outreg2 using ${tables}/permits_election.tex, keep(election) nocons tex(fragment) replace

reghdfe permits election L1.election F1.election L2.election F2.election sh_coca indrural i.year, a(i.codmpio)
outreg2 using ${tables}/permits_election.tex, keep(election L.election F.election L2.election ) nocons tex(fragment) append 

*Effect of elections and incumbent on permits
reghdfe permits i.election##i.incumbent sh_coca indrural i.year, a(i.codmpio)
outreg2 using ${tables}/permits_incumbent.tex, keep(1.election 1.incumbent 1.election#1.incumbent ) nocons tex(fragment) replace 

reghdfe permits election##incumbent L1.election##incumbent F1.election##incumbent L2.election##incumbent F2.election##incumbent sh_coca indrural i.year, a(i.codmpio)
outreg2 using ${tables}/permits_incumbent.tex, keep(1.election 1.incumbent 1.election#1.incumbent 1L.election 1L.election#1.incumbent 1F.election 1F.election#1.incumbent 1L2.election) nocons tex(fragment) append 

*Effect of close elections on permits
reghdfe permits election##i.close1 sh_coca indrural i.year, a(i.codmpio)
reghdfe permits election##i.close5 sh_coca indrural i.year, a(i.codmpio)
reghdfe permits election##i.close10 sh_coca indrural i.year, a(i.codmpio)





*END
