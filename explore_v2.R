# explore data like explore.R
# but dataset is now means and ranges instead of Unlisted
library(lattice)

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
load(file=paste(directory, "probsByMM_20150422.Rda", sep=''))

# hydroMode
Expected <- tr$Expected.mean
plot(density(Expected[train$hydroMode==1]), xlim=c(0,70), ylim=c(0,2))
for (i in 2:13) {
	lines(density(Expected[train$hydroMode==14])) #1,4,9
}

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
round((NApercent.tr + NApercent.te)/2, 5)

# Create function to estimate % density at 0mm, 1mm, ..., 69mm
# turn expected into binary: 0 for not xmm, 1 for xmm (where x is 0:69)
# run logistic regression and obtain percentages for 1 (xmm)
# after running 70 logistic regressions, you'll have 70 estimates for each observation
# for each observation, cumsum() the estimations and scale to equal 1

# grab ids and target
idTrain <- tr$Id.mean
idTest <- te$Id.mean
Expected <- tr$Expected.mean

# try using prsm() (similar to step(), but options for parallel, cross-validation, and a parsimony factor)
cls <- makeCluster(rep('localhost', 4))
# add factors of hydroMode but delete hydroMode
train$hm149 <- ifelse(train$hydroMode %in% c(1,4,9), 1, 0)
test$hm149 <- ifelse(test$hydroMode %in% c(1,4,9), 1, 0)
removeVariables <- c("hydroMode")
keepVariables <- setdiff(names(train), removeVariables)
tr.prsm <- train[, keepVariables]
te.prsm <- test[, keepVariables]
mm <- 0
tempExpected <- ifelse(Expected >= (mm - .5) & Expected <= (mm + .5), 1, 0)
beg <- Sys.time()
tempPrsmFit <- prsm(tempExpected, train, k = 0.0005, predacc = aiclogit, printdel=TRUE, cls=cls, cv=TRUE, cvk=5)
end <- Sys.time()
tot <- end - beg
vars2ModelWith <- names(tr.prsm)[tempPrsmFit]
tempFit <- glm(tempExpected ~ as.matrix(tr.prsm[,vars2ModelWith]), family = "binomial")
compareoutput <- predict(tempFit, tr.prsm, type="response")

# add squared variables
removeVariables <- c("hydroMode")
keepVariables <- setdiff(names(train), removeVariables)
train = train[,keepVariables]
trainSquared = list()
counter = 1
for (i in keepVariables) {
	trainSquared[[i]] = train[,i]^2
	counter = counter + 1
}
trainSquared = as.data.frame(trainSquared)
alltr = as.data.frame(cbind(train, trainSquared))

test = test[,keepVariables]
testSquared = list()
counter = 1
for (i in keepVariables) {
	testSquared[[i]] = test[,i]^2
	counter = counter + 1
}
testSquared = as.data.frame(testSquared)
allte = as.data.frame(cbind(test, testSquared))

# after using pca.R
Expected = tr$Expected.mean
numNodes <- detectCores() - 1
cls <- makeCluster(numNodes, type="FORK")
beg <- Sys.time()
probsByMM <- as.data.frame(parSapply(cls, 0:69, function(mm) {
	tempExpected <- ifelse(Expected >= (mm - .5) & Expected <= (mm + .5), 1, 0)
	tempFit <- glm(tempExpected ~ ., family = "binomial", data = pc.tr)
	predict(tempFit, pc.te, type="response")
}))
stopCluster(cls)
end <- Sys.time()
tot <- end - beg

allCumsums <- t(apply(probsByMM, MARGIN=1, cumsum))
cdfs <- as.data.frame(apply(allCumsums, MARGIN=2, function(x) {ifelse(x > 1, 1, x)})) # new method
cdfs$Id <- as.integer(te$Id.mean)
cdfs <- cdfs[,c(ncol(cdfs), 1:(ncol(cdfs)-1))]
names(cdfs) <- c("Id", paste("Predicted", 0:69, sep=''))
save(cdfs, file=paste(directory, "cdfs_20150509.Rda", sep=''))
write.csv(cdfs, file=paste(directory, "cdfs_20150509.csv", sep=''), row.names=FALSE)

# treat > 69.5 as 69s
Expected2 <- ifelse(Expected >= 69, 69, Expected)

beg <- Sys.time()
probsByMM <- as.data.frame(sapply(0:1, function(mm) {
	tempExpected <- ifelse(Expected >= (mm - .5) & Expected <= (mm + .5), 1, 0)
	tempFit <- glm(tempExpected ~ RhoHV.range, family = "binomial", data = train)
	predict(tempFit, test, type="response")
}))
end <- Sys.time()
tot <- end - beg # 1.2 minutes for 4
# 70/4 * tot # 21.4 estimated minutes, but 1.38 hours because of factor, i forgot

allCumsums <- t(apply(probsByMM, MARGIN=1, cumsum))
cdfs <- as.data.frame(t(apply(allCumsums, MARGIN=1, function(obs) obs/obs[length(obs)])))
cdfs$Id <- as.integer(te$Id.mean)
cdfs <- cdfs[,c(71,1:70)]
names(cdfs) <- c("Id", paste("Predicted", 0:69, sep=''))

logit70 <- function(trtemp, tetemp, mmmax=69) {
	probsByMM <- sapply(0:mmmax, function(mm) {
		tempExpected <- ifelse(trtemp$Expected >= (mm - .5) & trtemp$Expected <= (mm + .5), 1, 0)
		tempFit <- glm(tempExpected ~ . - Id, family = "binomial", data = trtemp)
		predict(tempFit, tetemp, type="response")
	})
	probsByMM <- cbind(probsByMM, matrix(0, nrow = nrow(tetemp), ncol = 70 - ncol(probsByMM)))
	allCumsums <- t(apply(probsByMM, MARGIN=1, cumsum))
	cdfs <- as.data.frame(t(apply(allCumsums, MARGIN=1, function(obs) obs/obs[length(obs)])))
	cdfs$Id <- as.integer(tetemp$Id)
	cdfs <- cdfs[,c(ncol(cdfs), 1:(ncol(cdfs)-1))]
	names(cdfs) <- c("Id", paste("Predicted", 0:69, sep=''))
	return(cdfs)
}

# model with just Reflectivity.range
trtemp <- train
trtemp$Id <- idTrain
trtemp$Expected <- Expected
trtemp <- trtemp[c("Id", "Reflectivity.range", "Expected")]
tetemp <- test
tetemp$Id <- idTest
tetemp <- tetemp[, c("Id", "Reflectivity.range")]

beg <- Sys.time()
probsByMM <- sapply(0:20, function(mm) {
	tempExpected <- ifelse(trtemp$Expected >= (mm - .5) & trtemp$Expected <= (mm + .5), 1, 0)
	tempFit <- glm(tempExpected ~ Reflectivity.range, family = "binomial", data = trtemp)
	predict(tempFit, tetemp, type="response")
})
probsByMM <- cbind(probsByMM, matrix(0, nrow = nrow(tetemp), ncol = 70 - ncol(probsByMM)))
allCumsums <- t(apply(probsByMM, MARGIN=1, cumsum))
cdfs <- as.data.frame(t(apply(allCumsums, MARGIN=1, function(obs) obs/obs[length(obs)])))
cdfs$Id <- as.integer(tetemp$Id)
cdfs <- cdfs[,c(ncol(cdfs), 1:(ncol(cdfs)-1))]
names(cdfs) <- c("Id", paste("Predicted", 0:69, sep=''))
end <- Sys.time()
tot <- end - beg

save(cdfs, file=paste(directory, "cdfs_20150510.Rda", sep=''))
write.csv(cdfs, file=paste(directory, "cdfs_20150510.csv", sep=''), row.names=FALSE)

# Change the probsByMM -> cdfs process of original model
load(file=paste(directory, "probsByMM_20150416.Rda", sep=''))
allCumsums <- t(apply(probsByMM, MARGIN=1, cumsum))
cdfs <- as.data.frame(apply(allCumsums, MARGIN=2, function(x) {ifelse(x > 1, 1, x)})) # new method
cdfs$Id <- as.integer(te$Id.mean)
cdfs <- cdfs[,c(ncol(cdfs), 1:(ncol(cdfs)-1))]
names(cdfs) <- c("Id", paste("Predicted", 0:69, sep=''))
save(cdfs, file=paste(directory, "cdfs_20150509_2.Rda", sep=''))
write.csv(cdfs, file=paste(directory, "cdfs_20150509_2.csv", sep=''), row.names=FALSE)

# original model but without Zdr.range
beg <- Sys.time()
trtemp <- train[,1:7]
tetemp <- test[,1:7]
probsByMM <- sapply(0:69, function(mm) {
	tempExpected <- ifelse(tr$Expected.mean >= (mm - .5) & tr$Expected.mean <= (mm + .5), 1, 0)
	tempFit <- glm(tempExpected ~ ., family = "binomial", data=trtemp)
	predict(tempFit, tetemp, type="response")
})
probsByMM <- cbind(probsByMM, matrix(0, nrow = nrow(tetemp), ncol = 70 - ncol(probsByMM)))
allCumsums <- t(apply(probsByMM, MARGIN=1, cumsum))
cdfs <- as.data.frame(t(apply(allCumsums, MARGIN=1, function(obs) obs/obs[length(obs)])))
cdfs$Id <- as.integer(te$Id.mean)
cdfs <- cdfs[,c(ncol(cdfs), 1:(ncol(cdfs)-1))]
names(cdfs) <- c("Id", paste("Predicted", 0:69, sep=''))
end <- Sys.time()
tot <- end - beg

# original model but without Zdr.range and RhoHV.range
beg <- Sys.time()
removeVars <- c("Zdr.range", "RhoHV.range")
includeVars <- setdiff(names(train)[1:8], removeVars)
trtemp <- train[,includeVars]
tetemp <- test[,includeVars]
cls <- makeCluster(7, type="FORK")
probsByMM <- parSapply(cls, 0:69, function(mm) {
	tempExpected <- ifelse(tr$Expected.mean >= (mm - .5) & tr$Expected.mean <= (mm + .5), 1, 0)
	tempFit <- glm(tempExpected ~ ., family = "binomial", data=trtemp)
	predict(tempFit, tetemp, type="response")
})
allCumsums <- t(apply(probsByMM, MARGIN=1, cumsum))
cdfs <- as.data.frame(t(apply(allCumsums, MARGIN=1, function(obs) obs/obs[length(obs)])))
cdfs$Id <- as.integer(te$Id.mean)
cdfs <- cdfs[,c(ncol(cdfs), 1:(ncol(cdfs)-1))]
names(cdfs) <- c("Id", paste("Predicted", 0:69, sep=''))
end <- Sys.time()
tot <- end - beg

save(cdfs, file=paste(directory, "cdfs_20150511.Rda", sep=''))
write.csv(cdfs, file=paste(directory, "cdfs_20150511.csv", sep=''), row.names=FALSE)