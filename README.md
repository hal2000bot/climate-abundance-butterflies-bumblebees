# Climate sensitivity of butterfly and bumblebee abundance

Reproducible R code and model input data accompanying a manuscript examining associations between climate anomalies and monitored butterfly and bumblebee abundance in Norway.

**Scope:** This repository reproduces **only the final climate–abundance mixed model**. It does not reproduce model selection, or manuscript figures.

## Repository files

| File | Purpose |
| --- | --- |
| `climate_abundance_model_input_GITHUB.csv` | Model-ready observations (13 columns). |
| `climate_abundance_GITHUB.R` | Standalone script that imports the CSV and fits the final model. |
| `README.md` | Reproduction instructions and data dictionary. |
| `CITATION.cff` | GitHub citation metadata; **confirm author and publication metadata before release**. |
| `.gitignore` | Excludes generated outputs and R session files, but **does not exclude the input CSV**. |

## Requirements

- R (record and report the version used for the published analysis).
- R package [`glmmTMB`](https://cran.r-project.org/package=glmmTMB) and its dependencies.

Install the required package once from an R console:

```r
install.packages("glmmTMB")
```

No database credentials or NINA-specific packages are needed to run the **standalone model script**.

## Reproduce the final model

1. Download or clone the repository, including `climate_abundance_model_input.csv`.
2. From a terminal in the repository directory, run:

   ```bash
   Rscript 02_fit_climate_abundance_model.R
   ```

   Alternatively, open the script in RStudio, set the working directory to the repository root, and source the script.
3. The script prints the model summary, observation count, and AIC and writes:

   - `climate_abundance_fixed_effects.csv`: fixed-effect coefficient summary.
   - `climate_abundance_final_model.rds`: serialized fitted model object.

Those two files are generated outputs and are not committed by default.

## Final model

The response is `log_total_abundance_z`, a within-taxon-group-and-locality z-score of `log(1 + total abundance)` prepared in the original analysis. 

- Taxon-group-specific linear year effect and climate effects.
- Spring temperature to the third power, summer temperature to the second power, and previous-year late-summer temperature to the second power (all as raw powers of the standardized climate predictors, interacted with taxon group).
- Spring, summer, and previous-year late-summer precipitation predictors, interacted with taxon group.
- Habitat type, plus linear and quadratic flower-cover-anomaly effects.
- An AR(1) temporal correlation structure for annual observations within locality: `ar1(factor(year) + 0 | locality_id_abund)`.

The reference taxon is **Butterfly**; the other level is **Bumblebee**. Polynomial terms are calculated by the model script, not included in the CSV.

## Input data dictionary

The CSV has one row per observation used for the final fitted model and the following **13 columns**:

| Column | Description |
| --- | --- |
| `log_total_abundance_z` | Response: within-locality and taxon-group z-score of log(1 + total abundance). |
| `taxon_group` | `Butterfly` or `Bumblebee`. |
| `year_z` | Globally standardized observation year from the original analysis. |
| `habitat_type` | Habitat category. |
| `spring_temp` | Standardized locality-centered spring (March–May) mean temperature anomaly. |
| `summer_temp` | Standardized locality-centered summer (June–August) mean temperature anomaly. |
| `spring_precip` | Standardized locality-centered spring precipitation anomaly. |
| `summer_precip` | Standardized locality-centered summer precipitation anomaly. |
| `prev_late_temp` | Standardized locality-centered previous-year late-summer (August–September) temperature anomaly. |
| `prev_late_precip` | Standardized locality-centered previous-year late-summer precipitation anomaly. |
| `flower_cover_anom_z` | Globally standardized deviation of flower cover from its locality-by-taxon-group mean. |
| `locality_id_abund` | Monitoring locality identifier used to group repeated observations. |
| `year` | Calendar year of observation, used for the AR(1) structure. |

Temperature and precipitation anomalies were calculated using locality means and globally z-scored in the original workflow. The provided CSV contains these **already transformed** values: do not recalculate transformations from the restricted 13-column dataset. The exporter selects the same rows used in the original fitted model.

## For authors: create the CSV

The export script is **not** a standalone raw-data pipeline. To generate the input file before publication:

1. Run the original analysis through the final fit of `m2_ar1`, so `dat_main` and `m2_ar1` both exist in the current R session.
2. In the intended repository/output directory run:

   ```r
   source("01_export_climate_abundance_data.R")
   ```

3. Check that `climate_abundance_model_input.csv` was created.

The CSV is not generated from the code in this repository alone; it must first be exported from the authors' existing analysis environment.

## Citation and reuse

Use the GitHub **Cite this repository** menu. **No software or data license is granted by this repository package yet**: the authors/data owners should choose and add an appropriate `LICENSE` and, if necessary, separate data-use terms before public release.
