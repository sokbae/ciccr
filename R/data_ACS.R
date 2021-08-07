#' ACS
#'
#' A random sample extracted from American Community Survey (ACS) 2018, restricted to white males residing in California with at least a bachelor's degree.
#' The original ACS dataset is not from case-population sampling, but this case-population sample is obtained by the following procedure.
#' The random sample is composed of 17,816 individuals whose age is restricted to be between 25 and 70.
#' @format A data frame with 17,816 rows and 4 variables:
#' \describe{
#'   \item{age}{age, in years}
#'   \item{ind}{industry code, in four digits}
#'   \item{baplus}{1 if a respondent has a master’s degree, a professional degree, or a doctoral degree; 0 otherwise}
#'   \item{topincome}{1 if income is top-coded; 0 otherwise}
#' }
#' @source \url{https://usa.ipums.org/usa/}
"ACS"
