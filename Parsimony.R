#
# prsm()
#
# arguments:
#	y: the vector of response values in the data
#	x: the matrix of predictor values
#	k: how lenient we are willing to be to sacrifice the preciseness of the model for the parsimony of the model
#	predacc: the prediction accuracy criterion (PAC) function
#	crit: either "max" or "min" depending on whether good values of the PAC are large or small
#	printdel: if TRUE, gives a "progress report" as the computation proceeds. Each time a predictor is deleted, the new value of the PAC is printed out along with the name of the variable
#	cls: cluster object
#
#	function returns the recommended predictor set
#
library('parallel')
library('boot')

prsm <- function(y, x, k=0.01, predacc=ar2, crit=NULL, printdel=FALSE, cls=NULL, cv=FALSE, cvk=10) {
	require(parallel)
	require(boot)
	
	minmax <- NULL
	# Determine whether to minimize of maximize the PAC
	if (identical(ar2, predacc)) {
		crit <- "max"
		minmax <- max
	} else if (identical(aiclogit, predacc)) {
		crit <- "min"
		minmax <- min
	} else {
		if (is.null(crit)) {
			stop("Error: crit is NULL. Do you want to minimize or maximize the PAC?")
		}
                else if (crit == "min"){
                    minmax <- min
                }
                else if (crit == "max"){
                    minmax <- max
                }
	}
	
	# Calculate full model to begin
	full <- predacc(y, x, cv, cvk) # starting PAC
	varsleft <- 1:ncol(x) # variable to keep track of current variables in the model
	if (printdel) cat("full outcome =  ", full)
	
	# Loop: delete variables one at a time, a greedy approach
	tmpbest <- full
	flag <- TRUE
	while(flag) {
		# Calculate PAC for each possible removal
		if (is.null(cls)) {
			tmp <- lapply(1:length(varsleft), function(i) {
				pac <- predacc(y, x[,varsleft[-i]], cv, cvk)
				return(pac)
			})
		} else if (!is.null(cls)) {
			tmp <- clusterApply(cls, 1:length(varsleft), function(i) {
				pac <- predacc(y, x[,varsleft[-i]], cv, cvk)
				return(pac)
			})
		}

		bestpac <- minmax(unlist(tmp))
		
		# Is the ratio "almost" enough (parsimoniously) to justify deleting the variable?
		if (crit == "min") {
			flag <- (bestpac / tmpbest) < 1 + k
		} else if (crit == "max") {
			flag <- (bestpac / tmpbest) > 1 - k
		}
		
		# If flag is still true, remove the variable and update varsleft
		if (flag) {
			var2rem <- which(tmp == bestpac)[1]
			nameOfvar2rem <- colnames(x)[varsleft[var2rem]]
			varsleft <- varsleft[-var2rem]
			if (printdel) cat("\ndeleted  ", nameOfvar2rem, "\nnew outcome =  ", bestpac)	
			tmpbest <- bestpac
		}
		if(length(varsleft) == 1) break
	} # end while()
	
	cat("\n")
	print(varsleft)
	return(varsleft)
}

ar2 <- function(y, x, cv, cvk) {
	require(boot)
	fit <- glm(y ~ ., data = x)
	if (!cv) {
		fitsum <- summary(fit)
		adjr <- fitsum$adj.r.squared
		return(adjr)
	} else if (cv) {
		cvfit <- cv.glm(as.data.frame(cbind(x,y)), fit, K = cvk)
		return(cvfit$delta[2]) # warning: ar2, the higher the better, delta, the lower the better..
	}
}

aiclogit <- function(y, x, cv, cvk) {
	require(boot)
	if (class(x) == "data.frame" || class(x) == "matrix") {
		fit <- glm(y ~ ., data = x, family = "binomial")
	} else {
		fit <- glm(y ~ x, family = "binomial")
	}
	if (!cv) {
		fitsum <- summary(fit)
		aic <- fitsum$aic
		return(aic)
	} else if (cv) {
		cvfit <- cv.glm(as.data.frame(cbind(x,y)), fit, K = cvk)
		return(cvfit$delta[2])
	}
}

# EXAMPLES:

# make cluster
cls <- makeCluster(rep('localhost', 4))

# Using the built-in dataset 'attitude':
## y <- as.matrix(attitude[,1])
## x <- as.matrix(attitude[,2:7])
## prsm(y, x, predacc = ar2, printdel = TRUE)
## prsm(y, x, predacc = ar2, printdel = TRUE, cls = cls)
## system.time(prsm(y, x, predacc = ar2, printdel = TRUE)) # .089 elapsed
## system.time(prsm(y, x, predacc = ar2, printdel = TRUE, cls = cls)) # .072 elapsed

# Using the dataset from UCI Machine Learning Repository
## pima <- read.table("http://archive.ics.uci.edu/ml/machine-learning-databases/pima-indians-diabetes/pima-indians-diabetes.data", header = FALSE, sep = ",")
## names(pima) <- c("NPreg", "Gluc", "BP", "Thick", "Insul", "BMI", "Genet", "Age", "Class")
## system.time(prsm(pima[,9], pima[,1:8], predacc = aiclogit, printdel = TRUE))
## system.time(prsm(pima[,9], pima[,1:8], predacc = aiclogit, printdel = TRUE, cls = cls))

# Make sure Leave.R is in pwd and then uncomment the following line to test the leave1out01() PAC function
## options(digits=5)
## source('Leave.R')
## print("Testing prsm() using pima with leave1out01 as PAC")
## system.time(prsm(pima[,9], pima[,1:8], predacc = leave1out01, crit = "max", printdel = TRUE))
## system.time(prsm(pima[,9], pima[,1:8], predacc = leave1out01, crit = "max", printdel = TRUE, cls=cls))
