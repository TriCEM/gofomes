## .................................................................................
## Purpose: Using tensor_flow and reticulate to build the prophet
##
## Author: Nick Brazeau & David Rasmussen
##
## Date: 20 February, 2023
##
## Notes:
## reticulate and TF for R: https://rstudio-pubs-static.s3.amazonaws.com/529704_0a08ca3509cd4990bb44014fbea096ad.html#18
## TF Repo for R: https://tensorflow.rstudio.com/install/
## https://tensorflow.rstudio.com/guides/keras/writing_a_training_loop_from_scratch
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
# Read in Simulation Data
#...........................................................
traindata <- readRDS("analyses/02-prophetdemon/sandbox/fake_data.RDS")

# normalize pop size
traindata$final_size <- lapply(simdata$final_size, function(x){x/100})

#............................................................
# Set up prophet model
#   For Conv layers: first argument is the # of filters, second argument is the kernel size
#   To think about: Should we sort rows/columns in adjacency matrix so most well-connected nodes are closer
#   Maybe by single-linkage clustering: https://www.section.io/engineering-education/hierarchical-clustering-in-python/
#...........................................................
n <- 1e2 # population size, needs to be same from sim
batch_size <- 10
input_shape_dim <- c(batch_size, n, n, 1)
# make CNN model
prophet <- keras::keras_model_sequential() %>%
  keras::layer_conv_2d(., filters = 2, kernel_size = 8, activation = "relu", padding = "same", input_shape = input_shape_dim) %>%
  keras::layer_max_pooling_2d(pool_size = 2) %>%
  keras::layer_conv_2d(., filters = 4, kernel_size = 4, activation = "relu", padding = "same") %>%
  keras::layer_max_pooling_2d(pool_size = 2) %>%
  keras::layer_conv_2d(., filters = 8, kernel_size = 2, activation = "relu", padding = "same") %>%
  keras::layer_max_pooling_2d(pool_size = 2) %>%
  keras::layer_flatten() %>%
  keras::layer_dense(., units = 32, activation = "relu") %>%
  keras::layer_dense(., units = 16, activation = "relu") %>%
  keras::layer_dense(., units = 1, activation = "sigmoid")

# see summary of what we made
prophet


#............................................................
# Using built in
#...........................................................
net_batch <- tensorflow::as_tensor( traindata$contact_networks[batchindices] )
true_final_sizes <- tensorflow::as_tensor( traindata$final_size[batchindices] )
true_final_sizes <- tensorflow::array_reshape(true_final_sizes, dim = c(batch_size, 1))

prophet %>% compile(
  optimizer = keras::optimizer_adam(),  # Optimizer
  # Loss function to minimize
  loss = keras::loss_mean_squared_error(),
  # List of metrics to monitor
  metrics = list(metric_sparse_categorical_accuracy()),
)

prophet %>%
  keras::fit(
    net_batch,
    true_final_sizes,
    batch_size = 10,
    epochs = 50
  )


