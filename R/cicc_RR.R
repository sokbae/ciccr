#' @title Causal Inference on Relative Risk
#'
#' @description Provides an upper bound on the average of log relative risk.
#'
#' @param y n-dimensional vector of binary outcomes
#' @param t n-dimensional vector of binary treatments
#' @param x n by p matrix of covariates
#' @param sampling 'cc' for case-control sampling; 'cp' for case-population sampling (default sampling =  'cc')
#' @param p_upper a specified upper bound for the unknown true case probability (default = 1)
#' @param cov_prob parameter for coverage probability of a confidence interval (default = 0.95)
#' @param length specified length of a sequence from 0 to p_upper (default = 20)
#'
#' @return An S3 object of type "ciccr". The object has the following elements:
#' \item{est}{(length)-dimensional vector of the upper bounds on the average of log relative risk}
#' \item{se}{(length)-dimensional vector of pointwise standard errors}
#' \item{ci}{(length)-dimensional vector of the upper ends of pointwise confidence interval}
#' \item{pseq}{(length)-dimensional vector of a grid from 0 to p_upper}
#' Notes. The outputs would be the same across different p values for for case-population sampling.
#'
#' @examples
#' # use the ACS dataset included in the package.
#'   y = ciccr::ACS$topincome
#'   t = ciccr::ACS$baplus
#'   x = ciccr::ACS$age
#' # The upper bound for Pr(y=1) is set as p_upper = 1 by default
#' # with the defaulty coverage probability of 0.95 for the default choice of case-control sampling.
#'   cicc_RR(y, t, x)
#' # The upper bound for Pr(y=1) is set as p_upper = 0.2
#' # with the coverage probablity of 0.99 for the case-control sample.
#'   cicc_RR(y, t, x, sampling = 'cc', p_upper = 0.2, cov_prob = 0.99)
#' @references Sung Jae Jun and Sokbae Lee. Causal Inference in Case-Control Studies.
#' \url{https://arxiv.org/abs/2004.08318}.
#'
#' @export
cicc_RR = function(y, t, x, sampling = 'cc', p_upper = 1L, cov_prob = 0.95, length = 20L){

  # Check whether p_upper is in (0,1]
  if (p_upper <=0L || p_upper > 1L){
    stop("'p_upper' must be in (0,1].")
  }

  # Check whether length_SA > 0
  if (length <= 0){
    stop("'length' must be greater than zero.")
  }

  # Check whether sampling is either case-control or case-population
  if ( sum( !(sampling %in% c('cc','cp')) ) > 0 ){
    stop("'sampling' must be either 'cc' or 'cp'.")
  }

  results = avg_retro_logit(y,t,x,'case')
  est_case = results$est
  se_case = results$se

  results = avg_retro_logit(y,t,x,'control')
  est_control = results$est
  se_control = results$se

  cv_norm = stats::qnorm(cov_prob)
  pseq = seq(from = 0, to = p_upper, length.out = ceiling(length))

  if (sampling=='cc'){

    xi = est_case*pseq + est_control*(1-pseq)
    xi_var = (se_case*pseq)^2 + (se_control*(1-pseq))^2
    xi_se = sqrt(xi_var)
    xi_ci = xi + cv_norm*xi_se
  }
  else if (sampling=='cp'){

    xi = rep(est_control,length(pseq))
    xi_se = rep(se_control,length(pseq))
    xi_ci = xi + cv_norm*xi_se
  }

  outputs = list("est" = xi, "se" = xi_se, "ci" = xi_ci, "pseq" = pseq)

  class(outputs) = "ciccr"

  outputs
}
