# directory prefix
directory <- "~/Documents/Kaggle/Rain/Rain-Gauge/Data/" # Mac
directory <- "C://Kaggle - other//Rain//Rain-Gauge//Data//" # PC

# Load data
load(file=paste(directory, "tr.Rda", sep=''))
load(file=paste(directory, "te.Rda", sep=''))

# Deal with NAs
tr <- apply(tr, MARGIN=2, function(column) {
	ifelse(column==-99900, NA, column)
})
te <- apply(te, MARGIN=2, function(column) {
	ifelse(column==-99900, NA, column)
})
tr <- as.data.frame(tr)
te <- as.data.frame(te)

# Save data
save(tr, file=paste(directory, "tr.Rda", sep=''))
save(te, file=paste(directory, "tr.Rda", sep=''))