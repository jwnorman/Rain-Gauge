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
cor(tr.Unlisted[,c(4,5,7:20)], use="complete.obs")

# 
boxplot(tr.Unlisted$Expected ~ tr.Missing$Composite_NA)

fit <- glm(tr.Unlisted$Expected ~ . - tr.Unlisted$Id, data=tr.Unlisted)
fit2 <- glm(tr.Unlisted$Expected ~ ., data=tr.Missing)
summary(fit)
summary(fit2)