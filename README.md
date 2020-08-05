
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ciccr

<!-- badges: start -->

<!-- badges: end -->

The goal of ciccr is to …

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
devtools::load_all(".")
#> Loading ciccr
## basic example code
```

To illustrate our method, we use the dataset ACS that is included the
packcage. This dataset is a extract from American Community Survey (ACS)
2018, restricted to white males residing in California with at least a
bachelor’s degree. The ACS is an ongoing annual survey by the US Census
Bureau that provides key information about US population. The included
variables are as follows:

``` r
  y = ACS$topincome
  t = ACS$baplus
  x = ACS$age
```

  - The binary outcome \`Top Income’ (\(Y\)) is defined to be one if a
    respondent’s annual total pre-tax wage and salary income is
    top-coded. In our sample extract, the top-coded income bracket has
    median income $565,000 and the next highest income that is not
    top-coded is $327,000.

  - The binary treatment (\(T\)) is defined to be one if a respondent
    has a master’s degree, a professional degree, or a doctoral degree.

  - The covariate (\(X\)) is age in years and is restricted to be
    between 25 and 70.

The original ACS sample is not a case-control sample but we construct
one by the following procedure.

1.  The case sample \((Y=1)\) is composed of 921 individuals whose
    income is top-coded.
2.  The control sample \((Y=0)\) of equal size is randomly drawn without
    replacement from the pool of individuals whose income is not
    top-coded.

We now construct cubic b-spline terms with three inner knots using the
age variable.

``` r
  x = splines::bs(x, df = 6)
```

Define \(\beta(y) = E [\log \text{OR}(X) | Y = y]\) for \(y = 0,1\),
where \(\text{OR}(x)\) is the odds ratio conditional on \(X=x\): \[
\text{OR}(x) = \frac{P(T=1|Y=1,X=x)}{P(T=0|Y=1,X=x)}\frac{P(T=0|Y=0,X=x)}{P(T=1|Y=0,X=x)}.
\] Using the retropspective sieve logistric regression model, we
estimate \(\beta(1)\) by

``` r
  results_case = avg_retro_logit(y,t,x,'case')
  results_case$est
#>         y 
#> 0.7286012
  results_case$se
#>         y 
#> 0.1013445
```

Here, option `'case'` refers to conditioning on \(Y=1\). Similarly, we
estimate \(\beta(0)\) by

``` r
  results_control = avg_retro_logit(y,t,x,'control')
  results_control$est
#>         y 
#> 0.5469094
  results_control$se
#>         y 
#> 0.1518441
```

Here, option `'control'` refers to conditioning on \(Y=1\). We now carry
out causal inference by

``` r
  cicc(y,t,x,0.2)
#> $coefficients
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
