# libraries
library(data.table)
trainExpected <- fread("train_2013.csv", select="Expected")

# directory prefix
directory <- "~/Documents/Kaggle/Rain/"

# load data
tr <- fread(paste(directory, "train_2013.csv", sep=''), header = TRUE,
			   colClasses = c("integer", "character", "character", "character", 									"character", "character", "character", "character", 									"character", "character", "character", "character", 	
			   				"character", "character", "character", "character", 
			   				"character", "character", "character", "numeric"),
			   	stringsAsFactors = FALSE, nrow = 1126695)

te <- fread(paste(directory, "test_2014.csv", sep=''), header = TRUE,
			   colClasses = c("integer", "character", "character", "character", 									"character", "character", "character", "character", 									"character", "character", "character", "character", 	
			   				"character", "character", "character", "character", 
			   				"character", "character", "character"),
			   	stringsAsFactors = FALSE, nrow = 630453)
tr <- as.data.frame(tr) # I'm not very familiar with data.table yet
te <- as.data.frame(te)
	   			   				  
save(tr, file=paste(directory, "tr.Rda", sep=''))
save(te, file=paste(directory, "te.Rda", sep=''))
load(file=paste(directory, "tr.Rda", sep=''))
load(file=paste(directory, "te.Rda", sep=''))

# According to competition director, there was a typo in Kdp so that Kdp is always 0
# To calculate Kdp, use the following formula
abs(Kdp) = exp(log(abs(RR3)/40.6)/0.866)*(abs(RR3)/RR3)

TimeToEnd.U <- unlist(strsplit(tr$TimeToEnd, split=' '))
DistanceToRadar.U <- unlist(strsplit(tr$DistanceToRadar, split=' '))

idLengths <- sapply(tr[,2], function(x) { # 2 is arbitrary
	length(unlist(strsplit(x, split=' ')))
}, USE.NAMES = FALSE)
unlistedColNames <- paste(names(tr)[2:19], ".Unlisted", sep='')
id.Unlisted <- rep(tr$Id, idLengths)
Expected.Unlisted <- rep(tr$Expected, idLengths)

# Create jumbo data frame
