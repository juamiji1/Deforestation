# Data inputs

All three required files are present in this folder:

```
data/
├── Interim/
│   ├── defo_caralc.dta        57 MB   the analysis dataset
│   └── Desc_vars90.dta        76 KB   1990s department-level baselines
└── muniCAR/
    └── muni_neighbors.xls    530 KB   municipal adjacency pairs
```

They are **excluded from git** by `../.gitignore` — the repository stores code, not data. Ship them with the package when distributing it (zip the whole `JEEM-replication/` folder), or re-copy from the project data directory (`Dropbox/My-Research/Deforestation/data`) if they go missing.

| File | Used by | Notes |
|---|---|---|
| `defo_caralc.dta` | 12 of 14 scripts | municipality-year panel, output of `1_JEEM_preparing_data.do` |
| `muni_neighbors.xls` | `4_..._neighbors.do`, `4_..._sutva.do` | raw GIS export, no code produces it |
| `Desc_vars90.dta` | `2_JEEM_descriptives.do` only | feeds `ttest_states.tex`; **orphan — no code creates it**, see main README |

## defo_caralc.dta

The unit of observation is the municipality-year, restricted to municipalities where the mayoral winner or runner-up was politically aligned with the state governor. Key variables:

| Variable | Meaning |
|---|---|
| `floss_prim_ideam_area_v2` | primary forest lost, % of 2000 baseline cover — **main outcome** |
| `floss_prim_legal_area_v2` / `floss_prim_ilegal_area_v2` | legal / illegal components |
| `mayorallied` | mayor's party = governor's party — **treatment** |
| `z_sh_votes_alc` | aligned candidate's vote share − 0.5 — **running variable** |
| `director_gob_law_v2` | law mandates the governor as REPA board head |
| `sh_politics_law`, `dmdn_politics2` | politicians' share of REPA board seats, majority dummy |
| `region`, `year` | fixed effects |

To rebuild it from raw sources, run `code/do-files/1_JEEM_preparing_data.do` — outside the scope of this package.
