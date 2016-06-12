library(earth) # https://cran.r-project.org/web/packages/earth/earth.pdf
if (!exists("test") || !exists("train") || !exists("validation")) {
    source("../load.R")
}
# https://cran.r-project.org/web/packages/ada/ada.pdf
f1 = as.formula(paste("OutcomeType ~", paste(names(train)[-c(1)], collapse="+"), collapse=NULL))


# mmars.model.train : modello calcolato solo sui dati di train per la scelta dei parametri
# mmars.model.comparsion : modello calcolato sui dati di train+test per il confronto con gli altri modelli
# mmars.model.full : modello calcolato su tutto il dataset per la sfida di kaggle

# mmars.model.train = earth(f1, data=train)

#Già calcolato, commentato per non perderci la vita ad aspettare
#types = c("backward", "cv")
#err = rep(0,2)
#set.seed(123)
#for(k in 1:2){
#   mmars.model.train = earth(f1, data=train, pmethod=types[k], nfold=5)
#   prevs = predict(mmars.model.train, newdata=test, type="class") # predizione fatta sui dati di test
#   a = misc.table(prevs, test$OutcomeType)
#   err[k] = 1-sum(diag(a))/sum(a)
#   print(c(err[k], types[k]))
#}
#min.k = which.min(err)
#best.method = types[min.k]
best.method = "backward" # calcolato precedentemente
cat("Best type: ", format(best.method),"\n")

mmars.model.comparsion = earth(f1, data=rbind(train,test), pmethod=best.method)
mmars.model.full = earth(f1, data=dataset, pmethod=best.method)

# Predizione della classe sui valori di validazione per il confronto con gli altri modelli (errore di miscalssificazione)
mmars.predictions.comparsion.class = predict(mmars.model.comparsion, validation, type="class")
# Predizione delle probabilità per la sfida di kaggle (sul dataset separato)
mmars.predictions.full.probs = predict(mmars.model.full, kaggle.dataset, type="response")

mmars.misc.table = misc.table(mmars.predictions.comparsion.class, validation$OutcomeType)
mmars.misc.error = 1 - sum(diag(mmars.misc.table))/sum(mmars.misc.table)

writePredictions(mmars.predictions.full.probs, kaggle.dataset[,1], "previsioni/mmars.csv")