# Project: Power Plays in the Jungle - Political Alignment and Environmental Degradation in Colombia

**Name**: Juan Miguel Jimenez R.

**Contact information**: juamiji@gmail.com

## What is the project?
We examine how political dynamics shape environmental outcomes in Colombia, focusing on the role of Regional Environmental Protection Agencies (REPAs). To identify causal effects, we implement a regression discontinuity design based on close mayoral elections. We find that when governors, who sit on the boards of REPAs, are politically aligned with local mayors, deforestation rises sharply—by about 60 percent. The problem is most pronounced in agencies where political actors dominate decision-making and around election years. Crucially, additional deforestation does not translate into local economic gains or higher public investment, suggesting that forests are being lost without broader social benefit. These findings highlight how institutional design can leave environmental governance vulnerable to political capture, and underscore the need for safeguards that protect natural resources from short-term political interests.

## Set-up
To replicate this project, you will need to have Stata-16, R-studio, Python with Google Earth Engine access, Jupyter notebooks, GitHub, and access to Dropbox.

### Required Software and Packages
- **Stata 16** or higher
- **R-studio** with spatial analysis packages
- **Python 3.x** with the following packages:
  - Google Earth Engine (`ee`)
  - `geemap`
  - `pandas`
  - `jupyter`
- **GitHub** for version control
- **Dropbox** for data storage

### Dropbox Structure
The main folders used in this project are:

| Path | Description |
| ---- | ----------- |
| `/My-Research/Deforestation/data` | Contains all datasets used in this project |
| `/Overleaf/Politicians_Deforestation/tables` | Contains all tables for the manuscript |
| `/Overleaf/Politicians_Deforestation/plots` | Contains all figures and plots |
| `/Github/Deforestation/code` | Contains all code used in this project |

### Overleaf
The project manuscript is available on Overleaf: https://www.overleaf.com/project/6535e4744c49b4c847ec1f56

| Path | Description |
| ---- | ----------- |
| `/plots` | Has all plots used in the draft |
| `/tables` | Has all tables used in the draft |

## What are the steps taken to conduct this work?
The steps to replicate all work can be viewed in the master do-file of the project (`C:/Github/Deforestation/code/0_JEEM_master.do`) which lists all do-files, R scripts, and Jupyter notebooks, and allows you to follow the pipeline. However, we ***do not*** recommend running it entirely since this project is data intensive and requires Google Earth Engine authentication.

**Note**: Before starting work please ***do not forget*** to pull from the origin to your local machine.

### Code folder explanation
The structure of the analysis pipeline is organized as follows:

| Prefix | Description |
| ---- | ----------- |
| `0_` | Master file |
| `1_` | Files with this prefix clean and prepare the raw data |
| `3_` | Files with this prefix make the main estimations |
| `4_` | Files with this prefix perform additional analysis |

### Key Analysis Files

### 1. Data Preparation and Replication of Satellite Data
| File | Description |
|------|--------------|
| `0_JEEM_master.do` | Master file that coordinates the entire analysis pipeline |
| `1_forestloss_measures_replication.ipynb` | Forest loss analysis using Hansen Global Forest Change data |
| `1_forestloss_IDEAM_measures_replication.ipynb` | Forest loss analysis using IDEAM data |
| `1_forestloss_illegal_measures_replication.ipynb` | Illegal deforestation measures |
| `1_primary_forest_measures_replication.ipynb` | Primary forest measure |
| `1_primary_forest_protected_measures_replication.ipynb` | Primary forest measure in protected areas |
| `1_bii_measures_replication.ipynb` | Biodiversity Intactness Index data |
| `1_land_change_replication.ipynb` | Land use change data |
| `1_nl_measures_replication.ipynb` | Night lights data |
| `1_JEEM_preparing_data.do` | Data cleaning and merging all together |

### 2. Descriptives and Empirical Strategy Assumptions
| File | Description |
|------|--------------|
| `2_JEEM_descriptives.do` | Descriptive statistics |
| `2_JEEM_RD_lc_assump.do` | Testing RDD assumptions |

### 3. Main Analysis (Regression Discontinuity Design)
| File | Description |
|------|--------------|
| `3_JEEM_RD_main.do` | Main regression discontinuity results |
| `3_JEEM_RD_mechs.do` | Mechanism analysis |
| `3_JEEM_RD_econchars.do` | Economic characteristics analysis |
| `3_JEEM_RD_bii.do` | Biodiversity loss results |

### 4. Robustness and Additional Analyses
| `4_JEEM_RD_main_robustness.do` | Robustness checks for main results |
| `4_JEEM_RD_main_lccontrols.do` | Analysis with LC controls |
| `4_JEEM_RD_main_placebos.do` | Placebo tests |
| `4_JEEM_RD_main_plotslargebw.do` | RD-plots in a large bandwidth |
| `4_JEEM_RD_main_neighbors.do` | Neighbor-based analysis |

## Getting Started
1. Clone the repository and pull the latest changes
2. Set up your Dropbox directory structure as outlined above
3. Authenticate with Google Earth Engine
4. Run the satellite data notebooks to generate the required datasets
5. Execute the Stata analysis pipeline starting with data preparation
6. Generate tables and figures using the specified do-files

For questions or issues, please contact the project author at the email address provided above.
