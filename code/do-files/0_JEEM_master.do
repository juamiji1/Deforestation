/*------------------------------------------------------------------------------
PROJECT: 
AUTHOR: JMJR
TOPIC: Master do-file
DATE:

NOTES: DO META!!!!! high deforestation!!!
------------------------------------------------------------------------------*/

clear all 

*Setting directories 
if c(username) == "juami" {
	gl localpath "C:\Users/`c(username)'\Dropbox\My-Research\Deforestation"
	gl overleafpath "C:\Users/`c(username)'\Dropbox\Overleaf\Politicians_Deforestation"
	gl code "C:\Github\Deforestation\code\do-files"
	
}
else {
	*gl path "C:\Users/`c(username)'\Dropbox\"
}

gl data "${localpath}\data"
gl tables "${overleafpath}\tables"
gl plots "${overleafpath}\plots"

cd "${data}"

*Setting a pre-scheme for plots
set scheme s2mono
grstyle init
grstyle title color black
grstyle color background white
grstyle color major_grid white


END

*-------------------------------------------------------------------------------
* Work flow 
*
*-------------------------------------------------------------------------------
do "${code}\1_JEEM_preparing_data.do"

do "${code}\2_JEEM_descriptives.do"
do "${code}\2_JEEM_RD_lc_assump.do"

do "${code}\3_JEEM_RD_main.do"
do "${code}\3_JEEM_RD_mechs.do"
do "${code}\3_JEEM_RD_econchars.do"

do "${code}\4_JEEM_RD_main_robustness.do"
do "${code}\4_JEEM_RD_main_lccontrols.do"
do "${code}\4_JEEM_RD_main_placebos.do"
do "${code}\4_JEEM_RD_main_plotslargebw.do"
do "${code}\4_JEEM_RD_main_neighbors.do"
do "${code}\4_JEEM_RD_main_electerm.do"

do "${code}\3_JEEM_RD_bii.do"






*END