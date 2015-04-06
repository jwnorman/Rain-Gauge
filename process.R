# libraries
library(data.table)
library(plyr)

# directory prefix
directory <- "~/Documents/Kaggle/Rain/Rain-Gauge/Data/" # Mac
directory <- "C://Kaggle - other//Rain//Rain-Gauge//Data//" # PC

# import data
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
tr <- as.data.frame(tr)
te <- as.data.frame(te)
	   			   				  
# load existing data
load(file=paste(directory, "trUnlisted.Rda", sep=''))
load(file=paste(directory, "teUnlisted.Rda", sep=''))
load(file=paste(directory, "trMissing.Rda", sep=''))
load(file=paste(directory, "teMissing.Rda", sep=''))
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

id_tr <- rep(tr$Id, id_Lengths_tr)
id_te <- rep(te$Id, id_Lengths_te)
Expected <- rep(tr$Expected, id_Lengths_tr)

# Create jumbo data frame
tr.Unlisted <- data.frame(id_tr, matrix(0, nrow=length(id_tr), ncol=length(tr)-2), Expected)
for (i in 2:19) {
	tr.Unlisted[,i] <- unlist(strsplit(tr[,i], split=' '))
}
names(tr.Unlisted) <- names(tr)

te.Unlisted <- data.frame(id_te, matrix(0, nrow=length(id_te), ncol=length(te)-1))
for (i in 2:19) {
	te.Unlisted[,i] <- unlist(strsplit(te[,i], split=' '))
}
names(te.Unlisted) <- names(te)

## Correct the classes of all the variables in tr.Unlisted and te.Unlisted
## Probably should've dealt with this when first making *.Unlisted
tr.Unlisted.backup <- tr.Unlisted
te.Unlisted.backup <- te.Unlisted
tr.Unlisted$TimeToEnd <- as.integer(tr.Unlisted$TimeToEnd)
tr.Unlisted$DistanceToRadar <- as.integer(tr.Unlisted$DistanceToRadar)
tr.Unlisted$Composite <- as.numeric(tr.Unlisted$Composite)
tr.Unlisted$HybridScan <- as.numeric(tr.Unlisted$HybridScan)
tr.Unlisted$HydrometeorType <- as.factor(tr.Unlisted$HydrometeorType)
tr.Unlisted$Kdp <- as.numeric(tr.Unlisted$Kdp)
tr.Unlisted$RR1 <- as.numeric(tr.Unlisted$RR1)
tr.Unlisted$RR2 <- as.numeric(tr.Unlisted$RR2)
tr.Unlisted$RR3 <- as.numeric(tr.Unlisted$RR3)
tr.Unlisted$RadarQualityIndex <- as.numeric(tr.Unlisted$RadarQualityIndex)
tr.Unlisted$Reflectivity <- as.numeric(tr.Unlisted$Reflectivity)
tr.Unlisted$ReflectivityQC <- as.numeric(tr.Unlisted$ReflectivityQC)
tr.Unlisted$RhoHV <- as.numeric(tr.Unlisted$RhoHV)
tr.Unlisted$Velocity <- as.numeric(tr.Unlisted$Velocity)
tr.Unlisted$Zdr <- as.numeric(tr.Unlisted$Zdr)
tr.Unlisted$LogWaterVolume <- as.numeric(tr.Unlisted$LogWaterVolume)
tr.Unlisted$MassWeightedMean <- as.numeric(tr.Unlisted$MassWeightedMean)
tr.Unlisted$MassWeightedSD <- as.numeric(tr.Unlisted$MassWeightedSD)

te.Unlisted$TimeToEnd <- as.integer(te.Unlisted$TimeToEnd)
te.Unlisted$DistanceToRadar <- as.integer(te.Unlisted$DistanceToRadar)
te.Unlisted$Composite <- as.numeric(te.Unlisted$Composite)
te.Unlisted$HybridScan <- as.numeric(te.Unlisted$HybridScan)
te.Unlisted$HydrometeorType <- as.factor(te.Unlisted$HydrometeorType)
te.Unlisted$Kdp <- as.numeric(te.Unlisted$Kdp)
te.Unlisted$RR1 <- as.numeric(te.Unlisted$RR1)
te.Unlisted$RR2 <- as.numeric(te.Unlisted$RR2)
te.Unlisted$RR3 <- as.numeric(te.Unlisted$RR3)
te.Unlisted$RadarQualityIndex <- as.numeric(te.Unlisted$RadarQualityIndex)
te.Unlisted$Reflectivity <- as.numeric(te.Unlisted$Reflectivity)
te.Unlisted$ReflectivityQC <- as.numeric(te.Unlisted$ReflectivityQC)
te.Unlisted$RhoHV <- as.numeric(te.Unlisted$RhoHV)
te.Unlisted$Velocity <- as.numeric(te.Unlisted$Velocity)
te.Unlisted$Zdr <- as.numeric(te.Unlisted$Zdr)
te.Unlisted$LogWaterVolume <- as.numeric(te.Unlisted$LogWaterVolume)
te.Unlisted$MassWeightedMean <- as.numeric(te.Unlisted$MassWeightedMean)
te.Unlisted$MassWeightedSD <- as.numeric(te.Unlisted$MassWeightedSD)

# According to competition director, there was a typo in Kdp so that Kdp is always 0
# To calculate Kdp, use the following formula
tr.Unlisted$Kdp <- exp(log(abs(tr.Unlisted$RR3)/40.6)/0.866)*sign(tr.Unlisted$RR3)
te.Unlisted$Kdp <- exp(log(abs(te.Unlisted$RR3)/40.6)/0.866)*sign(te.Unlisted$RR3)

# Create variable to mark the beginning of each new Id
# Then you can create smaller dataset for variables like DistanceToRadar which are the same for each Id
# build off of tr and te the summary variables like RR1.mean, RR1.range, etc.
tr.Unlisted$IdFirst <- c(1, diff(tr.Unlisted$Id))
te.Unlisted$IdFirst <- c(1, diff(te.Unlisted$Id))
tr <- tr.Unlisted[tr.Unlisted$IdFirst>0, c("Id", "DistanceToRadar", "Expected")]
te <- te.Unlisted[te.Unlisted$IdFirst>0, c("Id", "DistanceToRadar")]

# Add to tr and te feature extractions from different variables per Id like RR1.mean, RR1.median, etc.
# see dlply()
tr$numMeasurements <- table(tr.Unlisted$Id)
te$numMeasurements <- table(te.Unlisted$Id)
numHours <- dlply(.data=tr.Unlisted, .variables="Id", .fun=function(x) {
	length(which(diff(x) >= 0)) + 1
}, .parallel=TRUE)
# test <- sapply(tr.Unlisted$Id, function(x) {
#	length(which(diff(x) >= 0)) + 1
# })
RR1.mean <- tapply(tr.Unlisted$RR1, tr.Unlisted$Id, mean, na.rm = TRUE)

# Save
save(tr.Unlisted, file=paste(directory, "trUnlisted.Rda", sep=''))
save(te.Unlisted, file=paste(directory, "teUnlisted.Rda", sep=''))
save(tr, file=paste(directory, "tr.Rda", sep=''))
save(te, file=paste(directory, "te.Rda", sep=''))