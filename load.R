source("functions.R")


dataset = loadDataset("train.csv")
kaggle.dataset = loadDataset("test.csv") 

# Fattorizza allo stesso modo le variabili relative al colore/razza
primaryColorList = unique(c(levels(dataset$PrimaryColor), levels(kaggle.dataset$PrimaryColor)))
dataset$PrimaryColor = factor(dataset$PrimaryColor, levels=primaryColorList)
kaggle.dataset$PrimaryColor = factor(kaggle.dataset$PrimaryColor, levels=primaryColorList)

secondaryColorList = unique(c(levels(dataset$SecondaryColor), levels(kaggle.dataset$SecondaryColor)))
dataset$SecondaryColor = factor(dataset$SecondaryColor, levels=secondaryColorList)
kaggle.dataset$SecondaryColor = factor(kaggle.dataset$SecondaryColor, levels=secondaryColorList)

patternList = unique(c(levels(dataset$Pattern), levels(kaggle.dataset$Pattern)))
dataset$Pattern = factor(dataset$Pattern, levels=patternList)
kaggle.dataset$Pattern = factor(kaggle.dataset$Pattern, levels=patternList)

primaryBreedList = unique(c(levels(dataset$PrimaryBreed), levels(kaggle.dataset$PrimaryBreed)))
dataset$PrimaryBreed = factor(dataset$PrimaryBreed, levels=primaryBreedList)
kaggle.dataset$PrimaryBreed = factor(kaggle.dataset$PrimaryBreed, levels=primaryBreedList)

secondaryBreedList = unique(c(levels(dataset$SecondaryBreed), levels(kaggle.dataset$SecondaryBreed)))
dataset$SecondaryBreed = factor(dataset$SecondaryBreed, levels=secondaryBreedList)
kaggle.dataset$SecondaryBreed = factor(kaggle.dataset$SecondaryBreed, levels=secondaryBreedList)

# Divisione in train/test/validation
set.seed(314)
validation.indexes = sample(1:nrow(dataset), nrow(dataset)*0.2) #20% per il confronto tra i modelli
train = dataset[-validation.indexes, ]
validation = dataset[validation.indexes, ] # dataset di validazione per il confronto dei modelli
test.indexes = sample(1:nrow(dataset), nrow(dataset)*0.2) #20% per il test dei modelli (iperparametri/pruning/ecc.)
train = dataset[-test.indexes, ]
test = dataset[test.indexes, ]