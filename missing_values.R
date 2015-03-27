# Load data
load(file=paste(directory, "trUnlisted.Rda", sep=''))
load(file=paste(directory, "teUnlisted.Rda", sep=''))

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
variablesWithMissing.names <- paste(variablesWithMissing, "_NA", sep='')

produceMissingVariable <- function(variable) {
	na.as.factor <- ifelse(as.numeric(variable) == -99900.0, "type1",
					ifelse(as.numeric(variable) == -99901.0, "type2",
					ifelse(as.numeric(variable) == -99903.0, "type3",
					ifelse(variable == "nan",  "type4",
					ifelse(as.numeric(variable) == 999.0,    "type5",
					"type0")))))
	return(as.factor(na.as.factor))
}

replaceWithActualNA <- function(variable) {
	varWithNA <- ifelse(variable %in% c("-99900.0", "-99901.0", "-99903.0", "nan", "999.0"), NA, variable)
	return(varWithNA)
}
