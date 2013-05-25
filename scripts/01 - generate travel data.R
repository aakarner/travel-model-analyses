# setwd("E:/github repos/travel-data-analysis/data")

# Create random distance skims

# col 1 = origin
# col 2 = destination
# remaining columns = modes
										
dist <- rlnorm(2500, 3.0, 0.2)

dist.skims.am <- data.frame(
	orig = rep(1:50,50), # origins
	dest = as.vector(sapply(1:50, function(x) rep(x,50))), # destinations
	sov = dist, # sov
	hov2 = dist * 1.1, # hov2
	hov3 = dist * 1.15, # hov3
	bike = dist * 1.5, # bike
	walk = dist * 1.5) # walk

# Assume the same AM and PM distance skims
dist.skims.pm <- dist.skims.am

write.csv(SJV.sampl, "sample_trip table.csv", row.names = FALSE)
write.csv(dist.skims.am, "dist_skims_am.csv", row.names = FALSE)
write.csv(dist.skims.pm, "dist_skims_pm.csv", row.names = FALSE)

# End data prep