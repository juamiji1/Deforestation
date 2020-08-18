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
