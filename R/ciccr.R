#' @docType package
#' @name ciccr
#' @title ciccr: a package for causal inference in case-control and case-population studies
#'
#' @description The ciccr package provides methods for causal inference in case-control and case-population studies
#' under the monotone treatment response (MTR) and monotone treatment selection (MTS) assumptions.
#'
#' @section Functions:
#' The package includes the following:
#' \itemize{
#' \item{\code{\link{cicc_plot}}: }{plots upper bounds on relative and attributable risk.}
#' \item{\code{\link{cicc_RR}}: }{carries out causal inference on relative risk.}
#' \item{\code{\link{avg_RR_logit}}: }{averages the log odds ratio using retrospective logistic regression.}
#' \item{\code{\link{cicc_AR}}: }{carries out causal inference on attributable risk.}
#' \item{\code{\link{avg_AR_logit}}: }{averages the upper bound on causal attributable risk using prospective and retrospective logistic regression models.}
#' \item{\code{\link{ACS_CC}}: }{provides an illustrative case-control sample using the ACS dataset.}
#' \item{\code{\link{ACS_CP}}: }{provides an illustrative case-population sample using the ACS dataset.}
#' \item{\code{\link{ACS}}: }{provides an illustrative random sample using the ACS dataset.}
#' \item{\code{\link{FG_CC}}: }{provides an illustrative case-control sample using Fang and Gong (2020).}
#' \item{\code{\link{FG_CP}}: }{provides an illustrative case-population sample using Fang and Gong (2020).}
#' \item{\code{\link{FG}}: }{provides an illustrative random sample using Fang and Gong (2020).}
#' }
#' @references Jun, S.J. and Lee, S. (2020). Causal Inference under Outcome-Based Sampling with Monotonicity Assumptions.
#' \url{https://arxiv.org/abs/2004.08318}.
#' @references Manski, C.F. (1997). Monotone Treatment Response.
#' Econometrica, 65(6), 1311-1334.
#' @references Manski, C.F. and Pepper, J.V. (2000). Monotone Instrumental Variables: With an Application to the Returns to Schooling.
#' Econometrica, 68(4), 997-1010.
#' @references Fang, H. and Gong, Q. (2020). Detecting Potential Overbilling in Medicare Reimbursement via Hours Worked: Reply.
#' American Economic Review, 110(12): 4004-10.
NULL
