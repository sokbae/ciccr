## code to prepare `FG`, `FG_CC` and `FG_CP` datasets
rm(list=ls(all=T))

library(readstata13)
library(readr)

  seed = 230212
  set.seed(seed)

  dat = read.dta13("data-raw/FG20.dta")
  FG_case = dat[dat$flag==1,]
  n_case = nrow(FG_case)

  FG_control = dat[dat$flag==0,]
  n_control = nrow(FG_control)

  # Part 1: Construction of Case-Control Sample
  # Random sampling from controls without replacement

  rs_i = sample.int(n_control,n_case)
  FG_control_rs = FG_control[rs_i,]
  FG_CC = rbind(FG_case,FG_control_rs)
  n = nrow(FG_CC)
  FG_CC = FG_CC[sample.int(n,n),] # random permutation to shuffle the data
  rownames(FG_CC) = c()        # remove row names

  write_csv(FG_CC, "data-raw/FG_CC.csv")
  usethis::use_data(FG_CC, overwrite = TRUE)

  # Part 2: Construction of Case-Population Sample
  # Random sampling from all observations without replacement

  rs_i = sample.int((n_case+n_control),n_case)
  FG_all = rbind(FG_case,FG_control)
  FG_control_rs = FG_all[rs_i,]
  FG_control_rs[,4] = NA  # column 4 is flag (outcome variable)
  FG_CP = rbind(FG_case,FG_control_rs)
  n = nrow(FG_CP)
  FG_CP = FG_CP[sample.int(n,n),] # random permutation to shuffle the data
  rownames(FG_CP) = c()        # remove row names

  write_csv(FG_CP, "data-raw/FG_CP.csv")
  usethis::use_data(FG_CP, overwrite = TRUE)

  # Part 3: Keeping the Original Sample
  # Keep all observations and shuffle the data

  FG = rbind(FG_case,FG_control)
  n = nrow(FG)
  FG = FG[sample.int(n,n),] # random permutation to shuffle the data
  rownames(FG) = c()        # remove row names

  write_csv(FG, "data-raw/FG.csv")
  usethis::use_data(FG, overwrite = TRUE)

