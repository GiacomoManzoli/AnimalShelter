library(nnet)
if (!exists("test") || !exists("train") || !exists("validation")) {
    source("../load.R")
}

f1 = as.formula(paste("OutcomeType ~", paste(names(train)[-c(1)], collapse="+"), collapse=NULL))

# nn.model.train : modello calcolato solo sui dati di train per la scelta dei parametri
# nn.model.comparsion : modello calcolato sui dati di train+test per il confronto con gli altri modelli
# nn.model.full : modello calcolato su tutto il dataset per la sfida di kaggle

#nn.model.train = nnet(f1, data=train, MaxNWts = 10000, maxit = 200, trace = FALSE, size = 10)

## Già calcolato, commentato per non perderci la vita ad aspettare
#decay = 10^(seq(-3, -1, length=10))
#err = rep(0,10)
#set.seed(123)
#for(k in 1:10){
#   nn.model.train = nnet(f1, data=train, decay=decay[k], maxit=200, trace=FALSE, MaxNWts = 10000, size = 10)
#   prevs = predict(nn.model.train, newdata=test, type="class") # predizione fatta sui dati di test
#   a = misc.table(prevs, test$OutcomeType)
#   err[k] = 1-sum(diag(a))/sum(a)
#   print(c(err[k], decay[k]))
#}
#min.k = which.min(err)
#best.decay = decay[min.k]
best.decay = 0.001668101 # calcolato precedentemente
cat("Best decay: ", format(best.decay),"\n")

nn.model.comparsion = nnet(f1, data=rbind(train,test), MaxNWts = 10000, maxit = 1000, trace = FALSE, decay = best.decay, size=10)
nn.model.full = nnet(f1, data=dataset, MaxNWts = 10000, maxit = 1000, trace = FALSE, decay = best.decay, size=10)

# Predizione della classe sui valori di validazione per il confronto con gli altri modelli (errore di miscalssificazione)
nn.predictions.comparsion.class = predict(nn.model.comparsion, validation, type="class")
# Predizione delle probabilità per la sfida di kaggle (sul dataset separato)
nn.predictions.full.probs = predict(nn.model.full, kaggle.dataset, type="raw")

nn.misc.table = misc.table(nn.predictions.comparsion.class, validation$OutcomeType)
nn.misc.error = 1 - sum(diag(nn.misc.table))/sum(nn.misc.table)

writePredictions(nn.predictions.full.probs, kaggle.dataset[,1], "previsioni/nn.csv")