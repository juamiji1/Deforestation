# Power plays in the jungle: Political alignment and environmental degradation in Colombia
### Authors: Jimenez, J.M., Molina Alvarez, L.M., & Saavedra, S. 
### Publication: *Journal of Environmental Economics and Management*, 2026, **138**, 103335. [**DOI: 10.1016/j.jeem.2026.103335**](https://doi.org/10.1016/j.jeem.2026.103335) · [ScienceDirect](https://www.sciencedirect.com/science/article/pii/S0095069626000550) · Open access

---

## Abstract

We examine how political dynamics shape environmental outcomes in Colombia, focusing on the role of Regional Environmental Protection Agencies (REPAs). To identify causal effects, we implement a regression discontinuity design based on close mayoral elections. Our results show that when governors—who sit on REPA boards—are politically aligned with local mayors, annual deforestation increases by 0.044 percentage points, or about 40 percent relative to the mean. The problem is most pronounced in agencies where political actors dominate decision-making. Crucially, additional deforestation does not translate into local economic gains, suggesting that forests are being lost without broader social benefit. These findings highlight how decentralized institutional design can leave environmental governance vulnerable to political capture, underscoring the need for safeguards in the governance structure of environmental authorities to protect natural resources from short-term political interests.

**Keywords:** Deforestation, Political Economy, Colombia
**JEL Classification:** P48, Q23

---

## Replicating the paper

**→ Everything you need is in [`code/replication/`](code/replication/).**

That folder is a self-contained package that reproduces every table and figure in the published paper from the analysis dataset. It ships with its own master do-file, the required data, a package installer, and a manifest mapping each exhibit to the script and line that produces it.

Start with [`code/replication/README.md`](code/replication/README.md). In short: set one path in `0_JEEM_master_replication.do` and run it. Output lands in `code/replication/output/`.

| | |
|---|---|
| **Software** | Stata 19 |
| **Runtime** | one pass over 14 scripts |
| **Data** | included in the package (`defo_caralc.dta`, 57 MB, not versioned in git) |
| **Scope** | results only — see below for data construction |

The replication package deliberately excludes data construction, the satellite-measure notebooks, and the maps. Those are documented below for anyone who wants to rebuild the analysis dataset from raw sources.

---

## Repository structure

```
code/
├── replication/        ← self-contained replication package (start here)
├── do-files/           working Stata code, including data construction
├── python-scripts/     Google Earth Engine notebooks
└── zold/               archived earlier approaches (DiD, IV, event study)

do/                     pre-2022 generation of the project, superseded
material/               reference notes and sources
```

Data lives outside the repository, in Dropbox (`My-Research/Deforestation/data`); the manuscript lives in a separate Overleaf project. The repository holds code only.

---

## Rebuilding the analysis dataset

Not required for replication — the finished dataset ships with the package. This is for extending the project or auditing the construction.

**1 · Satellite measures** (`code/python-scripts/`, Python + Google Earth Engine)

| Notebook | Measure |
|---|---|
| `1_forestloss_measures_replication.ipynb` | Forest loss (Hansen GFC) |
| `1_forestloss_IDEAM_measures_replication.ipynb` | Forest loss (IDEAM) |
| `1_forestloss_illegal_measures_replication.ipynb` | Illegal deforestation |
| `1_primary_forest_measures_replication.ipynb` | Primary forest cover |
| `1_primary_forest_pretected_measures_replication.ipynb` | Protected primary forests |
| `1_bii_measures_replication.ipynb` | Biodiversity Intactness Index |
| `1_land_change_replication.ipynb` | Land use change |
| `1_nl_measures_replication.ipynb` | Night lights |
| `fires_measures_replication.ipynb` | Fires and hotspots |

Requires GEE authentication and substantial compute. Key packages: `ee`, `geemap`, `pandas`, `jupyter`.

**2 · Merge** (`code/do-files/1_JEEM_preparing_data.do`)

Combines the satellite measures with roughly 25 administrative sources — electoral records, REPA board composition, Fiscalía environmental crimes, the ICA livestock census, IDEAM forest permits, CEDE municipal characteristics, and 1990s baselines — into `defo_caralc.dta`, the municipality-year analysis panel.

**3 · Analysis** — the scripts in `code/replication/do-files/`.

Maps are drawn in external GIS software from `map_inputs.csv` and are not reproducible from this repository.

---

## Identification at a glance

| Element | Variable | Definition |
|---|---|---|
| Outcome | `floss_prim_ideam_area_v2` | primary forest lost, % of 2000 baseline cover |
| Treatment | `mayorallied` | mayor's party = governor's party |
| Running variable | `z_sh_votes_alc` | aligned candidate's vote share − 0.5 |
| Moderator | `director_gob_law_v2` | law mandates the governor as REPA board head |

Sample: municipality-years where the mayoral winner or runner-up was aligned with the governor. Local linear RD, triangular kernel, region and year fixed effects, CCT optimal bandwidth of 9.8 percentage points — 1,293 observations inside the window.

---

## Contact

Juan Miguel Jimenez R. — [juamiji@gmail.com](mailto:juamiji@gmail.com)

*Maintainer note:* the manuscript source is in the private Overleaf project [6535e4744c49b4c847ec1f56](https://www.overleaf.com/project/6535e4744c49b4c847ec1f56).
