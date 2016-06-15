misc.table = function(valPredetti, valOsservati) {
    t = table(valPredetti, valOsservati) # Conta i valori automaticamente
    err.tot <- 1-sum(diag(t))/sum(t)
    cat("Errore totale: ", format(err.tot),"\n")
    invisible(t) # ritorna il valore senza stamparlo
}

misc.conf.matrix = function(valPredetti, valOsservati) {
    t = table(valOsservati,valPredetti) # Conta i valori automaticamente
    err.tot <- 1-sum(diag(t))/sum(t)
    cat("Errore totale: ", format(err.tot),"\n")
    invisible(t) # ritorna il valore senza stamparlo
}


loadDataset = function(path) {
    dataset = read.csv(path)
    
    # Eta
    # cambia l'eta da "" a "-1 years" in modo da distinguere il caso con età sconosciuta
    dataset$AgeuponOutcome = factor(dataset$AgeuponOutcome, levels=c(levels(dataset$AgeuponOutcome),"-1 years"))
    dataset$AgeuponOutcome[dataset$AgeuponOutcome == ""] = "-1 years"
    dataset$AgeuponOutcome = factor(dataset$AgeuponOutcome)
    dataset$Age = sapply(dataset$AgeuponOutcome, function(x) { extractAge(x) * extractMultiplier(x) })
    dataset$AgeCategory = sapply(dataset$Age, extractAgeCategory)
    dataset$AgeCategory = as.factor(dataset$AgeCategory)

    # Data
    dataset$DayOfWeek = sapply(dataset$DateTime, extractDayOfWeek)
    dataset$DayOfWeek = factor(dataset$DayOfWeek, levels=c("Lunedì", "Martedì", "Mercoledì", "Giovedì", "Venerdì", "Sabato", "Domenica"))
    dataset$TimeOfDay = sapply(dataset$DateTime, extractTimeOfDay)
    dataset$TimeOfDay = factor(dataset$TimeOfDay, levels=c("Mattina", "Pomeriggio", "Sera", "Notte"))

    # Sesso / stato
    dataset$Gender = sapply(dataset$SexuponOutcome, extractGenger)
    dataset$Gender = as.factor(dataset$Gender)
    dataset$Status = sapply(dataset$SexuponOutcome, extractStatus)
    dataset$Status = as.factor(dataset$Status)

    # informazioni relative al clolor
    dataset$PrimaryColor = sapply(dataset$Color, extractPrimaryColor)
    dataset$PrimaryColor = as.factor(dataset$PrimaryColor)
    dataset$SecondaryColor = sapply(dataset$Color, extractSecondaryColor)
    dataset$SecondaryColor = as.factor(dataset$SecondaryColor)
    dataset$Pattern = sapply(dataset$Color, extractPattern)
    dataset$Pattern = as.factor(dataset$Pattern)
    dataset$HasComplexColor = sapply(dataset$Color, extractHasComplexColor)
    dataset$HasComplexColor = as.factor(dataset$HasComplexColor)

    # Informazioni relative alla razza
    dataset$PrimaryBreed = sapply(dataset$Breed, extractPrimaryBreed)
    dataset$PrimaryBreed = as.factor(dataset$PrimaryBreed)
    dataset$SecondaryBreed = sapply(dataset$Breed, extractSecondaryBreed)
    dataset$SecondaryBreed = as.factor(dataset$SecondaryBreed)
    dataset$IsMix = sapply(dataset$Breed, extractIsMix)
    dataset$IsMix = as.factor(dataset$IsMix)

    # Nomi
    dataset$HasName[dataset$Name == ""] = F
    dataset$HasName[dataset$Name != ""] = T
    dataset$HasName = as.factor(dataset$HasName)

    dataset = dataset[ , -which(names(dataset) %in% c("AnimalID","DateTime","Name","Age", "Breed", "Color", "AgeuponOutcome", "SexuponOutcome", "OutcomeSubtype"))]

    str(dataset)
    invisible(dataset)
}

writePredictions = function(probs, ids, filepath) {
    # probs: matrice di 5 colonne contenente le probabilità di ogni classe
    # ids: id degli animali
    # filepath: percorso dove salvare il file
    df = data.frame(ids)
    df$ID = df$ids
    
    df$Adoption = probs[,1]
    df$Died = probs[,2]
    df$Euthanasia= probs[,3]
    df$Return_to_owner= probs[,4]
    df$Transfer = probs[,5]
    df = df[,-c(1)] # toglie la colonna ids
    options(scipen = 50) # Evita la rappresentazione esponenziale nella stampa del file
    write.csv(df, file = filepath,row.names=FALSE, na="",quote=FALSE)
    options(scipen = 0)
}

#
#   FUNZIONI DI SUPPORTO ALL'ESTRAZIONE DEI DATI
#
extractAge = function(x) {
    charX = as.character(x)
    if (charX == "") { 
        return(0)
    }
    splitted = strsplit(charX," ") 
    return(as.numeric(splitted[[1]][1]))
}

extractMultiplier = function(x) {
    charX = as.character(x)
    if (charX == "") {
        return(0)
    }
    splitted = strsplit(charX," ") 
    s = gsub("s", '', splitted[[1]][2])
    if (is.na(s)) { 
        return(0) 
    }
    if (s == 'day') { return(1) }
    else if (s == 'week') { return(7) }
    else if (s == 'month') { return(30) }
    else if (s == 'year') { return(365) }
    else { return(0) }
}

extractAgeCategory = function(x){
    if (x < 0) {return("Sconosciuta")}
    if (x >= 0 && x < 30) {return("Neonato")}
    else if (x >= 30 && x <= 365) {return("Cucciolo")}
    else if (x > 365 && x <= 3650) {return("Adulto")}
    else {return("Anziano")}
}

extractDayOfWeek = function(x) {
    d = as.Date(x, format = "%Y-%m-%d %H:%M:%S")
    dow = format(d, "%u")
    if (dow == "1") {return("Lunedì")}
    else if (dow == "2") { return("Martedì") }
    else if (dow == "3") { return("Mercoledì") }
    else if (dow == "4") { return("Giovedì") }
    else if (dow == "5") { return("Venerdì") }
    else if (dow == "6") { return("Sabato") }
    else if (dow == "7") { return("Domenica") }
    else {return("")}
}

extractTimeOfDay = function(x) {
    charX = as.character(x)
    # La data è in formato yyyy-mm-dd hh:mm:ss
    timePart = strsplit(charX," ")[[1]][2]
    timePart = as.numeric(substr(timePart,0,2))
    if (timePart >= 6 && timePart <= 12) { return("Mattina")}
    if (timePart > 12 && timePart <= 17) { return("Pomeriggio")}
    if (timePart > 17 && timePart <= 20) { return("Sera")}
    return("Notte")
}

extractGenger = function(x) {
    charX = as.character(x)
    splitted = strsplit(charX," ") 
    if (!is.na(splitted[[1]][2])) {
        return(splitted[[1]][2])
    } else {
        return("Unknown")
    }
}

extractStatus = function(x) {
    if (grepl("Intact", x, fixed=TRUE)){
        return("Intact")
    } else if (grepl("Spayed", x, fixed=TRUE) || grepl("Neutered", x, fixed=TRUE)){
        return("Neutered")
    } else {
        return("Unknown")
    }
}

extractPrimaryColor = function(x) {
    charX = as.character(x)
    splitted = strsplit(charX,"/")
    primary = splitted[[1]][1]
    primaryColor = strsplit(primary, " ")[[1]][1]
    return(primaryColor)
}

extractSecondaryColor = function(x) {
    charX = as.character(x)
    splitted = strsplit(charX,"/")
    secondary = splitted[[1]][2]
    if (is.na(secondary)) { return ("-")}
    secondaryColor = strsplit(secondary, " ")[[1]][1]
    return(secondaryColor)
}

extractPattern = function(x) {
    charX = as.character(x)
    splitted = strsplit(charX,"/")
    primary = splitted[[1]][1]
    primaryPattern = strsplit(primary, " ")[[1]][2]
    if (!is.na(primaryPattern)) {return(primaryPattern)}
    secondary = splitted[[1]][2]
    if (is.na(secondary)) { return ("-")}
    secondaryPattern = strsplit(secondary, " ")[[1]][2]
    if (!is.na(secondaryPattern)) { return (secondaryPattern)}
    else { return('-')}
}

extractHasComplexColor = function(x) {
    charX = as.character(x)
    return( grepl("/", charX, fixed=TRUE) || grepl(" ", charX, fixed=TRUE))
}

extractIsMix = function(x) {
    charX = as.character(x)
    return( grepl("Mix", charX, fixed=TRUE) || grepl("/", charX, fixed=TRUE))
}

extractPrimaryBreed = function(x) {
    charX = as.character(x)
    charX = gsub(" Mix", '', charX)
    splitted = strsplit(charX,"/")
    primary = splitted[[1]][1]
    return(primary)
}

extractSecondaryBreed = function(x) {
    charX = as.character(x)
    charX = gsub("Mix", '', charX)
    splitted = strsplit(charX,"/")
    secondary = splitted[[1]][2]
    if (is.na(secondary)) { return ("-")}
    return(secondary)
}