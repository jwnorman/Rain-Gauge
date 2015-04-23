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
load(file=paste(directory, "cdfs.Rda", sep=''))
load(file=paste(directory, "largetr.Rda", sep=''))
load(file=paste(directory, "largete.Rda", sep=''))

# temporarily assign largetr/e to tr/e
tr <- largetr
te <- largete

# # # How does explnatory variables interact with other?
cortab <- round(cor(tr, use="complete.obs"), 2)
round(cor(train[, c("ebin", "rr1m", "rr1r", "rm", "rr", "rhvm", "rhvr")], use="complete.obs"),2)

# # # What percentage are NA
NApercent.tr <- apply(tr, MARGIN=2, function(x) {
	length(which(is.na(x)))/nrow(tr)
})
NApercent.te <- apply(tr, MARGIN=2, function(x) {
	length(which(is.na(x)))/nrow(tr)
})
round(NApercent.tr, 5)
round(NApercent.te, 5)
round((NApercent.tr + NApercent.te)/2, 5)

# # # Numeric, low missing dataset
variablesToKeep <- c("RR1.mean", "RR1.range", "Reflectivity.mean", "Reflectivity.range", "RhoHV.mean", "RhoHV.range", "Zdr.mean", "Zdr.range", "RR1.diffMean", "Reflectivity.diffMean", "RhoHV.diffMean", "Zdr.diffMean", "hydroMode")
train <- tr[, variablesToKeep]
test <- te[, variablesToKeep]

# # # Deal with NAs by surrogates or max densities
# By max density
combined <- as.data.frame(rbind(train, test))
apply(train, MARGIN=2, function(x){ length(which((is.na(x)))) })
apply(test, MARGIN=2, function(x){ length(which((is.na(x)))) })
apply(combined, MARGIN=2, function(x){ length(which((is.na(x)))) })

# find max densities of each variable
# should this be moved in to process.R?
maxDensities <- apply(combined, MARGIN=2, function(col) {
	densTemp <- density(col, na.rm=TRUE)
	densTemp$x[densTemp$y == max(densTemp$y)]
})
hydroModeFreqTable <- data.frame(table(combined$hydroMode))
maxDensities["hydroMode"] <- as.numeric(as.character(hydroModeFreqTable$Var1[hydroModeFreqTable$Freq == max(hydroModeFreqTable$Freq)])) # For absurd completeness

backuptrain <- train
backuptest <- test

# replace NAs, and split back in to train and test
combined <- as.data.frame(sapply(names(maxDensities), function(varName) {
	ifelse(is.na(combined[,varName]), maxDensities[varName], combined[,varName])
}))
combined$hydroMode <- as.factor(combined$hydroMode) # adds one to int; prob should turn to char first but it shouldn't effect results

# Bring back in Id and Expected
train <- as.data.frame(combined[1:(nrow(train)), ])
test <- as.data.frame(combined[(nrow(train)+1):nrow(combined), ])

# Save
save(train, file=paste(directory, "train.Rda", sep=''))
save(test, file=paste(directory, "test.Rda", sep=''))

# 3 things to try right now:
# 1) after glm, call step()
# 2) for when mm = 69, include 68.5 and up
# 3) use new variables (diffMeans and hydroMode)

# Create function to estimate % density at 0mm, 1mm, ..., 69mm
# turn expected into binary: 0 for not xmm, 1 for xmm (where x is 0:69)
# run logistic regression and obtain percentages for 1 (xmm)
# after running 70 logistic regressions, you'll have 70 estimates for each observation
# for each observation, cumsum() the estimations and scale to equal 1

# 1) hack to take treat > 69.5 as 69s:
Expected2 <- ifelse(Expected >= 69, 69, Expected)

beg <- Sys.time()
probsByMM <- as.data.frame(sapply(0:69, function(mm) {
	tempExpected <- ifelse(Expected2 >= (mm - .5) & Expected2 <= (mm + .5), 1, 0)
	tempFit <- glm(tempExpected ~ ., family = "binomial", data = train)
	# 2
	# tempFit <- step(tempFit)
	predict(tempFit, test, type="response")
}))
end <- Sys.time()
tot <- end - beg # 1.2 minutes for 4
70/4 * tot # 21.4 estimated minutes, but 1.38 hours because of factor, i forgot

# # beg2 <- Sys.time()
# probsByMM <- as.data.frame(sapply(0:3, function(mm) {
	# tempExpected <- ifelse(Expected2 >= (mm - .5) & Expected2 <= (mm + .5), 1, 0)
	# tempFit <- glm(tempExpected ~ ., family = "binomial", data = train)
	# # 2
	# tempFit <- step(tempFit)
	# predict(tempFit, test, type="response")
# }))
# end2 <- Sys.time()
# tot2 <- end2 - beg2 # 34.4 minutes for 4
# 70/4*tot2/60 # 10 hours estimate

cdfs <- as.data.frame(t(sapply(1:nrow(probsByMM), function(rownum) {
	tempCum <- as.numeric(cumsum(probsByMM[rownum, ]))
	Cum <- tempCum/tempCum[length(tempCum)]
})))
cdfs$Id <- idTest
cdfs <- cdfs[,c(71,1:70)]
names(cdfs) <- c("Id", paste("Predicted", 0:69, sep=''))

save(probsByMM, file=paste(directory, "probsByMM_20150422.Rda", sep=''))
save(cdfs, file=paste(directory, "cdfs_20150422.Rda", sep=''))

write.csv(cdfs, file=paste(directory, "cdfs.csv", sep=''), row.names=FALSE)


