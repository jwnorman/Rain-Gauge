# directory prefix
directory <- "~/Documents/Kaggle/Rain/Rain-Gauge/Data/" # Mac
directory <- "C://Kaggle - other//Rain//Rain-Gauge//Data//" # PC

# Load data
load(file=paste(directory, "tr.Rda", sep=''))
load(file=paste(directory, "te.Rda", sep=''))
load(file=paste(directory, "largetr.Rda", sep=''))
load(file=paste(directory, "largete.Rda", sep=''))

# Deal with NAs
largetr <- apply(largetr, MARGIN=2, function(column) {
	ifelse(column==-99999, NA, column)
})
largete <- apply(largete, MARGIN=2, function(column) {
	ifelse(column==-99999, NA, column)
})
largetr <- as.data.frame(largetr)
largete <- as.data.frame(largete)

# Save data
save(tr, file=paste(directory, "tr.Rda", sep=''))
save(te, file=paste(directory, "tr.Rda", sep=''))
save(largetr, file=paste(directory, "largetr.Rda", sep=''))
save(largete, file=paste(directory, "largete.Rda", sep=''))