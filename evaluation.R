# evaluation

library(parallel)

model <- logit70 # model returns in submittable format
keepVariables <- c("RR1.mean", "RR1.range", "Reflectivity.mean", "Reflectivity.range", "RhoHV.mean", "RhoHV.range")
data <- train[ , keepVariables]
data$Expected <- tr$Expected.mean
data$Id <- tr$Id.mean
data <- data[sample(x = nrow(data), size = 10000, replace = FALSE), ]
cvk <- 10
nobs <- floor(nrow(data) / cvk)
mmmax <- 69
dfsplitup <- lapply(1:cvk, function(block) {
	data[sample(x = 1:nrow(data), size = nobs, replace = FALSE), ]
})
begin <- Sys.time()
crpslist <- sapply(1:cvk, function(testnum) {
	trnums <- (1:10)[-testnum]
	trtemp <- do.call(rbind, dfsplitup[trnums])
	tetemp <- dfsplitup[[testnum]]
	predtemp <- model(trtemp, tetemp, mmmax)
	CRPS(predtemp[ , -1], tetemp$Expected, cls=TRUE)
})
end <- Sys.time()
tot <- end - begin

H <- function(x) {
	ifelse(x < 0, 0, 1)
}

isNonDecreasing <- function(cdfs) {
	cdfs <- as.matrix(cdfs)
	all(apply(cdfs, MARGIN = 1, function(row) {
		all(diff(row) >= 0)
	}))
}

CRPS <- function(cdfmat, actual, cls = FALSE) {
	if (!isNonDecreasing(cdfmat)) {
		stop("cdf isn't nondecreasing")
	}
	temp <- data.frame(cdfmat=cdfmat, actual=actual)
	mms <- matrix(rep(0:69, 1000), nrow = 1000, byrow = TRUE)
	if (!cls) {
		# sum(sapply(1:nrow(temp), function(row) {
			# sum(sapply(1:70, function(col) {
				# (temp[row, col] - H(col - mms[col]))^2
			# }))
		# })) / (70*nrow(temp))
		mean(sapply(1:nrow(temp), function(row) {
			mean((temp[row, 0:70] - H(mms[row, ] - actual[row]))^2)
		}))
	} else {
		numNodes <- detectCores() - 1
		cls <- makeCluster(numNodes, type="FORK")
		mean(parSapply(cls, 1:nrow(temp), function(row) {
			mean((temp[row, 0:70] - H(mms[row, ] - actual[row]))^2)
		}))
	}
}