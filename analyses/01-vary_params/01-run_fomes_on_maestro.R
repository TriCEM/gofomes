## .................................................................................
## Purpose: Running `fomes` on varying parameter map
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
maestro_map <- readRDS(paste0(here::here(), "/analyses/01-vary_params/results/maestro_params.RDS"))


#............................................................
# functions
#...........................................................
# personal scratch space
myscratchspace <- "/pine/scr/n/f/nfb/Projects/gofomes/01-vary_params_simresults/"
dir.create(myscratchspace, recursive = TRUE)
fomes_wrapper <- function(name, Iseed, N, beta, dur_I,
                          rho, init_contact_mat) {

    modout <- fomes::sim_Gillespie_SIR(Iseed = Iseed,
                                       N = N,
                                       beta = rep(beta, N),
                                       dur_I = dur_I,
                                       rho = rho,
                                       init_contact_mat = init_contact_mat,
                                       term_time = Inf,
                                       return_contact_matrices = FALSE)

    # out of scope behavior
    fn <- paste(myscratchspace, name, ".RDS", sep = "")
    saveRDS(modout, file = fn)

    # return within scope
    return(sum(modout$Event_traj == "transmission"))

}



#............................................................
# run maestroe on LongLeaf
#...........................................................
#availableCores()
plan(future.batchtools::batchtools_slurm, workers = (availableCores()-1),
     template = "slurm_templates/slurm_48hr.tmpl")
maestro_map <- maestro_map %>%
  dplyr::mutate(finalsize = furrr::future_pmap_dbl(., fomes_wrapper,
                                               .options = furrr_options(seed = TRUE)))

#............................................................
# save out results
#...........................................................
dir.create(paste0(here::here(), "/analyses/01-vary_params/results/"))
saveRDS(maestro_map, file = paste0(here::here(), "/analyses/01-vary_params/results/simmodel_results_from_maestro.RDS"))



