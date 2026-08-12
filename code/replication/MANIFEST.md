# Manifest — exhibit → source

Every table and figure the submitted manuscript loads, and the script that writes it.

Derived by extracting all `\input{}` and `\includegraphics{}` calls from the manuscript archive (`YJEEM_103335.zip`, 1 April 2026) and matching them against the export statements in the code. Exhibits that appear only in commented-out LaTeX are excluded.

Line numbers refer to `do-files/` in this package.

---

## Tables

| Output | Script | Line |
|---|---|---|
| `rdd_main_results.tex` | `3_JEEM_RD_main.do` | 174 |
| `rdd_mechs_results_alldefo_combined.tex` | `3_JEEM_RD_mechs.do` | 64 |
| `rdd_mechs_results_alldefo.tex` | `3_JEEM_RD_mechs.do` | 162 |
| `rdd_mechs_results_privgains.tex` | `3_JEEM_RD_mechs.do` | 461 |
| `rdd_mechs_results_privgains_govhead.tex` | `3_JEEM_RD_mechs.do` | 504 |
| `rdd_mechs_results_illdefo_combined.tex` | `3_JEEM_RD_mechs.do` | 550 |
| `rdd_mechs_results_legdefo_combined.tex` | `3_JEEM_RD_mechs.do` | 595 |
| `rdd_mechs_results_p1.tex` | `3_JEEM_RD_mechs.do` | 754 |
| `rdd_mechs_results_p2.tex` | `3_JEEM_RD_mechs.do` | 779 |
| `rd_econchars_results.tex` | `3_JEEM_RD_econchars.do` | 134 |
| `rdd_bii_results.tex` | `3_JEEM_RD_bii.do` | 48 |
| `rd_lc_results.tex` | `2_JEEM_RD_lc_assump.do` | 283 |
| `rd_lc_results_collapsed.tex` | `2_JEEM_RD_lc_assump.do` | 395 |
| `rd_lc_treatment_imbalanced.tex` | `2_JEEM_RD_lc_assump.do` | 472 |
| `rdplot_lc_results_geovars.tex` | `2_JEEM_RD_lc_assump.do` | 754 |
| `rdplot_lc_results_demovars.tex` | `2_JEEM_RD_lc_assump.do` | 771 |
| `rdplot_lc_results_econvars.tex` | `2_JEEM_RD_lc_assump.do` | 788 |
| `rdd_placebo_lluvia.tex` | `4_JEEM_RD_main_placebos.do` | 126 |
| `rdd_main_results_term.tex` | `4_JEEM_RD_main_electerm.do` | 72 |
| `ttest_states.tex` | `2_JEEM_descriptives.do` | 268 |

---

## Figures

**`2_JEEM_descriptives.do`**
`kdensity_sh_memberstype` · `desc_OLS_plot` · `desc_OLS_plot_bygovhead` · `desc_all_yearly_trend` · `desc_all_yearly_trend_bygovhead` · `desc_OLS_bii_plot` · `desc_OLS_bii_plot_bygovhead`

**`2_JEEM_RD_lc_assump.do`**
`mccraryplot_z_sh_votes_alc` · `rdplot_lc_results_geovars` · `rdplot_lc_results_demovars` · `rdplot_lc_results_econvars`

**`2_JEEM_RD_lc_assump_rdplots.do`** — 27 individual balance plots, `rdplot_<var>.pdf`, from three loops:

| Loop | Variables |
|---|---|
| Geographic | `ln_area` `sh_area` `pre_sh_area_agro` `sh_area_forest` `sh_paarea` `altura` `ruggedness` `mean_sut_crops` `ln_dist_mcados` |
| Demographic | `ln_pobl_tot93` `pobl_tot93_dens` `pre_indrural` `mean_gini` `pre_crime_rate` `pre_crime_env_rate` `pre_crime_forest_rate` `pre_sh_votes_alc` `pre_incumbent_gob` |
| Economic | `pre_ln_va` `pre_ln_nl` `pre_desemp_fisc_index` `pre_ln_regalias` `pre_ln_inv_total` `pre_sh_invenv` `pre_sh_area_coca` `pre_sh_area_bovino` `pre_floss_prim_ideam_area` |

**`3_JEEM_RD_main.do`**
`rdplot_main_results` · `rdplot_main_results_illegal` · `rdplot_main_results_legal` · `rdplot_main_sample_all` · `rdplot_main_sample_govheadyes` · `rdplot_main_sample_govheadno`

**`3_JEEM_RD_mechs.do`**
`rdplot_mechs_results_alldefo` · `rdplot_mechs_results_illdefo` · `rdplot_mechs_results_legdefo`

**`3_JEEM_RD_econchars.do`**
`coefplot_rd_econchars` · `coefplot_rd_econchars_govhead`

**`3_JEEM_RD_bii.do`**
`rdplot_bii_results` · `rdplot_bii_sample_all` · `rdplot_bii_sample_govheadyes` · `rdplot_bii_sample_govheadno` · `rdplot_bii_results_bwrobust` · `rdplot_bii_results_bwrobust_gobhead` · `rdplot_bii_results_bwrobust_gobnothead`

**`4_JEEM_RD_main_robustness.do`**
`rdplot_main_results_cl_coddane` · `rdplot_main_results_cl_carcode` · `rdplot_main_results_bwrobust` · `rdplot_main_results_bwrobust_gobhead` · `rdplot_main_results_bwrobust_gobnothead`

**`4_JEEM_RD_main_lccontrols.do`**
`rdplot_main_results_lccontrols`

**`4_JEEM_RD_main_placebos.do`**
`rdplot_main_results_placebo_pos10` · `rdplot_main_results_placebo_neg10`

**`4_JEEM_RD_main_plotslargebw.do`**
`rdplot_main_sample_all_largerange` · `rdplot_main_sample_govheadyes_largerange` · `rdplot_main_sample_govheadno_largerange`

**`4_JEEM_RD_main_neighbors.do`**
`rdplot_main_results_neighbors` · `rdplot_main_results_neighbors_illegal` · `rdplot_main_results_neighbors_legal`

**`4_JEEM_RD_main_sutva.do`**
`rdplot_main_results_sutvaout` · `rdplot_main_results_sutvaoutext` · `rdplot_main_results_illegal_sutvaout` · `rdplot_main_results_illegal_sutvaoutext` · `rdplot_main_results_legal_sutvaout` · `rdplot_main_results_legal_sutvaoutext`

**`4_JEEM_RD_main_electerm.do`**
`rdd_main_results_term` · `rdd_main_results_term_bh` · `rdplot_incumbency_term` · `rdplot_incumbency_term_bh`

---

## Not produced by this package

| Exhibit | Reason |
|---|---|
| `rdd_placebo_post.tex` | no code exists — never committed |
| `rdd_placebo_join.tex` | no code exists — never committed |
| `rdplot_main_results_90controls.pdf` | no code exists — never committed |
| `map_muni_floss_prim_ideam_area_v2.pdf` | map, external GIS |
| `map_muni_primary_forest_01.pdf` | map, external GIS |
| `CARs_deptos.pdf` | map, external GIS |
| `floss_macarena.png` | `code/python-scripts/1_floss_macarena.ipynb`, out of scope |

`2_JEEM_descriptives.do` also writes `desc_forestpermits.pdf`, which the submitted manuscript does not use.
