#' @title An Average of the Upper Bound of Causal Log Relative Risk
#'
#' @description Averages the upper bound of causal log relative risk using logistic regression models
#' under the monotone treatment response (MTR) and monotone treatment selection (MTS) assumptions.
#'
#' @param y n-dimensional vector of binary outcomes
#' @param t n-dimensional vector of binary treatments
#' @param x n by p matrix of covariates
#' @param sampling 'cc' for case-control sampling; 'cp' for case-population sampling (default sampling =  'cc')
#' @param p_upper specified upper bound for the unknown true case probability (default = 1)
#' @param length specified length of a sequence from 0 to p_upper (default = 20)
#' @param interaction TRUE if there are interaction terms in the retrospective logistic model; FALSE if not (default = FALSE)
#'
#' @return An S3 object of type "ciccr". The object has the following elements.
#' \item{est}{(length)-dimensional vector of the average of the upper bound of causal attributable risk}
#' \item{pseq}{(length)-dimensional vector of a grid from 0 to p_upper}
#'
#' @examples
#' # use the ACS dataset included in the package
#'   y = ciccr::ACS$topincome
#'   t = ciccr::ACS$baplus
#'   x = ciccr::ACS$age
#'   results = avg_RR_logit(y, t, x, sampling = 'cc')
#'
#' @references Sung Jae Jun and Sokbae Lee. Causal Inference in Case-Control Studies.
#' \url{https://arxiv.org/abs/2004.08318}.
#' @export
avg_RR_logit = function(y, t, x, sampling = 'cc', p_upper = 1L, length = 20L, interaction = FALSE){

  # Check whether y is either 0 or 1
  if ( sum( !(y %in% c(0,1)) ) > 0 ){
    stop("Each element of 'y' must be either 0 or 1.")
  }

  # Check whether t is either 0 or 1
  if ( sum( !(t %in% c(0,1)) ) > 0 ){
    stop("Each element of 't' must be either 0 or 1.")
  }

  # Check whether sampling is either case-control or case-population
  if ( sum( !(sampling %in% c('cc','cp')) ) > 0 ){
    stop("'sampling' must be either 'cc' or 'cp'.")
  }

  # Retrospective logistic estimation of P(T=1|Y=y,X=x)

  pgrd = seq(from = 0, to = p_upper, length.out = ceiling(length))
  small_e = 1e-8

  if (interaction == TRUE){

    lm_ret = stats::glm(t~y+x+y:x, family=stats::binomial("logit"))
    est_ret = stats::coef(lm_ret)
    x_reg_y1 = cbind(1,1,x,1*x)
    x_reg_y0 = cbind(1,0,x,0*x)

  } else if (interaction == FALSE){

    lm_ret = stats::glm(t~y+x, family=stats::binomial("logit"))
    est_ret = stats::coef(lm_ret)
    x_reg_y1 = cbind(1,1,x)
    x_reg_y0 = cbind(1,0,x)
  } else {
    stop("'interaction' must be either FALSE or TRUE.")
  }

  fit_ret_y1 = exp(x_reg_y1%*%est_ret)/(1+exp(x_reg_y1%*%est_ret))
  fit_ret_y0 = exp(x_reg_y0%*%est_ret)/(1+exp(x_reg_y0%*%est_ret))

  fit_ret_y1 = fit_ret_y1 + small_e*(fit_ret_y1 < small_e) + (1-small_e)*(fit_ret_y1 > (1-small_e))
  fit_ret_y0 = fit_ret_y0 + small_e*(fit_ret_y0 < small_e) + (1-small_e)*(fit_ret_y0 > (1-small_e))

  # Estimation of the odds ratio

  P11 = fit_ret_y1
  P10 = fit_ret_y0
  P01 = 1 - P11
  P00 = 1 - P10

  OR = (P11*P00)/(P10*P01)
  logOR = log(OR)

  # Estimation of the upper bounds

  if (sampling=='cc'){

    betaRR_cc1 = colMeans(logOR*y)/mean(y)
    betaRR_cc0 = colMeans(logOR*(1-y))/mean(1-y)
    betaRR_cc = pgrd*betaRR_cc1 + (1-pgrd)*betaRR_cc0
    est = betaRR_cc

  }  else if (sampling=='cp'){

    betaRR_cp = colMeans(logOR*(1-y))/mean(1-y)
    est = rep(betaRR_cp,length(pgrd))

  }

  outputs = list("est" = est, "pseq" = pgrd)

class(outputs) = "ciccr"

outputs

}


