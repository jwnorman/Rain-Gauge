# evaluation
rownum <- 102039
CRPS <- function(cdfmat, actualGaugeValues) {
	mean(
		sapply(nrow(cdfmat), 
			function(rownum) { # for every row
				(cdfmat[rownum,] - H( (0:69) - actualGaugeValues[rownum] ))^2
			}
		)
	)
}
CRPS(cdfmat, actualGaugeValues)
cdfmat <- matrix(1, nrow = 8937958, ncol = 70)
actualGaugeValues <- tr.Unlisted$Expected

H <- function(x) {
	ifelse(x < 0, 0, 1)
}

isNonDecreasing <- function(cdf) {
	return(all(diff(cdf) >= 0))
}

submissionNames <- c("Id", paste("Predicted", 0:69, sep=''))












