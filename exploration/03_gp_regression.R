# Fit the three curves separately
dg_fit <- estimate_growth_parameters(
  dg_pre,
  model_covariate = "curve_id",
  predict_n_steps = 100,
  save_gp_data = TRUE,
  n_cores = 1
)

# Inspect what changed
slotNames(dg_fit)

# Check the documented plotting function
args(plot_gp)

# Inspect the growth-parameter object
str(dg_fit@growth_parameters, max.level = 2)

# Extract the measurements for one curve
one_curve <- gather_od_data(
  dg_pre,
  metadata_field = "curve_id",
  field_value = "curve_1"
)

head(one_curve)
names(one_curve)

# Fit the GP directly
gp_result <- fit_predict_gp(
  df = one_curve,
  t_steps = 100,
  prepare_dataframe = TRUE,
  estimate_derivatives = TRUE
)

# Inspect the returned structure
names(gp_result)
str(gp_result, max.level = 2)
