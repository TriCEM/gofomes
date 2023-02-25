#!/bin/bash
######################################################################
# A batchtools launch script template for Slurm
#
######################################################################

#SBATCH --job-name=<%= job.name %>
#SBATCH --output=<%= log.file %>
#SBATCH --nodes=1
#SBATCH --time=2-00:00:00

## Resources needed:
<% if (length(resources) > 0) {
  opts <- unlist(resources, use.names = TRUE)
  opts <- sprintf("--%s=%s", names(opts), opts)
  opts <- paste(opts, collapse = " ") %>
#SBATCH <%= opts %>
<% } %>

## Launch R and evaluated the batchtools R job
Rscript -e 'batchtools::doJobCollection("<%= uri %>")'
