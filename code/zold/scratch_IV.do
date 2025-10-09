

eststo x1: areg floss_prim_ideam_area_v2 if dmdn_politics==0 & director_gob_law==0, a(year) vce(cl coddane)
eststo x2: areg floss_prim_ideam_area_v2 if dmdn_politics==0 & director_gob_law==1, a(year) vce(cl coddane)
eststo x3: areg floss_prim_ideam_area_v2 if dmdn_politics==1 & director_gob_law==0, a(year) vce(cl coddane)
eststo x4: areg floss_prim_ideam_area_v2 if dmdn_politics==1 & director_gob_law==1, a(year) vce(cl coddane)

coefplot x1 x2 x3 x4, vert 




*------
ivreghdfe floss_prim_ideam_area_v2 (director_gob_law = dmdn_politics), abs(year) vce(robust) first
ivreghdfe floss_prim_ideam_area_v2 (director_gob_law = dmdn_politics) if mayorallied==1, abs(year) vce(robust) first
ivreghdfe floss_prim_ideam_area_v2 (director_gob_law = dmdn_politics) if mayorallied==0, abs(year) vce(robust) first

ivreghdfe floss_prim_ideam_area_v2 (director_gob_law = dmdn_politics), abs(year) vce(cluster coddane) first
ivreghdfe floss_prim_ideam_area_v2 (director_gob_law = dmdn_politics) if mayorallied==1, abs(year) vce(cluster coddane) first
ivreghdfe floss_prim_ideam_area_v2 (director_gob_law = dmdn_politics) if mayorallied==0, abs(year) vce(cluster coddane) first







cap drop dmdn_politics
gen dmdn_politics=(sh_private_law>=.5) if sh_private_law!=.


binscatter floss_prim_ideam_area_v2 sh_private_law, n(100)
binscatter floss_prim_ideam_area_v2 sh_ethnias_law, n(100)
binscatter floss_prim_ideam_area_v2 sh_academics_law, n(100)
binscatter floss_prim_ideam_area_v2 sh_envngo_law, n(100)
binscatter floss_prim_ideam_area_v2 sh_politics_law, n(100)
binscatter floss_prim_ideam_area_v2 sh_politics2_law, n(100)


binscatter floss_prim_ideam_area_v2 sh_private, n(100)
binscatter floss_prim_ideam_area_v2 sh_ethnias, n(100)
binscatter floss_prim_ideam_area_v2 sh_academics, n(100)
binscatter floss_prim_ideam_area_v2 sh_envngo, n(100)
binscatter floss_prim_ideam_area_v2 sh_politics, n(100)
binscatter floss_prim_ideam_area_v2 sh_politics2, n(100)



mean floss_prim_ideam_area_v2 if dmdn_politics==0 & director_gob_law==0 & year>2000 & year<2021, over(year)
mat b0=e(b)
mat coln b0 = 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20

mean floss_prim_ideam_area_v2 if dmdn_politics==0 & director_gob_law==1 & year>2000 & year<2021, over(year)
mat b1=e(b)
mat coln b1 = 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20

mean floss_prim_ideam_area_v2 if dmdn_politics==1 & director_gob_law==0 & year>2000 & year<2021, over(year)
mat b2=e(b)
mat coln b2 = 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20

mean floss_prim_ideam_area_v2 if dmdn_politics==1 & director_gob_law==1 & year>2000 & year<2021, over(year)
mat b3=e(b)
mat coln b3 = 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20

coefplot (mat(b0[1]), label("0") mcolor("gs9")) (mat(b2[1]), label("1") color("gs6")), vert noci recast(connected)

 ///
(mat(b2[1]), label("2") mcolor("gs9")) (mat(b3[1]), label("3") color("gs6")) 



gen x = 12 if year==2012
replace x = 13 if year==2013
replace x = 14 if year==2014
replace x = 15 if year==2015
replace x = 16 if year==2016

gen y = 17 if x!=.


mean floss_prim_ideam_area_v2 if dmdn_politics==1 & director_gob_law==0 & year>2000 & year<2021, over(year)
mat b0=e(b)
mat coln b0 = 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20

mean floss_prim_ideam_area_v2 if director_gob_law==1 & year>2000 & year<2021, over(year)
mat b1=e(b)
mat coln b1 = 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20

coefplot (mat(b0[1]), label("0") mcolor("gs9")) (mat(b1[1]), label("1") color("gs6")), vert noci recast(connected)







coefplot (mat(b0[1]), label("Politicians minority") mcolor("gs9")) (mat(b1[1]), label("Politicians majority") color("gs6")), vert noci recast(connected) xline(4, lp(dash)) xline(8, lp(dash)) xline(12, lp(dash)) xline(16, lp(dash)) xline(20, lp(dash))  l2title("Primary Forest Loss (%)", size(medsmall)) b2title("Years", size(medsmall)) addplot(scatteri 16 12 16 13 16 14 16 15 16 16, recast(area) color(gs5%20) lcolor(white) base(0)) plotregion(margin(zero))



binscatter floss_prim_ideam_area_v2 sh_sameparty_gov, n(100)
binscatter floss_prim_ideam_area_v2 sh_sameparty_gov if dmdn_politics==0, n(100)
binscatter floss_prim_ideam_area_v2 sh_sameparty_gov if dmdn_politics==1, n(100)

two (scatter floss_prim_ideam_area_v2 sh_sameparty_gov) (lfit floss_prim_ideam_area_v2 sh_sameparty_gov)
two (scatter floss_prim_ideam_area_v2 sh_sameparty_gov if dmdn_politics==0) (lfit floss_prim_ideam_area_v2 sh_sameparty_gov if dmdn_politics==0)
two (scatter floss_prim_ideam_area_v2 sh_sameparty_gov if dmdn_politics==1) (lfit floss_prim_ideam_area_v2 sh_sameparty_gov if dmdn_politics==1)


scatter floss_prim_ideam_area_v2 sh_sameparty_gov if dmdn_politics==0
scatter floss_prim_ideam_area_v2 sh_sameparty_gov if dmdn_politics==1

summ sh_sameparty_gov, d
gen all_sameparty=(sh_sameparty_gov>=.1) if sh_sameparty_gov!=.



eststo x1: areg floss_prim_ideam_area_v2 if dmdn_politics==0 & director_gob_law==0 & all_sameparty==0, a(year) vce(cl coddane)
eststo x2: areg floss_prim_ideam_area_v2 if dmdn_politics==0 & director_gob_law==0 & all_sameparty==1, a(year) vce(cl coddane)

eststo x3: areg floss_prim_ideam_area_v2 if dmdn_politics==0 & director_gob_law==1 & all_sameparty==0, a(year) vce(cl coddane)
eststo x4: areg floss_prim_ideam_area_v2 if dmdn_politics==0 & director_gob_law==1 & all_sameparty==1, a(year) vce(cl coddane)

eststo x1: areg floss_prim_ideam_area_v2 if dmdn_politics==1 & director_gob_law==0 & all_sameparty==0, a(year) vce(cl coddane)
eststo x2: areg floss_prim_ideam_area_v2 if dmdn_politics==1 & director_gob_law==0 & all_sameparty==1, a(year) vce(cl coddane)

eststo x3: areg floss_prim_ideam_area_v2 if dmdn_politics==1 & director_gob_law==1 & all_sameparty==0, a(year) vce(cl coddane)
eststo x4: areg floss_prim_ideam_area_v2 if dmdn_politics==1 & director_gob_law==1 & all_sameparty==1, a(year) vce(cl coddane)





eststo x2: areg floss_prim_ideam_area_v2 if dmdn_politics==0 & all_sameparty==1, a(year) vce(cl coddane)
eststo x3: areg floss_prim_ideam_area_v2 if dmdn_politics==1 & all_sameparty==0, a(year) vce(cl coddane)
eststo x4: areg floss_prim_ideam_area_v2 if dmdn_politics==1 & all_sameparty==1, a(year) vce(cl coddane)

coefplot x1 x2 x3 x4 , vert 



two (scatter floss_prim_ideam_area_v2 sh_votes_gob) (lfit floss_prim_ideam_area_v2 sh_votes_gob)












/*
summ sh_politics2_law, d

cap drop z_sh_politics2_law
gen z_sh_politics2_law=sh_politics2_law - .5

rdrobust floss_prim_ideam_area_v2 z_sh_politics2_law, c(0) fuzzy(director_gob_law) all kernel(tri) masspoints(check) // the RD bw ends up being the same sample.. 