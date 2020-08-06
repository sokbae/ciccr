
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ciccr

<!-- badges: start -->

<!-- badges: end -->

The goal of ciccr is to implement inference methods described in the
paper entitled “Causal Inference in Case-Control Studies”.

## Installation

You can install the released version of ciccr from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("ciccr")
```

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("sokbae/ciccr")
```

## Example

``` r
library(ciccr)
```

To illustrate the usefulness of the package, we use the dataset ACS that
is included the packcage. This dataset is a extract from American
Community Survey (ACS) 2018, restricted to white males residing in
California with at least a bachelor’s degree. The ACS is an ongoing
annual survey by the US Census Bureau that provides key information
about US population. We use the following variables:

``` r
  y = ACS$topincome
  t = ACS$baplus
  x = ACS$age
```

  - The binary outcome \`Top Income’ is defined to be one if a
    respondent’s annual total pre-tax wage and salary income is
    top-coded. In our sample extract, the top-coded income bracket has
    median income $565,000 and the next highest income that is not
    top-coded is $327,000.

  - The binary treatment is defined to be one if a respondent has a
    master’s degree, a professional degree, or a doctoral degree.

  - The covariate is age in years and is restricted to be between 25 and
    70.

The original ACS sample is not a case-control sample but we construct
one by the following procedure.

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

Using the retropspective sieve logistric regression model, we estimate
the average of the log odds ratio conditional on the case sample by

``` r
  results_case = avg_retro_logit(y, t, x, 'case')
  results_case$est
#>         y 
#> 0.7286012
  results_case$se
#>         y 
#> 0.1013445
```

Here, option `'case'` refers to conditioning on \(Y=1\).

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

Here, option `'control'` refers to conditioning on \(Y=1\).

We carry out causal inference by

``` r
  cicc(y, t, x, 0.2)
#> $est
#>         y 
#> 0.5832477 
#> 
#> $se
#>         y 
#> 0.1231546 
#> 
#> attr(,"class")
#> [1] "ciccr"
```

Here, 0.2 is the specified upper bound for unknown
\(p = \text{Pr}(Y=1)\). If it is not specified, the dafault choice for
\(p\) is \(p = 1\).

``` r
  cicc(y, t, x)
#> $est
#>         y 
#> 0.7286012 
#> 
#> $se
#>         y 
#> 0.1013445 
#> 
#> attr(,"class")
#> [1] "ciccr"
```

# Reference

Sung Jae Jun and Sokbae Lee. Causal Inference in Case-Control Studies.
<https://arxiv.org/abs/2004.08318>.
