#' Fit Bayesian Generalized (Non-)Linear Multilevel Models
#' 
#' Fit a Bayesian generalized (non-)linear Multilevel model using Stan
#' 
#' @param formula An object of class 
#'   \code{\link[brms:brmsformula]{brmsformula}}
#'   (or one that can be coerced to that class): 
#'   a symbolic description of the model to be fitted. 
#'   The details of model specification are explained in 
#'   \code{\link[brms:brmsformula]{brmsformula}}.
#' @param data An optional data frame, list or environment  (or object coercible by 
#'   \code{as.data.frame} to a data frame) containing the variables in the model. 
#'   If not found in data, the variables are taken from \code{environment(formula)}, 
#'   typically the environment from which \code{brm} is called. 
#'   Although it is optional, we strongly recommend to supply a data.frame. 
#' @param family A description of the error distribution and link function 
#'   to be used in the model. This can be a family function, 
#'   a call to a family function or a character string naming the family.
#'   Currently, the following families are supported:
#'   \code{gaussian}, \code{student}, \code{binomial}, 
#'   \code{bernoulli}, \code{poisson}, \code{negbinomial}, 
#'   \code{geometric}, \code{Gamma}, \code{lognormal}, \code{inverse.gaussian}, 
#'   \code{exponential}, \code{weibull}, \code{Beta}, \code{von_mises},
#'   \code{categorical}, \code{cumulative}, \code{cratio}, \code{sratio}, 
#'   \code{acat}, \code{hurdle_poisson}, \code{hurdle_negbinomial}, 
#'   \code{hurdle_gamma}, \code{zero_inflated_binomial},
#'   \code{zero_inflated_beta}, \cr \code{zero_inflated_negbinomial}, 
#'   and \code{zero_inflated_poisson}.
#'   Every family function has a \code{link} argument allowing to specify
#'   the link function to be applied on the response variable.
#'   If not specified, default links are used.
#'   See \code{\link[stats:family]{family}} for help on standard family functions 
#'   and \code{\link[brms:brmsfamily]{brmsfamily}} for family functions
#'   specific to the \pkg{brms} package. 
#'   For backwards compatibility, \code{family} may also be a vector of two
#'   character strings, the first naming the family and the second naming the link.
#'   Further information is provided under 'Details'.
#' @param prior One or more \code{brmsprior} objects created by function 
#'   \code{\link[brms:set_prior]{set_prior}} and combined using the \code{c} method. 
#'   A single \code{brmsprior} object may be passed without \code{c()} surrounding it. 
#'   See also  \code{\link[brms:get_prior]{get_prior}} for more help.
#' @param autocor An optional \code{\link{cor_brms}} object describing 
#'   the correlation structure 
#'   within the response variable (i.e. the 'autocorrelation'). 
#'   See the documentation of \code{\link{cor_brms}} for a description 
#'   of the available correlation structures. Defaults to NULL, 
#'   corresponding to no correlations.
#' @param nonlinear An optional list of formuluas, specifying 
#'   linear models for non-linear parameters. If \code{NULL} (the default)
#'   \code{formula} is treated as an ordinary formula. 
#'   If not \code{NULL}, \code{formula} is treated as a non-linear model
#'   and \code{nonlinear} should contain a formula for each non-linear 
#'   parameter, which has the parameter on the left hand side and its
#'   linear predictor on the right hand side.
#'   Alternatively, it can be a single formula with all non-linear
#'   parameters on the left hand side (separated by a \code{+}) and a
#'   common linear predictor on the right hand side.
#'   More information is given under 'Details'.
#' @param partial (Deprecated) A one sided formula of the form 
#'   \code{~expression} allowing to specify predictors with 
#'   category specific effects in non-cumulative ordinal models 
#'   (i.e. in families \code{cratio}, \code{sratio}, or \code{acat}).
#'   As of \pkg{brms} > 0.8.0 category specific effects should be 
#'   specified directly within \code{formula} using function \code{cse}.
#' @param threshold A character string indicating the type of thresholds 
#'   (i.e. intercepts) used in an ordinal model. 
#'   \code{"flexible"} provides the standard unstructured thresholds and 
#'   \code{"equidistant"} restricts the distance between 
#'   consecutive thresholds to the same value.
#' @param sparse Logical; indicates whether the population-level 
#'   design matrix should be treated as sparse (defaults to \code{FALSE}). 
#'   For design matrices with many zeros, this can considerably 
#'   reduce required memory. For univariate sparse models, it may be
#'   sensible to prevent the design matrix from being centered
#'   (see 'Details' for more information), as centering may
#'   reduce sparsity. 
#'   For all models using multivariate syntax 
#'   (i.e. multivariate linear models, zero-inflated and hurdle models 
#'   as well as categorical models), setting \code{sparse = TRUE}, 
#'   is generally worth a try to decrease memory requirements.
#'   However, sampling speed is currently not improved or even
#'   slightly decreased.
#' @param cov_ranef A list of matrices that are proportional to the 
#'   (within) covariance structure of the random effects. 
#'   The names of the matrices should correspond to columns 
#'   in \code{data} that are used as grouping factors. 
#'   All levels of the grouping factor should appear as rownames 
#'   of the corresponding matrix. This argument can be used,
#'   among others, to model pedigrees and phylogenetic effects.
#' @param ranef A flag to indicate if random effects 
#'   for each level of the grouping factor(s) 
#'   should be saved (default is \code{TRUE}). 
#'   Set to \code{FALSE} to save memory. 
#'   The argument has no impact on the model fitting itself.
#' @param sample_prior A flag to indicate if samples from all specified 
#'   proper priors should be drawn additionally to the posterior samples
#'   (defaults to \code{FALSE}). Among others, these samples can be used 
#'   to calculate Bayes factors for point hypotheses. 
#'   Alternatively, \code{sample_prior} can be set to \code{"only"} to
#'   sample solely from the priors. In this case, all parameters must 
#'   have proper priors.
#' @param knots Optional list containing user specified knot values to be 
#'   used for basis construction of smoothing terms. For details see
#'   \code{\link[mgcv:gamm]{gamm}}.
#' @param stan_funs An optional character string containing self-defined 
#'   \pkg{Stan} functions, which will be included in the functions block 
#'   of the generated \pkg{Stan} code. 
#' @param fit An instance of S3 class \code{brmsfit} derived from a previous fit; 
#'   defaults to \code{NA}. 
#'   If \code{fit} is of class \code{brmsfit}, the compiled model associated 
#'   with the fitted result is re-used and all arguments 
#'   modifying the model code or data are ignored.
#' @param inits Either \code{"random"} or \code{"0"}. 
#'   If inits is \code{"random"} (the default), 
#'   Stan will randomly generate initial values for parameters. 
#'   If it is \code{"0"}, all parameters are initiliazed to zero. 
#'   This option is recommended for \code{exponential} and \code{weibull} models, 
#'   as it happens that default (\code{"random"}) inits cause samples 
#'   to be essentially constant. 
#'   Generally, setting \code{inits = "0"} is worth a try, 
#'   if chains do not behave well.
#'   Alternatively, \code{inits} can be a list of lists containing 
#'   the initial values, or a function (or function name) generating initial values. 
#'   The latter options are mainly implemented for internal testing.
#' @param chains Number of Markov chains (defaults to 4). 
#'   A deprecated alias is \code{n.chains}.
#' @param iter Number of total iterations per chain (including warmup; defaults to 2000).
#'   A deprecated alias is \code{n.iter}.
#' @param warmup A positive integer specifying number of warmup (aka burnin) iterations. 
#'   This also specifies the number of iterations used for stepsize adaptation, 
#'   so warmup samples should not be used for inference. The number of warmup should not 
#'   be larger than \code{iter} and the default is \code{iter/2}.
#'   A deprecated alias is \code{n.warmup}.
#' @param thin Thinning rate. Must be a positive integer. 
#'   Set \code{thin > 1} to save memory and computation time if \code{iter} is large. 
#'   Default is 1, that is no thinning. A deprecated alias is \code{n.thin}.
#' @param cluster	Number of clusters to use to run parallel chains. Default is 1.  
#'   A deprecated alias is \code{n.cluster}. To use the built-in parallel execution
#'   of \pkg{rstan}, specify argument \code{cores} instead of \code{cluster}. 
#' @param cluster_type A character string specifying the type of cluster created by 
#'   \code{\link[parallel:makeCluster]{makeCluster}} when sampling in parallel 
#'   (i.e. when \code{cluster} is greater \code{1}). 
#'   Default is \code{"PSOCK"} working on all platforms. 
#'   For OS X and Linux, \code{"FORK"} may be a faster and more stable option, 
#'   but it does not work on Windows.
#' @param save_model Either \code{NULL} or a character string. 
#'   In the latter case, the model code is
#'   saved in a file named after the string supplied in \code{save_model}, 
#'   which may also contain the full path where to save the file.
#'   If only a name is given, the file is saved in the current working directory. 
#' @param algorithm Character string indicating the estimation approach to use. 
#'   Can be \code{"sampling"} for MCMC (the default), \code{"meanfield"} for
#'   variational inference with independent normal distributions, or
#'   \code{"fullrank"} for variational inference with a multivariate normal
#'   distribution.
#' @param control A named \code{list} of parameters to control the sampler's behavior. 
#'   It defaults to \code{NULL} so all the default values are used. 
#'   The most important control parameters are discussed in the 'Details'
#'   section below. For a comprehensive overview see \code{\link[rstan:stan]{stan}}.
#' @param silent logical; If \code{TRUE}, warning messages of the sampler are suppressed.
#' @param seed Positive integer. Used by \code{set.seed} to make results reproducable.  
#' @param ... Further arguments to be passed to Stan.
#' 
#' @return An object of class \code{brmsfit}, which contains the posterior samples along 
#'   with many other useful information about the model.
#'   Use \code{methods(class = "brmsfit")} for an overview on available methods.
#'  
#' @author Paul-Christian Buerkner \email{paul.buerkner@@gmail.com}
#' 
#' @details Fit a generalized (non-)linear multilevel model, 
#'   which incorporates both population-level parameters 
#'   (also known as fixed-effects) and group-level parameters
#'   (also known as random effects) in a (non-)linear predictor 
#'   via full Bayesian inference using Stan. 
#'   
#'   \bold{Formula syntax of brms models}
#'   
#'   The details of the formula syntax applied in \pkg{brms} 
#'   can be found in the 'Details' section of
#'   \code{\link[brms:brmsformula]{brmsformula}}.
#'   
#'   \bold{Families and link functions}
#'   
#'   Family \code{gaussian} with \code{identity} link leads to linear regression. 
#'   Family \code{student} with \code{identity} link leads to 
#'   robust linear regression that is less influenced by outliers. 
#'   Families \code{poisson}, \code{negbinomial}, and \code{geometric} 
#'   with \code{log} link lead to regression models for count data. 
#'   Families \code{binomial} and \code{bernoulli} with \code{logit} link leads to 
#'   logistic regression and family \code{categorical} to multi-logistic regression 
#'   when there are more than two possible outcomes.
#'   Families \code{cumulative}, \code{cratio} ('contiuation ratio'), 
#'   \code{sratio} ('stopping ratio'), and \code{acat} ('adjacent category') 
#'   leads to ordinal regression. Families \code{Gamma}, \code{weibull}, 
#'   \code{exponential}, \code{lognormal}, and \code{inverse.gaussian} can be used 
#'   (among others) for survival regression.
#'   Families \code{hurdle_poisson}, \code{hurdle_negbinomial}, \code{hurdle_gamma}, 
#'   \code{zero_inflated_poisson}, and \cr
#'   \code{zero_inflated_negbinomial} combined with the 
#'   \code{log} link, and  \code{zero_inflated_binomial} with the \code{logit} link, 
#'   allow to estimate zero-inflated and hurdle models. These models 
#'   can be very helpful when there are many zeros in the data that cannot be explained 
#'   by the primary distribution of the response. Family \code{hurdle_gamma} is 
#'   especially useful, as a traditional \code{Gamma} model cannot be reasonably 
#'   fitted for data containing zeros in the response. 
#'   
#'   In the following, we list all possible links for each family.
#'   The families \code{gaussian}, and \code{student},
#'   accept the links (as names) \code{identity}, \code{log}, and \code{inverse};
#'   families \code{poisson}, \code{negbinomial}, and \code{geometric} the links 
#'   \code{log}, \code{identity}, and \code{sqrt}; 
#'   families \code{binomial}, \code{bernoulli}, \code{Beta},
#'   \code{cumulative}, \code{cratio}, \code{sratio}, and \code{acat} 
#'   the links \code{logit}, \code{probit}, \code{probit_approx}, 
#'   \code{cloglog}, and \code{cauchit}; 
#'   family \code{categorical} the link \code{logit}; 
#'   families \code{Gamma}, \code{weibull}, and \code{exponential} 
#'   the links \code{log}, \code{identity}, and \code{inverse};
#'   family \code{lognormal} the links \code{identity} and \code{inverse};
#'   family \code{inverse.gaussian} the links \code{1/mu^2}, 
#'   \code{inverse}, \code{identity} and \code{log}; 
#'   families \code{hurdle_poisson}, \code{hurdle_negbinomial},
#'   \code{hurdle_gamma}, \code{zero_inflated_poisson}, and
#'   \code{zero_inflated_negbinomial} the link \code{log}. 
#'   The first link mentioned for each family is the default.     
#'   
#'   Please note that when calling the \code{\link[stats:family]{Gamma}} 
#'   family function, the default link will be \code{inverse} not \code{log}. 
#'   Also, the \code{probit_approx} link cannot be used when calling the
#'   \code{\link[stats:family]{binomial}} family function. 
#'   
#'   The current implementation of \code{inverse.gaussian} models has some 
#'   convergence problems and requires carefully chosen prior distributions 
#'   to work efficiently. For this reason, we currently do not recommend
#'   to use the \code{inverse.gaussian} family, unless you really feel
#'   that your data requires exactly this type of model. \cr
#'   
#'   \bold{Prior distributions}
#'   
#'   Priors should be specified using the 
#'   \code{\link[brms:set_prior]{set_prior}} function. 
#'   Its documentation contains detailed information 
#'   on how to correctly specify priors. To find out on 
#'   which parameters or parameter classes priors can be defined, 
#'   use \code{\link[brms:get_prior]{get_prior}}. \cr
#'   
#'   \bold{Adjusting the sampling behavior of \pkg{Stan}}
#'   
#'   In addition to choosing the number of iterations, warmup samples, 
#'   and chains, users can control the behavior of the NUTS sampler, 
#'   by using the \code{control} argument.
#'   The most important reason to use \code{control} is to decrease 
#'   (or eliminate at best) the number of divergent transitions
#'   that cause a bias in the obtained posterior samples. 
#'   Whenever you see the warning
#'   "There were x divergent transitions after warmup." 
#'   you should really think about increasing \code{adapt_delta}.
#'   To do this, write \code{control = list(adapt_delta = <x>)}, 
#'   where \code{<x>} should usually be value between \code{0.8} 
#'   (current default) and \code{1}. Increasing \code{adapt_delta} 
#'   will slow down the sampler but will decrease the number of 
#'   divergent transitions threatening the validity of your 
#'   posterior samples.
#'   
#'   Another problem arises when the depth of the tree being evaluated 
#'   in each iteration is exceeded. This is less common than having 
#'   divergent transitions, but may also bias the posterior samples.
#'   When it happens, \pkg{Stan} will throw out a warning suggesting 
#'   to increase \code{max_treedepth}, which can be accomplished by 
#'   writing \code{control = list(max_treedepth = <x>)} with a positive 
#'   integer \code{<x>} that should usually be larger than the current 
#'   default of \code{10}. For more details on the \code{control} argument 
#'   see \code{\link[rstan:stan]{stan}}.
#'   
#' @examples
#' \dontrun{ 
#' ## Poisson regression for the number of seizures in epileptic patients
#' ## using student_t priors for population-level effects 
#' ## and half cauchy priors for standard deviations of group-level effects 
#' fit1 <- brm(count ~ log_Age_c + log_Base4_c * Trt_c 
#'             + (1|patient) + (1|visit) + (1|obs), 
#'             data = epilepsy, family = poisson(), 
#'             prior = c(set_prior("student_t(5,0,10)", class = "b"),
#'                       set_prior("cauchy(0,2)", class = "sd")))
#' ## generate a summary of the results
#' summary(fit1)
#' ## plot the MCMC chains as well as the posterior distributions
#' plot(fit1, ask = FALSE)
#' ## extract random effects standard devations and covariance matrices
#' VarCorr(fit1)
#' ## extract group specific effects of each level
#' ranef(fit1)
#' ## predict responses based on the fitted model
#' head(predict(fit1))  
#' ## plot marginal effects of each predictor
#' plot(marginal_effects(fit1), ask = FALSE)
#'  
#' ## Ordinal regression modeling patient's rating of inhaler instructions 
#' ## category specific effects are estimated for variable 'treat'
#' fit2 <- brm(rating ~ period + carry + cse(treat), 
#'             data = inhaler, family = sratio("cloglog"), 
#'             prior = set_prior("normal(0,5)"), chains = 2)
#' summary(fit2)
#' plot(fit2, ask = FALSE)    
#' 
#' ## Survival regression modeling the time between the first 
#' ## and second recurrence of an infection in kidney patients.
#' fit3 <- brm(time | cens(censored) ~ age * sex + disease + (1|patient), 
#'             data = kidney, family = lognormal())
#' summary(fit3) 
#' plot(fit3, ask = FALSE)
#' plot(marginal_effects(fit3), ask = FALSE)   
#' 
#' ## Probit regression using the binomial family
#' n <- sample(1:10, 100, TRUE)  # number of trials
#' success <- rbinom(100, size = n, prob = 0.4)
#' x <- rnorm(100)
#' fit4 <- brm(success | trials(n) ~ x, 
#'             family = binomial("probit"))
#' summary(fit4)
#' 
#' ## Simple non-linear gaussian model
#' x <- rnorm(100)
#' y <- rnorm(100, mean = 2 - 1.5^x, sd = 1)
#' fit5 <- brm(y ~ a1 - a2^x, nonlinear = a1 + a2 ~ 1,
#'             prior = c(set_prior("normal(0, 2)", nlpar = "a1"),
#'                       set_prior("normal(0, 2)", nlpar = "a2")))
#' summary(fit5)
#' plot(marginal_effects(fit5), ask = FALSE)
#' 
#' ## Normal model with heterogeneous variances
#' data_het <- data.frame(y = c(rnorm(50), rnorm(50, 1, 2)),
#'                        x = factor(rep(c("a", "b"), each = 50)))
#' fit6 <- brm(bf(y ~ x, sigma ~ 0 + x), data = data_het)
#' summary(fit6)
#' plot(fit6)
#' marginal_effects(fit6)
#' # extract residual SDs of both groups
#' sigmas <- exp(posterior_samples(fit6, "^b_sigma_"))
#' colMeans(sigmas)
#' hist(sigmas[, 1])
#' hist(sigmas[, 2])
#' }
#' 
#' @import rstan
#' @import parallel
#' @import methods
#' @import stats   
#' @export 
brm <- function(formula, data = NULL, family = gaussian(), 
                prior = NULL, autocor = NULL, nonlinear = NULL, 
                partial = NULL, threshold = c("flexible", "equidistant"), 
                cov_ranef = NULL, ranef = TRUE, sparse = FALSE,
                sample_prior = FALSE, knots = NULL, stan_funs = NULL, 
                fit = NA, inits = "random", chains = 4, iter = 2000, 
                warmup = floor(iter / 2), thin = 1, cluster = 1, 
                cluster_type = "PSOCK", control = NULL, 
                algorithm = c("sampling", "meanfield", "fullrank"),
                silent = TRUE, seed = 12345, save_model = NULL, ...) {
  
  dots <- list(...) 
  # use deprecated arguments if specified
  iter <- use_alias(iter, dots$n.iter)
  warmup <- use_alias(warmup, dots$n.warmup)
  thin <- use_alias(thin, dots$n.thin)
  chains <- use_alias(chains, dots$n.chains)
  cluster <- use_alias(cluster, dots$n.cluster)
  cov_ranef <- use_alias(cov_ranef, dots$cov.ranef)
  sample_prior <- use_alias(sample_prior, dots$sample.prior)
  save_model <- use_alias(save_model, dots$save.model)
  dots[c("n.iter", "n.warmup", "n.thin", "n.chains", "n.cluster",
         "cov.ranef", "sample.prior", "save.model")] <- NULL
  # some input checks 
  if (!(is.null(data) || is.list(data)))
    stop("argument 'data' must be a data.frame or list", call. = FALSE)
  check_brm_input(nlist(family, chains, cluster, inits))
  autocor <- check_autocor(autocor)
  threshold <- match.arg(threshold)
  algorithm <- match.arg(algorithm)
  
  testmode <- dots$testmode
  dots$testmode <- NULL
  if (is(fit, "brmsfit")) {  
    x <- fit  # re-use existing model
    # compute data to be passed to Stan
    standata <- standata(x, is_newdata = dots$is_newdata)
    dots$is_newdata <- NULL
    # extract the compiled model
    x$fit <- rstan::get_stanmodel(x$fit)  
  } else {  # build new model
    # see validate.R for function definitions
    family <- check_family(family)
    formula <- update_formula(formula, data = data, family = family, 
                              nonlinear = nonlinear, partial = partial)
    et <- extract_time(autocor$formula)  
    ee <- extract_effects(formula, family = family, et$all)
    if (is.null(dots$data.name)) {
      data.name <- substr(Reduce(paste, deparse(substitute(data))), 1, 50)
    } else {
      data.name <- dots$data.name
      dots$data.name <- NULL
    }
    # see data-helpers.R
    data <- update_data(data, family = family, effects = ee, et$group) 
    # see priors.R
    prior <- check_prior(prior, formula = formula, data = data, 
                         family = family, sample_prior = sample_prior, 
                         autocor = autocor,  threshold = threshold, 
                         warn = TRUE)
    # initialize S3 object
    x <- brmsfit(formula = formula, family = family, link = family$link, 
                 data = data, data.name = data.name, prior = prior, 
                 autocor = autocor, cov_ranef = cov_ranef, 
                 threshold = threshold, algorithm = algorithm)
    # see validate.R
    x$ranef <- tidy_ranef(ee, data = x$data)  
    x$exclude <- exclude_pars(ee, ranef = x$ranef, save_ranef = ranef)
    # see make_stancode.R
    x$model <- make_stancode(formula = formula, data = data, 
                             family = family, prior = prior,  
                             autocor = autocor, threshold = threshold, 
                             sparse = sparse, cov_ranef = cov_ranef, 
                             sample_prior = sample_prior, knots = knots, 
                             stan_funs = stan_funs, save_model = save_model, 
                             brm_call = TRUE)
    # generate standata before compiling the model to avoid
    # unnecessary compilations in case that the data is invalid
    standata <- standata(x, newdata = dots$is_newdata)
    message("Compiling the C++ model")
    x$fit <- rstan::stan_model(stanc_ret = x$model)
    x$model <- x$model$model_code
  }
  
  # arguments to be passed to stan
  if (is.character(inits) && !inits %in% c("random", "0")) {
    inits <- get(inits, mode = "function", envir = parent.frame())
  }
  args <- list(object = x$fit, data = standata, pars = x$exclude, 
               include = FALSE, algorithm = algorithm)
  args[names(dots)] <- dots 
  if (algorithm == "sampling") {
    args <- c(args, list(init = inits, iter = iter, warmup = warmup, 
              thin = thin, chains = chains, control = control,
              show_messages = !silent))
  }
  
  set.seed(seed)
  if (cluster > 1) {  # sample in parallel
    message("Start sampling")
    if (is.character(args$init) || is.numeric(args$init)) 
      args$init <- rep(args$init, chains)
    cl <- makeCluster(cluster, type = cluster_type)
    on.exit(stopCluster(cl))  # close all clusters when exiting brm
    clusterExport(cl = cl, varlist = "args", envir = environment())
    clusterEvalQ(cl, require(rstan))
    run_chain <- function(i) {
      args$chains <- 1L
      args$chain_id <- i
      args$init <- args$init[i]
      Sys.sleep(0.5 * i)
      if (args$algorithm == "sampling") {
        args$algorithm <- NULL
        do.call(rstan::sampling, args = args)
      } else {
        do.call(rstan::vb, args = args)
      } 
    }
    x$fit <- rstan::sflist2stanfit(parLapply(cl, X = 1:chains, run_chain))
  } else {  # do not sample in parallel
    if (args$algorithm == "sampling") {
      args$algorithm <- NULL
      x$fit <- do.call(rstan::sampling, args = args)
    } else {
      x$fit <- do.call(rstan::vb, args = args)
    } 
  }
  if (!isTRUE(testmode)) {
    x <- rename_pars(x) # see rename.R
  }
  x
}
