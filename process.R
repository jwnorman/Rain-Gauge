# libraries
library(data.table)

# directory prefix
directory <- "~/Documents/Kaggle/Rain/Rain-Gauge/Data/" # Mac
directory <- "C://Kaggle - other//Rain//Rain-Gauge//Data//" # PC

# load existing data
load(file=paste(directory, "tr.Rda", sep=''))
load(file=paste(directory, "te.Rda", sep=''))

# save existing data
save(tr, file=paste(directory, "tr.Rda", sep=''))
save(te, file=paste(directory, "te.Rda", sep=''))
save(meanDiffTrain, file=paste(directory, "meanDiffTrain.Rda", sep=''))
save(meanDiffTest, file=paste(directory, "meanDiffTest.Rda", sep=''))
save(largetr, file=paste(directory, "largetr.Rda", sep=''))
save(largete, file=paste(directory, "largete.Rda", sep=''))

# import data after summarizing using extract.cpp
trainFileName <- "meanDiffTrain.csv"
testFileName <- "meanDiffTest.csv"
headerExtension <- ".diffMean"

tr.header <- read.table(paste(directory, "train_2013.csv", sep=''), sep=',', nrow=1, header=FALSE, stringsAsFactors=FALSE)
te.header <- read.table(paste(directory, "test_2014.csv", sep=''), sep=',', nrow=1, header=FALSE, stringsAsFactors=FALSE)
tr.header <- paste(rep(tr.header, each=1), headerExtension, sep='')
te.header <- paste(rep(te.header, each=1), headerExtension, sep='')
			
extractedTrain <- fread(paste(directory, trainFileName, sep=''), 
			sep = ',',
			header = FALSE,
			colClasses = "numeric",
			nrows = 1126694)

extractedTest <- fread(paste(directory, testFileName, sep=''), 
			sep = ',',
			header = FALSE,
			colClasses = "numeric",
			nrow = 630452)
			
extractedTrain <- as.data.frame(extractedTrain)
extractedTest <- as.data.frame(extractedTest)
names(extractedTrain) <- tr.header
names(extractedTest) <- te.header

# Assign newly extracted data to savable variable
meanDiffTrain <- extractedTrain
meanDiffTest <- extractedTest

# Get rid of useless variables and rename poorly named variables

# grab ids and target
idTrain <- tr$Id.mean
idTest <- te$Id.mean
Expected <- tr$Expected.mean

# mean diff df
variablesToEliminate <- c("Id.diffMean", "HydrometeorType.diffMean", "Expected.diffMean")
variablesToKeepTrain <- setdiff(names(meanDiffTrain), variablesToEliminate)
variablesToKeepTest <- setdiff(names(meanDiffTest), variablesToEliminate)
meanDiffTrainFiltered <- meanDiffTrain[ , variablesToKeepTrain]
meanDiffTestFiltered  <- meanDiffTest[  , variablesToKeepTest]

# mean & range df
variablesToEliminate <- c("Id.mean", "Id.range", "HydrometeorType.mean", "HydrometeorType.range", "Expected.mean", "Expected.range")
variablesToKeepTrain <- setdiff(names(tr), variablesToEliminate)
variablesToKeepTest <- setdiff(names(te), variablesToEliminate)
meanRangeTrainFiltered <- tr[ , variablesToKeepTrain]
meanRangeTestFiltered <-  te[ , variablesToKeepTest]

# combine all variables into one df
largetr <- as.data.frame(cbind(meanRangeTrainFiltered, meanDiffTrainFiltered))
largete <- as.data.frame(cbind(meanRangeTestFiltered, meanDiffTestFiltered))
   				  
# According to competition director, there was a typo in Kdp so that Kdp is always 0
# To calculate Kdp, use the following formula
# Run these after you take care of NAs
tr$Kdp.mean <- exp(log(abs(tr$RR3.mean)/40.6)/0.866)*sign(tr$RR3.mean)
te$Kdp.mean <- exp(log(abs(te$RR3.mean)/40.6)/0.866)*sign(te$RR3.mean)
tr$Kdp.range <- exp(log(abs(tr$RR3.range)/40.6)/0.866)*sign(tr$RR3.range)
te$Kdp.range <- exp(log(abs(te$RR3.range)/40.6)/0.866)*sign(te$RR3.range)