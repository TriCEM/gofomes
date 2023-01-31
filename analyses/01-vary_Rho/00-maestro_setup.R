## .................................................................................
## Purpose: Maestro Document for setting up analysis of how Rho and NC affect approx of Mass Action
##
## Author: TBD
##
## Date: 30 January, 2023
##
## Notes:
## .................................................................................
library(tidyverse)


#............................................................
# magic number set up
#...........................................................
Iseednow <- 1
Nnow <- 1e3
rhonow <- seq(1e-3, 10, length.out = 10)
init_contact_matnow <- fomes:::genInitialConnections(initNC = 50,
                                                  N = Nnow)
# beta <- seq(1, 15, length.out = 10)
betanow <- 5
duration_of_Inow <- 5

#......................
# bring this together in a tibble
#......................
maestro_map <- tibble::as_tibble(
  expand.grid(Iseed = Iseednow,
              N = Nnow,
              rho = rhonow,
              init_contact_mat = init_contact_matnow,
              beta = betanow,
              dur_I = duration_of_Inow)
)

#......................
# now add in reps
#......................
reps <- 10
maestro_map <- dplyr::bind_rows(replicate(reps, maestro_map, simplify = F))

#......................
# now add in NE vs trad
#......................
maestro_map_NE <- maestro_map %>%
  dplyr::mutate(modtype = "NE")
maestro_map_trad <- maestro_map %>%
  dplyr::mutate(modtype = "trad")
# bring together
maestro_map <- dplyr::bind_rows(maestro_map_NE, maestro_map_trad)


#............................................................
# save out
#...........................................................
dir.create(paste0(here::here(), "/analyses/01-vary_rho_NC/simresults"))
saveRDS(maestro_map, file = paste0(here::here(), "/analyses/01-vary_rho_NC/simresults/maestro.RDS"))
