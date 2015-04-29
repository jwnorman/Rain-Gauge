# evaluation

library(parallel)

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
	mms <- matrix(rep(0:69, nrow(temp)), nrow = nrow(temp), byrow = TRUE)
	if (!cls) {
		mean(sapply(1:nrow(temp), function(row) {
			mean((temp[row, 0:70] - H(mms[row, ] - actual[row]))^2)
		}))
	} else {
		numNodes <- detectCores() - 1
		cls <- makeCluster(numNodes, type="FORK")
		crps <- mean(parSapply(cls, 1:nrow(temp), function(row) {
			mean((temp[row, 0:70] - H(mms[row, ] - actual[row]))^2)
		}))
		stopCluster(cls)
		return(crps)
	}
}

logit70 <- function(trtemp, tetemp, mmmax=69) {
	probsByMM <- sapply(0:mmmax, function(mm) {
		tempExpected <- ifelse(trtemp$Expected >= (mm - .5) & trtemp$Expected <= (mm + .5), 1, 0)
		tempFit <- glm(tempExpected ~ . - Id, family = "binomial", data = trtemp)
		predict(tempFit, tetemp, type="response")
	})
	probsByMM <- cbind(probsByMM, matrix(0, nrow = nrow(tetemp), ncol = 70 - ncol(probsByMM)))
	allCumsums <- t(apply(probsByMM, MARGIN=1, cumsum))
	cdfs <- as.data.frame(t(apply(allCumsums, MARGIN=1, function(obs) obs/obs[length(obs)])))
	cdfs$Id <- as.integer(tetemp$Id)
	cdfs <- cdfs[,c(ncol(cdfs), 1:(ncol(cdfs)-1))]
	names(cdfs) <- c("Id", paste("Predicted", 0:69, sep=''))
	return(cdfs)
}

getCRPS <- function(model = logit70, data = data, dataSize = nrow(size), cvk = 10, mmmax = 69, cls = FALSE) {
	data <- data[sample(x = nrow(data), size = dataSize, replace = FALSE), ]
	nobs <- floor(nrow(data) / cvk)
	dfsplitup <- lapply(1:cvk, function(block) {
		data[sample(x = 1:nrow(data), size = nobs, replace = FALSE), ]
	})
	begin <- Sys.time()
	crpslist <- sapply(1:cvk, function(testnum) {
		trnums <- (1:10)[-testnum]
		trtemp <- do.call(rbind, dfsplitup[trnums])
		tetemp <- dfsplitup[[testnum]]
		predtemp <- model(trtemp, tetemp, mmmax)
		CRPS(predtemp[ , -1], tetemp$Expected, cls = cls)
	})
	end <- Sys.time()
	tot <- end - begin
	list(time = tot, crps = crpslist, crpsavg = mean(crpslist))
}

keepVariables <- c("RR1.mean", "RR1.range", "Reflectivity.mean", "Reflectivity.range", "RhoHV.mean", "RhoHV.range")
data <- train[ , keepVariables]
data$Expected <- tr$Expected.mean
data$Id <- tr$Id.mean
getCRPS(data = data, dataSize = 100, mmmax = 5, cls = TRUE)

# 5.223747 minutes, serial, 6 variables, cvk = 10, mmmax = 69, size of all data used = 10000
# 2.456471 minutes, parall, 6 variables, cvk = 10, mmmax = 69, size of all data used = 10000
# 0.597540 minutes, parall, 6 variables, cvk = 10, mmmax = 10, size of all data used = 10000
# 0.061651 minutes, parall, 6 variables, cvk = 10, mmmax = 5 , size of all data used = 100

