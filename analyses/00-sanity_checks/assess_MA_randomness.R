## .................................................................................
## Purpose: Test NE versus traditional
##
## Author: Nick Brazeau
##
## Date: 03 January, 2023
##
## Notes:
## .................................................................................
#remotes::install_github("TriCEM/fomes", ref = "develop")
library(fomes)
library(tidyverse)
library(cowplot)

#............................................................
# Magic Numbers
#...........................................................
popsize <- 100
duration_of_I <- 5
initial_infxns <- 1
initNCval <- 99
betaind <- 5
rhoconn <- 50

# storage
niters <- 100
combouts <- as.data.frame(matrix(NA, nrow = niters, ncol = 5))
colnames(combouts) <- c("iter",
                        "NEfinalsize", "NEfinaltime",
                        "TDfinalsize", "TDfinaltime")
combouts$iter <- 1:niters

#............................................................
# run through
#...........................................................
for (i in 1:niters) {
  #......................
  # dynamic network
  #......................
  NEdynSIR <- fomes::sim_Gillespie_SIR(Iseed = initial_infxns,
                                       N = popsize,
                                       beta = rep(betaind, popsize),
                                       dur_I = duration_of_I,
                                       rho = rhoconn,
                                       initNC = initNCval,
                                       term_time = Inf)

  tidyNEdynSIR <- summary(NEdynSIR)
  # storage
  combouts[i, "NEfinalsize"] <- tidyNEdynSIR$FinalEpidemicSize
  combouts[i, "NEfinaltime"] <- max(tidyNEdynSIR$CumEvents$Time)


  #......................
  # traditional model
  #......................
  tradSIR <- fomes:::tradsim_Gillespie_SIR(Iseed = initial_infxns,
                                          N = popsize,
                                          beta = betaind,
                                          dur_I = duration_of_I,
                                          term_time = Inf)

  # storage
  combouts[i, "TDfinalsize"] <- sum(tradSIR[1,c("Susc", "Infxn")]) - tradSIR[nrow(tradSIR), "Susc"]
  combouts[i, "TDfinaltime"] <- tradSIR[nrow(tradSIR), "Time"]

}

#............................................................
# analyze results
#...........................................................
p1 <- combouts %>%
  dplyr::select(c("NEfinalsize", "TDfinalsize")) %>%
  tidyr::pivot_longer(cols = dplyr::contains("size"),
                      names_to = "model",
                      values_to = "finalsize") %>%
  dplyr::mutate(model = dplyr::case_when(model == "NEfinalsize" ~ "Dynamic MA",
                                         model == "TDfinalsize" ~ "Traditional")) %>%
ggplot() +
  geom_boxplot(aes(y = finalsize),
               outlier.colour = "red", outlier.shape = 8,
               outlier.size = 4) +
  ylab("Final Size Distribution") +
  theme_linedraw() +
  theme(axis.text.x = element_blank(),
        axis.ticks.x = element_blank()) +
  facet_grid(~model)


p2 <- combouts %>%
  dplyr::select(c("NEfinaltime", "TDfinaltime")) %>%
  tidyr::pivot_longer(cols = dplyr::contains("time"),
                      names_to = "model",
                      values_to = "finaltime") %>%
  dplyr::mutate(model = dplyr::case_when(model == "NEfinaltime" ~ "Dynamic MA",
                                         model == "TDfinaltime" ~ "Traditional")) %>%
  ggplot() +
  geom_boxplot(aes(y = finaltime),
               outlier.colour = "red", outlier.shape = 8,
               outlier.size = 4) +
  ylab("Final Time Distribution") +
  theme_linedraw() +
  theme(axis.text.x = element_blank(),
        axis.ticks.x = element_blank()) +
  facet_grid(~model)

# combine
plotout <- cowplot::plot_grid(p1, p2, nrow = 2)


jpeg("~/Desktop/temp_dynamic_ma_vs_trad.jpg",
     height = 6, width = 12,
     res = 500, units = "in")
plotout
graphics.off()

