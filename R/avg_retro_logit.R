#' @title An Average of the Log Odds Ratio
#'
#' @description Averages the log odds ratio using retrospective logistic regression.
#'
#' @param y n-dimensional vector of binary outcomes
#' @param t n-dimensional vector of binary treatments
#' @param x n by p matrix of covariates
#' @param w 'case' if the average is conditional on the case sample; 'control' if it is conditional on the control sample
#' default w =  'control'
#' @return An S3 object of type "ciccr". The object has the following elements.
#' \item{est}{a scalar estimate of the weighted average of the log odds ratio using retrospective logistic regression}
#' \item{se}{standard error}
#'
#' @examples
#' # use the ACS dataset included in the package
#'   y = ciccr::ACS$topincome
#'   t = ciccr::ACS$baplus
#'   x = ciccr::ACS$age
#' # use 'case' to condition on the distribution of covariates given y = 1
#'   w = 'case'
#'   results = avg_retro_logit(y, t, x, w)
#'
#' @references Sung Jae Jun and Sokbae Lee. Causal Inference in Case-Control Studies.
#' \url{https://arxiv.org/abs/2004.08318}.
#' @export
avg_retro_logit = function(y, t, x, w = 'control'){

  # Choice of the conditional distribution of covariates
  if (w=='case'){
    yselected = 1L
  }  else if (w=='control'){
    yselected = 0L
  }
  else {
    stop("'w' must be either 'case' or 'control'.")
  }

  # Check whether y is either 0 or 1
  if ( sum( !(y %in% c(0,1)) ) > 0 ){
    stop("Each element of 'y' must be either 0 or 1.")
  }

  # Check whether t is either 0 or 1
  if ( sum( !(t %in% c(0,1)) ) > 0 ){
    stop("Each element of 't' must be either 0 or 1.")
  }

  # Demeaning for x
  if (ncol(as.matrix(x)) == 1L){
    xcase = x[y==yselected]
    xcase_demeaned = x - mean(xcase)
  }    else {
    xcase = x[y==yselected,]
    xcase_demeaned = x - t(matrix(colMeans(xcase),nrow=ncol(x),ncol=nrow(x)))
  }

  # Retrospective logistic estimation

  lm_case = stats::glm(t~y+xcase_demeaned+y*xcase_demeaned, family=stats::binomial("logit"))
  est_all = stats::coef(lm_case)
  est = est_all[2]
  se_all = sqrt(diag(stats::vcov(lm_case)))
  se = se_all[2]

  outputs = list("est"=est,"se"=se)
  class(outputs) = 'ciccr'

  outputs
}
