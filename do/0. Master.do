/*------------------------------------------------------------------------------
PROJECT: Ideology & deforestation
TOPIC: master do-file
DATE: 09-07-2019
AUTHORS: JMJR & LM
NOTES:

------------------------------------------------------------------------------*/

clear all 

*Global for each user (JM or LM)
global user "JM"

if "${user}"=="JM"{
	* JM: Personal computer(C:\Users\USER) and WBG computer(C:\Users\WB548381).
	global path "C:\Users\WB548381"
}
else{
	global path "su path liz"
}

global data ${path}/Dropbox\Deforestacion\data
global do ${path}/Dropbox\Deforestacion\do
global logs ${path}/Dropbox\Deforestacion\logs
global work ${path}/Dropbox\Deforestacion\work
global maps ${path}/Dropbox\Maps

cd $data


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
