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
#' @param length specified length of a sequence from 0 to p_upper (default = 21)
#' @param interaction TRUE if there are interaction terms in the retrospective logistic model; FALSE if not (default = FALSE)
#' @param no_boot number of bootstrap repetitions to compute the confidence intervals (default = 0)
#'
#' @return An S3 object of type "ciccr". The object has the following elements:
#' \item{est}{(length)-dimensional vector of the upper bounds on the average of log relative risk}
#' \item{ci}{(length)-dimensional vector of the upper ends of pointwise one-sided confidence intervals}
#' \item{pseq}{(length)-dimensional vector of a grid from 0 to p_upper}
#' \item{cov_prob}{the nominal coverage probability}
#' \item{return_code}{status of existence of missing values in bootstrap replications}
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
cicc_RR = function(y, t, x, sampling = 'cc', p_upper = 1L, cov_prob = 0.95, length = 21L, interaction = FALSE, no_boot = 0L){

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

  n = length(y)

  results = avg_RR_logit(y, t, x, sampling=sampling, p_upper=p_upper, length=length, interaction=interaction)
  est = results$est
  pseq = results$pseq

    if (no_boot > 0){

       data = cbind(y,t,x)
       bt_est_matrix = {}

      for (k in 1:no_boot){

        bt_i = sample.int(n,n,replace=TRUE)
        bt_data = data[bt_i,]
        bt_y = bt_data[bt_i,1]
        bt_t = bt_data[bt_i,2]
        bt_x = bt_data[bt_i,c(-1,-2)]

        bt_results = avg_RR_logit(bt_y, bt_t, bt_x, sampling=sampling, p_upper=p_upper, length=length, interaction=interaction)
        bt_est = bt_results$est

        bt_est_matrix = rbind(bt_est_matrix,bt_est)
      }

      if ( sum(is.na(bt_est_matrix)==TRUE) > 0 ){
        bt_est_matrix = stats::na.omit(bt_est_matrix)
        dropout_rate = round(100*(1 - nrow(bt_est_matrix)/no_boot))
        return_code = paste("Warning: ", dropout_rate, "% of bootstrap samples with missing values are dropped", sep="")
      } else{
        return_code = "Success: no bootstrap sample is dropped"
      }

      tmp = (bt_est_matrix <= matrix(1,nrow=nrow(bt_est_matrix),ncol=1)%*%matrix(est,nrow=1))
      pstar = apply(tmp, 2, mean)
      zstar = stats::qnorm(mean(pstar))
      bc_prob = stats::pnorm(cov_prob + 2*zstar)
      bt_ci = apply(bt_est_matrix, 2, stats::quantile, prob=bc_prob) # bias-corrected percentile method

    } else if (no_boot == 0){

        bt_ci = NA
        return_code = "Only point estimates are provided without bootstrap inference"
      }


  outputs = list("est" = est, "ci" = bt_ci, "pseq" = pseq, "cov_prob" = cov_prob, "return_code" = return_code)

  class(outputs) = "ciccr"

  outputs
}
