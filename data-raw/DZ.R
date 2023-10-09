## code to prepare `DZ_CC` dataset
rm(list=ls(all=T))

DZ_CC = readstata13::read.dta13("data-raw/DZ19.dta")
readr::write_csv(DZ_CC, "data-raw/DZ_cc.csv")
usethis::use_data(DZ_CC, overwrite = TRUE)
