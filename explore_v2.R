# explore data like explore.R
# but dataset is now means and ranges instead of Unlisted

# directory prefix
directory <- "~/Documents/Kaggle/Rain/Rain-Gauge/Data/" # Mac
directory <- "C://Kaggle - other//Rain//Rain-Gauge//Data//" # PC

# load existing data
load(file=paste(directory, "tr.Rda", sep=''))
load(file=paste(directory, "te.Rda", sep=''))
load(file=paste(directory, "train.Rda", sep=''))
load(file=paste(directory, "test.Rda", sep=''))
load(file=paste(directory, "cdfs.Rda", sep=''))
load(file=paste(directory, "largetr.Rda", sep=''))
load(file=paste(directory, "largete.Rda", sep=''))

# temporarily assign largetr/e to tr/e
tr <- largetr
te <- largete

# # # How does explnatory variables interact with other?
cortab <- round(cor(tr, use="complete.obs"), 2)
round(cor(train[, c("ebin", "rr1m", "rr1r", "rm", "rr", "rhvm", "rhvr")], use="complete.obs"),2)

# # # What percentage are NA
NApercent.tr <- apply(tr, MARGIN=2, function(x) {
	length(which(is.na(x)))/nrow(tr)
})
NApercent.te <- apply(tr, MARGIN=2, function(x) {
	length(which(is.na(x)))/nrow(tr)
})
round((NApercent.tr + NApercent.te)/2, 5)

# Create function to estimate % density at 0mm, 1mm, ..., 69mm
# turn expected into binary: 0 for not xmm, 1 for xmm (where x is 0:69)
# run logistic regression and obtain percentages for 1 (xmm)
# after running 70 logistic regressions, you'll have 70 estimates for each observation
# for each observation, cumsum() the estimations and scale to equal 1

# treat > 69.5 as 69s
Expected2 <- ifelse(Expected >= 69, 69, Expected)

beg <- Sys.time()
probsByMM <- as.data.frame(sapply(0:69, function(mm) {
	tempExpected <- ifelse(Expected2 >= (mm - .5) & Expected2 <= (mm + .5), 1, 0)
	tempFit <- glm(tempExpected ~ ., family = "binomial", data = train)
	predict(tempFit, test, type="response")
}))
end <- Sys.time()
tot <- end - beg # 1.2 minutes for 4
# 70/4 * tot # 21.4 estimated minutes, but 1.38 hours because of factor, i forgot

allCumsums <- t(apply(probsByMM, MARGIN=1, cumsum))
scaledCumsums <- t(apply(allCumsums, MARGIN=1, function(obs) obs/obs[length(obs)]))

cdfs$Id <- idTest
cdfs <- cdfs[,c(71,1:70)]
names(cdfs) <- c("Id", paste("Predicted", 0:69, sep=''))

save(probsByMM, file=paste(directory, "probsByMM_20150422.Rda", sep=''))
save(cdfs, file=paste(directory, "cdfs_20150422.Rda", sep=''))

write.csv(cdfs, file=paste(directory, "cdfs.csv", sep=''), row.names=FALSE)


