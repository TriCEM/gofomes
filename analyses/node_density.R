## .................................................................................
## Purpose: Aessing node density of NE Dynamic Model
##
## Author: Nick Brazeau
##
## Date: 05 January, 2023
##
## Notes:
## .................................................................................
library(fomes)


#............................................................
# magic numbers and initial conditions
#...........................................................
iters <- 1e5
ret <- matrix(NA, nrow = iters, ncol = 10)
N <- 10
initNC <- 3
rho <- 0.694
conn <- genRandomNetworkConnections(N = N, initNC = initNC, rho = rho)
rowSums(conn)

#............................................................
# run iters of update network connections
#...........................................................
for (k in 1:iters) {
  ret[k, ] <- rowSums(updateNetworkConnections(adjmat = conn, rho = rho))
}

rowSums(conn) # to from style, each individual connections
colMeans(ret)



#............................................................
# PLAYGROUND
#...........................................................
rowSums(conn)
rowSums(updateNetworkConnections(adjmat = conn, rho = rho))


conn1 <- updateNetworkConnections(adjmat = conn, rho = rho)
conn2 <- updateNetworkConnections(adjmat = conn, rho = rho)
conn3 <- updateNetworkConnections(adjmat = conn, rho = rho)
conn4 <- updateNetworkConnections(adjmat = conn, rho = rho)
conn5 <- updateNetworkConnections(adjmat = conn, rho = rho)

