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
	gl do "C:\Github\Deforestation\code"
	
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
grstyle color major_grid dimgray

END

*-------------------------------------------------------------------------------
* Work flow 
*
*-------------------------------------------------------------------------------
do "${do}\1_JEEM_preparing_data.do"
*do "${do}\2_JEEM_descriptives.do"
*do "${do}\3_JEEM_RD_lc_scratch.do"
do "${do}\3_JEEM_RD_lc_assump.do"
do "${do}\3_JEEM_RD_main.do"
do "${do}\3_JEEM_RD_mechs.do"
do "${do}\4_JEEM_RD_econchars.do"





*END