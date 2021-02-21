context("Testing ciccr")

# code should work whether x has one variable or more

test_that("Case 1 with a scalar x: The default option for avg_RR_logit is 'control'", {

y = ACS_CC$topincome
t = ACS_CC$baplus
x = ACS_CC$age

results_default = avg_RR_logit(y, t, x)
results_control = avg_RR_logit(y, t, x, 'control')

expect_equal( results_default$est, results_control$est)

})

test_that("Case 2 with x and x^2: The default option for avg_RR_logit is 'control'", {

  y = ACS_CC$topincome
  t = ACS_CC$baplus
  x = ACS_CC$age
  x = cbind(x,x^2)

  results_default = avg_RR_logit(y, t, x)
  results_control = avg_RR_logit(y, t, x, 'control')

  expect_equal( results_default$est, results_control$est)

})

test_that("The results for avg_RR_logit should be different between 'case' and 'control'", {

  y = ACS_CC$topincome
  t = ACS_CC$baplus
  x = ACS_CC$age

  results_case = avg_RR_logit(y, t, x, 'case')
  results_control = avg_RR_logit(y, t, x, 'control')

  expect_false( results_case$est == results_control$est)

})

test_that("There should be an error other than 'case' and 'control'", {

  y = ACS_CC$topincome
  t = ACS_CC$baplus
  x = ACS_CC$age

  expect_error(avg_RR_logit(y, t, x, 'ctrl'))

})

test_that("Method 1: Each element of 'y' must be either 0 or 1.", {

  y = ACS_CC$topincome
  t = ACS_CC$baplus
  x = ACS_CC$age
  y[1] = 2

  expect_error(avg_RR_logit(y, t, x))

})

test_that("Method 2: Each element of 'y' must be either 0 or 1.", {

  y = ACS_CC$topincome
  t = ACS_CC$baplus
  x = ACS_CC$age
  y[1] = 2

  expect_error(avg_AR_logit(y, t, x))

})

test_that("Method 1: Each element of 't' must be either 0 or 1.", {

  y = ACS_CC$topincome
  t = ACS_CC$baplus
  x = ACS_CC$age
  t[1] = 2

  expect_error(avg_RR_logit(y, t, x))

})

test_that("Method 2: Each element of 't' must be either 0 or 1.", {

  y = ACS_CC$topincome
  t = ACS_CC$baplus
  x = ACS_CC$age
  t[1] = 2

  expect_error(avg_AR_logit(y, t, x))

})

test_that("The default sampling option for avg_AR_logit is 'cc'", {

  y = ACS_CC$topincome
  t = ACS_CC$baplus
  x = ACS_CC$age

  results_default = avg_AR_logit(y, t, x)
  results_cc = avg_AR_logit(y, t, x, sampling = 'cc')

  expect_equal( results_default$est, results_cc$est)

})

test_that("The results for cicc_RR should be different between 'cc' and 'cp'", {

  y = ACS_CC$topincome
  t = ACS_CC$baplus
  x = ACS_CC$age
  results_cc = cicc_RR(y, t, x, sampling = 'cc')

  y = ACS_CP$topincome
  y = as.integer(is.na(y)==FALSE)
  t = ACS_CP$baplus
  x = ACS_CP$age
  results_cp = cicc_RR(y, t, x, sampling = 'cp')

  expect_false(sum((results_cc$est != results_cp$est))==0)

})

test_that("The default sampling option for cicc_RR is 'cc'", {

  y = ACS_CC$topincome
  t = ACS_CC$baplus
  x = ACS_CC$age

  results_default = cicc_RR(y, t, x)
  results_cc = cicc_RR(y, t, x, sampling = 'cc')

  expect_equal( results_default$est, results_cc$est)

})

test_that("The sampling option for cicc_RR is either 'cc' or 'cp'", {

  y = ACS_CC$topincome
  t = ACS_CC$baplus
  x = ACS_CC$age

  expect_error(cicc_RR(y, t, x, sampling = 'cr'))

})

test_that("The sampling option for avg_AR_logit is either 'cc' or 'cp'", {

  y = ACS_CC$topincome
  t = ACS_CC$baplus
  x = ACS_CC$age

  expect_error(avg_AR_logit(y, t, x, sampling = 'cr'))

})

test_that("The results for avg_AR_logit should be different between 'cc' and 'cp'", {

  y = ACS_CC$topincome
  t = ACS_CC$baplus
  x = ACS_CC$age
  results_cc = avg_AR_logit(y, t, x, sampling = 'cc')

  y = ACS_CP$topincome
  y = as.integer(is.na(y)==FALSE)
  t = ACS_CP$baplus
  x = ACS_CP$age
  results_cp = avg_AR_logit(y, t, x, sampling = 'cp')

  expect_false(sum((results_cc$est != results_cp$est))==0)

})

test_that("The results for avg_AR_logit should be different between interaction = TRUE and FALSE", {

  y = ACS_CC$topincome
  t = ACS_CC$baplus
  x = ACS_CC$age
  results1 = avg_AR_logit(y, t, x, interaction = FALSE)
  results2 = avg_AR_logit(y, t, x, interaction = TRUE)

  expect_false(sum((results1$est != results2$est))==0)

})

test_that("There should be an error if interaction != TRUE or FALSE", {

  y = ACS_CC$topincome
  t = ACS_CC$baplus
  x = ACS_CC$age

  expect_error(avg_AR_logit(y, t, x, interaction = Linear))

})


test_that("The default sampling option for cicc_AR is 'cc'", {

  y = ACS_CC$topincome
  t = ACS_CC$baplus
  x = ACS_CC$age

  results_default = cicc_AR(y, t, x)
  results_cc = cicc_AR(y, t, x, sampling = 'cc')

  expect_equal( results_default$est, results_cc$est)

})

test_that("Method 1: Checking cicc_plot options", {

  y = ACS_CC$topincome
  t = ACS_CC$baplus
  x = ACS_CC$age

  results = cicc_RR(y, t, x)

  expect_error(cicc_plot(results, parameter = 'Relative Risk'))

})

test_that("Method 2: Checking cicc_plot options", {

  y = ACS_CC$topincome
  t = ACS_CC$baplus
  x = ACS_CC$age

  results = cicc_RR(y, t, x)

  expect_error(cicc_plot(results, sampling ='cr'))

})

test_that("Checking whether cicc_plot works with default options", {

  y = ACS_CC$topincome
  t = ACS_CC$baplus
  x = ACS_CC$age

  expect_type(cicc_RR(y, t, x), "list")

})

