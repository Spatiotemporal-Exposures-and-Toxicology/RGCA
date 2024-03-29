test_that("rgca hill inverse works", {
  a <- 2
  b <- 3
  c <- 0.5
  y <- -1
  # case 1, y extended to small negative conc, invert slope
  expect_equal(hill_invs_factry(a, b, c)(y),
               -b / (1 + (-a / y)^(1 / c)))
  # negate a and y
  a <- -a
  y <- -y
  expect_equal(hill_invs_factry(a, b, c)(y),
               -b / (1 + (-a / y)^(1 / c)))
  # case 2, standard inverse, y<a
  a <- 2
  y <- 1
  expect_equal(hill_invs_factry(a, b, c)(y),
               b / (a / y - 1)^(1 / c))
  # negate a and y
  a <- -a
  y <- -y
  expect_equal(hill_invs_factry(a, b, c)(y),
               b / (a / y - 1)^(1 / c))
  # case 3, reflected part of the standard inverse, y < 2a
  a <- 2
  y <- 3.5
  expect_equal(hill_invs_factry(a, b, c)(y),
               -2 * b - b / (a / (2 * a - y) - 1)^(1 / c))
  # negate a and y
  a <- -a
  y <- -y
  expect_equal(hill_invs_factry(a, b, c)(y),
               -2 * b - b / (a / (2 * a - y) - 1)^(1 / c))
  # case 4, reflection of extension, slope inverted
  a <- 2
  y <- 6
  expect_equal(hill_invs_factry(a, b, c)(y),
               -2 * b + b / (1 + (a / (-2 * a + y))^(1 / c)))
  y <- -y
  a <- -a
  expect_equal(hill_invs_factry(a, b, c)(y),
               -2 * b + b / (1 + (a / (-2 * a + y))^(1 / c)))
})

test_that("mix_response_prediction_works", {
  # specify a set of chemicals
  sills <- c(6, 3, 4, 8)
  ec50_vec <- c(1.2, 2.1, 0.1, 4.1)
  slopes <- c(0.5, 1.1, 2.0, 1.2)
  # Rmax is used to scale IA across clusters, can copy sills
  param_matrix <- as.matrix(cbind("a" = sills,
                                  "b" = ec50_vec,
                                  "c" = slopes,
                                  "max_R" = sills))

  # create the inverse function list used in denominator of GCA
  hill_inverse_list <- apply(param_matrix,
                             MARGIN = 1,
                             function(x) {
                               do.call(hill_invs_factry, as.list(x))
                             })
  # create the GCA function to optimize over
  GCA_function <- eff_response_opt(hill_inverse_list,
                                   conc_vec = c(1, 2, 3),
                                   synergy_const = 0,
                                   interval_sign = 1)
  # Check GCA equation solving, match saved state (snapshot April 2024)
  expect_snapshot(optimize(GCA_function,
                           interval = c(-20, 10),
                           tol = .Machine$double.eps))
  # test the negative case as well
  GCA_function_neg <- eff_response_opt(hill_inverse_list,
                                       conc_vec = c(1, 2, 3),
                                       synergy_const = 0,
                                       interval_sign = -1)
  expect_snapshot(optimize(GCA_function_neg,
                           interval = c(-20, 10),
                           tol = .Machine$double.eps))

  # specify a clustering
  clust_assign <- c(1, 1, 2, 1)
  # generate the mix response function
  mix_function <- mix_function_generator(param_matrix,
                                         clust_assign,
                                         get_counts = FALSE,
                                         scale_CA = FALSE,
                                         synergy_const = 0)
  # specify some mixture doses to test
  dose_range <- seq(0, 10, length.out = 3)
  # create a matrix of mixture doses
  dose_matrix <- tidyr::expand_grid(dose_range, dose_range,
                                    dose_range, dose_range)
  # test that mixture doses give expected response (snapshot April 2024)
  expect_snapshot(apply(dose_matrix, MARGIN = 1, mix_function))
})


test_that("summary_stats_are_correct", {
  set.seed(100)
  #create fake mcmc chains
  fake_MCMC <- list()
  iters <- 300
  n_chems <- 10
  n_reps <- 3
  fake_MCMC$slope_record <- matrix(rnorm(n_chems * iters), nrow = iters)
  fake_MCMC$sill_mideffect_record <- matrix(rnorm(2 * n_chems * iters),
                                            nrow = iters)
  fake_MCMC$sigma <- matrix(rnorm(n_chems * iters), nrow = iters)
  fake_MCMC$tau <- matrix(rnorm(iters), nrow = iters)
  fake_MCMC$u_RE <- matrix(rnorm(n_reps * n_chems * iters), nrow = iters)
  fake_MCMC$v_RE <- matrix(rnorm(n_reps * n_chems * iters), nrow = iters)
  fake_MCMC$u_RE_sd <- matrix(rnorm(n_chems * iters), nrow = iters)
  fake_MCMC$v_RE_sd <- matrix(rnorm(n_chems * iters), nrow = iters)

  # the summary stats should correspond to the median of the thinned samples
  expect_snapshot(pull_summary_parameters(fake_MCMC))

  # for the second parameter summary function, need replicate sets
  repl_fun <- function(idx) idx + ((1:n_reps) - 1) * 10
  replicate_sets <<- lapply(1:n_chems, repl_fun)
  # the pulled parameters should correspond to the thinned samples only
  expect_snapshot(pull_parameters(fake_MCMC, input_replicates = replicate_sets))
})
