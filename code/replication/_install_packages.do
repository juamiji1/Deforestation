/*------------------------------------------------------------------------------
User-written Stata packages required by this replication package.

Run once on a fresh Stata installation. Requires an internet connection.
Tested on Stata 19.
------------------------------------------------------------------------------*/

*Estimation
ssc install reghdfe, replace
ssc install ftools, replace        // reghdfe dependency

*Regression discontinuity (Calonico, Cattaneo, Titiunik)
ssc install rdrobust, replace      // provides rdrobust and rdplot
ssc install rddensity, replace     // manipulation / McCrary-type test
ssc install lpdensity, replace     // rddensity dependency

*Tables and figures
ssc install estout, replace        // provides eststo and esttab
ssc install coefplot, replace
ssc install grstyle, replace
ssc install palettes, replace      // grstyle dependency
ssc install colrspace, replace     // grstyle dependency
ssc install outreg, replace        // provides frmttable (ttest_states.tex)

*Data handling
ssc install carryforward, replace
ssc install unique, replace
ssc install labutil, replace       // provides labmask

*END
