# explore data

# load existing data
load(file=paste(directory, "trUnlisted.Rda", sep=''))
load(file=paste(directory, "teUnlisted.Rda", sep=''))
load(file=paste(directory, "trMissing.Rda", sep=''))
load(file=paste(directory, "teMissing.Rda", sep=''))

plot(density(tr.Unlisted$Expected), xlim=c(0,69))
plot(density(tr.Unlisted$Expected[tr.Unlisted$Expected<=69]))

prop.table(table(tr.Unlisted$Expected==0)) # .2581745
prop.table(table(tr.Unlisted$Expected==0, tr.Unlisted$HydrometeorType)) 
table(tr.Unlisted$Expected==0, tr.Unlisted$HydrometeorType)
# c(1, 10, 13, 2, 3, 4, 9) = more rain than not rain
# c(11, 5, 6, 7, 8) = less rain than not rain
fit <- lm(tr.Unlisted$Expected ~ tr.Unlisted$HydrometeorType)
summary(fit)

# look at correlation between explanatory variables
# isolate numeric variables first
str(tr.Unlisted)
cor(tr.Unlisted[,c(2:5,7:20)], use="complete.obs")

# # TimeToEnd
head(tr.Unlisted$TimeToEnd,50)
summary(tr.Unlisted$TimeToEnd)
plot(density(tr.Unlisted$TimeToEnd))
prop.table(table(tr.Unlisted$TimeToEnd))

# by count
plot(table(tr.Unlisted$Expected==0, tr.Unlisted$TimeToEnd)[2,], col="red") # == 0
points(table(tr.Unlisted$Expected==0, tr.Unlisted$TimeToEnd)[1,], col="blue") # != 0

# by proportion
dis <- prop.table(table(tr.Unlisted$Expected==0, tr.Unlisted$TimeToEnd), margin=2)
plot(dis[1,1:60]) # 0 and 61 have low counts; It seems as TimeToEnd increases, Expected is more likely to be nonzero; from about .245 to about .268 so very small difference, but it's consistent, but nonlinear

# how does time to end interact with other explanatory variables?
cortab <- cor(tr.Unlisted[,c(2:5,7:20)], use="complete.obs")
