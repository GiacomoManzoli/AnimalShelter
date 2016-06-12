# Descrizione del dataset

Il dataset contiene 26729 osservazioni relative agli animali che hanno lasciato un rifugio per animali nel periodo che va dall'Ottobre 2013 a Marzo 2016.

Per ogni osservazione sono disponibili 10 variabili che descrivono lo stato dell'animale quanto ha lasciato il rifugio.
Le variabili sono:

- `AnimalID`: Factor con tanti livelli, specifica l'id associato all'animale
- `Name`: Factor con 5411 livelli. 7691 animali sono senza nome.
- `DateTime`: Factor con tanti livelli, rappresenta la data e ora in cui l'animale è stato prelevato dal rifugio, il formato è `aaaa-mm-gg hh:mm:ss`
- `Outcome`: Variabile da prevedere, 5 possibili livelli. Rappresenta il destino dell'animale.
- `OutcomeSubtype`: Motivazione del perché l'animale ha fatto quella fine. 17 livelli, 13612 NA.
- `AnimalType`: Cane o gattto
- `SexuponOutcome`: 5 livelli che descrivono il sesso dell'animale.
- `AgeuponOutcome`: Età dell'animale, espressa in settimane, mesi o anni.
- `Breed`: razza dell'animale 1229 livelli.
- `Color`: colore dell'animale, 332 livelli.

L'obiettivo è quello di riuscire a predirre la variabile `Outcome`.

Trattandosi di un dataset per una sfida di Kaggle, viene fornito un ulteriore set di dati composto da 11456 osservazioni con 8 variabili, che viene utilizzato per calcolare la classifica.
Questo dataset non contiene per ovvi motivi le variabili `Outcome` e `OutcomeSubtype`.

# Modifiche alle variabili

Drop della colonna ID. poco interessante.

Transformazione della colonna relativa all'età: ci sono 16 animali che hanno come età `0 years`. Una prima idea può essere quella di toglierli, dato che sono un numero limitato, tuttavia di queste 16 osservazioni, 15 hanno lo stesso valore come variabile risposta, quindi vengono tenute. Un ragionamento simile vale per gli animali che hanno il età non settata.

In ogni caso la variabile è espressa in un'unità di misura che può essere scomoda, conviene riportare il tutto in giorni, creando una nuova variabile `eta`. Per gli animali che hanno come età `0 years` e `""` viene utilizzato il valore 0. Inoltre ci sono le `s` dei plurali che creano qualche problema.

Il risultato ottenuto è riportato sotto e la colonna `AgeuponOutcome` può essere rimossa.

```
> summary(dataset$eta)
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    0.0    60.0   365.0   789.1  1095.0  7300.0 
```

Per quanto riguarda la data di uscita, l'informazione a disposizione è troppo dettagliata. Può essere utile scomporla per identificare in che fascia oraria e in che giorno della settimana è stato prelevato l'animale.

Anche l'informazione riguardante il sesso dell'animale può essere suddivisa in genere (maschio o femmina) e se è stato castrato o meno.

Osservando le informazioni sul colore ci sono 332 tipologie diverse alcune molto simili tra loro, questo perché la variabile racchiude informazioni sia sui due colori principali del pelo dell'animale, sia sul pattern del pelo (tigrato, a macchie, ecc.).
L'idea è quindi quella di andare a scorporare maggiormente le informazioni estraendo il colore primario, quello secondario e il pattern con il quale si alternano questi colori.

Così facendo i 332 livelli per il colore sono diventati 29 per il colore primario, 23 per il colore secondario e 10 per il pattern.

Volendo sarebbe possibile ridurre utileriormente i livelli perché anche con questa nuova scomposizione ci sono tra loro dei colori simili come `Chocolate` e `Brown`.

Per quanto riguarda le razze ci sono 1229 livelli possibili, questo perché la variabile include anche l'informazione relativa al fatto se l'animale è di razza oppure se è un incrocio: sembra che nel caso siano note entrambe le razze, queste siano separate da uno slash, mentre se è nota solo quella principale, questa viene seguita da `Mix`.

Dal momento che è ragionevole che la razza di un animale favorisca o meno la sua adozione, si può scomporre la variabile in più 3 variabili:

- `IsMix`: se l'animale è un incrocio o meno
- `PrimaryBreed`: la razza principale dell'animale, quella a sinsitra dello slash
- `SecondaryBreed`: la razza secondaria dell'animale, quella a destra dello slash

Così facendo si ottengono rispettivamente 2, 215 e 138 livelli. Sono ancora molti e probabilmente ci sono varie razze simili tra loro, ma per identificare è necessaria una maggiore conoscenza sul dominio.

Infine, dal campo dati nome è estrapolare l'infomrazione riguardo il fatto se l'animale ha un nome o meno. L'idea è che il fatto che l'animale abbia un nome può aumentare la probabilità che il proprietario venga a recuperarlo (una delle possibili classi), mentre un animale randagio senza nome è difficile che venga recuperato dal suo padrone.

Una volta estrapolate tutte le infomrazioni è possibile rimuovere dal dataset le variabili `AnimalID`, `DateTime`, `Name`, `Breed`, `Color`, `AgeuponOutcome`, `SexuponOutcome` e `OutcomeSubtype`. Quest'ultima viene rimossa perché quando è disponbile è fortemente correlata alla variabile `Outcome` e durante la previsione sul dataset secondario non è disponibile. 

---

# Workflow

1. Caricamento del dataset
2. Split in train e test (20k e resto) (per debug 1000 e 200)
3. Modelli da fare (calcolati su: dataset originale, dataset modificato in train, dataset modificato totale)
    
    1. (OK) Regressione logistica 
    2. (OK) Albero di classificazione `library(tree)`
    3. (OK) MARS `library(polspline)`
    4. (OK) Neural Net `library(nnet)`
    5. (~OK) GAM `library(gam)`
    6. (OK) Random Forest `library (randomForest)`
    7. (OK) Bagging `library(ipred)`
    8. (OK) Boosting `library(ada)`

4. Calcolo della tabella di misclassificazione
5. Potrebbe servire una funzione extractClass che dalle probabilità estrae una classe
6. Generazione dei file per Kaggle

## Regressione logistica

```
Best decay:  0.001 
Errore totale:  0.3365762 
> logit.misc.table
                 valOsservati
valPredetti       Adoption Died Euthanasia Return_to_owner Transfer
  Adoption            1827    1         38             364      462
  Died                   0    0          0               0        0
  Euthanasia             3    1         40              17       21
  Return_to_owner      242    4         71             446      142
  Transfer             120   36        173             104     1233
  
Kaggle Score 0.89358 (basso è meglio) Posizione 487
```

## Alberi

In R gli alberi e le foreste lavorano solo con factor che hanno < 32 livelli. Vengono quindi droppate le colonne relative alle razze.

```
> tree.misc.error
[1] 0.3543499
> tree.misc.table
                 valOsservati
valPredetti       Adoption Died Euthanasia Return_to_owner Transfer
  Adoption            1765    2         33             352      431  
  Died                   0    0          0               0        0
  Euthanasia             0    0          0               0        0
  Return_to_owner      289    3         86             465      206
  Transfer             138   37        203             114     1221
  
  comparsion.size = 21
  full.size = 19
  
Kaggle Score: 0.87657 (Posizione 450)
```

## Neural net

```
Best decay:  0.001668101 
Errore totale:  0.6159027 

> nn.misc.table
                 valOsservati
valPredetti       Adoption Died Euthanasia Return_to_owner Transfer
  Adoption            1892    4         41             338      375 = 2650
  Died                   0    0          0               0        0
  Euthanasia             2    1         63               8       20 = 94
  Return_to_owner      188    1         70             495      135 = 889
  Transfer             110   36        148              90     1328 = 1712

> nn.misc.error
[1] 0.6159027

Kaggle Score: 0.93989 (Posizione 538)

##### seconda rete

> nn.misc.error
[1] 0.2946679
> nn.misc.table
                 valOsservati
valPredetti       Adoption Died Euthanasia Return_to_owner Transfer
  Adoption            1901    3         31             331      374
  Died                   0    1          0               0        0
  Euthanasia             4    4         77              11       30
  Return_to_owner      183    3         65             502      165
  Transfer             104   31        149              87     1289

KaggleScore: 1.22650

```

## Random forest
```
ntree=600 mtry=12
> forest.misc.error
[1] 0.1863424
> forest.misc.table
                 valOsservati
valPredetti       Adoption Died Euthanasia Return_to_owner Transfer
  Adoption            1961    3         27             224      259
  Died                   0   29          0               0        2
  Euthanasia             4    1        203               7       15
  Return_to_owner      141    2         29             646       72
  Transfer              86    7         63              54     1510

kaggle score:  2.18340
```


## MARS
```
> source("modelli/mars.R")
Best type:  backward 
Errore totale:  0.5867166 
> mmars.misc.error
[1] 0.5867166
> mmars.misc.table
                 valOsservati
valPredetti       Adoption Died Euthanasia Return_to_owner Transfer
  Adoption            1994    2         61             599      566
  Return_to_owner       99    2         48             187       74
  Transfer              99   38        213             145     1218
```

## AdaBoost

```
> boost.model.comparsion.1
Call:
ada(f1, data = trainAlt, iter = 50)

Loss: exponential Method: discrete   Iteration: 50 

Final Confusion Matrix for Data:
          Final Prediction
True value    No   Yes
       No  12673  3287
       Yes  2443  8326

Train Error: 0.214 

Out-Of-Bag Error:  0.219  iteration= 50 

Additional Estimates of number of iterations:

train.err1 train.kap1 
        50         44 

> boost.model.comparsion.2
Call:
ada(f2, data = trainAlt, iter = 50)

Loss: exponential Method: discrete   Iteration: 50 

Final Confusion Matrix for Data:
          Final Prediction
True value    No
       No  26532
       Yes   197

Train Error: 0.007 

Out-Of-Bag Error:  0.007  iteration= 6 

Additional Estimates of number of iterations:

train.err1 train.kap1 
         1          1 

> boost.model.comparsion.3
Call:
ada(f3, data = trainAlt, iter = 50)

Loss: exponential Method: discrete   Iteration: 50 

Final Confusion Matrix for Data:
          Final Prediction
True value    No   Yes
       No  25142    32
       Yes  1475    80

Train Error: 0.056 

Out-Of-Bag Error:  0.057  iteration= 46 

Additional Estimates of number of iterations:

train.err1 train.kap1 
        49         49 

> boost.model.comparsion.4
Call:
ada(f4, data = trainAlt, iter = 50)

Loss: exponential Method: discrete   Iteration: 50 

Final Confusion Matrix for Data:
          Final Prediction
True value    No   Yes
       No  21428   515
       Yes  3960   826

Train Error: 0.167 

Out-Of-Bag Error:  0.168  iteration= 44 

Additional Estimates of number of iterations:

train.err1 train.kap1 
        41         41 

> boost.model.comparsion.5
Call:
ada(f5, data = trainAlt, iter = 50)

Loss: exponential Method: discrete   Iteration: 50 

Final Confusion Matrix for Data:
          Final Prediction
True value    No   Yes
       No  16031  1276
       Yes  3976  5446

Train Error: 0.196 

Out-Of-Bag Error:  0.201  iteration= 48 #missclass error

Additional Estimates of number of iterations:

train.err1 train.kap1 
        49         49 

> boost.misc.error
[1] 0.6130964
> boost.misc.table
                 valOsservati
valPredetti       Adoption Died Euthanasia Return_to_owner Transfer
  Adoption            1900    4         53             393      475
  Euthanasia             1    0         17               3        4
  Return_to_owner      185    1         70             437      131
  Transfer             106   37        182              98     1248


KaggleScore :  0.88321
```

## GAM normale
```
> mgam.misc.table = misc.table(mgam.predictions.comparsion.class, validation$OutcomeType)
Errore totale:  0.6138447 
> mgam.misc.error = 1 - sum(diag(mgam.misc.table))/sum(mgam.misc.table)
> mgam.misc.table
                 valOsservati
valPredetti       Adoption Died Euthanasia Return_to_owner Transfer
  Adoption            1878    2         49             394      493
  Euthanasia             1    1         17               4       11
  Return_to_owner      213    2         67             415      138
  Transfer             100   37        189             118     1216
  

```

## GAM senza breed

trovate le razze poco significative

```
> mgam.misc.table
                 valOsservati
valPredetti       Adoption Died Euthanasia Return_to_owner Transfer
  Adoption            1824    1         44             396      489
  Euthanasia             1    0         10               1        7
  Return_to_owner      267    3         67             393      147
  Transfer             100   38        201             141     1215
> mgam.mist.error
Errore: oggetto "mgam.mist.error" non trovato
> mgam.misc.error
[1] 0.6198316
```

Specificare che sarebbe più corretto fare la selezione stepwise, però che con la scusa che vengono addestrati più modelli risulta troppo onerosa perché dovrebbe essere fatta per ognuno dei modelli. 


## TODO:

- aggiungere grafico dell'errore dell'albero di classificazione
- Multiclass SVM?