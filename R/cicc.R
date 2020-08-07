#' @title Causal Inference for Relative Risk
#'
#' @description Provides an upper bound on the average of log relative risk
#'
#' @param y n-dimensional vector of binary outcomes
#' @param t n-dimensional vector of binary treatments
#' @param x n by p matrix of covariates
#' @param p_upper a specified upper bound for the unknown true case probability (default = 1)
#' @param cov_prob parameter for coverage probability of a confidence interval (default = 0.95)
#' @param length_SA specified length of a sequence for snesitivity analysis (default = 20)
#'
#' @return An S3 object of type "ciccr". The object has the following elements:
#' \item{est}{a scalar estimate of the upper bound on the average of log relative risk}
#' \item{se}{standard error}
#' \item{ci}{upper end of confidence interval}
#' \item{estSA}{sensitivity analysis: (length_SA)-dimensional vector of the upper bounds on the average of log relative risk}
#' \item{seSA}{sensitivity analysis: (length_SA)-dimensional vector of pointwise standard errors}
#' \item{ciSA}{sensitivity analysis: (length_SA)-dimensional vector of the upper ends of pointwise confidence interval}
#'
#' @examples
#' # use the ACS dataset included in the package.
#'   y = ciccr::ACS$topincome
#'   t = ciccr::ACS$baplus
#'   x = ciccr::ACS$age
#' # The upper bound for Pr(y=1) is set as p_upper = 1 by default
#' # with the defaulty coverage probability of 0.95.
#'   cicc(y, t, x)
#' # The upper bound for Pr(y=1) is set as p_upper = 0.2
#' # with the coverage probablity of 0.99.
#'   cicc(y, t, x, 0.2, 0.99)
#' @references Sung Jae Jun and Sokbae Lee. Causal Inference in Case-Control Studies.
#' \url{https://arxiv.org/abs/2004.08318}.
#'
#' @export
cicc = function(y, t, x, p_upper = 1L, cov_prob = 0.95, length_SA = 20L){

  # Check whether p_upper is in (0,1]
  if (p_upper <=0L || p_upper > 1L){
    stop("'p_upper' must be in (0,1].")
  }

  # Check whether length_SA > 0
  if (length_SA <= 0){
    stop("'length_SA' must be greater than zero.")
  }

  results = avg_retro_logit(y,t,x,'case')
  est_case = results$est
  se_case = results$se

  results = avg_retro_logit(y,t,x,'control')
  est_control = results$est
  se_control = results$se

  if (est_control >= est_case){
    ub_est = est_control
    ub_se = se_control
  } else {
    ub_est = est_control*(1-p_upper) + est_case*p_upper
    ub_var = (se_control*(1-p_upper))^2 + (se_case*p_upper)^2
    ub_se = sqrt(ub_var)
  }

  cv_norm = stats::qnorm(cov_prob)
  ub_ci = ub_est + cv_norm*ub_se

  # Sensitivity analysis
  pseq = seq(from = 0, to = p_upper, length.out = ceiling(length_SA))
  xi = est_case*pseq + est_control*(1-pseq)
  xi_var = (se_case*pseq)^2 + (se_control*(1-pseq))^2
  xi_se = sqrt(xi_var)
  xi_ci = xi + cv_norm*xi_se

  outputs = list("est" = ub_est, "se" = ub_se, "ci" = ub_ci,
                 "est.SA" = xi, "se.SA" = xi_se, "ci.SA" = xi_ci)
  class(outputs) = "ciccr"

  outputs
}
