/*------------------------------------------------------------------------------
PROJECT: Ideology & deforestation
TOPIC: master do-file
DATE: 09-07-2019
AUTHORS: JMJR & LM
NOTES:

------------------------------------------------------------------------------*/

clear all 

*Setting directories 
if c(username) == "jmjimenez" {
	gl path "C:\Users/`c(username)'\Dropbox\My-Research\Deforestation"
	gl do "C:\Users/`c(username)'\Documents\GitHub\Deforestation\do"
	gl maps "C:\Users/`c(username)'\Dropbox\My-Research\Maps"
}
else {
	gl path "C:\Users/`c(username)'\Dropbox\Deforestation"
}

gl data ${path}/data
gl logs ${path}/logs
gl work ${path}/work
gl plots ${work}/plots
gl tables ${work}/tables

cd "${data}"

*Setting a pre-scheme for graphs
grstyle init
grstyle title color black
grstyle color background white
grstyle color major_grid dimgray

*-------------------------------------------------------------------------------
* 							A. Preparing data sets
*
*-------------------------------------------------------------------------------

/*1. Data sets: this do creates 
				- elections_panel.dta 
				- municipios.dta
				- departamentos.dta
				- forestloss_00_18.dta
				- elections_forestloss_00_18.dta
*/

do "${do}\1. Data-sets.do"

*-------------------------------------------------------------------------------
* 							B. Descriptive statistics
*
*-------------------------------------------------------------------------------

do "${do}\2. Descriptives.do"


*-------------------------------------------------------------------------------
* 							C. Estimations at the year level 
*
*-------------------------------------------------------------------------------

do "${do}\3. Estimations.do"


*-------------------------------------------------------------------------------
* 							C. Estimations at the year level 
*
*-------------------------------------------------------------------------------

do "${do}\4. Estimations-election-year.do"


do "${do}\5. Estimations-election-dynamics.do"

*END