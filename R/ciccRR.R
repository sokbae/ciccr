#' @title Causal Inference on Relative Risk
#'
#' @description Provides upper bounds on the average of log relative risk
#' under the monotone treatment response (MTR) and monotone treatment selection (MTS) assumptions.
#'
#' @param y n-dimensional vector of binary outcomes
#' @param t n-dimensional vector of binary treatments
#' @param x n by d matrix of covariates
#' @param sampling 'cc' for case-control sampling; 'cp' for case-population sampling (default sampling =  'cc')
#' @param cov_prob parameter for coverage probability of a uniform confidence band (default = 0.95)
#'
#' @return An S3 object of type "ciccr". The object has the following elements:
#' \item{est}{estimates of the upper bounds on the average of log relative risk at p=0 and p=1}
#' \item{se}{pointwise standard errors at p=0 and p=1}
#' \item{ci}{the upper end points of the uniform confidence band at p=0 and p=1}
#' \item{pseq}{two end points: p=0 and p=1}
#'
#' @examples
#' # use the ACS dataset included in the package.
#'   y = ciccr::ACS$topincome
#'   t = ciccr::ACS$baplus
#'   x = ciccr::ACS$age
#'
#'   ciccRR(y, t, x, sampling = 'cc', cov_prob = 0.95)
#'
#' @references Sung Jae Jun and Sokbae Lee. Causal Inference in Case-Control Studies.
#' \url{https://arxiv.org/abs/2004.08318}.
#'
#' @export
ciccRR = function(y, t, x, sampling = 'cc', cov_prob = 0.95){

  # Check whether sampling is either case-control or case-population
  if ( sum( !(sampling %in% c('cc','cp')) ) > 0 ){
    stop("'sampling' must be either 'cc' or 'cp'.")
  }

  if (sampling=='cc'){

    results = avg_retro_logit(y, t, x, 'case')
    est_case = results$est
    se_case = results$se

    results = avg_retro_logit(y, t, x, 'control')
    est_control = results$est
    se_control = results$se

    cv_norm = stats::qnorm(1-(1-cov_prob)/2) # two-sided normal critical value

    # Uniform confidence band for the upper bounds under case-control studies
    est = c(est_control, est_case)
    se = c(se_control, se_case)
    ci = est + cv_norm*max(se)

  }  else if (sampling=='cp'){

    results = avg_retro_logit(y, t, x, 'control')
    est = rep(results$est,2)
    se = rep(results$se,2)
    ci = est + stats::qnorm(cov_prob)*se
  }

  outputs = list("est" = est, "se" = se, "ci" = ci, "pseq" = c(0,1), "cov_prob" = cov_prob)

  class(outputs) = "ciccr"

  outputs
}
