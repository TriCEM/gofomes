## .................................................................................
## Purpose: Running NE fomes and Traditional model on Maestro
##
## Author: Nick Brazeau
##
## Date: 30 January, 2023
##
## Notes:
## .................................................................................
# remotes::install_github("TriCEM/fomes", ref = "develop")
library(fomes)
library(tidyverse)
library(furrr)

#............................................................
# read in data
#...........................................................
maestro_map <- readRDS(paste0(here::here(), "/analyses/01-vary_rho_NC/simresults/maestro.RDS"))


#............................................................
# functions
#...........................................................
fomes_wrapper <- function(Iseed, N, beta, dur_I,
                          rho, init_contact_mat, modtype) {

  if (modtype == "NE") {
    modout <- fomes::sim_Gillespie_SIR(Iseed = Iseed,
                                       N = N,
                                       beta = rep(beta, N),
                                       dur_I = dur_I,
                                       rho = rho,
                                       init_contact_mat = init_contact_mat,
                                       term_time = Inf)
  } else if (modtype == "trad") {
    modout <- fomes:::tradsim_Gillespie_SIR(Iseed = Iseed,
                                            N = N,
                                            beta = beta,
                                            dur_I = dur_I,
                                            term_time = Inf)
  } else {
    stop("Your maestro must be of model type NE or Trad")
  }
  # out
  return(modout)
}


finalsize_wrapper <- function(modresult, modtype) {
  if (modtype == "NE") {
    ret <- summary(modresult)$FinalEpidemicSize
  } else if (modtype == "trad") {
    ret <- sum(modresult[1,c("Susc", "Infxn")]) - modresult[nrow(modresult), "Susc"]
  } else {
    stop("Your maestro must be of model type NE or Trad")
  }
  return(ret)
}

#............................................................
# run on maestro
#...........................................................
maestro_map <- maestro_map %>%
  dplyr::mutate(modresult = furrr::future_pmap(., fomes_wrapper,
                                               .options = furrr_options(seed = TRUE)),
                EpidemicFinalSize = purrr::map2_dbl(modresult, modtype, finalsize_wrapper)
  )



#............................................................
# save out results
#...........................................................
dir.create(paste0(here::here(), "/analyses/01-vary_rho_NC/simresults"))
saveRDS(maestro_map, file = paste0(here::here(), "/analyses/01-vary_rho_NC/simresults/model_results_from_maestro.RDS"))



