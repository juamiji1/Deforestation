# Project: Politicians and Deforestation - Environmental and Economic Effects

**Name**: Juan Miguel Jimenez R.

**Contact information**: juamiji@gmail.com

## What is the project?
This project investigates the relationship between political governance and deforestation patterns in Colombia. Using regression discontinuity design and satellite imagery analysis, we examine how political control and governance structures affect forest loss, environmental outcomes, and economic development. The analysis combines Google Earth Engine satellite data (Hansen Global Forest Change), administrative boundaries, and socioeconomic indicators to understand the long-term environmental and economic consequences of different governance regimes.

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
The project manuscript is available on Overleaf. 

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
| `0_` | Master files and data replication notebooks |
| `1_` | Files with this prefix clean and prepare the raw data |
| `3_` | Files with this prefix make the main estimations and analysis |
| `4_` | Files with this prefix perform additional economic analysis |
| `5_` | Files with this prefix conduct environmental and sustainability analysis |

### Key Analysis Files

#### Data Preparation and Replication
- `0_JEEM_master.do` - Master file that coordinates the entire analysis pipeline
- `1_JEEM_preparing_data.do` - Data cleaning and preparation
- `preparing_data.R` - R script for spatial data preparation

#### Jupyter Notebooks for Satellite Data Analysis
- `0_forestloss_measures_replication.ipynb` - Forest loss analysis using Hansen Global Forest Change data
- `0_forestloss_IDEAM_measures_replication.ipynb` - Forest loss analysis using IDEAM data
- `0_forestloss_illegal_measures_replication.ipynb` - Illegal deforestation measures
- `0_primary_forest_measures_replication.ipynb` - Primary forest analysis
- `0_bii_measures_replication.ipynb` - Biodiversity Intactness Index analysis
- `0_land_change_replication.ipynb` - Land use change analysis
- `0_nl_measures_replication.ipynb` - Night lights analysis
- `fires_measures_replication.ipynb` - Fire incidents analysis

#### Main Analysis (Regression Discontinuity)
- `3_JEEM_RD_main.do` - Main regression discontinuity results
- `3_JEEM_RD_main_robustness.do` - Robustness checks for main results
- `3_JEEM_RD_main_lccontrols.do` - Analysis with land cover controls
- `3_JEEM_RD_main_neighbors.do` - Neighbor-based analysis
- `3_JEEM_RD_main_placebos.do` - Placebo tests
- `3_JEEM_RD_lc_assump.do` - Land cover assumptions testing
- `3_JEEM_RD_bii.do` - Biodiversity analysis
- `3_JEEM_RD_mechs.do` - Mechanism analysis

#### Economic Analysis
- `4_JEEM_RD_econchars.do` - Economic characteristics analysis
- `4_JEEM_RD_main_term.do` - Term-based economic analysis

#### Additional Analysis
- `3_JEEM_descriptives.do` - Descriptive statistics
- `forest_loss_twfe.do` - Two-way fixed effects analysis for forest loss
- `forest_loss_twfe_v2.do` - Updated TWFE analysis
- `alternative_channels.do` - Alternative mechanism analysis

### Code source for tables - Guide
Below we can find what do-file generates the raw tables for each result included in the analysis:

| File | Table(s) that it makes |
| ---- | ----------- |
| `3_JEEM_RD_lc_assump.do` | Land cover assumptions and smooth condition tests |
| `3_JEEM_RD_main.do` | Main effects of political control on deforestation |
| `3_JEEM_RD_main_robustness.do` | Robustness analysis for main outcomes |
| `3_JEEM_RD_bii.do` | Effects on biodiversity measures |
| `3_JEEM_RD_mechs.do` | Mechanism analysis tables |
| `4_JEEM_RD_econchars.do` | Economic characteristics analysis |
| `3_JEEM_descriptives.do` | Descriptive statistics tables |
| `forest_loss_twfe.do` | Two-way fixed effects results |

## What has been done by others and by whom?
- Google Earth Engine satellite data processing and validation
- Administrative boundary data cleaning and geocoding
- Spatial analysis framework development

## What is the current status of the project? What remains to be done?
**Current Status**: 
- Main regression discontinuity analysis completed
- Satellite data processing pipeline established
- Robustness checks and mechanism analysis in progress

**Remaining Tasks**:
- Final robustness checks and sensitivity analysis
- Policy simulation analysis
- Final manuscript preparation

## Anything else we should know?
- **Google Earth Engine Access**: You will need to authenticate with Google Earth Engine to run the satellite data analysis notebooks.
- **Data Intensive**: Please do not try to run `0_JEEM_master.do` file all at once. We recommend running this file section by section.
- **Computational Requirements**: The satellite data analysis requires significant computational resources and internet connectivity.
- **Authentication**: Before running any GEE notebooks, make sure to run `ee.Authenticate()` and `ee.Initialize()`.
- **File Dependencies**: Some analysis files depend on outputs from the Jupyter notebooks, so run the notebooks first before the Stata analysis.

## Getting Started
1. Clone the repository and pull the latest changes
2. Set up your Dropbox directory structure as outlined above
3. Authenticate with Google Earth Engine
4. Run the satellite data notebooks to generate the required datasets
5. Execute the Stata analysis pipeline starting with data preparation
6. Generate tables and figures using the specified do-files

For questions or issues, please contact the project author at the email address provided above.
