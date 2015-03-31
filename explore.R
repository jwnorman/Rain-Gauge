# explore data

# directory prefix
directory <- "~/Documents/Kaggle/Rain/Rain-Gauge/Data/" # Mac

# load existing data
load(file=paste(directory, "trUnlisted.Rda", sep=''))
load(file=paste(directory, "teUnlisted.Rda", sep=''))
load(file=paste(directory, "trMissing.Rda", sep=''))
load(file=paste(directory, "teMissing.Rda", sep=''))

# # # TimeToEnd
head(tr.Unlisted$TimeToEnd,50)
summary(tr.Unlisted$TimeToEnd)
plot(density(tr.Unlisted$TimeToEnd))
prop.table(table(tr.Unlisted$TimeToEnd))

# # How does TimeToEnd interact with other explanatory variables?
cortab <- cor(tr.Unlisted[,c(2:5,7:20)], use="complete.obs")

# # Look at How TimeToEnd interacts with Expected == 0 or != 0

# by looking at the counts
plot(table(tr.Unlisted$Expected==0, tr.Unlisted$TimeToEnd)[2,], col="red") # == 0
points(table(tr.Unlisted$Expected==0, tr.Unlisted$TimeToEnd)[1,], col="blue") # != 0

# by looking at the proportions
dis <- prop.table(table(tr.Unlisted$Expected==0, tr.Unlisted$TimeToEnd), margin=2)
plot(dis[1,1:60])

# # Given there is some rain, how does TimeToEnd interact with Expected now?

# using mean as comparison
plot(tapply(tr.Unlisted$Expected[tr.Unlisted$Expected > 0], tr.Unlisted$TimeToEnd[tr.Unlisted$Expected > 0], mean)) # mean decrease as TimeToEnd goes up?

# using median as comparison
plot(tapply(tr.Unlisted$Expected[tr.Unlisted$Expected > 0], tr.Unlisted$TimeToEnd[tr.Unlisted$Expected > 0], median)) # median practically always at 1.30

# using density as comparison
densities <- tapply(tr.Unlisted$Expected[tr.Unlisted$Expected > 0], tr.Unlisted$TimeToEnd[tr.Unlisted$Expected > 0], density)
plot(densities[[1]], xlim=c(0,70), ylim=c(0,1.5), mar=1, main="", xlab="", ylab="")
lapply(densities[2:length(densities)], function(d) {
	lines(d)
})

# using density as comparison limiting mm < 69
densities <- tapply(tr.Unlisted$Expected[tr.Unlisted$Expected %in% 1:69], tr.Unlisted$TimeToEnd[tr.Unlisted$Expected %in% 1:69], density)
plot(densities[[1]], xlim=c(0,70), ylim=c(0,1.5), mar=1, main="", xlab="", ylab="")
lapply(densities[2:length(densities)], function(d) {
	lines(d)
	Sys.sleep(.01)
})

counts <- tapply(tr.Unlisted$TimeToEnd[tr.Unlisted$Expected %in% 1:69], tr.Unlisted$Expected[tr.Unlisted$Expected %in% 1:69], length)
table(tr.Unlisted$TimeToEnd[tr.Unlisted$Expected %in% 0:100], tr.Unlisted$Expected[tr.Unlisted$Expected %in% 0:100]) # like i saw earlier with peaks at 0 and every 13/14 mm, there are particular high counts at 1,2,3, 14, 28, 43, 57

# compare to overall mm dist
plot(table(tr.Unlisted$Expected[tr.Unlisted$Expected %in% 5:100])) # same thing: 1,2,3, 14, 28, 43, 57, 72, 86, 100,... so it doesn't have to do with TimeToEnd; just Expected

# # # HydrometeorType
prop.table(table(tr.Unlisted$Expected==0)) # .2581745
prop.table(table(tr.Unlisted$Expected==0, tr.Unlisted$HydrometeorType)) 
table(tr.Unlisted$Expected==0, tr.Unlisted$HydrometeorType)
# c(1, 10, 13, 2, 3, 4, 9) = more rain than not rain
# c(11, 5, 6, 7, 8) = less rain than not rain
fit <- lm(tr.Unlisted$Expected ~ tr.Unlisted$HydrometeorType)
summary(fit)