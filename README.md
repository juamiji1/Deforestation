# **Project:** Power Plays in the Jungle - Political Alignment and Environmental Degradation in Colombia  

**Author:** Juan Miguel Jimenez R.  
**Contact:** [juamiji@gmail.com](mailto:juamiji@gmail.com)

---

## Overview
This project examines how political dynamics shape environmental outcomes in Colombia, focusing on Regional Environmental Protection Agencies (REPAs). Using a regression discontinuity design (RDD) based on close mayoral elections, we find that when governors and mayors are politically aligned, *deforestation increases by about 60%*—especially where political actors dominate agency boards and around election years. Despite higher forest loss, *no gains in local income or public investment* are observed, suggesting that forests are being lost without broader social benefits. The findings highlight how institutional design can leave environmental governance vulnerable to political capture, underscoring the need for stronger safeguards.

---

## Environment Setup
To replicate results, ensure access to:

| Tool | Notes |
|------|-------|
| *Stata 19* | Main analysis and data processing |
| *Google Earth Engine* | Remote sensing data access |
| *Python 3.x* | Language used for GEE |
| *Jupyter Notebooks* | Python execution environment |
| *GitHub* | Version control |
| *Dropbox* | Data and output storage |

### Key Python Packages
`ee`, `geemap`, `pandas`, `jupyter`

---

## Directory Structure

| Location | Contents |
|-----------|-----------|
| `/Deforestation/data` | All raw and processed datasets |
| `/Deforestation/code` | Stata, and Python scripts |
| `/Overleaf/tables` | Tables for manuscript |
| `/Overleaf/plots` | Figures and plots |
| `/Overleaf/Politicians_Deforestation` | Main manuscript |
| `/Dropbox` | Shared data repository |

*Overleaf project:* [View here](https://www.overleaf.com/project/6535e4744c49b4c847ec1f56)

---

## Code Organization
All scripts are stored within the `/code` directory:  
- *Stata do-files:* located in `/code/do-files`  
- *Python notebooks:* located in `/code/python-scripts`  

Each file name begins with a numeric prefix indicating its role in the analysis pipeline:

| Prefix | Purpose |
|--------|----------|
| `0_` | Master pipeline coordination |
| `1_` | Data preparation and cleaning |
| `2_` | Descriptive analysis and RDD assumptions |
| `3_` | Main estimations |
| `4_` | Robustness checks and extensions |

---

## Pipeline for replication
The master file that coordinates the entire analysis pipeline is `0_JEEM_master.do`.

### 1. Data Preparation & Satellite Replication
| File | Description |
|------|--------------|
| `1_forestloss_measures_replication.ipynb` | Forest loss (Hansen GFC) |
| `1_forestloss_IDEAM_measures_replication.ipynb` | Forest loss (IDEAM) |
| `1_forestloss_illegal_measures_replication.ipynb` | Illegal deforestation |
| `1_primary_forest_measures_replication.ipynb` | Primary forest cover |
| `1_primary_forest_protected_measures_replication.ipynb` | Protected primary forests |
| `1_bii_measures_replication.ipynb` | Biodiversity Intactness Index |
| `1_land_change_replication.ipynb` | Land use change |
| `1_nl_measures_replication.ipynb` | Night lights analysis |
| `1_JEEM_preparing_data.do` | Data cleaning and merging |

---

### 2. Descriptives & RDD Assumptions
| File | Description |
|------|--------------|
| `2_JEEM_descriptives.do` | Descriptive statistics |
| `2_JEEM_RD_lc_assump.do` | RDD validity checks |

---

### 3. Main Analysis (RDD)
| File | Description |
|------|--------------|
| `3_JEEM_RD_main.do` | Main results |
| `3_JEEM_RD_mechs.do` | Mechanisms |
| `3_JEEM_RD_econchars.do` | Economic characteristics |
| `3_JEEM_RD_bii.do` | Biodiversity effects |

---

### 4. Robustness & Additional Analyses
| File | Description |
|------|--------------|
| `4_JEEM_RD_main_robustness.do` | Robustness checks |
| `4_JEEM_RD_main_lccontrols.do` | Land cover controls |
| `4_JEEM_RD_main_placebos.do` | Placebo tests |
| `4_JEEM_RD_main_plotslargebw.do` | RD plots (wide bandwidth) |
| `4_JEEM_RD_main_neighbors.do` | Neighbor-based analysis |

---

## Reproduction Guide
1. Clone the repository and pull the latest version.  
2. Mirror the Dropbox structure shown above.  
3. Authenticate with Google Earth Engine.  
4. Run the Jupyter notebooks to generate satellite indicators.  
5. Execute Stata scripts starting from `0_JEEM_master.do`.  
6. Export tables and plots for Overleaf.

---

For questions or issues, please contact the authors.

