context("Testing ciccr")

# code should work whether x has one variable or more

test_that("The default option for avg_retro_logit is 'control'", {

y = ACS$topincome
t = ACS$baplus
x = ACS$age

results_default = avg_retro_logit(y, t, x)
results_control = avg_retro_logit(y, t, x, 'control')

expect_equal( results_default$est, results_control$est)

})
