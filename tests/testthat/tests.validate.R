test_that("extract_effects finds all variables in very long formulas", {
  expect_equal(extract_effects(t2_brand_recall ~ psi_expsi + psi_api_probsolv + 
                                 psi_api_ident + psi_api_intere + psi_api_groupint)$all, 
               t2_brand_recall ~ t2_brand_recall + psi_expsi + psi_api_probsolv + psi_api_ident + 
                 psi_api_intere + psi_api_groupint)
})

test_that("extract_effects finds all random effects terms", {
  random <- extract_effects(y ~ a + (1+x|g1) + x + (1|g2) + z)$random
  expect_equal(random$form, list(~1 + x, ~1))
  expect_equal(random$group, c("g1", "g2"))
  expect_equal(extract_effects(y ~ (1+x|g1:g2) + (1|g1))$random$group, 
               c("g1", "g1:g2"))
  expect_equal(extract_effects(y ~ (1|g1))$random$group, c("g1"))
  expect_equal(extract_effects(y ~ log(x) + (1|g1))$random$group, c("g1"))
  expect_equal(extract_effects(y ~ (x+z):v + (1+x|g1))$random$form, list(~1+x))
  expect_equal(extract_effects(y ~ v + (1+x|g1/g2/g3))$random$group, 
               c("g1", "g1:g2", "g1:g2:g3"))
  expect_equal(extract_effects(y ~ v + (1+x|g1/g2) + (1|g3))$random$form, 
               list(~1+x, ~1+x, ~1))
  expect_equal(extract_effects(y ~ (1+x||g1/g2) + (1|g3))$random$cor, 
               c(FALSE, FALSE, TRUE))
  expect_equal(extract_effects(y ~ 1|g1)$random$group, "g1")
  expect_error(extract_effects(y ~ (1+x|g1+g2) + x + (1|g1)))
})

test_that("extract_effects accepts || syntax", {
  random <- brms:::extract_effects(y ~ a + (1+x||g1) + (1+z|g2))$random
  target <- data.frame(group = c("g1", "g2"), gn = 1:2, id = c(NA, NA),
                       cor = c(FALSE, TRUE), stringsAsFactors = FALSE)
  target$form <- list(~1+x, ~1+z)
  expect_equal(random, target)
  expect_equal(extract_effects(y ~ (1+x||g1:g2))$random$group, c("g1:g2"))
  expect_error(extract_effects(y ~ (1+x||g1-g2) + x + (1|g1)))
})

test_that("extract_effects finds all response variables", {
  expect_equal(extract_effects(y1~x)$response, "y1")
  expect_equal(extract_effects(cbind(y1,y2)~x)$response, 
               c("y1", "y2")) 
  expect_equal(extract_effects(cbind(y1,y2,y2)~x)$response, 
               c("y1", "y2", "y21")) 
  expect_equal(extract_effects(y1+y2+y3~x)$response, "y1") 
  expect_equal(extract_effects(y1/y2 ~ (1|g))$response, "y1")
  expect_equal(extract_effects(cbind(y1/y2,y2,y3*3) ~ (1|g))$response,
               c("response1", "y2", "response3"))
})

test_that("extract_effects handles addition arguments correctly", {
  expect_equal(extract_effects(y | se(I(a+2)) ~ x, family = gaussian())$se, 
               ~ .se(I(a+2)))
  expect_equal(extract_effects(y | se(I(a+2)) ~ x, family = gaussian())$all, 
               y ~ y + a + x)
  expect_equal(extract_effects(y | weights(1/n) ~ x, 
                               family = gaussian())$weights, 
               ~ .weights(1/n))
  expect_equal(extract_effects(y | se(a+2) | cens(log(b)) ~ x, 
                               family = gaussian())$cens, 
               ~ .cens(log(b)))
  expect_equal(extract_effects(y | se(a+2) + cens(log(b)) ~ x, 
                               family = gaussian())$se, 
               ~ .se(a+2))
  expect_equal(extract_effects(y | trials(10) ~ x, family = binomial())$trials, 
               10)
  expect_equal(extract_effects(y | cat(cate) ~ x, family = cumulative())$cat, 
               ~ .cat(cate))
  expect_equal(extract_effects(y | cens(cens^2) ~ z, family = weibull())$cens, 
               ~ .cens(cens^2))
  expect_equal(extract_effects(y | cens(cens^2) ~ z + (x|patient), 
                               family = weibull())$all, 
               y ~ y + cens + z + x + patient)
  expect_equal(extract_effects(resp | disp(a + b) ~ x, 
                               family = gaussian())$disp,
               ~.disp(a + b))
})

test_that("extract_effects accepts complicated random terms", {
  expect_equal(extract_effects(y ~ x + (I(as.numeric(x)-1) | z))$random$form,
               list(~I(as.numeric(x) - 1)))
  expect_equal(extract_effects(y ~ x + (I(exp(x)-1) + I(x/y) | z))$random$form,
               list(~I(exp(x)-1) + I(x/y)))
})

test_that("extract_effects accepts calls to the poly function", {
  expect_equal(extract_effects(y ~ z + poly(x, 3))$all,
               y ~ y + z + x + poly(x, 3))
})

test_that("extract_effects also saves untransformed variables", {
  ee <- extract_effects(y ~ as.numeric(x) + (as.factor(z) | g))
  expect_equivalent(ee$all, y ~ y + x + as.numeric(x) + as.factor(z) + z + g)
})

test_that("extract_effects finds all variables in non-linear models", {
  nonlinear <- list(a ~ z1 + (1|g1), b ~ z2 + (z3|g2))
  ee <- extract_effects(y ~ a - b^x, nonlinear = nonlinear)
  expect_equal(ee$all, y ~ y + x + z1 + g1 + z2 + z3 + g2)
})

test_that("extract_effects rejects REs in non-linear formulas", {
  expect_error(extract_effects(y ~ exp(-x/a) + (1|g), nonlinear = a ~ 1),
               "Group-level effects in non-linear models", fixed = TRUE)
})

test_that("extract_effects finds all spline terms", {
  ee <- extract_effects(y ~ s(x) + t2(z) + v)
  expect_equal(all.vars(ee$fixed), c("y", "v"))
  expect_equivalent(ee$gam, ~ s(x) + t2(z))
  ee <- extract_effects(y ~ lp , nonlinear = list(lp ~ s(x) + t2(z) + v))
  expect_equal(all.vars(ee$nonlinear[[1]]$fixed), "v")
  expect_equivalent(ee$nonlinear[[1]]$gam, ~ s(x) + t2(z))
  expect_error(extract_effects(y ~ s(x) + te(z) + v), 
               "splines 'te' and 'ti' are not yet implemented")
})

test_that("extract_effects correctly handles group IDs", {
  form <- bf(y ~ x + (1+x|3|g) + (1|g2),
             sigma = ~ (x|3|g) + (1||g2))
  target <- data.frame(group = c("g", "g2"), gn = 1:2, id = c("3", NA),
                       cor = c(TRUE, TRUE), stringsAsFactors = FALSE)
  target$form <- list(~1+x, ~1)
  expect_equal(extract_effects(form)$random, target)
  
  form <- bf(y ~ a, nonlinear = a ~ x + (1+x|3|g) + (1|g2),
             sigma = ~ (x|3|g) + (1||g2))
  target <- data.frame(group = c("g", "g2"), gn = 1:2, id = c("3", NA),
                       cor = c(TRUE, FALSE), stringsAsFactors = FALSE)
  target$form <- list(~x, ~1)
  expect_equal(extract_effects(form)$sigma$random, target)
})

test_that("extract_effects handles very long RE terms", {
  # tests issue #100
  covariate_vector <- paste0("xxxxx", 1:80, collapse = "+")
  formula <- paste(sprintf("y ~ 0 + trait + trait:(%s)", covariate_vector),
                   sprintf("(1+%s|id)", covariate_vector), sep = " + ")
  ee <- extract_effects(formula = as.formula(formula))
  expect_equal(ee$random$group, "id")
})

test_that("nonlinear_effects finds missing parameters", {
  expect_error(nonlinear_effects(list(a = a ~ 1, b = b ~ 1), model = y ~ a^x),
               "missing in formula: b")
})

test_that("nonlinear_effects accepts valid non-linear models", {
  nle <- nonlinear_effects(list(a = a ~ 1 + (1+x|origin), b = b ~ 1 + z), 
                           model = y ~ b - a^x)
  expect_equal(names(nle), c("a", "b"))
  expect_equal(nle[["a"]]$all, ~x + origin)
  expect_equal(nle[["b"]]$all, ~z)
  expect_equal(nle[["a"]]$random$form[[1]], ~1+x)
})

test_that("extract_time returns all desired variables", {
  expect_equal(extract_time(~1), list(time = "", group = "", all = ~1))
  expect_equal(extract_time(~tt), list(time = "tt", group = "", all = ~1 + tt)) 
  expect_equal(extract_time(~1|trait), list(time = "", group = "trait", all = ~1+trait)) 
  expect_equal(extract_time(~time|trait), 
               list(time = "time", group = "trait", all = ~1+time+trait)) 
  expect_equal(extract_time(~time|Site:trait),
               list(time = "time", group = "Site:trait", all = ~1+time+Site+trait))
  expect_error(extract_time(~t1+t2|g1), 
               "Autocorrelation structures may only contain 1 time variable")
  expect_error(extract_time(~1|g1/g2), 
               paste("Illegal grouping term: g1/g2"))
})

test_that("update_formula returns correct formulas", {
  expect_warning(uf <- update_formula(y ~ x + z, partial = ~ a + I(a^2)))
  expect_equal(uf, y ~ x + z + cse(a + I(a^2)))
})

test_that("get_effect works correctly", {
  effects <- extract_effects(y ~ a - b^x, 
               nonlinear = list(a ~ z, b ~ v + mono(z)))
  expect_equivalent(get_effect(effects), list(y ~ a - b^x, ~1 + z, ~ 1 + v))
  expect_equivalent(get_effect(effects, "mono"), list(b = ~ z))
  effects <- extract_effects(y ~ x + z + (1|g))
  expect_equivalent(get_effect(effects), list(y ~ 1 + x + z))
})

test_that("check_re_formula returns correct REs", {
  #old_ranef = list(patient = c("Intercept"), visit = c("Trt_c", "Intercept"))
  old_form <- y ~ x + (1|patient) + (Trt_c|visit)
  form <- check_re_formula(~(1|visit), old_form)
  expect_equivalent(form, ~(1|visit))
  form <- check_re_formula(~(1+Trt_c|visit), old_form)
  expect_equivalent(form, ~(1+Trt_c|visit))
  form <- check_re_formula(~(0+Trt_c|visit) + (1|patient), old_form)
  expect_equivalent(form, ~ (1|patient) + (0+Trt_c | visit))
})

test_that("update_re_terms works correctly", {
  expect_equivalent(update_re_terms(y ~ x, ~ (1|visit)), y ~ x)
  expect_equivalent(update_re_terms(y ~ x + (1+Trt_c|patient), ~ (1|patient)), 
                    y ~ x + (1|patient))
  expect_equivalent(update_re_terms(y ~ x + (1|patient), ~ 1), 
                    y ~ x)
  expect_equivalent(update_re_terms(y ~ x + (1+visit|patient), NA), 
                    y ~ x)
  expect_equivalent(update_re_terms(y ~ x + (1+visit|patient), NULL), 
                    y ~ x + (1+visit|patient))
  expect_equivalent(update_re_terms(y ~ (1|patient), NA), y ~ 1)
  expect_equivalent(update_re_terms(y ~ x + (1+x|visit), ~ (1|visit)), 
                    y ~ x + (1|visit))
  expect_equivalent(update_re_terms(y ~ x + (1|visit), ~ (1|visit) + (x|visit)),
                    y ~ x + (1|visit))
  expect_equal(update_re_terms(bf(y ~ x, sigma = ~ x + (x|g)), ~ (1|g)),
               bf(y ~ x, sigma = ~ x + (1|g)))
  expect_equal(update_re_terms(bf(y ~ x, nonlinear = x ~ z + (1|g)), ~ (1|g)),
               bf(y ~ x, nonlinear = x ~ z + (1|g)))
})

test_that("amend_terms performs expected changes to terms objects", {
  expect_equal(amend_terms("a"), NULL)
  expect_equal(amend_terms(y~x), terms(y~x))
  form <- structure(y~x, rsv_intercept = TRUE)
  expect_equal(attr(amend_terms(form), "rm_intercept"), TRUE)
})

test_that("tidy_ranef works correctly", {
  data <- data.frame(g = 1:10, x = 11:20, y = 1:10)
  target <- data.frame(id = 1, group = "g", gn = 1, 
                       coef = c("Intercept", "x"), cn = 1:2,
                       nlpar = "", cor = FALSE, 
                       stringsAsFactors = FALSE)
  target$form <- replicate(2, ~1+x)
  expect_equivalent(tidy_ranef(extract_effects(y~(1+x||g)), data = data),
                    target)
  expect_equivalent(tidy_ranef(extract_effects(y~x), data = data), 
                    empty_ranef())
})

test_that("check_brm_input returns correct warnings and errors", {
  expect_error(check_brm_input(list(chains = 3, cluster = 2)), 
               "chains must be a multiple of cluster", fixed = TRUE)
  x <- list(family = weibull(), inits = "random", chains = 1, cluster = 1,
            algorithm = "sampling")
  expect_warning(check_brm_input(x))
  x$family <- inverse.gaussian()
  expect_warning(check_brm_input(x))
  x$family <- poisson("sqrt")
  expect_warning(check_brm_input(x))
})

test_that("exclude_pars returns expected parameter names", {
  ranef <- data.frame(id = c(1, 1, 2), group = c("g1", "g1", "g2"),
                       gn = c(1, 1, 2), coef = c("x", "z", "x"), 
                       cn = c(1, 2, 1), nlpar = "", 
                       cor = c(TRUE, TRUE, FALSE))
  ep <- exclude_pars(list(), ranef = ranef)
  expect_true(all(c("r_1", "r_2") %in% ep))
  ep <- exclude_pars(list(), ranef = ranef, save_ranef = FALSE)
  expect_true("r_1_1" %in% ep)
  
  ranef$nlpar <- c("a", "a", "")
  ep <- exclude_pars(list(), ranef = ranef, save_ranef = FALSE)
  expect_true(all(c("r_1_a_1", "r_1_a_2") %in% ep))
  effects <- brms:::extract_effects(y ~ x + s(z))
  expect_true("zs_1" %in% exclude_pars(effects = effects))
  effects <- extract_effects(y ~ eta, nonlinear = list(eta ~ x + s(z)))
  expect_true("zs_eta_1" %in% exclude_pars(effects = effects))
})
