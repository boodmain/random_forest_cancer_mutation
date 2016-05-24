
args <- commandArgs(trailingOnly = TRUE)
train_filename        = args[1]
predict_filename      = args[2]
result_class_filename = args[3]
result_prob_filename  = args[4]



#############
# read data #
#############

data_train = read.table(train_filename, header=T)
data_train$TorF= factor(data_train$TorF, levels=c(0,1), labels=c(F,T))


#######################
# train random forest #
#######################

library(randomForest)
set.seed(780223)

#train
RF_model	= randomForest(TorF ~ ., data=data_train, ntree=1000, importance=FALSE)



#####################
# Predict mutations #
#####################

data_predict = read.table(predict_filename, header=TRUE)

data_class  = predict(RF_model, data_predict, type="class")
data_prob   = predict(RF_model, data_predict, type="prob")


write.table(data_class, file=result_class_filename, sep="\t", quote=F, row.names=F)
write.table(data_prob,  file=result_prob_filename,  sep="\t", quote=F, row.names=F)

