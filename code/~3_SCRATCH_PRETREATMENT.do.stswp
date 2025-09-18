
use "${data}/Interim\defo_caralc.dta", clear 

*-------------------------------------------------------------------------------
* Labels
*
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
* Main Results
*
*-------------------------------------------------------------------------------
summ z_sh_votes_alc, d

rdrobust floss_prim_ideam_area_v2 z_sh_votes_alc, all kernel(triangular)
gl h = e(h_l)
gl ht= round(${h}, .001)
gl p = e(p)
gl k = e(kernel)
gl if "if abs(z_sh_votes_alc)<=${h}"
gl controls "mayorallied i.mayorallied#c.z_sh_votes_alc z_sh_votes_alc"

cap drop tweights
gen tweights=(1-abs(z_sh_votes_alc/${h})) ${if}

eststo clear

*All municipalities 
eststo r1: reghdfe floss_prim_ideam_area_v2 ${controls} [aw=tweights] ${if} & director_gob_law_v2!=., abs(year) vce(robust)

gen rdsample=1 if e(sample)==1

duplicates tag coddane if rdsample==1, g(dup)

tab dup mayorallied

unique coddane if rdsample==1

*-------------------------------------------------------------------------------
* Creating preperiod
*-------------------------------------------------------------------------------
sort coddane year

by coddane: egen XT=max(mayorallied) if rdsample==1
by coddane: gen DT=mayorallied[_n]-mayorallied[_n-1] if rdsample==1

by coddane: egen minY1=min(year) if DT==1 & rdsample==1 & XT==1
by coddane: egen minY0=min(year) if DT==0 & rdsample==1 & XT==0

gen minY=minY1 if XT==1 & rdsample==1
replace minY=minY0 if XT==0 & rdsample==1 & minY==.
replace minY=minY-1

tab minY

*-------------------------------------------------------------------------------
* Stats defo ilegal vs legal 
*-------------------------------------------------------------------------------
tabstat floss_prim_legal_area_v2 if minY!=., by(director_gob_law_v2) s(N mean sd min p5 p25 p50 p75 p95 max) 
tabstat floss_prim_ilegal_area_v2 if minY!=., by(director_gob_law_v2) s(N mean sd min p5 p25 p50 p75 p95 max)  
tabstat sh_floss_prim_ilegal if minY!=., by(director_gob_law_v2) s(N mean sd min p5 p25 p50 p75 p95 max) 

tabstat floss_prim_legal_area_v2 if minY!=., by(carcode_master) s(N mean sd min p5 p25 p50 p75 p95 max) 
tabstat floss_prim_ilegal_area_v2 if minY!=., by(carcode_master) s(N mean sd min p5 p25 p50 p75 p95 max) 
tabstat sh_floss_prim_ilegal if minY!=., by(carcode_master) s(N mean sd min p5 p25 p50 p75 p95 max) 

*-------------------------------------------------------------------------------
* Regs
*-------------------------------------------------------------------------------
*All municipalities 
eststo r1: reghdfe sh_floss_prim_ilegal ${controls} [aw=tweights] ${if} & director_gob_law_v2!=., abs(year) vce(robust)

*Municipalities under a CAR in which Gobernor is mandated as director 
eststo r2: reghdfe sh_floss_prim_ilegal ${controls} [aw=tweights] ${if} & director_gob_law_v2==1, abs(year) vce(robust)

*Municipalities under a CAR in which Gobernor is NOT mandated as director 
eststo r3: reghdfe sh_floss_prim_ilegal ${controls} [aw=tweights] ${if} & director_gob_law_v2==0, abs(year) vce(robust)

coefplot (r1, label(All)) (r2, label(Governor is head)) (r3, label(Governor not head)), keep(mayorallied) ///
coeflabels(mayorallied = " ") ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(cols(3)) xtitle("Primary Forest Loss (%)", size(medsmall)) ytitle("Partisan Alignment Between Mayor and Governor", size(medsmall)) ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2)



tabstat sh_floss_prim_ilegal if rdsample==1 & director_gob_law_v2!=., by(mayorallied) s(N mean sd min p5 p25 p50 p75 p95 max) 
tabstat sh_floss_prim_ilegal if rdsample==1 & director_gob_law_v2==1, by(mayorallied) s(N mean sd min p5 p25 p50 p75 p95 max) 
tabstat sh_floss_prim_ilegal if rdsample==1 & director_gob_law_v2==0, by(mayorallied) s(N mean sd min p5 p25 p50 p75 p95 max) 


reghdfe sh_floss_prim_ilegal mayorallied [aw=tweights] ${if} & director_gob_law_v2==1
reghdfe sh_floss_prim_ilegal mayorallied [aw=tweights] ${if} & director_gob_law_v2==0





