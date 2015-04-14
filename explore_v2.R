# explore data like explore.R
# but dataset is now means and ranges instead of Unlisted

# directory prefix
directory <- "~/Documents/Kaggle/Rain/Rain-Gauge/Data/" # Mac
directory <- "C://Kaggle - other//Rain//Rain-Gauge//Data//" # PC

# load existing data
load(file=paste(directory, "tr.Rda", sep=''))
load(file=paste(directory, "te.Rda", sep=''))

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
round((NApercent.tr + NApercent.te)/2, 2)

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