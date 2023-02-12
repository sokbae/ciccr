## code to prepare `FG`, `FG_CC` and `FG_CP` datasets
rm(list=ls(all=T))

library(readstata13)
library(readr)

  seed = 230212
  set.seed(seed)

  dat = read.dta13("data-raw/FG20.dta")
  FS_case = dat[dat$flag==1,]
  n_case = nrow(FS_case)

  FS_control = dat[dat$flag==0,]
  n_control = nrow(FS_control)

  # Part 1: Construction of Case-Control Sample
  # Random sampling from controls without replacement

  rs_i = sample.int(n_control,n_case)
  FS_control_rs = FS_control[rs_i,]
  FS_CC = rbind(FS_case,FS_control_rs)
  n = nrow(FS_CC)
  FS_CC = FS_CC[sample.int(n,n),] # random permutation to shuffle the data
  rownames(FS_CC) = c()        # remove row names

  write_csv(FS_CC, "data-raw/FS_CC.csv")
  usethis::use_data(FS_CC, overwrite = TRUE)

  # Part 2: Construction of Case-Population Sample
  # Random sampling from all observations without replacement

  rs_i = sample.int((n_case+n_control),n_case)
  FS_all = rbind(FS_case,FS_control)
  FS_control_rs = FS_all[rs_i,]
  FS_control_rs[,4] = NA  # column 4 is flag (outcome variable)
  FS_CP = rbind(FS_case,FS_control_rs)
  n = nrow(FS_CP)
  FS_CP = FS_CP[sample.int(n,n),] # random permutation to shuffle the data
  rownames(FS_CP) = c()        # remove row names

  write_csv(FS_CP, "data-raw/FS_CP.csv")
  usethis::use_data(FS_CP, overwrite = TRUE)

  # Part 3: Keeping the Original Sample
  # Keep all observations and shuffle the data

  FS = rbind(FS_case,FS_control)
  n = nrow(FS)
  FS = FS[sample.int(n,n),] # random permutation to shuffle the data
  rownames(FS) = c()        # remove row names

  write_csv(FS, "data-raw/FS.csv")
  usethis::use_data(FS, overwrite = TRUE)

