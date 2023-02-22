## .................................................................................
## Purpose: Setup for Varying Parameters to Determine Effect on Final Distribution Size
##
## Author: Nick Brazeau
##
## Date: 30 January, 2023
##
## Notes: Using a dataframe ("maestro") to hold model parameters as input. Will then map
##        through dataframe and to fit various models following the format of R for Data Science
##        framework: https://r4ds.had.co.nz/many-models.html
##
##        Given that we want to fit many models, will use the UNC Cluster Longleaf as a workhorse
## .................................................................................
library(tidyverse)
library(fomes)
set.seed(48)
#............................................................
# Constant Numbers for Simulations
#...........................................................
Iseednow <- 1 # initial infection
Nnow <- 1e2 # population size
betanow <- 0.5
duration_of_Inow <- 10

#............................................................
# Parameters to Vary
#...........................................................
# init contact matrices
init_connectionsnow <- lapply(seq(5, 50, by = 5), function(x){
  return(fomes::genInitialConnections(initNC = x, N = Nnow))
})
# need to tidy this for better join
init_connectionsnow <- tibble::tibble(contnames = paste("cm", 1:length(init_connectionsnow), sep = ""),
                                      init_contact_mat = init_connectionsnow)

# rewiring
rhonow <- seq(-5, 5, length.out = 11)
rhonow <- sapply(rhonow, function(x){10^x})

# SIR Rate Params
#betanow <- seq(0.05, 1, length.out = 10)
#duration_of_Inow <- c(1, seq(5, 25, by = 5))



#............................................................
# Maestro: Bringing this all together
#...........................................................
maestro_map <- tibble::as_tibble(
  expand.grid(Iseed = Iseednow,
              N = Nnow,
              rho = rhonow,
              contnames = init_connectionsnow$contnames,
              beta = betanow,
              dur_I = duration_of_Inow)
)

# join tidy
maestro_map <- maestro_map %>%
  dplyr::left_join(., init_connectionsnow, by = "contnames") %>%
  dplyr::select(-c("contnames"))

# now add in reps
reps <- 1e2
maestro_map <- dplyr::bind_rows(replicate(reps, maestro_map, simplify = F))


# add modnames
modnames <- sapply(1:nrow(maestro_map), function(x){paste("NEmod", x, sep = "")})
maestro_map <- maestro_map %>%
  dplyr::mutate(name = modnames) %>%
  dplyr::select(c("name", dplyr::everything()))

#............................................................
# Mass Action Model to Compare
#...........................................................
# ma mat
manow <- matrix(1, Nnow, Nnow)
diag(manow) <- 0
# combine
massaction <- tibble::as_tibble(expand.grid(Iseed = Iseednow,
                                            N = Nnow,
                                            rho = 10^-.Machine$double.xmax,
                                            init_contact_mat = list(manow),
                                            beta = betanow,
                                            dur_I = duration_of_Inow))

# now add in reps
reps <- 1e2
massaction <- dplyr::bind_rows(replicate(reps, massaction, simplify = F))

# add modnames
modnames <- sapply(1:nrow(massaction), function(x){paste("MAmod", x, sep = "")})
massaction <- massaction %>%
  dplyr::mutate(name = modnames) %>%
  dplyr::select(c("name", dplyr::everything()))

#............................................................
# finalize
#...........................................................
# bring together
maestro_map_final <- dplyr::bind_rows(maestro_map, massaction)



#............................................................
# save out
#...........................................................
dir.create(paste0(here::here(), "/analyses/01-vary_params/results"))
saveRDS(maestro_map_final, file = paste0(here::here(), "/analyses/01-vary_params/results/maestro_params.RDS"))
