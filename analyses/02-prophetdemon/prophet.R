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
## https://tensorflow.rstudio.com/guides/keras/writing_a_training_loop_from_scratch
## .................................................................................
#install.packages("tensorflow")
#install.packages("keras")
library(tidyverse)
library(reticulate)
library(tensorflow)
library(keras)
library(tfautograph)
reticulate::use_python("/Users/nbrazeau/Documents/Github/prophetdemon/venv/bin/python")
reticulate::use_virtualenv("/Users/nbrazeau/Documents/Github/prophetdemon/venv")

#............................................................
# Read in Simulation Data
#...........................................................
traindata <- readRDS("analyses/02-prophetdemon/sandbox/fake_data.RDS")

# normalize pop size
traindata$final_size <- lapply(traindata$final_size, function(x){x/100})


#............................................................
# Set up prophet model
#   For Conv layers: first argument is the # of filters, second argument is the kernel size
#   To think about: Should we sort rows/columns in adjacency matrix so most well-connected nodes are closer
#   Maybe by single-linkage clustering: https://www.section.io/engineering-education/hierarchical-clustering-in-python/
#...........................................................
n <- 1e2 # population size, needs to be same from sim
batch_size <- 10 # num sims per training episode
input_shape_dim <- c(batch_size, n, n, 1)
# make CNN model
prophet <- keras::keras_model_sequential() %>%
  keras::layer_conv_2d(., filters = 2, kernel_size = 8, activation = "relu", padding = "same", input_shape = input_shape_dim[2:length(input_shape_dim)]) %>%
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
# Set up Training Regimen
#...........................................................
#......................
# gradient items
#......................
optimizer <- keras::optimizer_adam(learning_rate = 1e-3) # adam is good GD optimizer - can explore adamax, etc
loss_fn <- keras::loss_mean_squared_error() # can later change loss fxn

#......................
# setting up epoch/epochs
#......................
epochs <- 500 # number of times to explore the batched training data
epochs_losses <- rep(NA, epochs)

# run through epochs
for (i in 1:epochs) {
  # Iterate over the batches of the dataset.
  tfautograph::autograph(for (batch in train_dataset) {
    # Sample realizations for training batch
    batchindices <- sample(1:length(traindata$contact_networks), size = batch_size)
    net_batch <- tensorflow::as_tensor( traindata$contact_networks[batchindices] )
    true_final_sizes <- tensorflow::as_tensor( traindata$final_size[batchindices] )
    true_final_sizes <- tensorflow::array_reshape(true_final_sizes, dim = c(batch_size, 1))

    # calculate gradients
    with(tf$GradientTape() %as% tape, {
      predicted_final_sizes <- prophet(net_batch)
      loss_value <- loss_fn(true_final_sizes, predicted_final_sizes)
    })
    # apply gradients
    grads <- tape$gradient(loss_value, prophet$trainable_variables)
    # zip together for gradients
    optimizer$apply_gradients(zip_lists(grads, prophet$trainable_variables))
    #TODO unreadvariable OK? https://stackoverflow.com/questions/60722174/what-are-the-unreadvariable-in-tensorflow-2-0
    # or is this the issue why weights aren't being updated?>!
  })

  #......................
  # store loss
  #......................
  epochs_losses[i] <- as.numeric(loss_value)
}

plot(epochs_losses)

#............................................................
# Validation Regimen
#...........................................................
