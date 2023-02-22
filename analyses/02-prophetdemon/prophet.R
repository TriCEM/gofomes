## .................................................................................
## Purpose: Using tensor_flow and reticulate to build the prophet
##
## Author: Nick Brazeau
##
## Date: 20 February, 2023
##
## Notes:
## reticulate and TF for R: https://rstudio-pubs-static.s3.amazonaws.com/529704_0a08ca3509cd4990bb44014fbea096ad.html#18
## TF Repo for R: https://tensorflow.rstudio.com/install/
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
# source python scripts
#...........................................................
model <- keras_model_sequential()  %>%
  layer_dense(units = 256, activation = 'relu', input_shape = c(784)) %>%
  layer_dropout(rate = 0.4) %>%
  layer_dense(units = 128, activation = 'relu') %>%
  layer_dropout(rate = 0.3) %>%
  layer_dense(units = 10, activation = 'softmax')

model %>% compile(
  loss = 'categorical_crossentropy',
  optimizer = optimizer_rmsprop(),
  metrics = c('accuracy')
)
