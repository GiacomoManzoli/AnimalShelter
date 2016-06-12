library(ggplot2) # Grafici complessi http://docs.ggplot2.org/current/
# library(ggthemes) # Temi per i grafici https://github.com/jrnold/ggthemes Alla fine il tema di defautl è più bello
library(dplyr) # Manipolazione dei dati (raggruppa/ecc.)

outcomesByAnimal = function() {
    outcomes <- dataset[,] %>% 
        group_by(AnimalType, OutcomeType) %>% 
        summarise(tot = n())

    ggplot(outcomes, aes(x = AnimalType, y = tot, fill = OutcomeType)) +
        geom_bar(stat = "identity", position = "fill") +
        labs(y = "Proporzioni",  x = "Animale",title = "Esito in base al tipo di animale", fill="Esito")
}

outcomesByGender = function() {
    outcomes <- dataset[,] %>% 
        group_by(AnimalType, Gender, OutcomeType) %>% 
        summarise(tot = n())

    ggplot(outcomes, aes(x = Gender, y = tot, fill = OutcomeType)) +
        geom_bar(stat = "identity", position = "fill") +
        facet_wrap(~AnimalType) +
        labs(y = "Proporzioni",  x = "Sesso",title = "Esito in base al sesso", fill="Esito")
}

outcomesByStatus = function() {
    outcomes <- dataset[,] %>% 
        group_by(AnimalType, Gender, Status, OutcomeType) %>% 
        summarise(tot = n())

    ggplot(outcomes, aes(x = Status, y = tot, fill = OutcomeType)) +
        geom_bar(stat = "identity", position = "fill") +
        facet_wrap(~AnimalType+Gender) +
        labs(y = "Proporzioni",  x = "Stato",title = "Esito in base al sesso a allo stato", fill="Esito")
}

outcomesByTimeOfDay = function() {
    outcomes <- dataset[,] %>% 
        group_by(AnimalType, TimeOfDay, OutcomeType) %>% 
        summarise(tot = n())

    ggplot(outcomes, aes(x = TimeOfDay, y = tot, fill = OutcomeType)) +
        geom_bar(stat = "identity", position = "fill") +
        facet_wrap(~AnimalType) +
        labs(y = "Proporzioni",  x = "Fascia oraria",title = "Esito in base alla fascia oraria", fill="Esito")
}

outcomesByDayOfWeek = function() {
    outcomes <- dataset[,] %>% 
        group_by(AnimalType, DayOfWeek, OutcomeType) %>% 
        summarise(tot = n())

    ggplot(outcomes, aes(x = DayOfWeek, y = tot, fill = OutcomeType)) +
        geom_bar(stat = "identity", position = "fill") +
        facet_wrap(~AnimalType) +
        labs(y = "Proporzioni",  x = "Giorno",title = "Esito in base al giorno della settimana", fill="Esito")
}


outcomesByTimeAndDay = function () {
     outcomes <- dataset[,] %>% 
        group_by(AnimalType, DayOfWeek, TimeOfDay, OutcomeType) %>% 
        summarise(tot = n())

    ggplot(outcomes, aes(x = TimeOfDay, y = tot, fill = OutcomeType)) +
        geom_bar(stat = "identity", position = "fill") +
        facet_wrap(~AnimalType+DayOfWeek) +
        labs(y = "Proporzioni",  x = "Giorno",title = "Esito in base al giorno della settimana", fill="Esito")
}


outcomesByPureBreed = function() {
    outcomes <- dataset[,] %>% 
        group_by(AnimalType, IsMix, OutcomeType) %>% 
        summarise(tot = n())

    ggplot(outcomes, aes(x = IsMix, y = tot, fill = OutcomeType)) +
        geom_bar(stat = "identity", position = "fill") +
        facet_wrap(~AnimalType) +
        labs(y = "Proporzioni",  x = "Incrocio", title = "Esito in base alla purezza della razza", fill="Esito")
}

outcomesByHasName = function() {
    outcomes <- dataset[,] %>% 
        group_by(AnimalType, HasName, OutcomeType) %>% 
        summarise(tot = n())

    ggplot(outcomes, aes(x = HasName, y = tot, fill = OutcomeType)) +
        geom_bar(stat = "identity", position = "fill") +
        facet_wrap(~AnimalType) +
        labs(y = "Proporzioni",  x = "Ha un nome?", title = "Esito in base al nome", fill="Esito") 
}

outcomesByHasComplexColor = function() {
    outcomes <- dataset[,] %>% 
        group_by(AnimalType, HasComplexColor, OutcomeType) %>% 
        summarise(tot = n())

    ggplot(outcomes, aes(x = HasComplexColor, y = tot, fill = OutcomeType)) +
        geom_bar(stat = "identity", position = "fill") +
        facet_wrap(~AnimalType) +
        labs(y = "Proporzioni",  x = "Ha un pelo composto?", title = "Esito in base al tipo di pelo", fill="Esito") 
}

outcomesByAgeCategory = function() {
    outcomes <- dataset[,] %>% 
        group_by(AnimalType, AgeCategory, OutcomeType) %>% 
        summarise(tot = n())

    ggplot(outcomes, aes(x = AgeCategory, y = tot, fill = OutcomeType)) +
        geom_bar(stat = "identity", position = "fill") +
        facet_wrap(~AnimalType) +
        labs(y = "Proporzioni",  x = "Fascia d'età", title = "Esito in base alla fascia d'età", fill="Esito") 
}

outcomesByPrimaryColor = function() {
    outcomes <- dataset[,] %>% 
        group_by(AnimalType, PrimaryColor, OutcomeType) %>% 
        summarise(tot = n())

    ggplot(outcomes, aes(x = PrimaryColor, y = tot, fill = OutcomeType)) +
        geom_bar(stat = "identity", position = "fill") +
        coord_flip() + 
        facet_wrap(~AnimalType) +
        labs(y = "Proporzioni",  x = "Colore principale", title = "Esito in base al colore principale", fill="Esito") 
}

outcomesBySecondaryColor = function() {
    outcomes <- dataset[,] %>% 
        group_by(AnimalType, SecondaryColor, OutcomeType) %>% 
        summarise(tot = n())

    ggplot(outcomes, aes(x = SecondaryColor, y = tot, fill = OutcomeType)) +
        geom_bar(stat = "identity", position = "fill") +
        coord_flip() + 
        facet_wrap(~AnimalType) +
        labs(y = "Proporzioni",  x = "Colore secondario", title = "Esito in base al colore secondario", fill="Esito") 
}

outcomesByPattern = function() {
    outcomes <- dataset[,] %>% 
        group_by(AnimalType, Pattern, OutcomeType) %>% 
        summarise(tot = n())

    ggplot(outcomes, aes(x = Pattern, y = tot, fill = OutcomeType)) +
        geom_bar(stat = "identity", position = "fill") +
        coord_flip() + 
        facet_wrap(~AnimalType) +
        labs(y = "Proporzioni",  x = "Pattern del pelo", title = "Esito in base al pattern del pelo", fill="Esito") 
}