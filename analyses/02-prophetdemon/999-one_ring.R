## .................................................................................
## Purpose: Using reticulate to capture prophet and demon output
##
## Author: Nick Brazeau
##
## Date: 20 February, 2023
##
## Notes:
## .................................................................................
library(tidyverse)
library(reticulate)

#............................................................
# source python scripts
#...........................................................
reticulate::source_python("analyses/02-prophetdemon/test_input.py")
addtest(a = 1, b = 3)
