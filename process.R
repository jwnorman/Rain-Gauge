# libraries
library(data.table)
trainExpected <- fread("train_2013.csv", select="Expected")

# directory prefix
directory <- "~/Documents/Kaggle/Rain/Rain-Gauge/Data"
# load data
tr <- fread(paste(directory, "train_2013.csv", sep=''), header = TRUE,
			   colClasses = c("integer", "character", "character", "character", 
			   	"character", "character", "character", "character", 									
			   	"character", "character", "character", "character", 	
			   	"character", "character", "character", "character", 
			   	"character", "character", "character", "numeric"),
			   	stringsAsFactors = FALSE, nrow = 1126695)

te <- fread(paste(directory, "test_2014.csv", sep=''), header = TRUE,
			   colClasses = c("integer", "character", "character", "character", 									
			   	"character", "character", "character", "character", 									
			   	"character", "character", "character", "character", 	
			   	"character", "character", "character", "character", 
			   	"character", "character", "character"),
			   	stringsAsFactors = FALSE, nrow = 630453)
tr <- as.data.frame(tr) # I'm not very familiar with data.table yet
te <- as.data.frame(te)
	   			   				  
save(tr, file=paste(directory, "tr.Rda", sep=''))
save(te, file=paste(directory, "te.Rda", sep=''))
load(file=paste(directory, "tr.Rda", sep=''))
load(file=paste(directory, "te.Rda", sep=''))

# # Create jumbo training and testing dataset, tr.Unlisted and te.Unlisted
# # tr and te have multiple observations per column for only one response
# # i need to unlist them

# Calculate number of multiple observations per column for each row
# This will allow me to create an id unlisted column 
# and a Expected (response var) unlisted column which has the format:
# 1 1 1 1 1 1 1 2 2 2 2 2 3 3 4 4 4 4 4 ... etc
id_Lengths_tr <- sapply(tr[,2], function(x) { # 2 is arbitrary
	length(unlist(strsplit(x, split=' ')))
}, USE.NAMES = FALSE)

id_Lengths_te <- sapply(te[,2], function(x) { # 2 is arbitrary
	length(unlist(strsplit(x, split=' ')))
}, USE.NAMES = FALSE)

# For the new dataset, the names will be the same except with an appended ".Unlisted"
unlistedColNames_tr <- paste(names(tr)[2:19], ".Unlisted", sep='')
unlistedColNames_te <- paste(names(te)[2:18], ".Unlisted", sep='')
id_Unlisted_tr <- rep(tr$Id, id_Lengths_tr)
id_Unlisted_te <- rep(te$Id, id_Lengths_te)
Expected.Unlisted <- rep(tr$Expected, id_Lengths_tr)

# Create jumbo data frame
tr.Unlisted <- data.frame(id_Unlisted_tr, matrix(0, nrow=length(id_Unlisted_tr), ncol=length(unlistedColNames_tr)), Expected.Unlisted)
names(tr.Unlisted)[2:19] <- unlistedColNames_tr
for (i in 2:19) {
	tr.Unlisted[,i] <- unlist(strsplit(tr[,i], split=' '))
}

te.Unlisted <- data.frame(id_Unlisted_te, matrix(0, nrow=length(id_Unlisted_te), ncol=length(unlistedColNames_te)))
names(te.Unlisted)[2:18] <- unlistedColNames_te
for (i in 2:18) {
	te.Unlisted[,i] <- unlist(strsplit(te[,i], split=' '))
}

save(tr.Unlisted, file=paste(directory, "trUnlisted.Rda", sep=''))
save(te.Unlisted, file=paste(directory, "teUnlisted.Rda", sep=''))

# According to competition director, there was a typo in Kdp so that Kdp is always 0
# To calculate Kdp, use the following formula
abs(Kdp) = exp(log(abs(RR3)/40.6)/0.866)*(abs(RR3)/RR3)