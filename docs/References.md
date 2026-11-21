
# Literature References — Spline Regression

This document collects the literature used for extending
DGrowthR with penalized spline regression and comparing
its performance against Gaussian process regression.

## 1. Spline Theory and Implementation

### Wood (2017)
**Generalized Additive Models: An Introduction with R**
Second Edition, CRC Press.

[Publisher link](https://doi.org/10.1201/9781315370279)

Relevant sections:
- Section 4.2: Univariate smoothing
- Section 5.2: Penalized regression splines
- Section 5.3: One-dimensional smoothers
- Section 5.9: Choosing the basis dimension
- Section 6.2: Smoothness selection criteria
- Chapter 7: GAMs in Practice — mgcv

### Fahrmeir et al. (2013)
**Regression: Models, Methods and Applications**
Springer.

[Publisher link](https://doi.org/10.1007/978-3-642-34333-9)

Relevant sections:
- Section 8.1.1: Polynomial splines
- Section 8.1.2: Penalized splines
- Section 8.1.4: Smoothing splines
- Section 8.1.9: Choosing the smoothing parameter

## 2. Gaussian Process Regression

### Rasmussen & Williams (2006)
**Gaussian Processes for Machine Learning**
MIT Press.

[Free online book](https://gaussianprocess.org/gpml/)

Relevant sections:
- Chapter 2: Regression
- Chapter 5: Model Selection
- Section 6.2: Regularization
- Section 6.3: Spline Models

## 3. Related Microbial Growth Literature

### Osthege et al. (2022)
**bletl — A Python package for integrating BioLector
microcultivation devices in the Design-Build-Test-Learn cycle**

[Publication](https://doi.org/10.1002/elsc.202100108)

Relevant section:
- Section 2.2.1: Spline approximations
