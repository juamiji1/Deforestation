# Replication Package — Results

**Paper:** *Power Plays in the Jungle — Political Alignment and Environmental Degradation in Colombia*
**Author:** Juan Miguel Jimenez R. ([juamiji@gmail.com](mailto:juamiji@gmail.com))

---

## Scope

This package reproduces the **results** of the paper: every table and figure generated from the analysis dataset by the estimation code.

**Out of scope, by design:**

| Excluded | Why | Where it lives |
|---|---|---|
| Data construction | `1_JEEM_preparing_data.do` merges ~25 raw sources into the analysis dataset | `code/do-files/` |
| Satellite measures | Google Earth Engine notebooks, require GEE authentication and hours of compute | `code/python-scripts/` |
| Maps | Drawn in external GIS software from `map_inputs.csv` | not versioned |

The analysis dataset is taken as given. See [Known gaps](#known-gaps) for the four exhibits this package cannot produce.

---

## Contents

```
replication/
├── 0_JEEM_master_replication.do   run this
├── _install_packages.do           Stata packages, run once
├── MANIFEST.md                    every exhibit → script that makes it
├── do-files/                      14 analysis scripts
├── data/                          the 3 input files (present, not versioned)
└── output/
    ├── tables/                    .tex fragments land here
    └── plots/                     .pdf figures land here
```

---

## How to run

1. **Install packages.** Uncomment the `_install_packages.do` line in the master, run once, re-comment. Requires internet.

2. **Check the data.** All three input files are already in `data/` — see [data/README-DATA.md](data/README-DATA.md). They are excluded from git, so zip the whole `replication/` folder when distributing the package.

3. **Set the path.** Edit one line at the top of `0_JEEM_master_replication.do`:

   ```stata
   gl repl "C:/Github/Deforestation/code/replication"
   ```

   Everything else derives from it. The master aborts with a clear message if the data isn't found.

4. **Run** `0_JEEM_master_replication.do`. Output goes to `output/tables/` and `output/plots/` — never to Dropbox or Overleaf.

Built and tested on **Stata 19**.

---

## Pipeline

| Script | Produces |
|---|---|
| `2_JEEM_descriptives.do` | descriptive figures, state-level t-test table |
| `2_JEEM_RD_lc_assump.do` | McCrary test, balance tables, treatment-predictability test |
| `2_JEEM_RD_lc_assump_rdplots.do` | 27 balance RD-plots (appendix) |
| `3_JEEM_RD_main.do` | **main results** — total / illegal / legal forest loss |
| `3_JEEM_RD_mechs.do` | mechanisms — board composition, green governor, election year |
| `3_JEEM_RD_econchars.do` | economic characteristics (the "no local benefit" result) |
| `3_JEEM_RD_bii.do` | Biodiversity Intactness Index |
| `4_JEEM_RD_main_robustness.do` | SE clustering, bandwidth grids |
| `4_JEEM_RD_main_lccontrols.do` | controlling for imbalanced baseline characteristics |
| `4_JEEM_RD_main_placebos.do` | placebo cutoffs (±10pp), rainfall placebo |
| `4_JEEM_RD_main_plotslargebw.do` | RD plots over a wider vote-margin range |
| `4_JEEM_RD_main_neighbors.do` | spillovers to neighboring municipalities |
| `4_JEEM_RD_main_sutva.do` | SUTVA checks, dropping treated neighbors |
| `4_JEEM_RD_main_electerm.do` | results aggregated to the electoral term |

Each script is self-contained: it loads the analysis dataset itself and re-derives its own bandwidth, weights, and controls. They can be run individually in any order, not only through the master.

**Specification.** All estimates follow equation (1): local linear RD with a triangular kernel, region and year fixed effects, at the CCT optimal bandwidth (0.098). Implemented by calling `rdrobust` to select the bandwidth, constructing triangular weights `1-|z/h|`, then estimating via `reghdfe` so that fixed effects and `esttab` export are available.

---

## Differences from the working code

The scripts are copies of `code/do-files/`, with two edits, both marked `REPLICATION PACKAGE:` in the source:

1. **`2_JEEM_descriptives.do`** — the *Maps* block, which writes `map_inputs.csv` for external GIS, is commented out. It produces no paper exhibit, and disabling it keeps the package from writing into `data/`.

2. **`2_JEEM_RD_lc_assump_rdplots.do`** — the optimal bandwidth is now derived at the top of the file. In the working version `${h}` was used on line 10 but not defined until line 22; it resolved only because the preceding script left the global behind in the same Stata session. Same `rdrobust` call, same bandwidth, but the file now runs standalone.

No estimation code, sample restriction, or specification was changed.

---

## Known gaps

Four exhibits in the submitted manuscript cannot be produced by this package.

**No code exists anywhere in the project** — not in the do-files, not in `zold/`, and `git log -S` finds them in no commit in the repository's history. They were produced in interactive Stata sessions whose code was never saved:

| Exhibit | Last written |
|---|---|
| `rdd_placebo_post.tex` | 30 Mar |
| `rdd_placebo_join.tex` | 19 Mar |
| `rdplot_main_results_90controls.pdf` | 13 Nov |

**Out of scope by design:** the maps (`map_muni_floss_prim_ideam_area_v2.pdf`, `map_muni_primary_forest_01.pdf`, `CARs_deptos.pdf`) and `floss_macarena.png`, the last of which comes from `code/python-scripts/1_floss_macarena.ipynb`.

One further caveat on inputs: **`Desc_vars90.dta` is itself an orphan.** It is required here and ships as an input, but no code in the project creates it. Its predecessor `lcvars90.dta` was built by `code/zold/NEW_placebo_polmajority.do`; `Desc_vars90.dta` is a later regeneration whose script was never committed. It feeds `ttest_states.tex` only.

---

## Verification

The `.tex` table fragments produced by this code were checked byte-for-byte against the frozen copies inside the submitted manuscript archive (`YJEEM_103335.zip`, 1 April 2026). `rdd_main_results`, `rdd_bii_results`, `rdd_mechs_results_alldefo_combined`, `rd_econchars_results`, and `rd_lc_results` are identical.
