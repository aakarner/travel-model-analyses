# ----------------------------------
# This script creates imagined distance skims for a 50 zone 
# network with five possible modes.
# 
# The resultant csv files are already stored in the 'data'
# directory on GitHub, so do not need to be recreated.
# ----------------------------------

# Create random distance skims
dist <- rlnorm(2500, 3.0, 0.2)

# Create a data frame to store skims. Skims for non-
# drive alone are multiples of drive alone distance
dist.skims.am <- data.frame(
	orig = rep(1:50,50),
	dest = as.vector(sapply(1:50, function(x) rep(x,50))),
	sov = dist, # sov
	hov2 = dist * 1.1, # hov2
	hov3 = dist * 1.15, # hov3
	bike = dist * 1.5, # bike
	walk = dist * 1.5) # walk

# Assume the same AM and PM distance skims
dist.skims.pm <- dist.skims.am

write.csv(dist.skims.am, "data/dist_skims_am.csv", row.names = FALSE)
write.csv(dist.skims.pm, "data/dist_skims_pm.csv", row.names = FALSE)

# End data prep