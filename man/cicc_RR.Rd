% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/cicc_RR.R
\name{cicc_RR}
\alias{cicc_RR}
\title{Causal Inference on Relative Risk}
\usage{
cicc_RR(y, t, x, sampling = "cc", cov_prob = 0.95)
}
\arguments{
\item{y}{n-dimensional vector of binary outcomes}

\item{t}{n-dimensional vector of binary treatments}

\item{x}{n by d matrix of covariates}

\item{sampling}{'cc' for case-control sampling; 'cp' for case-population sampling; 'rs' for random sampling (default =  'cc')}

\item{cov_prob}{coverage probability of a uniform confidence band (default = 0.95)}
}
\value{
An S3 object of type "ciccr". The object has the following elements:
\item{est}{estimates of the upper bounds on the average of log relative risk at p=0 and p=1}
\item{se}{pointwise standard errors at p=0 and p=1}
\item{ci}{the upper end points of the uniform confidence band at p=0 and p=1}
\item{pseq}{two end points: p=0 and p=1}
}
\description{
Provides upper bounds on the average of log relative risk
under the monotone treatment response (MTR) and monotone treatment selection (MTS) assumptions.
}
\examples{
# use the ACS_CC dataset included in the package.
  y = ciccr::ACS_CC$topincome
  t = ciccr::ACS_CC$baplus
  x = ciccr::ACS_CC$age
  results_RR = cicc_RR(y, t, x, sampling = 'cc', cov_prob = 0.95)

}
\references{
Jun, S.J. and Lee, S. (2023). Causal Inference under Outcome-Based Sampling with Monotonicity Assumptions.
\url{https://arxiv.org/abs/2004.08318}.

Manski, C.F. (1997). Monotone Treatment Response.
Econometrica, 65(6), 1311-1334.

Manski, C.F. and Pepper, J.V. (2000). Monotone Instrumental Variables: With an Application to the Returns to Schooling.
Econometrica, 68(4), 997-1010.
}
