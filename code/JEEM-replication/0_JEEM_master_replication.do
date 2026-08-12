/*------------------------------------------------------------------------------
PROJECT: Power Plays in the Jungle - Political Alignment and Environmental
         Degradation in Colombia
AUTHOR:  Juan Miguel Jimenez R. (juamiji@gmail.com)
TOPIC:   Master do-file - REPLICATION PACKAGE (results only)

SCOPE:   Reproduces every table and figure in the paper that is generated from
         the analysis dataset. Data construction (1_JEEM_preparing_data.do, the
         Google Earth Engine notebooks) and the maps are NOT part of this
         package - see README.md.

USAGE:   1. Set the global `repl' below to the folder containing this file.
         2. Place the three required data files under `repl'/data (see
            data/README-DATA.md).
         3. Run this file.
------------------------------------------------------------------------------*/

clear all
set more off

*-------------------------------------------------------------------------------
* USER INPUT - set this to the folder containing this do-file
*-------------------------------------------------------------------------------
gl repl "C:/Github/Deforestation/code/JEEM-replication"

*-------------------------------------------------------------------------------
* Derived paths - do not edit
*-------------------------------------------------------------------------------
gl code   "${repl}/do-files"
gl data   "${repl}/data"
gl tables "${repl}/output/tables"
gl plots  "${repl}/output/plots"

*Fail early and loudly if the paths are wrong
cap confirm file "${data}/Interim/defo_caralc.dta"
if _rc {
	di as error "defo_caralc.dta not found in ${data}/Interim/"
	di as error "Check the global 'repl' above and see data/README-DATA.md"
	exit 601
}

cd "${data}"

*-------------------------------------------------------------------------------
* Required user-written packages
*-------------------------------------------------------------------------------
*Run once on a fresh Stata installation, then leave commented out
*do "${repl}/_install_packages.do"

*-------------------------------------------------------------------------------
* Plot scheme
*-------------------------------------------------------------------------------
set scheme s2mono
grstyle init
grstyle title color black
grstyle color background white
grstyle color major_grid white

*-------------------------------------------------------------------------------
* Work flow
*-------------------------------------------------------------------------------

*Descriptives and RD validity
do "${code}/2_JEEM_descriptives.do"
do "${code}/2_JEEM_RD_lc_assump.do"
do "${code}/2_JEEM_RD_lc_assump_rdplots.do"

*Main estimations
do "${code}/3_JEEM_RD_main.do"
do "${code}/3_JEEM_RD_mechs.do"
do "${code}/3_JEEM_RD_econchars.do"
do "${code}/3_JEEM_RD_bii.do"

*Robustness and extensions
do "${code}/4_JEEM_RD_main_robustness.do"
do "${code}/4_JEEM_RD_main_lccontrols.do"
do "${code}/4_JEEM_RD_main_placebos.do"
do "${code}/4_JEEM_RD_main_plotslargebw.do"
do "${code}/4_JEEM_RD_main_neighbors.do"
do "${code}/4_JEEM_RD_main_sutva.do"
do "${code}/4_JEEM_RD_main_electerm.do"

di as result "Replication complete. Output written to ${tables} and ${plots}"

*END
