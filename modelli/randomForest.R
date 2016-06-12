library(randomForest)
if (!exists("test") || !exists("train") || !exists("validation")) {
    source("../load.R")
}

trainAlt = train[,-which(names(train) %in% c("PrimaryBreed", "SecondaryBreed"))]
testAlt = test[,-which(names(test) %in% c("PrimaryBreed", "SecondaryBreed"))]
validationAlt = validation[,-which(names(validation) %in% c("PrimaryBreed", "SecondaryBreed"))]
datasetAlt = dataset[,-which(names(dataset) %in% c("PrimaryBreed", "SecondaryBreed"))]
kaggle.datasetAlt = kaggle.dataset[,-which(names(kaggle.dataset) %in% c("PrimaryBreed", "SecondaryBreed"))]

f1 = as.formula(paste("OutcomeType ~", paste(names(trainAlt)[-c(1)], collapse="+"), collapse=NULL))

# forest.model.train : modello calcolato solo sui dati di train per la scelta dei parametri
# forest.model.comparsion : modello calcolato sui dati di train+test per il confronto con gli altri modelli
# forest.model.full : modello calcolato su tutto il dataset per la sfida di kaggle

# Già calcolato, commentato per non perderci la vita ad aspettare
#mtry = c(5, 10, 12)
#err = rep(0,3)
#for(k in 1:3){
#    cat("Provo con ", mtry[k], "\n")
#    forest.model.train = randomForest(f1, data=train, mtry=mtry[k]) #Number of variables randomly sampled as candidates at #each split
#    prevs = predict(forest.model.train, newdata=test, type="response") # predizione fatta sui dati di test
#    a = misc.table(prevs, test$OutcomeType)
#    err[k] = 1-sum(diag(a))/sum(a)
#    print(c(err[k], mtry[k]))
#}
#min.k = which.min(mtry)
#best.mtry = mtry[k]
best.mtry = 12 # tutte le variabili a disposizione
cat("Best mtry: ", format(best.mtry),"\n")

#ntree = c(200, 400, 600)
#err = rep(0,3)
#for(k in 1:3){
#    cat("Provo con ", ntree[k], "\n")
#    forest.model.train = randomForest(f1, data=train, mtry=best.mtry, ntree=ntree[k]) #Number of variables randomly #sampled as candidates at each split
#    prevs = predict(forest.model.train, newdata=test, type="response") # predizione fatta sui dati di test
#    a = misc.table(prevs, test$OutcomeType)
#    err[k] = 1-sum(diag(a))/sum(a)
#    print(c(err[k], ntree[k]))
#}
#min.k = which.min(ntree)
#best.ntree = ntree[k]
best.ntree = 600
cat("Best ntree: ", format(best.ntree),"\n")

forest.model.comparsion = randomForest(f1, data=rbind(train,test), mtry=best.mtry, ntree=best.ntree)
forest.model.full = randomForest(f1, data=dataset, mtry=best.mtry, ntree=best.ntree)

# Predizione della classe sui valori di validazione per il confronto con gli altri modelli (errore di miscalssificazione)
forest.predictions.comparsion.class = predict(forest.model.comparsion, validation, type="response")
# Predizione delle probabilità per la sfida di kaggle (sul dataset separato)
forest.predictions.full.probs = predict(forest.model.full, kaggle.dataset, type="prob")

forest.misc.table = misc.table(forest.predictions.comparsion.class, validation$OutcomeType)
forest.misc.error = 1 - sum(diag(forest.misc.table))/sum(forest.misc.table)

writePredictions(forest.predictions.full.probs, kaggle.dataset[,1], "previsioni/forest.csv")