library(ipred) # https://cran.r-project.org/web/packages/ipred/ipred.pdf
library(rpart) # https://stat.ethz.ch/R-manual/R-devel/library/rpart/html/rpart.control.html

if (!exists("test") || !exists("train") || !exists("validation")) {
    source("../load.R")
}

print(" --- Bagging ---")

f1 = as.formula(paste("OutcomeType ~", paste(names(train)[-c(1)], collapse="+"), collapse=NULL))


# bagg.model.train : modello calcolato solo sui dati di train per la scelta dei parametri
# bagg.model.comparsion : modello calcolato sui dati di train+test per il confronto con gli altri modelli
# bagg.model.full : modello calcolato su tutto il dataset per la sfida di kaggle

#Già calcolato, commentato per non perderci la vita ad aspettare
print("Provo i vari valori per nbagg...")
nbags = c(10,25,50)
err = rep(0,3)
set.seed(123)
for(k in 1:3){
    cat("Provo nbagg = ", format(nbags[k]),"\n")
    bagg.model.train = bagging(f1, data=train, nbagg=nbags[k], control=rpart.control(minsplit=2, cp=0, xval=0))
    prevs = predict(bagg.model.train, newdata=test) # predizione fatta sui dati di test
    a = misc.table(prevs, test$OutcomeType)
    err[k] = 1-sum(diag(a))/sum(a)
    print(c(err[k], nbags[k]))
}
min.k = which.min(err)
best.nbag = nbag[min.k]
#best.method = "backward" # calcolato precedentemente
cat("Best nbagg: ", format(best.nbag),"\n")

print("Calcolo i modelli finali...")
bagg.model.comparsion = bagging(f1, data=rbind(train,test), nbagg=best.nbag, control=rpart.control(minsplit=2, cp=0, xval=0))
bagg.model.full = bagging(f1, data=dataset, nbagg=best.nbag, control=rpart.control(minsplit=2, cp=0, xval=0))

print("Effettuo le predizioni...")
# Predizione della classe sui valori di validazione per il confronto con gli altri modelli (errore di miscalssificazione)
bagg.predictions.comparsion.class = predict(bagg.model.comparsion, validatioe)
# Predizione delle probabilità per la sfida di kaggle (sul dataset separato)
bagg.predictions.full.probs = predict(bagg.model.full, kaggle.dataset, type="probs")

bagg.misc.table = misc.table(bagg.predictions.comparsion.class, validation$OutcomeType)
bagg.misc.error = 1 - sum(diag(bagg.misc.table))/sum(bagg.misc.table)

print("Salvo le predizioni...")
writePredictions(bagg.predictions.full.probs, kaggle.dataset[,1], "previsioni/bagg.csv")