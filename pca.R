# principal component analysis
removeVariables <- c("hydroMode", "hm149")
keepVariables <- setdiff(names(train), removeVariables)
trpc <- scale(train[, keepVariables])
tepc <- scale(test[, keepVariables])
pc <- princomp(trpc)
cumpc <- cumsum(pc$sd^2)/sum(pc$sd^2)
pc.tr <- as.data.frame(pc$scores[,1:8])
pc.te <- as.data.frame((tepc %*% pc$loadings))[,1:8]