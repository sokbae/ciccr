context("Testing ciccr")

# code should work whether x has one variable or more

test_that("The default option for avg_RR_logit is 'control'", {

y = ACS_CC$topincome
t = ACS_CC$baplus
x = ACS_CC$age

results_default = avg_RR_logit(y, t, x)
results_control = avg_RR_logit(y, t, x, 'control')

expect_equal( results_default$est, results_control$est)

})

test_that("The default sampling option for avg_A_logit is 'cc'", {

  y = ACS_CC$topincome
  t = ACS_CC$baplus
  x = ACS_CC$age

  results_default = avg_AR_logit(y, t, x)
  results_cc = avg_AR_logit(y, t, x, sampling = 'cc')

  expect_equal( results_default$est, results_cc$est)

})
