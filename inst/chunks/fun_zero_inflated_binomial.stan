  /* zero-inflated binomial log-PDF of a single response 
   * Args: 
   *   y: the response value 
   *   eta: linear predictor for binomial part 
   *   zi: zero-inflation probability
   * Returns:  
   *   a scalar to be added to the log posterior 
   */ 
   real zero_inflated_binomial_lpmf(int y, int trials, 
                                    real eta, real zi) {
     if (y == 0) { 
       return log_sum_exp(bernoulli_lpmf(1 | zi), 
                          bernoulli_lpmf(0 | zi) + 
                          binomial_logit_lpmf(0 | trials, eta)); 
     } else { 
       return bernoulli_lpmf(0 | zi) +  
              binomial_logit_lpmf(y | trials, eta); 
     } 
   }
  /* zero-inflated binomial log-PDF of a single response 
   * logit parameterization of the zero-inflation part
   * Args: 
   *   y: the response value 
   *   eta: linear predictor for binomial part 
   *   eta_zi: linear predictor for zero-inflation part 
   * Returns:  
   *   a scalar to be added to the log posterior 
   */ 
   real zero_inflated_binomial_logit_lpmf(int y, int trials, 
                                          real eta, real eta_zi) {
     if (y == 0) { 
       return log_sum_exp(bernoulli_logit_lpmf(1 | eta_zi), 
                          bernoulli_logit_lpmf(0 | eta_zi) + 
                          binomial_logit_lpmf(0 | trials, eta)); 
     } else { 
       return bernoulli_logit_lpmf(0 | eta_zi) +  
              binomial_logit_lpmf(y | trials, eta); 
     } 
   }
