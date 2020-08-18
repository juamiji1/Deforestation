/*------------------------------------------------------------------------------
Topic: Estimations to explor political dynamics 

Date: 
Author: JMJR

NOTE: 
------------------------------------------------------------------------------*/


clear all 


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
