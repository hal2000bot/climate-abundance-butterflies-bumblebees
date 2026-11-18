# Dependency: glmmTMB (install.packages("glmmTMB") if necessary).
# The CSV already contains standardized variables from the original analysis.

if (!requireNamespace("glmmTMB", quietly = TRUE)) {
  stop("Package 'glmmTMB' is required. Install with install.packages('glmmTMB').")
}

input_file <- "climate_abundance_model_input_GITHUB.csv"
if (!file.exists(input_file)) stop("Input CSV not found: ", input_file)
dat <- utils::read.csv(input_file, check.names = FALSE,
                       stringsAsFactors = FALSE)

required <- c(
  "log_total_abundance_z", "taxon_group", "year_z", "habitat_type",
  "spring_temp", "summer_temp", "spring_precip", "summer_precip",
  "prev_late_temp", "prev_late_precip", "flower_cover_anom_z",
  "locality_id_abund", "year"
)
missing <- setdiff(required, names(dat))
if (length(missing)) stop("Input CSV is missing: ", paste(missing, collapse = ", "))
if (nrow(dat) == 0L || anyNA(dat[required])) {
  stop("Input CSV must contain nonempty, complete model data.")
}

# Explicit factor levels preserve the reference taxon (Butterfly) used in the
# original analysis, and preserve habitat labels as sorted factor levels.
if (!all(dat$taxon_group %in% c("Butterfly", "Bumblebee"))) {
  stop("Unexpected taxon group in CSV.")
}
dat$taxon_group <- factor(dat$taxon_group,
                          levels = c("Butterfly", "Bumblebee"))
dat$habitat_type <- factor(dat$habitat_type)
dat$locality_id_abund <- factor(dat$locality_id_abund)
dat$year <- as.integer(dat$year)

# These are raw powers of standardized predictors (NOT orthogonal polynomials).
dat$spring_temp2 <- dat$spring_temp^2
dat$spring_temp3 <- dat$spring_temp^3
dat$summer_temp2 <- dat$summer_temp^2
dat$prev_late_temp2 <- dat$prev_late_temp^2
dat$flower_cover_anom_z2 <- dat$flower_cover_anom_z^2

# Exact final model m2_ar1 from the original analysis: Gaussian response,
# group-specific year/climate terms, habitat, quadratic flower cover,
# and AR(1) dependence of yearly observations within locality.
m2_ar1 <- glmmTMB::glmmTMB(
  log_total_abundance_z ~
    taxon_group * year_z +
    habitat_type +
    taxon_group * spring_temp +
    taxon_group * spring_temp2 +
    taxon_group * spring_temp3 +
    taxon_group * summer_temp +
    taxon_group * summer_temp2 +
    taxon_group * spring_precip +
    taxon_group * summer_precip +
    taxon_group * prev_late_temp +
    taxon_group * prev_late_temp2 +
    taxon_group * prev_late_precip +
    flower_cover_anom_z +
    flower_cover_anom_z2 +
    ar1(factor(year) + 0 | locality_id_abund),
  data = dat,
  family = gaussian()
)

print(summary(m2_ar1))
cat("\nObservations:", stats::nobs(m2_ar1), "\n")
cat("AIC:", stats::AIC(m2_ar1), "\n")

# Optional standard outputs for checking reproduction.
utils::write.csv(as.data.frame(summary(m2_ar1)$coefficients$cond),
                 file = "climate_abundance_fixed_effects.csv")
saveRDS(m2_ar1, file = "climate_abundance_final_model.rds")
cat("Saved climate_abundance_fixed_effects.csv and climate_abundance_final_model.rds\n")
