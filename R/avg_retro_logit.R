#' Average of the log odds ratio using retrospective logistic regression
#'
#' @param y n-dimensional vector of binary outcomes
#' @param t n-dimensional vector of binary treatments
#' @param x n by p matrix of matrix of covariates
#' @param w 'case' if the average is conditional on the case sample; 'control' if it is conditional on the control sample
#' @return estimate and standard error of the weighted average of the log odds ratio using retrospective logistic regression
avg_retro_logit = function(y,t,x,w){

  # Choice of the conditional distribution of covariates
  if (w=='case'){
    yselected = 1L
  }  else if (w=='control'){
    yselected = 0L
  }
  else {
    stop("'w' must be either 'case' or 'control'.")
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

  output_list <- list("est"=est,"se"=se)

  output_list
}
