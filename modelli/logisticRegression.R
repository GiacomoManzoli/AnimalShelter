library(nnet)
if (!exists("test") || !exists("train") || !exists("validation")) {
    source("../load.R")
}

f1 = as.formula(paste("OutcomeType ~", paste(names(train)[-c(1)], collapse="+"), collapse=NULL))

# Utilizzare mlogit da qualche problema
# GLM funziona solo per i binomiale.
# multinom di nnet simula una regressione logistica per le varie classi

# logit.model.train : modello calcolato solo sui dati di train per la scelta dei parametri
# logit.model.comparsion : modello calcolato sui dati di train+test per il confronto con gli altri modelli
# logit.model.full : modello calcolato su tutto il dataset per la sfida di kaggle

#logit.model.train = multinom(f1, data=train, MaxNWts = 10000, maxit = 200, trace = FALSE)

## Già calcolato, commentato per non perderci la vita ad aspettare
##decay = 10^(seq(-3, -1, length=10))
##err = rep(0,10)
##set.seed(123)
##for(k in 1:10){
##   logit.model.train = multinom(f1, data=train, decay=decay[k], maxit=200, trace=FALSE, MaxNWts = 10000)
##   prevs = predict(logit.model.train, newdata=test, type="class") # predizione fatta sui dati di test
##   a = misc.table(prevs, test$OutcomeType)
##   err[k] = 1-sum(diag(a))/sum(a)
##   print(c(err[k], decay[k]))
##}
##min.k = which.min(err)
#best.decay = decay[min.k]
best.decay = 0.001 # calcolato precedentemente
cat("Best decay: ", format(best.decay),"\n")

logit.model.comparsion = multinom(f1, data=rbind(train,test), MaxNWts = 10000, maxit = 200, trace = FALSE, decay = best.decay)
logit.model.full = multinom(f1, data=dataset, MaxNWts = 10000, maxit = 200, trace = FALSE, decay = best.decay)

# Predizione della classe sui valori di validazione per il confronto con gli altri modelli (errore di miscalssificazione)
logit.predictions.comparsion.class = predict(logit.model.comparsion, validation, type="class")
# Predizione delle probabilità per la sfida di kaggle (sul dataset separato)
logit.predictions.full.probs = predict(logit.model.full, kaggle.dataset, type="probs")

logit.misc.table = misc.table(logit.predictions.comparsion.class, validation$OutcomeType)
logit.misc.error = 1 - sum(diag(logit.misc.table))/sum(logit.misc.table)

writePredictions(logit.predictions.full.probs, kaggle.dataset[,1], "previsioni/logit.csv")