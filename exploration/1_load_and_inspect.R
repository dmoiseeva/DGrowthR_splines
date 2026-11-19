# Install devtools
install.packages("devtools")

# Load the library
library(devtools)
install()
remotes::install_github("stefpeschel/permApprox")

# small experimental dataset
set.seed(42)

# 16 time measurements
time <- seq(0, 15, by = 1)

# Three illustrative microbial growth curves with different growth characteristics
growth <- function(t, amplitude, rate, midpoint) {
  0.05 + amplitude / (1 + exp(-rate * (t - midpoint)))
}

od_data <- data.frame(
  Time = time,
  curve_1 = growth(time, 1.2, 0.8, 6) +
    rnorm(length(time), 0, 0.015),
  curve_2 = growth(time, 1.0, 0.6, 7) +
    rnorm(length(time), 0, 0.015),
  curve_3 = growth(time, 0.45, 0.4, 9) +
    rnorm(length(time), 0, 0.015)
)

head(od_data)

# Experimental conditions associated with each curve
metadata <- data.frame(
  curve_id = c("curve_1", "curve_2", "curve_3"),
  treatment = c("control", "control", "drug_A")
)

metadata

# Raw measurements
matplot(
  od_data$Time,
  od_data[, -1],
  type = "b",
  pch = 16,
  xlab = "Time (h)",
  ylab = "Optical Density",
  main = "Synthetic microbial growth curves"
)

# first DGrowthR object
library(DGrowthR)

dgobj <- DGrowthRFromData(
  od_data = od_data,
  metadata = metadata
)

# Inspect the object
dgobj
class(dgobj)

# Which slots does the object contain?
slotNames(dgobj)

# Inspect the dimensions of stored data
dim(dgobj@raw_od)
dim(dgobj@metadata)

# Plot the growth curves through DGrowthR
plot_growth_curves(dgobj)

# Open the function in RStudio
View(fit_predict_gp)

# Set a debugging entry point
debugonce(fit_predict_gp)

# Log-transform OD measurements and subtract the baseline.
# raw_od remains unchanged; od_data is updated.

dgobj <- preprocess_data(
  dgobj,
  baseline = 1,
  log_transform = TRUE,
  skip_first_n_timepoints = 0
)

# Inspect preprocessed observations
head(dgobj@od_data)

# Plot preprocessed growth curves
plot_growth_curves(dgobj)


# Extract the observations belonging to curve_1.
# This fixes the previously undefined 'one_curve'.

one_curve <- gather_od_data(
  dgobj,
  metadata_field = "curve_id",
  field_value = "curve_1"
)

# Keep only the columns expected by fit_predict_gp().
one_curve <- one_curve[
  , c("timepoint", "timepoint_n", "od")
]

print(one_curve)

# Fit the GP and obtain predictions on 200 timepoints.
# prepare_dataframe=TRUE creates a convenient prediction table.
# estimate_derivatives=TRUE computes first and second derivatives.

gp_result <- fit_predict_gp(
  df = one_curve,
  t_steps = 200,
  complete_sigma = FALSE,
  prepare_dataframe = TRUE,
  estimate_derivatives = TRUE,
  delete = TRUE
)

# Inspect the complete result
names(gp_result)

# Inspect GP predictions
gp_prediction <- gp_result$prediction$prediction_dataframe

head(gp_prediction)
names(gp_prediction)

# Inspect fitted hyperparameters and convergence
gp_result$mle


library(ggplot2)

# Approximate 95% pointwise normal intervals.
gp_prediction$lower <- gp_prediction$mean -
  1.96 * sqrt(pmax(gp_prediction$diag.sigma, 0))

gp_prediction$upper <- gp_prediction$mean +
  1.96 * sqrt(pmax(gp_prediction$diag.sigma, 0))

p_single <- ggplot() + geom_point(data = one_curve,
                                  aes(x = timepoint, y = od),
                                  color = "grey40",
                                  size = 2) +
  geom_ribbon(
    data = gp_prediction,
    aes(x = timepoint, ymin = lower, ymax = upper),
    fill = "steelblue",
    alpha = 0.2
  ) +
  geom_line(
    data = gp_prediction,
    aes(x = timepoint, y = mean),
    color = "steelblue4",
    linewidth = 1.1
  ) +
  labs(
    title = "DGrowthR Gaussian Process Fit: curve_1",
    x = "Time (h)",
    y = "Baseline-corrected log(OD)"
  ) + theme_classic()

print(p_single)

# model_covariate="curve_id" fits one GP per curve.
# save_gp_data=TRUE retains predicted curves and derivatives.

fit_runtime <- system.time({

  dg_fitted <- estimate_growth_parameters(
    object = dgobj,
    model_covariate = "curve_id",
    predict_n_steps = 200,
    downsample_every_n_timepoints = 1,
    sample_posterior_gpfit = FALSE,
    save_gp_data = TRUE,
    n_cores = 1
  )

})

print(fit_runtime)

# Inspect the newly populated slots
slotNames(dg_fitted)

# Growth parameters for all three curves
growth_params <- dg_fitted@growth_parameters
print(growth_params)

# Predicted mean curves and derivatives
gp_all <- dg_fitted@gpfit_info$gpfit_data
head(gp_all)

# Link each observation to its GP model for faceting.
observed <- dg_fitted@od_data
observed$gpfit_id <- observed$curve_id

# Approximate 95% pointwise normal intervals
gp_all$lower <- gp_all$mean -
  1.96 * sqrt(pmax(gp_all$diag.sigma, 0))

gp_all$upper <- gp_all$mean +
  1.96 * sqrt(pmax(gp_all$diag.sigma, 0))

p_all <- ggplot() +

  geom_point(
    data = observed,
    aes(x = timepoint, y = od),
    color = "grey40",
    size = 1.5
  ) +

  geom_ribbon(
    data = gp_all,
    aes(x = timepoint, ymin = lower, ymax = upper),
    fill = "steelblue",
    alpha = 0.2
  ) +

  geom_line(
    data = gp_all,
    aes(x = timepoint, y = mean),
    color = "steelblue4",
    linewidth = 1
  ) +

  facet_wrap(~gpfit_id) +

  labs(
    title = "DGrowthR: Three Gaussian Process Fits",
    x = "Time (h)",
    y = "Baseline-corrected log(OD)"
  ) +

  theme_classic()

print(p_all)

derivative_data <- rbind(

  data.frame(
    timepoint = gp_all$timepoint,
    gpfit_id = gp_all$gpfit_id,
    derivative = "First derivative",
    value = gp_all$first_derivative
  ),

  data.frame(
    timepoint = gp_all$timepoint,
    gpfit_id = gp_all$gpfit_id,
    derivative = "Second derivative",
    value = gp_all$second_derivative
  )

)

p_derivatives <- ggplot(
  derivative_data,
  aes(
    x = timepoint,
    y = value,
    color = gpfit_id
  )
) +

  geom_hline(
    yintercept = 0,
    linetype = "dashed",
    color = "grey60"
  ) +

  geom_line(linewidth = 1) +

  facet_wrap(
    ~derivative,
    ncol = 1,
    scales = "free_y"
  ) +

  labs(
    title = "GP First and Second Derivatives",
    x = "Time (h)",
    y = "Derivative",
    color = "Curve"
  ) +

  theme_classic()

print(p_derivatives)

dir.create("results", showWarnings = FALSE)

write.csv(
  gp_all,
  "results/gp_predictions.csv",
  row.names = FALSE
)

write.csv(
  growth_params,
  "results/growth_parameters.csv",
  row.names = FALSE
)

ggsave(
  "results/gp_fits.png",
  p_all,
  width = 9,
  height = 5,
  dpi = 300
)

ggsave(
  "results/gp_derivatives.png",
  p_derivatives,
  width = 9,
  height = 6,
  dpi = 300
)
