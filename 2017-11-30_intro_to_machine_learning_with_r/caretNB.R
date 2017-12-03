# libraries needed by caret
library(klaR)
library(MASS)
# for the Naive Bayes modelling
library(caret)
# to process the text into a corpus
library(tm)
# to get nice looking tables
library(pander)
# to simplify selections
library(dplyr)


# a utility function for % freq tables
frqtab <- function(x, caption) {
  round(100*prop.table(table(x)), 1)
}
# utility function to summarize model comparison results
sumpred <- function(cm) {
  summ <- list(TN=cm$table[1,1],  # true negatives
               TP=cm$table[2,2],  # true positives
               FN=cm$table[1,2],  # false negatives
               FP=cm$table[2,1],  # false positives
               acc=cm$overall["Accuracy"],  # accuracy
               sens=cm$byClass["Sensitivity"],  # sensitivity
               spec=cm$byClass["Specificity"])  # specificity
  lapply(summ, FUN=round, 2)
}
# if (!file.exists("smsspamcollection.zip")) {
#   download.file(url="http://www.dt.fee.unicamp.br/~tiago/smsspamcollection/smsspamcollection.zip",
#                 destfile="smsspamcollection.zip", method="curl")
# }
# sms_raw <- read.table(unz("smsspamcollection.zip","SMSSpamCollection"),
#                       header=FALSE, sep="\t", quote="", stringsAsFactors=FALSE)
sms_raw <- read.csv("C:/Users/gfeng/Documents/_datascience/Machine-Learning-with-R-datasets-master/sms_spam.csv", stringsAsFactors=FALSE)
#sms_raw <- sms_raw[1:10, ]
colnames(sms_raw) <- c("type", "text")
sms_raw$type <- factor(sms_raw$type)
# randomize it a bit
set.seed(12358)
sms_raw <- sms_raw[sample(nrow(sms_raw)),]
str(sms_raw)

sms_corpus <- Corpus(VectorSource(sms_raw$text))
sms_corpus_clean <- sms_corpus %>%
  tm_map(content_transformer(tolower)) %>% 
  tm_map(removeNumbers) %>%
  tm_map(removeWords, stopwords(kind="en")) %>%
  tm_map(removePunctuation) %>%
  tm_map(stripWhitespace)
sms_dtm <- DocumentTermMatrix(sms_corpus_clean)

train_index <- createDataPartition(sms_raw$type, p=0.75, list=FALSE)
sms_raw_train <- sms_raw[train_index,]
sms_raw_test <- sms_raw[-train_index,]
sms_corpus_clean_train <- sms_corpus_clean[train_index]
sms_corpus_clean_test <- sms_corpus_clean[-train_index]
sms_dtm_train <- sms_dtm[train_index,]
sms_dtm_test <- sms_dtm[-train_index,]

ft_orig <- frqtab(sms_raw$type)
ft_train <- frqtab(sms_raw_train$type)
ft_test <- frqtab(sms_raw_test$type)
ft_df <- as.data.frame(cbind(ft_orig, ft_train, ft_test))
colnames(ft_df) <- c("Original", "Training set", "Test set")
pander(ft_df, style="rmarkdown",
       caption=paste0("Comparison of SMS type frequencies among datasets"))
sms_dict <- findFreqTerms(sms_dtm_train, lowfreq=5)
sms_train <- DocumentTermMatrix(sms_corpus_clean_train, list(dictionary=sms_dict))
sms_test <- DocumentTermMatrix(sms_corpus_clean_test, list(dictionary=sms_dict))

# modified sligtly fron the code in the book
convert_counts <- function(x) {
  x <- ifelse(x > 0, 1, 0)
  x <- factor(x, levels = c(0, 1), labels = c("Absent", "Present"))
}
sms_train <- sms_train %>% apply(MARGIN=2, FUN=convert_counts)
sms_test <- sms_test %>% apply(MARGIN=2, FUN=convert_counts)

ctrl <- trainControl(method="cv", 10)
set.seed(12358)
sms_model1 <- train(sms_train, sms_raw_train$type, method="nb",
                    trControl=ctrl)
sms_test_pred <- predict(sms_model1, sms_test)
library(gmodels)
CrossTable(sms_test_pred, sms_raw_test$type,
           prop.chisq = FALSE, prop.t = FALSE,
           dnn = c('predicted', 'actual'))