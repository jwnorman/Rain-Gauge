# explore data like explore.R
# but dataset is now means and ranges instead of Unlisted

# directory prefix
directory <- "~/Documents/Kaggle/Rain/Rain-Gauge/Data/" # Mac
directory <- "C://Kaggle - other//Rain//Rain-Gauge//Data//" # PC

# load existing data
load(file=paste(directory, "tr.Rda", sep=''))
load(file=paste(directory, "te.Rda", sep=''))
load(file=paste(directory, "train.Rda", sep=''))
load(file=paste(directory, "test.Rda", sep=''))

# # # How does explnatory variables interact with other?
cortab <- cor(tr, use="complete.obs")
round(cor(train[, c("ebin", "rr1m", "rr1r", "rm", "rr", "rhvm", "rhvr")], use="complete.obs"),2)

# # # What percentage are NA
NApercent.tr <- apply(tr, MARGIN=2, function(x) {
	length(which(is.na(x)))/nrow(tr)
})
NApercent.te <- apply(tr, MARGIN=2, function(x) {
	length(which(is.na(x)))/nrow(tr)
})
round(NApercent.tr, 4)
round(NApercent.te, 4)
round((NApercent.tr + NApercent.te)/2, 4)

# # # Numeric, low missing dataset
train <- tr[,c("Id.mean", "RR1.mean", "RR1.range", "Reflectivity.mean", "Reflectivity.range", "RhoHV.mean", "RhoHV.range", "Expected.mean")]
test <- te[,c("Id.mean", "RR1.mean", "RR1.range", "Reflectivity.mean", "Reflectivity.range", "RhoHV.mean", "RhoHV.range")]
names(train) <- c("id", "rr1m", "rr1r", "rm", "rr", "rhvm", "rhvr", "e")
names(test) <- c("id", "rr1m", "rr1r", "rm", "rr", "rhvm", "rhvr")

# # # Look at Expected as Binary
train$ebin <- ifelse(train$e > 0, 1, 0) # rain as 1 or 0
fit <- glm(ebin ~ rr1m + rr1r + rm + rr + rhvm + rhvr, family = "binomial", data = train)
summary(fit)

# # # Deal with NAs by surrogates or max densities
# By max density
combined <- as.data.frame(rbind(train[,2:(ncol(train)-1)], test[,2:(ncol(test))]))
apply(train, MARGIN=2, function(x){ length(which((is.na(x)))) })
apply(test, MARGIN=2, function(x){ length(which((is.na(x)))) })
apply(combined, MARGIN=2, function(x){ length(which((is.na(x)))) })

# find max densities of each variable
# should this be moved in to process.R?
maxDensities <- apply(combined, MARGIN=2, function(col) {
	densTemp <- density(col, na.rm=TRUE)
	densTemp$x[densTemp$y == max(densTemp$y)]
})
backuptrain <- train
backuptest <- test

# replace NAs, and split back in to train and test
combined$rr1m <- ifelse(is.na(combined$rr1m), maxDensities["rr1m"], combined$rr1m)
combined$rr1r <- ifelse(is.na(combined$rr1r), maxDensities["rr1r"], combined$rr1r)
combined$rm <- ifelse(is.na(combined$rm), maxDensities["rm"], combined$rm)
combined$rr <- ifelse(is.na(combined$rr), maxDensities["rr"], combined$rr)
combined$rhvm <- ifelse(is.na(combined$rhvm), maxDensities["rhvm"], combined$rhvm)
combined$rhvr <- ifelse(is.na(combined$rhvr), maxDensities["rhvr"], combined$rhvr)

# Bring back in Id and Expected
train <- combined[1:(nrow(train)), ]
test <- combined[(nrow(train)+1):nrow(combined), ]
train$id <- tr$Id.mean
test$id <- te$Id.mean
train$e <- tr$Expected.mean

# Save
save(train, file=paste(directory, "train.Rda", sep=''))
save(test, file=paste(directory, "test.Rda", sep=''))

# Create function to estimate % density at 0mm, 1mm, ..., 69mm
# turn expected into binary: 0 for not xmm, 1 for xmm (where x is 0:69)
# run logistic regression and obtain percentages for 1 (xmm)
# after running 70 logistic regressions, you'll have 70 estimates for each observation
# for each observation, cumsum() the estimations and scale to equal 1

probsByMM <- as.data.frame(sapply(0:69, function(mm) {
	tempExpected <- ifelse(train$e >= (mm - .5) & train$e <= (mm + .5), 1, 0)
	tempFit <- glm(tempExpected ~ rr1m + rr1r + rm + rr + rhvm + rhvr, family = "binomial", data = train)
	predict(tempFit, test, type="response")
}))

cdfs <- as.data.frame(t(sapply(1:nrow(probsByMM), function(rownum) {
	tempCum <- cumsum(probsByMM[rownum, ])
	Cum <- tempCum/tempCum[length(tempCum)]
})))
cdfs$Id <- test$id
cdfs <- cdfs[,c(71,1:70)]
names(cdfs) <- c("Id", paste("Predicted", 0:69, sep=''))

save(probsByMM, file=paste(directory, "probsByMM.Rda", sep=''))
save(cdfs, file=paste(directory, "cdfs.Rda", sep=''))

write.csv(probsByMM, file=paste(directory, "cdfs.csv", sep=''), row.names=FALSE)


