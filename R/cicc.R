#' Upper bound on the average of log relative risk
#'
#' @param y n-dimensional vector of binary outcomes
#' @param t n-dimensional vector of binary treatments
#' @param x n by p matrix of matrix of covariates
#' @param p the upper bound for the unknown true case probability
#' @return estimate and standard error of the upper bound on the average of log relative risk
cicc = function(y,t,x,p){

  # Check whether p is between 0 and 1
  if (p <=0 || p >= 1){
    stop("'p' must be strictly between 0 and 1.")
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

  outputs = list("coefficients"=ub_est,"se"=ub_se)

  class(outputs) = "ciccr"
  outputs
}
