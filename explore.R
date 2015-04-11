# explore data

# directory prefix
directory <- "~/Documents/Kaggle/Rain/Rain-Gauge/Data/" # Mac
directory <- "C://Kaggle - other//Rain//Rain-Gauge//Data//" # PC

# load existing data
load(file=paste(directory, "tr.Rda", sep=''))
load(file=paste(directory, "te.Rda", sep=''))

# # # How does explnatory variables interact with other?
cortab <- cor(tr, use="complete.obs")

# # # What percentage are NA
NApercent <- apply(tr, MARGIN=2, function(x) {
	length(which(is.na(x)))/nrow(tr)
})
round(NApercent, 2)

# # # TimeToEnd
head(tr$TimeToEnd,50)
summary(tr$TimeToEnd)
plot(density(tr$TimeToEnd))
prop.table(table(tr$TimeToEnd))

# # Look at How TimeToEnd interacts with Expected == 0 or != 0
# by looking at the counts
plot(table(tr$Expected==0, tr$TimeToEnd)[2,], col="red") # == 0
points(table(tr$Expected==0, tr$TimeToEnd)[1,], col="blue") # != 0

# by looking at the proportions
dis <- prop.table(table(tr$Expected==0, tr$TimeToEnd), margin=2)
plot(dis[1,1:60])

# # Given there is some rain, how does TimeToEnd interact with Expected now?
# using mean as comparison
plot(tapply(tr$Expected[tr$Expected > 0], tr$TimeToEnd[tr$Expected > 0], mean)) # mean decrease as TimeToEnd goes up?

# using median as comparison
plot(tapply(tr$Expected[tr$Expected > 0], tr$TimeToEnd[tr$Expected > 0], median)) # median practically always at 1.30

# using density as comparison
densities <- tapply(tr$Expected[tr$Expected > 0], tr$TimeToEnd[tr$Expected > 0], density)
plot(densities[[1]], xlim=c(0,70), ylim=c(0,1.5), mar=1, main="", xlab="", ylab="")
lapply(densities[2:length(densities)], function(d) {
	lines(d)
})

# using density as comparison limiting mm < 69
densities <- tapply(tr$Expected[tr$Expected %in% 1:69], tr$TimeToEnd[tr$Expected %in% 1:69], density)
plot(densities[[1]], xlim=c(0,70), ylim=c(0,1.5), mar=1, main="", xlab="", ylab="")
lapply(densities[2:length(densities)], function(d) {
	lines(d)
	Sys.sleep(.01)
})

counts <- tapply(tr$TimeToEnd[tr$Expected %in% 1:69], tr$Expected[tr$Expected %in% 1:69], length)
table(tr$TimeToEnd[tr$Expected %in% 0:100], tr$Expected[tr$Expected %in% 0:100]) # like i saw earlier with peaks at 0 and every 13/14 mm, there are particular high counts at 1,2,3, 14, 28, 43, 57

# compare to overall mm dist
plot(table(tr$Expected[tr$Expected %in% 5:100])) # same thing: 1,2,3, 14, 28, 43, 57, 72, 86, 100,... so it doesn't have to do with TimeToEnd; just Expected

plot(tapply(tr$RadarQualityIndex, tr$TimeToEnd, mean, na.rm=TRUE))

# # # DistanceToRadar
attach(tr)
head(trDistanceToRadar, 100) # for each Id, the DistanceToRadar doesn't vary
any(is.na(DistanceToRadar))
plot(density((DistanceToRadar))) # similar dist to TimeToEnd (fairly uniform over 0 to 100)
plot(tapply(Expected, DistanceToRadar, mean, na.rm=TRUE))
plot(tapply(Expected[Expected>0], DistanceToRadar[Expected>0], mean, na.rm=TRUE), ylim=c(2,20))
plot(tapply(RadarQualityIndex, DistanceToRadar, mean, na.rm=TRUE)) # random

# # # HydrometeorType
prop.table(table(tr$Expected==0)) # .2581745
prop.table(table(tr$Expected==0, tr$HydrometeorType)) 
prop.table(table(tr$Expected==0, tr$HydrometeorType), margin=2) 
table(tr$Expected==0, tr$HydrometeorType)
# c(1, 10, 13, 2, 3, 4, 9) = more rain than not rain
# c(11, 5, 6, 7, 8) = less rain than not rain

# # # RadarQualityIndex
plot(density(RadarQualityIndex[RadarQualityIndex<=1], na.rm=TRUE))