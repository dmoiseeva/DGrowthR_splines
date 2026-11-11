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

# Three illustrative microbial growth curves
# with different growth characteristics
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

# Experimental conditions associated with each curve
metadata <- data.frame(
  curve_id = c("curve_1", "curve_2", "curve_3"),
  treatment = c("control", "control", "drug_A")
)

head(od_data)
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

# What is stored in raw_od versus od_data?
# How does the curve_id connect metadata with measurements?
# Which slots are initially empty, and which become populated after fitting?

slotNames(dgobj)
