install.packages("mgcv")
library(mgcv)

# Generate simulated growth data
set.seed(42)

time <- sort(runif(50, min = 0, max = 24))

# Simulated underlying growth curve
true_growth <- 1.8 / (1 + exp(-(time - 10) / 2))

# Add measurement noise
log_od <- true_growth + rnorm(50, mean = 0, sd = 0.08)

# Create a data frame
df <- data.frame(
  time = time,
  log_od = log_od
)

# Check its structure
head(df)
str(df)

# Fit a penalized cubic regression spline
model <- gam(
  log_od ~ s(time, bs = "cr", k = 10),
  data = df,
  family = gaussian(),
  method = "REML"
)

# Inspect the fitted model
summary(model)

# Visualize observations and spline
plot(df$time, df$log_od,
     pch = 16,
     xlab = "Time (h)",
     ylab = "log(OD)",
     main = "Microbial Growth: Cubic Regression Spline")

newdata <- data.frame(
  time = seq(0, 24, length.out = 200)
)

pred <- predict(model, newdata = newdata)

lines(newdata$time, pred,
      col = "blue", lwd = 2)

?mgcv::gam
?mgcv::s
?mgcv::predict.gam
?mgcv::gam.check

gam(log_od ~ s(time, bs = "cr", k = 10),
    data = df,
    method = "REML")
# gam()	Fits a generalized additive model
# s(time)	Estimates a smooth function of time
# bs = "cr"	Uses a cubic regression spline basis
# k = 10	Sets basis dimension, limiting maximum flexibility
# method = "REML" Estimates smoothing parameter by restricted maximum likelihood
# family = gaussian()	Assumes Gaussian response errors with identity link

# mgcv's several spline bases

# 1. Penalized cubic regression spline
model1 <- gam(
  log_od ~ s(time, bs = "cr", k = 10),
  data = df,
  method = "REML"
)

summary(model1)
plot(model1)

# 2. Cubic B-spline + second-derivative penalty
model_bs <- gam(
  log_od ~ s(time, bs = "bs", k = 10, m = c(3, 2)),
  data = df,
  method = "REML"
)

# 3. Cubic P-spline + second-difference penalty
model_ps <- gam(
  log_od ~ s(time, bs = "ps", k = 10, m = c(2, 2)),
  data = df,
  method = "REML"
)

# 4. Thin plate regression spline
model_tp <- gam(
  log_od ~ s(time, bs = "tp", k = 10),
  data = df,
  method = "REML"
)

# Compare fitted curves
plot(df$time, df$log_od,
     pch = 16,
     xlab = "Time (h)",
     ylab = "log(OD)",
     main = "Comparison of Spline Methods")

time_grid <- data.frame(
  time = seq(min(df$time), max(df$time), length.out = 200)
)

lines(time_grid$time, predict(model_bs, time_grid),
      col = "blue", lwd = 2)

lines(time_grid$time, predict(model_ps, time_grid),
      col = "red", lwd = 2)

lines(time_grid$time, predict(model_tp, time_grid),
      col = "darkgreen", lwd = 2)

legend("bottomright",
       legend = c("B-spline", "P-spline", "Thin plate"),
       col = c("blue", "red", "darkgreen"),
       lty = 1, lwd = 2)
