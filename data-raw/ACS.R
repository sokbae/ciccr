## code to prepare `ACS_CC` and `ACS_CP` datasets
rm(list=ls(all=T))

library(readr)

  seed = 345346
  set.seed(seed)

  ACS_case = read.table("data-raw/ACS_cases.csv",header=T,sep=",")
  colnames(ACS_case) = c("age", "married", "ind", "baplus", "topincome")
  n_case = nrow(ACS_case)

  ACS_control = read.table("data-raw/ACS_controls.csv",header=T,sep=",")
  colnames(ACS_control) = c("age", "married", "ind", "baplus", "topincome")
  n_control = nrow(ACS_control)

  # Part 1: Construction of Case-Control Sample
  # Random sampling from controls without replacement

  rs_i = sample.int(n_control,n_case)
  ACS_control_rs = ACS_control[rs_i,]
  ACS_CC = rbind(ACS_case,ACS_control_rs)
  ACS_CC = ACS_CC[,-2]  # drop the marital status variable
  n = nrow(ACS_CC)
  ACS_CC = ACS_CC[sample.int(n,n),] # random permutation to shuffle the data
  rownames(ACS_CC) = c()        # remove row names

  write_csv(ACS_CC, "data-raw/ACS_CC.csv")
  usethis::use_data(ACS_CC, overwrite = TRUE)

  # Part 2: Construction of Case-Population Sample
  # Random sampling from all observations with replacement

  rs_i = sample.int((n_case+n_control),n_case)
  ACS_all = rbind(ACS_case,ACS_control)
  ACS_control_rs = ACS_all[rs_i,]
  ACS_control_rs[,5] = NA
  ACS_CP = rbind(ACS_case,ACS_control_rs)
  ACS_CP = ACS_CP[,-2]  # drop the marital status variable
  n = nrow(ACS_CP)
  ACS_CP = ACS_CP[sample.int(n,n),] # random permutation to shuffle the data
  rownames(ACS_CP) = c()        # remove row names

  write_csv(ACS_CP, "data-raw/ACS_CP.csv")
  usethis::use_data(ACS_CP, overwrite = TRUE)

