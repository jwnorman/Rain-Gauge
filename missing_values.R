# libraries
library(data.table)
trainExpected <- fread("train_2013.csv", select="Expected") #example of select

# directory prefix
directory <- "~/Documents/Kaggle/Rain/Rain-Gauge/Data/"

# Load data
load(file=paste(directory, "trUnlisted.Rda", sep=''))
load(file=paste(directory, "teUnlisted.Rda", sep=''))
load(file=paste(directory, "trMissing.Rda", sep=''))
load(file=paste(directory, "teMissing.Rda", sep=''))

# # Deal with NA's
# # From the Kaggle data page, there are mentions of
# # five different types of missing values
# # -99900, -99901, -99903, nan, 999

# create column with factors of different types of missing
# for example, HybridScan will be used to create come HybridScan.missing
# not na: type0
# -99900: type1
# -99901: type2
# -99903: type3
# nan	: type4
# 999	: type5

variablesWithMissing <- apply(tr.Unlisted, MARGIN=2, function(x) {
	any(x %in% c("-99900.0", "-99901.0", "-99903.0", "nan", "999.0"))
})
variablesWithMissing <- names(variablesWithMissing[variablesWithMissing])

# make sure there aren't any differences with the testing dataset
# only difference: no missing in te.Unlisted$Reflectivity; nothing to worry about
variablesWithMissing.te <- apply(te.Unlisted, MARGIN=2, function(x) {
	any(x %in% c("-99900.0", "-99901.0", "-99903.0", "nan", "999.0"))
})
variablesWithMissing.te <- names(variablesWithMissing.te[variablesWithMissing.te])
setdiff(variablesWithMissing, variablesWithMissing.te)

variablesWithMissing.names <- paste(variablesWithMissing, "_NA", sep='')

# Function to produce new variables of the same length
# but instead of -99900.0 2.410 -99903.0 nan nan nan, it will
# return type1 type0 type3 type4 type4 type4 as factors
produceMissingVariable <- function(variable) {
	na.as.factor <- ifelse(as.numeric(variable) == -99900.0, "type1",
					ifelse(as.numeric(variable) == -99901.0, "type2",
					ifelse(as.numeric(variable) == -99903.0, "type3",
					ifelse(as.numeric(variable) == 999.0,    "type5",
					"type0"))))
	na.as.factor <- ifelse(is.na(na.as.factor), "type4", na.as.factor)
	return(as.factor(na.as.factor))
}

# Create empty data frame to store missing factors
# tr.Missing
tr.Missing <- data.frame(matrix(0, nrow=nrow(tr.Unlisted), ncol=length(variablesWithMissing.names)))
names(tr.Missing) <- variablesWithMissing.names

# test <- data.frame(matrix(0, nrow=500, ncol=length(variablesWithMissing.names)))
for (i in 1:ncol(tr.Missing)) {
	#test[,i] <- produceMissingVariable(
	#					head(tr.Unlisted[,variablesWithMissing[i]], 500)
	#				  )
	tr.Missing[,i] <- produceMissingVariable(
						tr.Unlisted[,variablesWithMissing[i]]
					  )
}

# te.Missing
te.Missing <- data.frame(matrix(0, nrow=nrow(te.Unlisted), ncol=length(variablesWithMissing.names)))
names(te.Missing) <- variablesWithMissing.names
test <- data.frame(matrix(0, nrow=500, ncol=length(variablesWithMissing.names)))
for (i in 1:ncol(te.Missing)) {
	#test[,i] <- produceMissingVariable(
	#					head(te.Unlisted[,variablesWithMissing[i]], 500)
	#				  )
	te.Missing[,i] <- produceMissingVariable(
						te.Unlisted[,variablesWithMissing[i]]
					  )
}

save(tr.Missing, file=paste(directory, "trMissing.Rda", sep=''))
save(te.Missing, file=paste(directory, "teMissing.Rda", sep=''))

# Replace the values of -99900.0, -99901.0, etc. with NA since the other values are already accounted for in *.Missing
# Also, I'll need to be able to use arithmetic with the columns and I can't have these -99900's throwing it off.

replaceWithActualNA <- function(variable) {
	varWithNA <- ifelse(variable %in% c("-99900.0", "-99901.0", "-99903.0", "nan", "999.0"), NA, variable)
	return(varWithNA)
}

for (i in 1:length(variablesWithMissing)) {
	tr.Unlisted[,variablesWithMissing[i]] <- replaceWithActualNA(tr.Unlisted[,variablesWithMissing[i]])
}

for (i in 1:length(variablesWithMissing)) {
	te.Unlisted[,variablesWithMissing[i]] <- replaceWithActualNA(te.Unlisted[,variablesWithMissing[i]])
}

save(tr.Unlisted, file=paste(directory, "trUnlisted.Rda", sep=''))
save(te.Unlisted, file=paste(directory, "teUnlisted.Rda", sep=''))


