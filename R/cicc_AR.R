#' @title Causal Inference for Attributable Risk
#'
#' @description Provides an upper bound on the average of attributable risk.
#'
#' @param y n-dimensional vector of binary outcomes
#' @param t n-dimensional vector of binary treatments
#' @param x n by p matrix of covariates
#' @param sampling 'cc' for case-control sampling; 'cp' for case-population sampling (default sampling =  'cc')
#' @param p_upper a specified upper bound for the unknown true case probability (default = 1)
#' @param cov_prob parameter for coverage probability of a confidence interval (default = 0.95)
#' @param length specified length of a sequence from 0 to p_upper (default = 21)
#' @param no_boot number of bootstrap repetitions to compute the confidence intervals (default = 999)
#'
#' @return An S3 object of type "ciccr". The object has the following elements:
#' \item{est}{(length)-dimensional vector of the upper bounds on the average of attributable risk}
#' \item{se}{(length)-dimensional vector of pointwise standard errors}
#' \item{ci}{(length)-dimensional vector of the upper ends of pointwise confidence intervals}
#' \item{pseq}{(length)-dimensional vector of a grid from 0 to p_upper}
#'
#' @examples
#' # use the ACS dataset included in the package.
#'   y = ciccr::ACS$topincome
#'   t = ciccr::ACS$baplus
#'   x = ciccr::ACS$age
#'   AR = cicc_AR(y, t, x, sampling = 'cc', no_boot = 100)
#'
#' @references Sung Jae Jun and Sokbae Lee. Causal Inference in Case-Control Studies.
#' \url{https://arxiv.org/abs/2004.08318}.
#'
#' @export
cicc_AR = function(y, t, x, sampling = 'cc', p_upper = 1L, cov_prob = 0.95, length = 21L, no_boot = 999L){

  # Check whether p_upper is in (0,1]
  if (p_upper <=0L || p_upper > 1L){
    stop("'p_upper' must be in (0,1].")
  }

  # Check whether length_SA > 0
  if (length <= 0){
    stop("'length' must be greater than zero.")
  }

  n = length(y)
  results = avg_AR_logit(y, t, x, sampling, p_upper, length)
  est = results$est
  pseq = results$pseq

  data = cbind(y,t,x)
  bt_est_matrix = {}
  for (k in 1:no_boot){

  bt_i = sample.int(n,n,replace=TRUE)
  bt_data = data[bt_i,]
  bt_y = bt_data[bt_i,1]
  bt_t = bt_data[bt_i,2]
  bt_x = bt_data[bt_i,c(-1,-2)]

  bt_results = avg_AR_logit(bt_y, bt_t, bt_x, sampling, p_upper, length)
  bt_est = bt_results$est
  bt_est_matrix = rbind(bt_est_matrix,bt_est)
  }

  bt_ci = apply(bt_est_matrix, 2, stats::quantile, prob=cov_prob)
  bt_se = apply(bt_est_matrix, 2, stats::sd)

  outputs = list("est" = est, "se" = bt_se, "ci" = bt_ci, "pseq" = pseq)

  class(outputs) = "ciccr"

  outputs
}
