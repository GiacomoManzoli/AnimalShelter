
# Regressione logistica utilizzando GLM - One vs all

if (!exists("test") || !exists("train") || !exists("validation")) {
    print("Dati non presenti, li carico...")
    source("./load.R")
}

f1 = as.formula(paste("OutcomeType ~", paste(names(train)[-c(1)], collapse="+"), collapse=NULL))


# logit2.model.train : modello calcolato solo sui dati di train per la scelta dei parametri
# logit2.model.comparsion : modello calcolato sui dati di train+test per il confronto con gli altri modelli
# logit2.model.full : modello calcolato su tutto il dataset per la sfida di kaggle

# logit2.model.train = multinom(f1, data=train, MaxNWts = 10000, maxit = 200, trace = FALSE)

print("--- GLM - OneVSALL ---")

# Splitto la variabili con K classi in k variabili binomiali
print("Adatto il dataset...")
# Non posso usare Primary e SecondaryBreed perché alcuni valori di kaggle.dataset non compaiono in dataset
dataset = dataset[,-which(names(dataset) %in% c("PrimaryBreed", "SecondaryBreed"))]
kaggle.dataset = kaggle.dataset[,-which(names(kaggle.dataset) %in% c("PrimaryBreed", "SecondaryBreed"))]
trainAlt = rbind(train,test)
datasetAlt = dataset[,]

trainAlt$OutAdoption =      sapply(trainAlt$OutcomeType, function(x) {if (as.character(x)=="Adoption") {return("Yes")} else {return("No")}})
trainAlt$OutDied =          sapply(trainAlt$OutcomeType, function(x) {if (as.character(x)=="Died") {return("Yes")} else {return("No")}} )
trainAlt$OutEuthanasia =    sapply(trainAlt$OutcomeType, function(x) {if (as.character(x)=="Euthanasia") {return("Yes") }else {return("No")}} )
trainAlt$OutReturnToOwner = sapply(trainAlt$OutcomeType, function(x) {if (as.character(x)=="Return_to_owner") {return("Yes") }else {return("No")}} )
trainAlt$OutTransfer =      sapply(trainAlt$OutcomeType, function(x) {if (as.character(x)=="Transfer") {return("Yes")} else {return("No")}} )
trainAlt = trainAlt[,-which(names(trainAlt) %in% c("OutcomeType"))]
trainAlt[,13] = as.factor(trainAlt[,13]) 
trainAlt[,14] = as.factor(trainAlt[,14]) 
trainAlt[,15] = as.factor(trainAlt[,15]) 
trainAlt[,16] = as.factor(trainAlt[,16]) 
trainAlt[,17] = as.factor(trainAlt[,17])
trainAlt[,18] = as.factor(trainAlt[,18]) 
trainAlt[,19] = as.factor(trainAlt[,19])

datasetAlt$OutAdoption =      sapply(datasetAlt$OutcomeType, function(x) {if (as.character(x)=="Adoption") {return("Yes") }else {return("No")}})
datasetAlt$OutDied =          sapply(datasetAlt$OutcomeType, function(x) {if (as.character(x)=="Died") {return("Yes") }else {return("No")}} )
datasetAlt$OutEuthanasia =    sapply(datasetAlt$OutcomeType, function(x) {if (as.character(x)=="Euthanasia") {return("Yes") }else {return("No")}} )
datasetAlt$OutReturnToOwner = sapply(datasetAlt$OutcomeType, function(x) {if (as.character(x)=="Return_to_owner") {return("Yes") }else {return("No")}} )
datasetAlt$OutTransfer =      sapply(datasetAlt$OutcomeType, function(x) {if (as.character(x)=="Transfer") {return("Yes") }else {return("No")}} )
datasetAlt = datasetAlt[,-which(names(datasetAlt) %in% c("OutcomeType"))]
datasetAlt[,13] = as.factor(datasetAlt[,13]) 
datasetAlt[,14] = as.factor(datasetAlt[,14]) 
datasetAlt[,15] = as.factor(datasetAlt[,15]) 
datasetAlt[,16] = as.factor(datasetAlt[,16]) 
datasetAlt[,17] = as.factor(datasetAlt[,17])

# Definizione delle formule

f1 = as.formula(paste("OutAdoption ~", paste(names(dataset)[-c(1)], collapse="+"), collapse=NULL)) # Uso i nomi di train così esclude le nuove colonne
f2 = as.formula(paste("OutDied ~", paste(names(dataset)[-c(1)], collapse="+"), collapse=NULL))
f3 = as.formula(paste("OutEuthanasia ~", paste(names(dataset)[-c(1)], collapse="+"), collapse=NULL))
f4 = as.formula(paste("OutReturnToOwner ~", paste(names(dataset)[-c(1)], collapse="+"), collapse=NULL))
f5 = as.formula(paste("OutTransfer ~", paste(names(dataset)[-c(1)], collapse="+"), collapse=NULL))


# non viene fatta l'ottimizzazione degli iper-parametri perché ci sono troppi modelli.
# trainAlt contiene già l'rbind di train e test
print("Calcolo modelli comparazione...")
logit2.model.comparsion.1 = glm(f1, data=trainAlt, family=binomial)
logit2.model.comparsion.2 = glm(f2, data=trainAlt, family=binomial)
logit2.model.comparsion.3 = glm(f3, data=trainAlt, family=binomial)
logit2.model.comparsion.4 = glm(f4, data=trainAlt, family=binomial)
logit2.model.comparsion.5 = glm(f5, data=trainAlt, family=binomial)

print("Calcolo modelli completi...")
logit2.model.full.1 = glm(f1, data=datasetAlt, family=binomial)
logit2.model.full.2 = glm(f2, data=datasetAlt, family=binomial)
logit2.model.full.3 = glm(f3, data=datasetAlt, family=binomial)
logit2.model.full.4 = glm(f4, data=datasetAlt, family=binomial)
logit2.model.full.5 = glm(f5, data=datasetAlt, family=binomial)

# Predizione sul test di validazione, prima normalizzo le probabilità
print("Predizione sui modelli di comparazione...")
logit2.predictions.comparsion.probs.1 = predict(logit2.model.comparsion.1, validation, type="response") # Probabilità del livello yes
logit2.predictions.comparsion.probs.2 = predict(logit2.model.comparsion.2, validation, type="response")
logit2.predictions.comparsion.probs.3 = predict(logit2.model.comparsion.3, validation, type="response")
logit2.predictions.comparsion.probs.4 = predict(logit2.model.comparsion.4, validation, type="response")
logit2.predictions.comparsion.probs.5 = predict(logit2.model.comparsion.5, validation, type="response")

## Matrici di confusione per i singoli modelli
mat1 = misc.conf.matrix(logit2.predictions.comparsion.probs.1 > 0.5, validation$OutcomeType=="Adoption")
mat2 = misc.conf.matrix(logit2.predictions.comparsion.probs.2 > 0.5, validation$OutcomeType=="Died")
mat3 = misc.conf.matrix(logit2.predictions.comparsion.probs.3 > 0.5, validation$OutcomeType=="Euthanasia")
mat4 = misc.conf.matrix(logit2.predictions.comparsion.probs.4 > 0.5, validation$OutcomeType=="Return_to_owner")
mat5 = misc.conf.matrix(logit2.predictions.comparsion.probs.5 > 0.5, validation$OutcomeType=="Transfer")

print("Aggiusto le probabilità e le classi...")
logit2.predictions.comparsion.probs = matrix(nrow=length(logit2.predictions.comparsion.probs.1), ncol=5)
logit2.predictions.comparsion.class = rep(0,length(logit2.predictions.comparsion.probs.1))
for (i in 1:length(logit2.predictions.comparsion.probs.1)) {
    v = c(logit2.predictions.comparsion.probs.1[i],
          logit2.predictions.comparsion.probs.2[i],
          logit2.predictions.comparsion.probs.3[i],
          logit2.predictions.comparsion.probs.4[i],
          logit2.predictions.comparsion.probs.5[i])
    v = v/sum(v) # Normalizza le probabilità
    logit2.predictions.comparsion.probs[i,] = v
    class = which.max(v)
    fclass = ""
    if (class == 1){ fclass = "Adoption"}
    else if (class== 2) {fclass = "Died"}
    else if (class== 3) {fclass = "Euthanasia"}
    else if (class== 4) {fclass = "Return_to_owner"}
    else if (class== 5) {fclass = "Transfer"}
    logit2.predictions.comparsion.class[i] = fclass
}
logit2.predictions.comparsion.class = as.factor(logit2.predictions.comparsion.class)

# Predizione delle probabilità per la sfida di kaggle (sul dataset separato)
print("Predizione sul modello completo...")
logit2.predictions.full.probs.1 = predict(logit2.model.full.1, kaggle.dataset, type="response") # Probabilità #del livello yes
logit2.predictions.full.probs.2 = predict(logit2.model.full.2, kaggle.dataset, type="response")
logit2.predictions.full.probs.3 = predict(logit2.model.full.3, kaggle.dataset, type="response")
logit2.predictions.full.probs.4 = predict(logit2.model.full.4, kaggle.dataset, type="response")
logit2.predictions.full.probs.5 = predict(logit2.model.full.5, kaggle.dataset, type="response")
print("Aggiusto le probabilità...")
logit2.predictions.full.probs = matrix(nrow=length(logit2.predictions.full.probs.1), ncol=5)
for (i in 1:length(logit2.predictions.full.probs.1)) {
    v = c(logit2.predictions.full.probs.1[i],
          logit2.predictions.full.probs.2[i],
          logit2.predictions.full.probs.3[i],
          logit2.predictions.full.probs.4[i],
          logit2.predictions.full.probs.5[i])
    v = v/sum(v) # Normalizza le probabilità
    logit2.predictions.full.probs[i,] = v
}

logit2.misc.table = misc.table(logit2.predictions.comparsion.class, validation$OutcomeType)
logit2.misc.error = 1 - sum(diag(logit2.misc.table))/sum(logit2.misc.table)
print("Scrivo le predizioni...")
writePredictions(logit2.predictions.full.probs, kaggle.dataset[,1], "previsioni/logit-2.csv")