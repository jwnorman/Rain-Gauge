# evaluation

H <- function(x) {
	ifelse(x < 0, 0, 1)
}

isNonDecreasing <- function(cdf) {
	return(all(diff(cdf) >= 0))
}

submissionNames <- c("Id", paste("Predicted", 0:69, sep=''))

CRPS <- function(cdfmat, actual) {
	temp <- data.frame(cdfmat=cdfmat, actual=actual)
	if (!isNonDecreasing(cdfmat)) {
		stop("cdf isn't nondecreasing")
	}
	mean(apply(temp, MARGIN=1, function(temprow) {
		mean((as.integer(temprow[1:70]) - H((0:69) - as.integer(temprow[71])))^2)
	})	)
}

cdfmat <- matrix(1, nrow = 8937958, ncol = 70)
actual <- tr.Unlisted$Expected
cdfmattest <- head(cdfmat, 1200)
actualtest <- head(actual, 1200)
CRPS(cdfmat, actual)


