library(ada) # funziona solo con i modelli binomiali
# https://cran.r-project.org/web/packages/ada/ada.pdf
if (!exists("test") || !exists("train") || !exists("validation")) {
    source("../load.R")
}

# Splitto la variabili con K classi in k variabili binomiali

trainAlt = rbind(train,test)
datasetAlt = dataset[,]

trainAlt$OutAdoption =      sapply(trainAlt$OutcomeType, function(x) {if (as.character(x)=="Adoption") {return("Yes")} else {return("No")}})
trainAlt$OutDied =          sapply(trainAlt$OutcomeType, function(x) {if (as.character(x)=="Died") {return("Yes")} else {return("No")}} )
trainAlt$OutEuthanasia =    sapply(trainAlt$OutcomeType, function(x) {if (as.character(x)=="Euthanasia") {return("Yes") }else {return("No")}} )
trainAlt$OutReturnToOwner = sapply(trainAlt$OutcomeType, function(x) {if (as.character(x)=="Return_to_owner") {return("Yes") }else {return("No")}} )
trainAlt$OutTransfer =      sapply(trainAlt$OutcomeType, function(x) {if (as.character(x)=="Transfer") {return("Yes")} else {return("No")}} )
trainAlt = trainAlt[,-which(names(trainAlt) %in% c("OutcomeType"))]
trainAlt[,15] = as.factor(trainAlt[,15]) 
trainAlt[,16] = as.factor(trainAlt[,16]) 
trainAlt[,17] = as.factor(trainAlt[,17]) 
trainAlt[,18] = as.factor(trainAlt[,18]) 
trainAlt[,19] = as.factor(trainAlt[,19])

datasetAlt$OutAdoption = sapply(datasetAlt$OutcomeType, function(x) {if (as.character(x)=="Adoption") {return("Yes") }else {return("No")}})
datasetAlt$OutDied = sapply(datasetAlt$OutcomeType, function(x) {if (as.character(x)=="Died") {return("Yes") }else {return("No")}} )
datasetAlt$OutEuthanasia = sapply(datasetAlt$OutcomeType, function(x) {if (as.character(x)=="Euthanasia") {return("Yes") }else {return("No")}} )
datasetAlt$OutReturnToOwner = sapply(datasetAlt$OutcomeType, function(x) {if (as.character(x)=="Return_to_owner") {return("Yes") }else {return("No")}} )
datasetAlt$OutTransfer = sapply(datasetAlt$OutcomeType, function(x) {if (as.character(x)=="Transfer") {return("Yes") }else {return("No")}} )
datasetAlt = datasetAlt[,-which(names(datasetAlt) %in% c("OutcomeType"))]
datasetAlt[,15] = as.factor(datasetAlt[,15]) 
datasetAlt[,16] = as.factor(datasetAlt[,16]) 
datasetAlt[,17] = as.factor(datasetAlt[,17]) 
datasetAlt[,18] = as.factor(datasetAlt[,18]) 
datasetAlt[,19] = as.factor(datasetAlt[,19])

f1 = as.formula(paste("OutAdoption ~", paste(names(train)[-c(1)], collapse="+"), collapse=NULL)) # Uso i nomi di train così esclude le nuove colonne
f2 = as.formula(paste("OutDied ~", paste(names(train)[-c(1)], collapse="+"), collapse=NULL))
f3 = as.formula(paste("OutEuthanasia ~", paste(names(train)[-c(1)], collapse="+"), collapse=NULL))
f4 = as.formula(paste("OutReturnToOwner ~", paste(names(train)[-c(1)], collapse="+"), collapse=NULL))
f5 = as.formula(paste("OutTransfer ~", paste(names(train)[-c(1)], collapse="+"), collapse=NULL))

# boost.model.comparsion : modello calcolato sui dati di train+test per il confronto con gli altri modelli
# boost.model.full : modello calcolato su tutto il dataset per la sfida di kaggle

# non viene fatta l'ottimizzazione degli iper-parametri perché ci sono troppi modelli.
# trainAlt contiene già l'rbind di train e test
print("Calcolo modelli comparazione...")
boost.model.comparsion.1 = ada(f1, data=trainAlt, iter=50)
boost.model.comparsion.2 = ada(f2, data=trainAlt, iter=50)
boost.model.comparsion.3 = ada(f3, data=trainAlt, iter=50)
boost.model.comparsion.4 = ada(f4, data=trainAlt, iter=50)
boost.model.comparsion.5 = ada(f5, data=trainAlt, iter=50)

print("Calcolo modelli completi...")
boost.model.full.1 = ada(f1, data=datasetAlt, iter=50)
boost.model.full.2 = ada(f2, data=datasetAlt, iter=50)
boost.model.full.3 = ada(f3, data=datasetAlt, iter=50)
boost.model.full.4 = ada(f4, data=datasetAlt, iter=50)
boost.model.full.5 = ada(f5, data=datasetAlt, iter=50)

# Predizione sul test di validazione, prima normalizzo le probabilità
print("Predizione sui modelli di comparazione...")
boost.predictions.comparsion.probs.1 = predict(boost.model.comparsion.1, validation, type="probs")[,2] # Probabilità del livello yes
boost.predictions.comparsion.probs.2 = predict(boost.model.comparsion.2, validation, type="probs")[,2]
boost.predictions.comparsion.probs.3 = predict(boost.model.comparsion.3, validation, type="probs")[,2]
boost.predictions.comparsion.probs.4 = predict(boost.model.comparsion.4, validation, type="probs")[,2]
boost.predictions.comparsion.probs.5 = predict(boost.model.comparsion.5, validation, type="probs")[,2]

print("Aggiusto le probabilità e le classi...")
boost.predictions.comparsion.probs = matrix(nrow=length(boost.predictions.comparsion.probs.1), ncol=5)
boost.predictions.comparsion.class = rep(0,length(boost.predictions.comparsion.probs.1))
for (i in 1:length(boost.predictions.comparsion.probs.1)) {
    v = c(boost.predictions.comparsion.probs.1[i],
          boost.predictions.comparsion.probs.2[i],
          boost.predictions.comparsion.probs.3[i],
          boost.predictions.comparsion.probs.4[i],
          boost.predictions.comparsion.probs.5[i])
    v = v/sum(v) # Normalizza le probabilità
    boost.predictions.comparsion.probs[i,] = v
    class = which.max(v)
    fclass = ""
    if (class == 1){ fclass = "Adoption"}
    else if (class== 2) {fclass = "Died"}
    else if (class== 3) {fclass = "Euthanasia"}
    else if (class== 4) {fclass = "Return_to_owner"}
    else if (class== 5) {fclass = "Transfer"}
    boost.predictions.comparsion.class[i] = fclass
}
boost.predictions.comparsion.class = as.factor(boost.predictions.comparsion.class)

# Predizione delle probabilità per la sfida di kaggle (sul dataset separato)
print("Predizione sul modello completo...")
boost.predictions.full.probs.1 = predict(boost.model.full.1, kaggle.dataset, type="probs")[,2] # Probabilità del livello yes
boost.predictions.full.probs.2 = predict(boost.model.full.2, kaggle.dataset, type="probs")[,2]
boost.predictions.full.probs.3 = predict(boost.model.full.3, kaggle.dataset, type="probs")[,2]
boost.predictions.full.probs.4 = predict(boost.model.full.4, kaggle.dataset, type="probs")[,2]
boost.predictions.full.probs.5 = predict(boost.model.full.5, kaggle.dataset, type="probs")[,2]
print("Aggiusto le probabilità...")
boost.predictions.full.probs = matrix(nrow=length(boost.predictions.full.probs.1), ncol=5)
for (i in 1:length(boost.predictions.full.probs.1)) {
    v = c(boost.predictions.full.probs.1[i],
          boost.predictions.full.probs.2[i],
          boost.predictions.full.probs.3[i],
          boost.predictions.full.probs.4[i],
          boost.predictions.full.probs.5[i])
    v = v/sum(v) # Normalizza le probabilità
    boost.predictions.full.probs[i,] = v
}


boost.misc.table = misc.table(boost.predictions.comparsion.class, validation$OutcomeType)
boost.misc.error = 1 - sum(diag(boost.misc.table))/sum(boost.misc.table)
print("Scrivo le predizioni...")
writePredictions(boost.predictions.full.probs, kaggle.dataset[,1], "previsioni/boost.csv")