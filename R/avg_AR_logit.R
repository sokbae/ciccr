#' @title An Average of the Upper Bound of Causal Attributable Risk
#'
#' @description Averages the upper bound of causal attributable risk using logistic regression models
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
#'   results = avg_AR_logit(y, t, x, sampling = 'cc')
#'
#' @references Sung Jae Jun and Sokbae Lee. Causal Inference in Case-Control Studies.
#' \url{https://arxiv.org/abs/2004.08318}.
#' @export
avg_AR_logit = function(y, t, x, sampling = 'cc', p_upper = 1L, length = 20L, interaction = FALSE){

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

  # Prospective logistic estimation of P(Y=1|X=x)

  small_e = 1e-8

  lm_pro = stats::glm(y~x, family=stats::binomial("logit"))
  est_pro = stats::coef(lm_pro)
  fit_pro = stats::fitted.values(lm_pro)
  fit_pro = matrix(fit_pro,ncol=1)

  fit_pro = fit_pro + small_e*(fit_pro < small_e) + (1-small_e)*(fit_pro > (1-small_e))

  # Estimation of r(x,p)

  pgrd = seq(from = 0, to = p_upper, length.out = ceiling(length))
  pseq = matrix(pgrd, nrow=1)
  hhat = mean(y)

  if (sampling=='cc'){
    r_num = ((1-hhat)*fit_pro)%*%pseq
    r_den = r_num + (hhat*(1-fit_pro))%*%(1-pseq)
    r_den = r_den + small_e*(r_den < small_e)
    r_cc = r_num/r_den
  }  else if (sampling=='cp'){
    r1 = (1-hhat)/hhat
    r2 = fit_pro/(1-fit_pro)
    r_cp = (r1*r2)%*%pseq
  }

  # Retrospective logistic estimation of P(T=1|Y=y,X=x)

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


  # Estimation of Gamma_AR(x,p)

  P11 = fit_ret_y1
  P10 = fit_ret_y0
  P11 = matrix(P11, ncol=1)%*%matrix(1, nrow=1, ncol=ncol(pseq))
  P10 = matrix(P10, ncol=1)%*%matrix(1, nrow=1, ncol=ncol(pseq))

  P01 = 1 - P11
  P00 = 1 - P10

  # Estimation of beta_AR(p,y)

  if (sampling=='cc'){

    term1_cc_den = P10 + r_cc*(P11-P10)
    term1_cc_den = term1_cc_den + small_e*(term1_cc_den < small_e)
    term1_cc = P11/term1_cc_den

    term2_cc_den = P00 + r_cc*(P01-P00)
    term2_cc_den = term2_cc_den + small_e*(term2_cc_den < small_e)
    term2_cc = P01/term2_cc_den

    GammaAR_cc = term1_cc - term2_cc

    betaAR_cc1 = colMeans(r_cc*GammaAR_cc*y)/mean(y)
    betaAR_cc0 = colMeans(r_cc*GammaAR_cc*(1-y))/mean(1-y)
    betaAR_cc = pgrd*betaAR_cc1 + (1-pgrd)*betaAR_cc0
    est = betaAR_cc

  }  else if (sampling=='cp'){

    term1_cp = P11/P10
    term2_cp = P01/P00

    GammaAR_cp = term1_cp - term2_cp
    betaAR_cp = colMeans(r_cp*GammaAR_cp*(1-y))/mean(1-y)
    est = betaAR_cp

  }

  outputs = list("est" = est, "pseq" = pgrd)

class(outputs) = "ciccr"

outputs

}


