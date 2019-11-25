/*------------------------------------------------------------------------------
PROJECT: Ideology & deforestation
TOPIC: master do-file
DATE: 09-07-2019
AUTHORS: JMJR & LM
NOTES:

------------------------------------------------------------------------------*/

clear all 

*Paths 
if c(username) == "BFI User" {
	gl path "C:\Users/`c(username)'\Dropbox"
	gl do "C:\Users/`c(username)'\Documents\GitHub\Deforestation\do"
	gl work "C:\Users/`c(username)'\Documents\GitHub\Deforestation\work"
}
else {
	gl path "C:\Users/`c(username)'\Dropbox\Deforestation"
	gl do "C:\Users/`c(username)'\Documents\GitHub\Deforestation\do"
	gl work "C:\Users/`c(username)'\Documents\GitHub\Deforestation\work"
}

global data ${path}/Deforestacion\data
global logs ${path}/Deforestacion\logs
global maps ${path}/Maps

cd "${data}"


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
do "${do}\1. Data sets"

*-------------------------------------------------------------------------------
* 							B. Descriptive statistics
*
*-------------------------------------------------------------------------------
