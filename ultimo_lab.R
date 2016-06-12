#-----------------------------------------------
#esercitazione del 30-5-2016 per il corso di Data mining - AA2015/2016
# esercizi su classificazione - dati di un'azienda di telecomunicazioni
# b. scarpa
#-----------------------------------------------
#
#
#importazione dei dati in R
#
tele.stima <- read.table("telekom.stima.dat")
tele.v <- read.table("telekom.verifica.dat")
#
#
#creazione delle variabili fattore
#
tele.stima$status <- factor(tele.stima$status)
tele.v$status <- factor(tele.v$status)
tele.stima$piano.tariff <- factor(tele.stima$piano.tariff)
tele.v$piano.tariff <- factor(tele.v$piano.tariff)
tele.stima$canale.attivaz <- factor(tele.stima$canale.attivaz)
tele.v$canale.attivaz <- factor(tele.v$canale.attivaz)
tele.stima$zona.attivaz <- factor(tele.stima$zona.attivaz)
tele.v$zona.attivaz <- factor(tele.v$zona.attivaz)
#
#creo campione bilanciato
#
tele1 <- tele.stima[tele.stima$status==1, ]
tele0 <- tele.stima[tele.stima$status==0, ]
set.seed(12345)
acaso <- sample(1:nrow(tele0), nrow(tele1))
tele0.s <- tele0[acaso, ]
tele.s <- rbind(tele1, tele0.s)
#
g <- as.numeric(tele.v$status==1)
#
churn <- as.numeric(tele.s$status==1)
#
f1 <-  as.formula(paste("status~", paste(names(tele.s)[-c(1:2)], 
                      collapse="+"),  collapse=NULL))
f0 <-  as.formula(paste("churn~", paste(names(tele.s)[-c(1:2)], 
                      collapse="+"),  collapse=NULL))

#-----------------------------------------------
#modello logistica - (a1)
#-----------------------------------------------
#	
m1 <-  glm(f1, family=binomial, data=tele.s)
p1 <- predict(m1, newdata=tele.v, type="response")
#
source("lift-roc1.R")
tabella.sommario(p1>0.5,tele.v$status)
a1 <- lift.roc(p1, g, type="crude")
#
#-----------------------------------------------
#modello logistico con tutto il dataset di train - (a1b)
#-----------------------------------------------
#
m2 <-  glm(f1, family=binomial, data=tele.stima)
p1b<- predict(m2, newdata=tele.v, type="response")
#
tabella.sommario(p1b>0.5,tele.v$status)
a1b <- lift.roc(p1b, g, type="crude")
#
#selezione stepwise delle variabili
m2step <- step(m2,direction="both")
#-----------------------------------------------
#modello lineare - (a2)
#-----------------------------------------------
#
l1 <-  lm(f0, data=tele.s)
summary(l1) 
p2 <- predict(l1, newdata=tele.v)
#
tabella.sommario(p2>0.5,tele.v$status)
a2 <- lift.roc(p2, g, type="crude")
# 
#-----------------------------------------------
#modello lineare con tutto il dataset di train - (a2b)
#-----------------------------------------------
#
churn<-as.numeric(tele.stima$status==1)
l2 <-  lm(f0, data=tele.stima)
p2b <- predict(l2, newdata=tele.v)
#
tabella.sommario(p2b>0.5,tele.v$status)
a2b <-lift.roc(p2b, g, type="crude")
#

#-----------------------------------------------
#tree - (a5)
#-----------------------------------------------
#
library(tree)
set.seed(123)
parte1 <- sample(1:NROW(tele.s), 3000) 
parte2 <- setdiff(1:NROW(tele.s), parte1)
#
t1 <- tree(f1, data=tele.s[parte1,],
         control=tree.control(nobs=length(parte1), minsize=2, mindev=0.002))
plot(t1)
text(t1,cex=0.6)
#
t2 <- prune.tree(t1, newdata=tele.s[parte2,])
plot(t2)
J <- t2$size[t2$dev==min(t2$dev)]
#
t3<-prune.tree(t1, best=J)
plot(t3)
text(t3,cex=0.8)
#
pp5<- predict(t3, newdata=tele.v, type="class")
tabella.sommario(pp5,tele.v$status)
p5 <-  predict(t3, newdata=tele.v, type="vector")[,2]
a5 <- lift.roc(p5,g,type="crude")
#
#-----------------------------------------------
#tree con tutto dataset di train - (a5b)
#-----------------------------------------------
#
set.seed(123)
parte1<- sample(1:NROW(tele.stima), 8000) 
parte2<- setdiff(1:NROW(tele.stima), parte1)
#
t1b<- tree(f1, data=tele.stima[parte1,],
         control=tree.control(nobs=length(parte1), minsize=2, mindev=0.002))
plot(t1b)
text(t1b,cex=0.8)
t2b<- prune.tree(t1b, newdata=tele.stima[parte2,])
plot(t2b)
J <- t2b$size[t2b$dev==min(t2b$dev)]
#
t3b<-prune.tree(t1b, best=J)
plot(t3b)
text(t3b)
#
pp5b<- predict(t3b, newdata=tele.v, type="class")
tabella.sommario(pp5b,tele.v$status)
p5b <-  predict(t3b, newdata=tele.v, type="vector")[,2]
a5b <- lift.roc(p5b,g,type="crude")

#-------------------------------------------------

#-------------------------------------------------
#mars
#-------------------------------------------------
#

library(polspline)
mars2<-polyclass(tele.s$status,tele.s[,-c(1,2)])
p6<-ppolyclass(tele.v[,-c(1,2)],mars2)[,2]
tabella.sommario(p6>0.5, tele.v$status)
a6<- lift.roc(p6, g, type="crude")


#----------------
#neural net - (a7)
#-----------------
library(nnet)

set.seed(123)
cb1 <- sample(1:NROW(tele.s), 3000) 
cb2 <- setdiff(1:NROW(tele.s), cb1)
####
#prima prova...che e' definitiva!!!

n1<- nnet(f1, data=tele.s[cb1,], decay=0.0016, size=5,
             maxit=100,  trace=FALSE)
  p1n<- predict(n1, newdata=tele.s[cb2,], type="class")
  a<- tabella.sommario(p1n, tele.s[cb2,]$status)
  errore <-  1-sum(diag(a))/sum(a)

#---
#selezione del weight decay
#ci mette molto tempo
#---
decay<- 10^(seq(-3, -1, length=10))
err <- rep(0,10)
set.seed(123)
for(k in 1:10){
   n1<- nnet(f1, data=tele.s[cb1,], decay=decay[k], size=5,
              maxit=1200,  trace=FALSE)
   p1n<- predict(n1, newdata=tele.s[cb2,], type="class")
   a<- tabella.sommario(p1n, tele.s[cb2,]$status)
   err[k] <-  1-sum(diag(a))/sum(a)
   print(c(err[k], decay[k]))
}
#
#minimo in 0.0016
#
n2<- nnet(f1, data=tele.s[cb1,], decay=0.0016, size=5,  maxit=1000)
p7<- predict(n1, newdata=tele.v, type="class")
#
tabella.sommario(p7,tele.v$status)
a7<- lift.roc(p7, g, type="crude")

#------------
#GAM
#------------
# 
library(gam)
#-------
#esercizio di con poche variabili esplicative, da usare a lezione
#
fg1 <- as.formula(paste("status~s(", paste(names(tele.v[11:15]), collapse=")+s("),")+ 
          piano.tariff+ metodo.pagamento+ etacl+ zona.attivaz+ 
          canale.attivaz + vas1 + vas2"))
gam1 <-  gam(fg1, family=binomial, data=tele.s)
p8 <- predict(gam1,newdata=tele.v,type="response")
#
err.gamc1 <- tabella.sommario(p8>0.5,tele.v$status)
err.gamc1
#
summary(gam1)
plot(gam1, ask=T)

a8<- lift.roc(p8, g, type="crude")


#----
#gam con tutte le variabili esplicative, 
#----
fg2 <- as.formula(paste("status~s(", paste(names(train), collapse=")+s("),")"))
fg2 <- as.formula(paste("status~s(", paste(names(tele.v[11:(NCOL(tele.v))]), collapse=")+s("),")+ 
          piano.tariff+ metodo.pagamento+ etacl+ zona.attivaz+ canale.attivaz + vas1 + vas2"))
gam2 <-  gam(fg2, family=binomial, data=tele.s)
p.gam2.c <- predict(gam2,newdata=tele.v,type="response")
#
err.gamc2 <- tabella.sommario(p.gam2.c>0.5,tele.v$status)
err.gamc2
#
summary(gam2)
a8b<- lift.roc(p.gam2.c, g, type="crude")

#------------------------------------------
#confronti finali
#------------------------------------------
##
#---------
#tabella 
#---------
#

#logistica bil 
et1<-tabella.sommario(p1>0.5,tele.v$status)
e1<- 1-sum(diag(et1))/sum(et1)
#logistica non bil 
et2<-tabella.sommario(p1b>0.5,tele.v$status)
e2<- 1-sum(diag(et2))/sum(et2)
#lineare bil
et3<-tabella.sommario(p2>0.5,tele.v$status)
e3<- 1-sum(diag(et3))/sum(et3)
#lineare non bil
et4<-tabella.sommario(p2b>0.5,tele.v$status)
e4<- 1-sum(diag(et4))/sum(et4)

#mars
et6 <-tabella.sommario(p6>0.5,tele.v$status)
e6<- 1-sum(diag(et6))/sum(et6)
#tree bil
et7 <-tabella.sommario(pp5,tele.v$status)
e7<- 1-sum(diag(et7))/sum(et7)
#tree non bil
et8 <- tabella.sommario(pp5b,tele.v$status)
e8<- 1-sum(diag(et8))/sum(et8)
#nnet
et10 <- tabella.sommario(p7>0.5,tele.v$status)
e10<- 1-sum(diag(et10))/sum(et10)
#gam 1
et12 <- tabella.sommario(p8>0.5,tele.v$status)
e12<- 1-sum(diag(et12))/sum(et12)

nomi<- c("modello lineare bilanciato","modello lineare non bilanciato", "regressione logistica bilanciata", 
          "regressione logistica non bilanciato","MARS","GAM",
         "albero di classificazione", "albero di classificazione non bilanciato",
        "rete neurale")
#
tabella.confronto <- data.frame(nomi=nomi,err.q=100*rbind(e3,e4, e1, e2,  e6,e12,
                           e7, e8,e10))
#

#------------
#per i lift crude
#------------

#logistica bil 
a1<- lift.roc(p1, g, type="crude")
#logistica non bil 
a1b<- lift.roc(p1b, g, type="crude")
#lineare bil
a2<-lift.roc(p2, g, type="crude")
#lineare non bil
a2b<-lift.roc(p2b, g, type="crude")
#tree bil
a5 <- lift.roc(p5,g,type="crude")
#tree non bil
a5b <- lift.roc(p5b,g,type="crude")
#mars
a6<- lift.roc(p6, g, type="crude")
#nnet
a7<- lift.roc(p7, g, type="crude")

#gam 1
a8 <- lift.roc(p8, g, type="crude")


plot(a1[[1]], a1[[2]], type="l", 
xlim=c(0,0.2),         ylim=c(0,5.4), 
  cex=0.75, col=1, pch=1,
      xlab="frazione di soggetti previsti", ylab="fattore di miglioramento")
lines(a1b[[1]], a1b[[2]], type="l", cex=0.75, col=2, lty=3, pch=8)
lines(a2[[1]], a2[[2]], type="l", cex=0.75, col=2, lty=2, pch=2)
lines(a2b[[1]], a2b[[2]], type="l", cex=0.75, col=1, lty=3,pch=9)
lines(a3[[1]], a3[[2]], type="l", cex=0.75,  col=3, pch=7,lty=2)
lines(a5[[1]], a5[[2]], type="l", cex=0.75, col=4,lty=1, pch=4)
lines(a5b[[1]],a5b[[2]], type="l", cex=0.75, col=6,lty=1, pch=4)
lines(a6[[1]], a6[[2]], type="l", cex=0.75, col=2,lty=1, pch=3)
lines(a7[[1]], a7[[2]], type="l", cex=0.75, col=5,lty=1, pch=7)
lines(a8[[1]], a8[[2]], type="l", cex=0.75,  lty=2, pch=3, col=1)
#

legend(0.08,5.4,c("modello logistico bilanciato","modello logistico non bilanciato               ", 
                 "modello lineare bilanciato", "modello lineare non bilanciato",
                 "albero di classificazione","albero di classificazione bil","MARS","GAM1",
                "rete neurale"),
                col=c(1,2,2,1,3,4,6,2,5,1),
                lty=c(1,3,2,3,2,1,1,1,1))

#
#------------
#per i lift bin
#------------

#logistica bil 
a1<- lift.roc(p1, g, type="bin")
#logistica non bil 
a1b<- lift.roc(p1b, g, type="bin")
#lineare bil
a2<-lift.roc(p2, g, type="bin")
#lineare non bil
a2b<-lift.roc(p2b, g, type="bin")
#tree bil
a5 <- lift.roc(p5,g,type="bin")
#tree non bil
a5b <- lift.roc(p5b,g,type="bin")
#mars
a6<- lift.roc(p6, g, type="bin")
#nnet
a7<- lift.roc(p7, g, type="bin")

#gam 1
a12 <- lift.roc(p8, g, type="bin")
#gam 2
a13 <- lift.roc(p.gam2.c, g, type="bin")


#----------------
#confronti lift bin
#----------------
#
plot(a1[[1]], a1[[2]], type="b", 
#xlim=c(0,0.2),         ylim=c(0,5.4), 
  cex=0.75, col=1, pch=1,
      xlab="frazione di soggetti previsti", ylab="fattore di miglioramento")
lines(a1b[[1]], a1b[[2]], type="b", cex=0.75, col=2, lty=3, pch=8)
lines(a2[[1]], a2[[2]], type="b", cex=0.75, col=2, lty=2, pch=2)
lines(a2b[[1]], a2b[[2]], type="b", cex=0.75, col=1, lty=3,pch=9)
lines(a3[[1]], a3[[2]], type="b", cex=0.75,  col=3, pch=7,lty=2)
lines(a5[[1]], a5[[2]], type="b", cex=0.75, col=4,lty=1, pch=4)
lines(a5b[[1]], a5b[[2]], type="l", cex=0.75, col=6,lty=1, pch=4)
lines(a6[[1]], a6[[2]], type="b", cex=0.75, col=2,lty=1, pch=3)
lines(a7[[1]], a7[[2]], type="b", cex=0.75, col=5,lty=1, pch=7)
lines(a12[[1]], a12[[2]], type="b", cex=0.75,  lty=2, pch=3, col=1)
lines(a13[[1]], a13[[2]], type="b", cex=0.75, col=2, lty=1,pch=3)
#
legend(0.2,7.2,c("modello logistico bilanciato","modello logistico non bilanciato               ", 
                 "modello lineare bilanciato", "modello lineare non bilanciato",
                "analisi discriminante", 
                "albero di classificazione","albero di classificazione bil","MARS","GAM1",
                "rete neurale"),
                col=c(1,2,2,1,3,4,6,2,2,5),
                lty=c(1,3,2,3,2,1,1,1,1),pch=c(1, 8, 2, 9, 7, 4,3, 3, 3,7))
#

#----------------------------------
#combinazione di modelli
#----------------------------------
#----------------
#random forest
#----------------
library (randomForest)

set.seed(123)
 rf2a<- randomForest(f1, data=tele.s[cb1,2:110],nodesize=1,
                     xtest=tele.s[cb2,3:110], ytest=tele.s[cb2,2], mtry=5)
plot(rf2a)

set.seed(123)
 rf2b<- randomForest(f1, data=tele.s[cb1,2:110],nodesize=1, mtry=50)
plot(rf2b)

#
#------
#provare con altri valori di mtry confrontando i risultati su cb2
#
#------
#------
#scelgo mtry=50
#
#
set.seed(123)
rf2b<- randomForest(f1, data=tele.s[cb1,2:110], nodesize=1, mtry=50)

p.rf2<-predict(rf2b,newdata=tele.v[,3:110])
p.prob.rf2<-predict(rf2b,newdata=tele.v[,3:110], type="prob")

tabella.sommario(p.rf2,osserv=tele.v$status)
#rf lift roc
a21 <- lift.roc(p.prob.rf2[,2], g, type="bin")


########################
##       Bagging      ##
########################


library(ipred)

# nbag= numero di alberi da costruire
# coob= Calcola l'out of bag; cioË scelgo le osservazioni non scelte dal primo bootstrap come insieme di valutazione

set.seed(123)
bagc1<- bagging(status~.,data=tele.s[,2:110],nbagg=25)
pbagc1<-predict(bagc1,newdata=tele.v)
tab.bag1<-tabella.sommario(pbagc1, tele.v$status)
pbagc1.prob <-predict(bagc1,newdata=tele.v, type="prob")[,2]


bagc2<- bagging(status~.,data=tele.s[,2:110],nbagg=50)
pbagc2<-predict(bagc2,newdata=tele.v)
tab.bag2<-tabella.sommario(pbagc2, tele.v$status)



set.seed(123)
bagc3<- bagging(status~.,data=tele.s[,2:110],nbagg=25, control=rpart.control(minsplit=2, cp=0, xval=0))
pbagc3<-predict(bagc3,newdata=tele.v)
tab.bag3<-tabella.sommario(pbagc3, tele.v$status)
pbagc3.prob <-predict(bagc3,newdata=tele.v, type="prob")
#bag lift roc
a22 <- lift.roc(pbagc1.prob, g, type="bin")

#---
#
#---

#-----------
#boosting
#-----------

library(ada)
adab1<-ada(status~., data=tele.s, iter=50)
p.adab1 <- predict(adab1, newdata=tele.v)
tabella.sommario(p.adab1, osserv=tele.v$status)


plot(adab1)
plot(adab1, F,T)
p.adab1 <- predict(adab1, newdata=tele.v)
tabella.sommario(p.adab1, osserv=tele.vstatust)
p.prob.adab1 <- predict(adab1, newdata=tele.v, type="prob")[,2]

#boost lift roc
a23 <- lift.roc(p.prob.adab1, g, type="bin")



#-----------------------------
#lift bin
#-----------------------------


#rf lift roc
a21 <- lift.roc(p.prob.rf2[,2], g, type="bin")
#bag lift roc
a22 <- lift.roc(pbagc1.prob, g, type="bin")
#boost lift roc
a23 <- lift.roc(p.prob.adab1, g, type="bin")
#mars
a6<- lift.roc(p6, g, type="bin")

#per lift
plot(a21[[1]], a21[[2]], type="l", 
xlim=c(0,1),         ylim=c(0,7.5), 
  cex=0.75, col=1, pch=1,
      xlab="frazione di soggetti previsti", ylab="fattore di miglioramento")
lines(a22[[1]], a22[[2]], type="l", cex=0.75, col=2, lty=3, pch=8)
lines(a23[[1]], a23[[2]], type="l", cex=0.75, col=3, lty=2, pch=2)
lines(a6[[1]], a6[[2]], type="l", cex=0.75, col=4, lty=3,pch=9)

#

legend(0.6,7.5,c("random forest","bagging               ", 
                 "boosting", "MARS"),
                col=c(1,2,3,4),
                lty=c(1,3,2,3))


#-----------------------------
#lift crude
#-----------------------------


#rf lift roc
a21 <- lift.roc(p.prob.rf2[,2], g, type="crude")
#bag lift roc
a22 <- lift.roc(pbagc1.prob, g, type="crude")
#boost lift roc
a23 <- lift.roc(p.prob.adab1, g, type="crude")
#mars
a6<- lift.roc(p6, g, type="crude")

#per lift
plot(a21[[1]], a21[[2]], type="l", 
xlim=c(0,0.2),         ylim=c(0,7.5), 
  cex=0.75, col=1, pch=1,
      xlab="frazione di soggetti previsti", ylab="fattore di miglioramento")
lines(a22[[1]], a22[[2]], type="l", cex=0.75, col=2, lty=3, pch=8)
lines(a23[[1]], a23[[2]], type="l", cex=0.75, col=3, lty=2, pch=2)
lines(a6[[1]], a6[[2]], type="l", cex=0.75, col=4, lty=3,pch=9)

#

legend(0.08,7.5,c("random forest","bagging               ", 
                 "boosting", "MARS"),
                col=c(1,2,3,4),
                lty=c(1,3,2,3))



