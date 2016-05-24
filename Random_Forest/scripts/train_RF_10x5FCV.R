

pdf("Result_plot.pdf")


#############
# read data #
#############


data = read.table("Data/My_FinalSet_Training.tsv", header=T)
data$TorF= factor(data$TorF, levels=c(0,1), labels=c(F,T))
str(data) 

# data sampling
library(caret)
set.seed(780223)
in_train = createMultiFolds(data$TorF, k = 5, times = 10)

data_train = list(); data_test = list()

for (i in 1:50) {
  data_train[[i]] = data[in_train[[i]],]
  data_test[[i]] = data[-in_train[[i]],]
}

#################
# random forest #
#################

library(randomForest)
library(ROCR)

set.seed(1234)

RF_model = list();
RF_predict = list()
RF_predict_prob = list();
RF_ROC_predict = list();
RF_ROC_performance = list()

for (i in 1:50) {
  RF_model[[i]]  = randomForest(TorF ~ ., data=data_train[[i]], ntree=1000, importance =T) 
  RF_predict[[i]]      = predict(RF_model[[i]], data_test[[i]], type="class")
  RF_predict_prob[[i]] = predict(RF_model[[i]], data_test[[i]], type="prob")
}

pred.ls=list()
for (i in 1:50) {
  pred.ls[[i]]=as.numeric(predict(RF_model[[i]], data_test[[i]], type="prob")[,"TRUE"])
}

labels.ls=list()
for (i in 1:50) {
  labels.ls[[i]]=data_test[[i]]$TorF
}

RF_ROC_predict     = prediction(predictions=pred.ls, labels=labels.ls)
RF_ROC_performance = performance(RF_ROC_predict, measure="tpr", x.measure="fpr")


##################
# writing result #
##################

# Draw a plot for ROC curve (averaging 10x5fold)
plot(RF_ROC_performance, avg="threshold", spread.estimate="stderror", main="ROC curve", col="blue")
abline(a=0,b=1,lty=2)
save(RF_ROC_performance, file="Result_ROC_perf_cv5.Rdata")

RF_AUC	= performance(RF_ROC_predict, measure="auc")
auc	= as.numeric(RF_AUC@y.values)
auc.avg = mean(auc)
save(RF_AUC, file="Result_AUC_cv5.Rdata")

write(paste(nrow(data[data$TorF==TRUE,]),'\t',auc.avg), file="Result_TRUEnum_AUC.txt")
cat ("\n** AUC average : ", auc.avg, "\n\n** Variable Importance : \n")


## variable importance (averaging 10x5fold)
RF_importance_order=list()

RF_importance	= as.table(importance(RF_model[[1]],type=1))
for (i in 2:50) { RF_importance	= cbind(RF_importance,as.vector(importance(RF_model[[i]],type=1))) }

RF_importance_avg = apply(RF_importance, 1, mean)
RF_importance_order = order(RF_importance_avg, decreasing=T)

write(paste("Variable","\t",gsub("Breast_data_","",strsplit(getwd(),"/")[[1]][6])), "Result_VarImpt.txt")
write.table(RF_importance_avg, "Result_VarImpt.txt", quote=F, col.names=F, sep="\t", append=T)
as.matrix(RF_importance_avg)[RF_importance_order,]


dev.off()
