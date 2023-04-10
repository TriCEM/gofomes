## .................................................................................
## Purpose: Demon variatonal autoencoder to thwart prophet
##
## Author: Nick Brazeau
##
## Date: 22 February, 2023
##
## Notes:
## VAE built heavily from https://github.com/ageron/handson-ml2
## tutorial on AE in R https://nbisweden.github.io/workshop-neural-nets-and-deep-learning/session_rAutoencoders/lab_autoencoder_hapmap.html
## .................................................................................
#install.packages("tensorflow")
#install.packages("keras")
library(tidyverse)
library(reticulate)
library(tensorflow)
library(keras)
reticulate::use_python("/Users/nbrazeau/Documents/Github/prophetdemon/venv/bin/python")
reticulate::use_virtualenv("/Users/nbrazeau/Documents/Github/prophetdemon/venv")


#............................................................
# Set up demon ENcoder
#...........................................................
n <- 1e2 # population size, needs to be same from sim as nodes, etc

coding_dim <- 10
inputs <- keras::layer_input(shape = c(n,n))
z <- keras::layer_flatten(object = inputs) %>%
  keras::layer_dense(., units = 150, activation = "selu") %>%
  keras::layer_dense(., units = 150, activation = "selu")
# mu - mean coding
codings_mean <- z %>%
  keras::layer_dense(coding_dim)
# lambda - log var coding
codings_log_var <- z %>%
  keras::layer_dense(coding_dim)
# reparameterization trick (to not violate backwards prop)

z = keras.layers.Flatten()(inputs)
z = keras.layers.Dense(150,activation="selu")(z)
z = keras.layers.Dense(100,activation="selu")(z)
codings_mean = keras.layers.Dense(coding_dim)(z) # mean coding
codings_log_var = keras.layers.Dense(coding_dim)(z) # log var coding
codings = CodingSampler()([codings_mean,codings_log_var])
demon_encoder = keras.Model(inputs=[inputs], outputs=[codings_mean, codings_log_var, codings])

