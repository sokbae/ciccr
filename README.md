
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ciccr

<!-- badges: start -->

<!-- badges: end -->

The goal of ciccr is to implement methods for carrying out causal
inference in case-control studies.

## Installation

You can install the released version of ciccr from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("ciccr")
```

Alternatively, you can install the development version from
[GitHub](https://github.com/)
with:

``` r
# install.packages("devtools") # uncomment this line if devtools is not installed yet 
devtools::install_github("sokbae/ciccr")
```

## Example

We first call the ciccr package.

``` r
library(ciccr)
```

To illustrate the usefulness of the package, we use the dataset ACS that
is included in the package. This dataset is an extract from American
Community Survey (ACS) 2018, restricted to white males residing in
California with at least a bachelor’s degree. The ACS is an ongoing
annual survey by the US Census Bureau that provides key information
about US population. We use the following variables:

``` r
  y = ACS$topincome
  t = ACS$baplus
  x = ACS$age
```

  - The binary outcome `y` is defined to be one if a respondent’s annual
    total pre-tax wage and salary income is top-coded. In the sample
    extract, the top-coded income bracket has median income $565,000 and
    the next highest income that is not top-coded is $327,000.

  - The binary treatment `t` is defined to be one if a respondent has a
    master’s degree, a professional degree, or a doctoral degree.

  - The covariate `x` is age in years and is restricted to be between 25
    and 70.

The original ACS survey is not from case-control sampling but we
construct a case-control sample by the following procedure:

1.  The case sample is composed of 921 individuals whose income is
    top-coded.
2.  The control sample of equal size is randomly drawn without
    replacement from the pool of individuals whose income is not
    top-coded.

We now construct cubic b-spline terms with three inner knots using the
age variable.

``` r
  x = splines::bs(x, df = 6)
```

Using the retrospective sieve logistic regression model, we estimate the
average of the log odds ratio conditional on the case sample by

``` r
  results_case = avg_retro_logit(y, t, x, 'case')
  results_case$est
#>         y 
#> 0.7286012
  results_case$se
#>         y 
#> 0.1013445
```

Here, option `'case'` refers to conditioning on the event that income is
top-coded.

Similarly, we estimate the average of the log odds ratio conditional on
the control sample by

``` r
  results_control = avg_retro_logit(y, t, x, 'control')
  results_control$est
#>         y 
#> 0.5469094
  results_control$se
#>         y 
#> 0.1518441
```

Here, option `'control'` refers to conditioning on the event that income
is not top-coded.

We carry out causal inference by

``` r
  results = cicc(y, t, x, p_upper = 0.2)
```

Here, 0.2 is the specified upper bound for unknown case probability. If
it is not specified, the default choice for `p` is `p = 1`.

``` r
  est = results$est
  print(est)
#>  [1] 0.5469094 0.5488219 0.5507345 0.5526470 0.5545596 0.5564721 0.5583847
#>  [8] 0.5602972 0.5622097 0.5641223 0.5660348 0.5679474 0.5698599 0.5717725
#> [15] 0.5736850 0.5755976 0.5775101 0.5794227 0.5813352 0.5832477
  se = results$se
  print(se)
#>  [1] 0.1518441 0.1502495 0.1486627 0.1470838 0.1455132 0.1439511 0.1423978
#>  [8] 0.1408536 0.1393188 0.1377937 0.1362787 0.1347740 0.1332800 0.1317971
#> [15] 0.1303256 0.1288660 0.1274187 0.1259841 0.1245626 0.1231546
  ci = results$ci
  print(ci)
#>  [1] 0.7966706 0.7959604 0.7952628 0.7945784 0.7939075 0.7932506 0.7926083
#>  [8] 0.7919808 0.7913688 0.7907728 0.7901933 0.7896308 0.7890860 0.7885594
#> [15] 0.7880516 0.7875633 0.7870953 0.7866480 0.7862224 0.7858191
```

The S3 objejct `results` contains a grid of estimates, standard errors
and one-sided confidence intervals ranging from `p = 0` to `p =
p_upper'. The default coverage probbabiilty is set at 0.95 and the
default length of the grid is 20. Both can can be changed in the`cicc’
command. For example, the following command sets the coverage
probability at 0.9 and the length of the grid at 30.

``` r
  results = cicc(y, t, x, p_upper = 0.2, cov_prob = 0.9, length = 30L)
```

The point and confidence interval estimates of the \`cucc’ command is
based on the scale of log relative risk. It is more conventional to look
at the results in terms of the relative scale. To do so, we take the
exponential:

``` r
  e_est = exp(est)
  e_ci = exp(ci)
```

It is handy to examine the results by ploting a graph.

TBD

## Reference

Sung Jae Jun and Sokbae Lee. Causal Inference in Case-Control Studies.
<https://arxiv.org/abs/2004.08318>.