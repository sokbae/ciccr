#' @title Upper Bounds on Relative Risk and Attributable Risk
#'
#' @description Plots upper bounds on relative risk and attributable risk
#'
#' @param y n-dimensional vector of binary outcomes
#' @param t n-dimensional vector of binary treatments
#' @param x n by p matrix of covariates
#' @param sampling 'cc' for case-control sampling; 'cp' for case-population sampling (default sampling =  'cc')
#' @param p_upper a specified upper bound for the unknown true case probability (default = 1; relevant for only 'cc')
#' @param cov_prob parameter for coverage probability of a confidence interval (default = 0.95)
#' @param length specified length of a sequence from 0 to p_upper (default = 20; ; relevant for only 'cc')
#' @param interaction TRUE if there are interaction terms in the retrospective logistic model
#' to estimate the upper bound on attributable risk; FALSE if not (default = FALSE)
#' @param no_boot number of bootstrap repetitions to compute the confidence intervals
#' for attributable risk (default = 0)
#' @param save_plots TRUE if the plots are saved as pdf files; FALSE if not (default = FALSE)
#' @param file_name the pdf file name to save the plots (default = Sys.Date())
#' @param plots_ctl value to determine the topleft position of the legend in the figure
#' a large value makes the legend far away from the confidence intervals (default = 0.3)
#' @param plots_dir a directory where the plots are saved (default = FALSE);
#' plots will be saved under "(current working directory)/figures" by default.
#'
#' @return A X-Y plot where the X axis shows the range of p from 0 to p_upper and
#' the Y axis depicts both point estimates and the upper end point of the one-sided confidence intervals.
#'
#' @examples
#' # use the ACS dataset included in the package.
#'   y = ciccr::ACS$topincome
#'   t = ciccr::ACS$baplus
#'   x = ciccr::ACS$age
#'   cicc_plot(y, t, x)
#'
#' @references Sung Jae Jun and Sokbae Lee. Causal Inference in Case-Control Studies.
#' \url{https://arxiv.org/abs/2004.08318}.
#'
#' @export
cicc_plot = function(y, t, x, sampling = 'cc', p_upper = 1L, cov_prob = 0.95, length = 20L,
                     interaction = FALSE, no_boot = 0L,
                     save_plots = FALSE, file_name = Sys.Date(), plots_ctl = 0.3,
                     plots_dir = FALSE){

  RR = cicc_RR(y, t, x, sampling=sampling, p_upper=p_upper, cov_prob=cov_prob, length=length)

  RR_xi = exp(RR$est)
  RR_xi_ci = exp(RR$ci)
  pseq = RR$pseq

  AR = cicc_AR(y, t, x, sampling=sampling, p_upper=p_upper, cov_prob=cov_prob, length=length, interaction=interaction, no_boot=no_boot)

  AR_xi = AR$est
  AR_xi_ci = AR$ci

  if (save_plots == TRUE){
    if (plots_dir == FALSE){
    figure_dir = paste0(getwd(), "/figures")
      if ( dir.exists(figure_dir)==FALSE ){
        dir.create(figure_dir)
      }
    setwd(figure_dir)
    }
    else {
      setwd(plots_dir)
    }
  }

  pdf_file_name_RR = paste(file_name,"-RR.pdf",sep="")
  pdf_file_name_AR = paste(file_name,"-AR.pdf",sep="")
  xlab_name = "Unknown True Case Probability"
  ylab_name_RR = "Relative Risk"
  ylab_name_AR = "Attributable Risk"
  xlim_value = c(0,max(pseq))
  ylim_value_RR = c(min(RR_xi),(max(RR_xi_ci)+plots_ctl*(max(RR_xi_ci)-min(RR_xi))))
  legend_title_RR = c(expression=paste("Estimate of the Upper Bound on Relative Risk"),
                      paste(cov_prob*100,"% One-Sided Pointwise Confidence Interval",sep=""))

  if (save_plots == TRUE){
    grDevices::pdf(pdf_file_name_RR)
  }

  graphics::plot(pseq, RR_xi, type = "l", lty = "solid", col = "blue", xlab = xlab_name, ylab = ylab_name_RR,
       xlim = xlim_value, ylim = ylim_value_RR)
  graphics::lines(pseq, RR_xi_ci, type = "l", lty = "dashed", col = "red")
  graphics::legend("topleft", legend_title_RR, lty =c("solid", "dashed"), col = c("blue", "red"))

  if (save_plots == TRUE){
    grDevices::dev.off()
    grDevices::pdf(pdf_file_name_AR)
  }

  if (no_boot > 0){

    ylim_value_AR = c(min(AR_xi),(max(AR_xi_ci)+plots_ctl*(max(AR_xi_ci)-min(AR_xi))))
    legend_title_AR = c(expression=paste("Estimate of the Upper Bound on Attributable Risk"),
                        paste(cov_prob*100,"% One-Sided Pointwise Confidence Interval",sep=""))

    graphics::plot(pseq, AR_xi, type = "l", lty = "solid", col = "blue", xlab = xlab_name, ylab = ylab_name_AR,
                   xlim = xlim_value, ylim = ylim_value_AR)
    graphics::lines(pseq, AR_xi_ci, type = "l", lty = "dashed", col = "red")
    graphics::legend("topleft", legend_title_AR, lty =c("solid", "dashed"), col = c("blue", "red"))

  } else if (no_boot == 0){

    ylim_value_AR = c(min(AR_xi),(1+plots_ctl)*max(AR_xi))
    legend_title_AR = c(expression=paste("Estimate of the Upper Bound on Attributable Risk"))

    graphics::plot(pseq, AR_xi, type = "l", lty = "solid", col = "blue", xlab = xlab_name, ylab = ylab_name_AR,
                   xlim = xlim_value, ylim = ylim_value_AR)
    graphics::legend("topleft", legend_title_AR, lty =c("solid"), col = c("blue"))

  }

  if (save_plots == TRUE){
    grDevices::dev.off()
  }

}
