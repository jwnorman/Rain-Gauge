# libraries
library(data.table)

# directory prefix
directory <- "~/Documents/Kaggle/Rain/Rain-Gauge/Data/" # Mac
directory <- "C://Kaggle - other//Rain//Rain-Gauge//Data//" # PC

# import data after summarizing using extract.cpp

tr.header <- read.table(paste(directory, "train_2013.csv", sep=''), sep=',', nrow=1, header=FALSE, stringsAsFactors=FALSE)
te.header <- read.table(paste(directory, "test_2014.csv", sep=''), sep=',', nrow=1, header=FALSE, stringsAsFactors=FALSE)
tr.header <- paste(rep(tr.header, each=2), c(".mean", ".range"), sep='')
te.header <- paste(rep(te.header, each=2), c(".mean", ".range"), sep='')

tr <- fread(paste(directory, "trainSummary.csv", sep=''), 
			sep = ',',
			header = FALSE,
			colClasses = "numeric",
			nrow = 1126694)

te <- fread(paste(directory, "testSummary.csv", sep=''), 
			sep = ',',
			header = FALSE,
			colClasses = "numeric",
			nrow = 630452)
			
tr <- as.data.frame(tr)
te <- as.data.frame(te)
names(tr) <- tr.header
names(te) <- te.header
	   			   				  
# load existing data
load(file=paste(directory, "tr.Rda", sep=''))
load(file=paste(directory, "te.Rda", sep=''))

# According to competition director, there was a typo in Kdp so that Kdp is always 0
# To calculate Kdp, use the following formula
# Run these after you take care of NAs
tr$Kdp.mean <- exp(log(abs(tr$RR3.mean)/40.6)/0.866)*sign(tr$RR3.mean)
te$Kdp.mean <- exp(log(abs(te$RR3.mean)/40.6)/0.866)*sign(te$RR3.mean)
tr$Kdp.range <- exp(log(abs(tr$RR3.range)/40.6)/0.866)*sign(tr$RR3.range)
te$Kdp.range <- exp(log(abs(te$RR3.range)/40.6)/0.866)*sign(te$RR3.range)

save(tr, file=paste(directory, "tr.Rda", sep=''))
save(te, file=paste(directory, "te.Rda", sep=''))