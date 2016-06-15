library(tree)
if (!exists("test") || !exists("train") || !exists("validation")) {
    source("../load.R")
}
print("--- Tree ---")

print("Adatto il dataset...")
trainAlt = train[,-which(names(train) %in% c("PrimaryBreed", "SecondaryBreed"))]
testAlt = test[,-which(names(test) %in% c("PrimaryBreed", "SecondaryBreed"))]
validationAlt = validation[,-which(names(validation) %in% c("PrimaryBreed", "SecondaryBreed"))]
datasetAlt = dataset[,-which(names(dataset) %in% c("PrimaryBreed", "SecondaryBreed"))]
kaggle.datasetAlt = kaggle.dataset[,-which(names(kaggle.dataset) %in% c("PrimaryBreed", "SecondaryBreed"))]

f1 = as.formula(paste("OutcomeType ~", paste(names(trainAlt)[-c(1)], collapse="+"), collapse=NULL))

# tree.model.train : modello calcolato solo sui dati di train per la scelta dei parametri
# tree.model.comparsion : modello calcolato sui dati di train+test per il confronto con gli altri modelli
# tree.model.full : modello calcolato su tutto il dataset per la sfida di kaggle

print("Calcolo il primo albero...")
# L'albero cresce sui dati di train
tree.model.train = tree(f1, data=trainAlt, control=tree.control(nobs=nrow(trainAlt), minsize=2, mindev=0.002))

print("Effettuo il pruning...")
# Pota l'albero utilizzando i dati di test
tree.temp = prune.tree(tree.model.train, newdata=testAlt)
J = tree.temp$size[tree.temp$dev==min(tree.temp$dev)]
# Albero potato
print("Calcolo il modello potato (comparsion) ...")
tree.model.comparsion <- prune.tree(tree.model.train, best=J)
# Per il modello di kaggle prima faccio cresce l'albero sui dati di train+test e poi poto con quelli di validazione
obs = rbind(trainAlt,testAlt)
print("Calcolo il primo albero...")
tree.temp1 = tree(f1, data=obs, control=tree.control(nobs=nrow(obs), minsize=2, mindev=0.002))
print("Effetto il pruning...")
tree.temp2 = prune.tree(tree.temp1, newdata=validationAlt)
J = tree.temp2$size[tree.temp2$dev==min(tree.temp2$dev)]
print("Calcolo il modello potato (full)...")
tree.model.full = prune.tree(tree.temp1, best=J)

print("Effettuo le predizioni...")
# Predizione della classe sui valori di validazione per il confronto con gli altri modelli (errore di miscalssificazione)
tree.predictions.comparsion.class = predict(tree.model.comparsion, validationAlt, type="class")
# Predizione delle probabilità per la sfida di kaggle (sul dataset separato)
tree.predictions.full.probs = predict(tree.model.full, kaggle.datasetAlt, type="vector")

tree.misc.table = misc.table(tree.predictions.comparsion.class, validation$OutcomeType)
tree.misc.error = 1 - sum(diag(tree.misc.table))/sum(tree.misc.table)

print("Scrivo le predizioni...")
writePredictions(tree.predictions.full.probs, kaggle.dataset[,1], "previsioni/tree.csv")
