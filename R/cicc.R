#' @title Causal Inference for Relative Risk
#'
#' @description Provides an upper bound on the average of log relative risk
#'
#' @param y n-dimensional vector of binary outcomes
#' @param t n-dimensional vector of binary treatments
#' @param x n by p matrix of covariates
#' @param p a specified upper bound for the unknown true case probability (default = 1)
#'
#' @return An S3 object of type "ciccr". The object has the following elements.
#' \item{est}{a scalar estimate of the upper bound on the average of log relative risk}
#' \item{se}{standard error}
#'
#' @examples
#' # use the ACS dataset included in the package
#'   y = ciccr::ACS$topincome
#'   t = ciccr::ACS$baplus
#'   x = ciccr::ACS$age
#' # The upper bound for Pr(y=1) is set as p = 1 by default
#'   cicc(y, t, x)
#' # The upper bound for Pr(y=1) is set as p = 0.2 if a plausible upper bound is avaiable
#'   cicc(y, t, x, 0.2)
#' @references Sung Jae Jun and Sokbae Lee. Causal Inference in Case-Control Studies.
#' \url{https://arxiv.org/abs/2004.08318}.
#'
#' @export
cicc = function(y, t, x, p = 1L){

  # Check whether p is in (0,1]
  if (p <=0L || p > 1L){
    stop("'p' must be in (0,1].")
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
    ub_est = est_control*(1-p) + est_case*p
    ub_var = (se_control*(1-p))^2 + (se_case*p)^2
    ub_se = sqrt(ub_var)
  }

  outputs = list("est"=ub_est,"se"=ub_se)
  class(outputs) = "ciccr"

  outputs
}
