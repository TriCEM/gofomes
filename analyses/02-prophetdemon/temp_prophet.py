#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Jan 19 15:42:20 2023

Train prophet model to predict final sizes on Erdos-Renyi random graphs
Then predict final sizes on a different test set of networks

@author: David
"""

import tensorflow as tf
from tensorflow import keras
import numpy as np
import networkx as nx
import seaborn as sns
import pandas as pd 


# Sim params
n = 100 # pop size
final_time = 10.0 # time simulations should end
init_I = np.zeros(n)
init_I[0] = 1 # seed first infection
edge_p = .05  # edge probability
omega = 0 # immune waining: set to zero for SIR / Inf for SIS
nu = 0.5 # recovery/removal rate


"""
    Set up prophet model
    For Conv layers: first argument is the # of filters, second argument is the kernel size
    To think about: Should we sort rows/columns in adjacency matrix so most well-connected nodes are closer
    Maybe by single-linkage clustering: https://www.section.io/engineering-education/hierarchical-clustering-in-python/
"""
batch_size = 10 # num sims per training episode
input_shape = (batch_size,n,n,1)
prophet = keras.models.Sequential([
    keras.layers.Conv2D(2,8,activation="relu",padding="same",input_shape=input_shape[1:]),
    keras.layers.MaxPooling2D(2),
    keras.layers.Conv2D(4,4,activation="relu",padding="same"),
    keras.layers.MaxPooling2D(2),
    keras.layers.Conv2D(8,2,activation="relu",padding="same"),
    keras.layers.MaxPooling2D(2),
    keras.layers.Flatten(),
    keras.layers.Dense(32, activation="relu"),
    keras.layers.Dense(16, activation="relu"),
    keras.layers.Dense(1, activation="sigmoid")
    ])
prophet.summary()


"""
    Set training params
"""
#replay_buffer = deque(maxlen=2000)
optimizer = keras.optimizers.Adam(lr=1e-3)
loss_fn = keras.losses.mean_squared_error

"""
    Generate training set of nets and final sizes
"""
p_vals = np.tile(np.linspace(0.02, 0.05, num=16),10)
train_final_sizes, train_nets = generate(sim, p_vals)

"""
    Train prophet on simulated nets/epidemics
"""
episode_losses = []
for episode in range(500):
    
    # Sample realizations for training batch
    batch_indices = np.random.choice(len(train_final_sizes), batch_size)
    net_batch = tf.convert_to_tensor(train_nets[batch_indices])s
    true_final_sizes = tf.convert_to_tensor(train_final_sizes[batch_indices])
    true_final_sizes = tf.reshape(true_final_sizes, [batch_size,1])
    
    with tf.GradientTape() as tape:
       predicted_final_sizes = prophet(net_batch)
       loss = tf.reduce_mean(loss_fn(true_final_sizes,predicted_final_sizes))
    grads = tape.gradient(loss, prophet.trainable_variables)
    optimizer.apply_gradients(zip(grads, prophet.trainable_variables))   

    #if episode % 10 == 0:
    print('Episode: ' + str(episode) + '; Loss: ' + f'{loss.numpy():.3f}')

    episode_losses.append(loss.numpy())
    
plot_training(episode_losses,'Loss','loss_by_episode.png')

"""
    For validation/test set: Simulate new batches of networks under different edge_p values
    Compare error in predictions at each value with std error in epi sizes
"""
p_vals = np.tile(np.linspace(0.02, 0.05, num=4),100)
test_final_sizes, test_nets = generate(sim, p_vals)
predicted_final_sizes = prophet.predict(test_nets)
predicted_final_sizes = np.squeeze(predicted_final_sizes)
test_dict = {'Test Final Size': test_final_sizes, 'Predicted Final Size': predicted_final_sizes, 'Edge Prob': p_vals} 
df = pd.DataFrame(test_dict)
results_file = 'prophet_finalsize_predictions.csv'
df.to_csv(results_file,index=False) 
    
