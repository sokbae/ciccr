## code to prepare `ACS` dataset

library(readr)

  seed = 345346
  set.seed(seed)

  ACS_case = read.table("data-raw/ACS_cases.csv",header=T,sep=",")
  colnames(ACS_case) = c("age", "married", "ind", "baplus", "topincome")
  n_case = nrow(ACS_case)

  ACS_control = read.table("data-raw/ACS_controls.csv",header=T,sep=",")
  colnames(ACS_control) = c("age", "married", "ind", "baplus", "topincome")
  n_control = nrow(ACS_control)

  # Random sampling from controls without replacement

  rs_i = sample.int(n_control,n_case)
  ACS_control_rs = ACS_control[rs_i,]
  ACS = rbind(ACS_case,ACS_control_rs)
  ACS = ACS[,-2]  # drop the marital status variable
    n = nrow(ACS)
  ACS = ACS[sample.int(n,n),] # random permutation to shuffle the data
  rownames(ACS) = c()        # remove row names

  write_csv(ACS, "data-raw/ACS.csv")
  usethis::use_data(ACS, overwrite = TRUE)
