# Store the preprocessed result in a new object
dg_pre <- preprocess_data(dgobj)

# Compare raw and processed growth curves
plot_growth_curves(dgobj)
plot_growth_curves(dg_pre)

# Inspect the processed object
slotNames(dg_pre)
str(dg_pre@od_data, max.level = 2)
