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
		tempFit <- glm(tempExpected ~ . - Id - Expected, family = "binomial", data = trtemp)
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

getCRPS <- function(model = logit70, data = data, dataSize = nrow(data), cvk = 10, mmmax = 69, cls = FALSE) {
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
	list(varnames = names(data), time = tot, crps = crpslist, crpsavg = mean(crpslist))
}

keepVariables <- c("RR1.mean", "RR1.range", "Reflectivity.mean", "Reflectivity.range", "RhoHV.mean", "RhoHV.range")
keepVariables <- c("RR1.range", "RR1.range")
data <- train[ , keepVariables]
data$Expected <- tr$Expected.mean
data$Id <- tr$Id.mean
data <- data[,-1]
getCRPS(data = data, dataSize = 50000, mmmax = 12, cls = TRUE)

# 5.223747 minutes, serial, 6 variables, cvk = 10, mmmax = 69, size of all data used = 10000
# 2.456471 minutes, parall, 6 variables, cvk = 10, mmmax = 69, size of all data used = 10000
# 0.597540 minutes, parall, 6 variables, cvk = 10, mmmax = 10, size of all data used = 10000
# 0.061651 minutes, parall, 6 variables, cvk = 10, mmmax = 5 , size of all data used = 100
# 2.878385 minutes, parall, 6 variables, cvk = 10, mmmax = 12, size of all data used = 50000, .007379382
# 33.47914 minutes, parall, 6 variables, cvk = 10, mmmax = 12, size of all data used = 500000, .007568024
# 2.410278 minutes, parall, RR1.mean   , cvk = 10, mmmax = 12, size of all data used = 50000, .0079908

holder <- list()
listofvarnames <- names(train)[-length(names(train))]
counter = 1
for (varname in listofvarnames) {
	keepVariables <- c("hydroMode", varname)
	data <- train[ , keepVariables]
	data$Expected <- tr$Expected.mean
	data$Id <- tr$Id.mean
	data <- data[,-1]
	holder[[counter]] <- getCRPS(data = data, dataSize = 50000, mmmax = 12, cls = TRUE)
	counter = counter + 1
}

save(holder, file = paste(directory, "holder1.Rda", sep=''))

holder2 <- list()
removeVars <- c("Reflectivity.mean", "hydroMode")
keepVars <- setdiff(names(train), removeVars)
listofvarnames <- keepVars
counter = 1
for (varname in listofvarnames) {
	keepVariables <- c("Reflectivity.mean", varname)
	data <- train[ , keepVariables]
	data$Expected <- tr$Expected.mean
	data$Id <- tr$Id.mean
	holder2[[counter]] <- getCRPS(data = data, dataSize = 50000, mmmax = 12, cls = TRUE)
	counter = counter + 1
}

save(holder2, file = paste(directory, "holder2.Rda", sep=''))

before = Sys.time()
holder3 <- list()
listofvarnames <- names(train)[-length(names(train))]
counter = 1
for (varname in listofvarnames) {
	keepVariables <- c("hydroMode", varname)
	data <- train[ , keepVariables]
	data$Expected <- tr$Expected.mean
	data$Id <- tr$Id.mean
	data <- data[,-1]
	holder3[[counter]] <- getCRPS(data = data, dataSize = 50000, mmmax = 12, cls = TRUE)
	counter = counter + 1
	
	## repeat with squared term
	data <- train[ , keepVariables]
	data[,2] <- data[,2]^2
	data$Expected <- tr$Expected.mean
	data$Id <- tr$Id.mean
	data <- data[,-1]
	holder3[[counter]] <- getCRPS(data = data, dataSize = 50000, mmmax = 12, cls = TRUE)
	counter = counter + 1
}
after = Sys.time()
total = after - before
total

save(holder3, file = paste(directory, "holder3.Rda", sep=''))

# Start with original model, and use getCrps() + backwards stepwise procedure
before = Sys.time()
holder4 <- list()
all <- names(train)[1:8]
counter = 1
for (varnum in 0:length(all)) {
	if (varnum == 0) {
		data <- train[ , all]
	} else {
		data <- train[ , all[-varnum]]
	}
	data$Expected <- tr$Expected.mean
	data$Id <- tr$Id.mean
	holder4[[counter]] <- getCRPS(data = data, dataSize = 50000, mmmax = 69, cls = TRUE)
	cat("Leaving out: ", all[varnum], " \n")
	cat("All: ", holder4[[counter]]$crps, "\n")
	cat("Average: ", holder4[[counter]]$crpsavg, " \n\n")
	counter = counter + 1
}
after = Sys.time()
total = after - before
total

save(holder4, file = paste(directory, "holder4.Rda", sep=''))
## Leaving Zdr.mean and Zdr.range yield better results!

# Step 2 of backwards stepwise, original model - Zdr.range
before = Sys.time()
holder5 <- list()
all <- names(train)[1:7] # remove Zdr.range (it just happens to be last)
counter = 1
for (varnum in 0:length(all)) {
	if (varnum == 0) {
		data <- train[ , all]
	} else {
		data <- train[ , all[-varnum]]
	}
	data$Expected <- tr$Expected.mean
	data$Id <- tr$Id.mean
	holder5[[counter]] <- getCRPS(data = data, dataSize = 1126694, mmmax = 69, cls = TRUE)
	cat("Leaving out: ", all[varnum], " \n")
	cat("All: ", holder5[[counter]]$crps, "\n")
	cat("Average: ", holder5[[counter]]$crpsavg, " \n\n")
	counter = counter + 1
}
after = Sys.time()
total = after - before
total

save(holder5, file = paste(directory, "holder5.Rda", sep=''))

# Step 3 of backwards stepwise, original model - Zdr.range - Reflectivity.range
before = Sys.time()
holder6 <- list()
removeVars <- c("Zdr.range", "Reflectivity.range")
includeVars <- setdiff(names(train)[1:8], removeVars)
counter = 1
for (varnum in 0:length(includeVars)) {
	if (varnum == 0) {
		data <- train[ , includeVars]
	} else {
		data <- train[ , includeVars[-varnum]]
	}
	data$Expected <- tr$Expected.mean
	data$Id <- tr$Id.mean
	holder6[[counter]] <- getCRPS(data = data, dataSize = 50000, mmmax = 69, cls = TRUE)
	cat("Leaving out: ", all[varnum], " \n")
	cat("All: ", holder6[[counter]]$crps, "\n")
	cat("Average: ", holder6[[counter]]$crpsavg, " \n\n")
	counter = counter + 1
}
after = Sys.time()
total = after - before
total

save(holder6, file = paste(directory, "holder6.Rda", sep=''))

# Step 3 v2 of backwards stepwise, original model - Zdr.range - RhoHV.mean
before = Sys.time()
holder7 <- list()
removeVars <- c("Zdr.range", "RhoHV.mean")
includeVars <- setdiff(names(train)[1:8], removeVars)
counter = 1
for (varnum in 0:length(includeVars)) {
	if (varnum == 0) {
		data <- train[ , includeVars]
	} else {
		data <- train[ , includeVars[-varnum]]
	}
	data$Expected <- tr$Expected.mean
	data$Id <- tr$Id.mean
	holder7[[counter]] <- getCRPS(data = data, dataSize = 50000, mmmax = 20, cls = TRUE)
	cat("Leaving out: ", all[varnum], " \n")
	cat("All: ", holder7[[counter]]$crps, "\n")
	cat("Average: ", holder7[[counter]]$crpsavg, " \n\n")
	counter = counter + 1
}
after = Sys.time()
total = after - before
total

save(holder7, file = paste(directory, "holder7.Rda", sep=''))

load(file = paste(directory, "holder1.Rda", sep=''))
load(file = paste(directory, "holder2.Rda", sep=''))
sort(unlist(lapply(holder, function(x) x$crpsavg)))
sort(unlist(lapply(holder2, function(x) x$crpsavg)))