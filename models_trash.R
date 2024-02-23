library(caret)

birdData <- read.csv("assets/data/birdData.csv")

# drop locName column
birdData$locName <- NULL

# get the 50 more common species and remove the rest
species <- sort(table(birdData$sciName), decreasing = TRUE)[1:50]
birdData <- birdData[birdData$sciName %in% names(species), ]

# transform the sciName column to a factor
birdData$sciName <- as.factor(birdData$sciName)

# split the data into training and testing sets
set.seed(123)
trainingIndex <- createDataPartition(birdData$howMany, p = 0.8, list = FALSE)
training <- birdData[trainingIndex, ]
testing <- birdData[-trainingIndex, ]

# train a logistic regression model
logisticModel <- glm(sciName ~ ., data = training, family = "gaussian")

# test the model
logisticPredictions <- predict(logisticModel, testing)


# # drop the sciName column
# birdData$sciName <- NULL
# 
# # drop the exoticCategory columns
# birdData$exoticCategoryN <- NULL
# birdData$exoticCategoryP <- NULL
# birdData$exoticCategoryX <- NULL
# 
# # goup the data by date and cooridnates and sum the howMany column
# birdData <- aggregate(howMany ~ ., birdData, sum)
# 
# # scale all the data except the howMany column
# birdData[, -which(names(birdData) == "howMany")] <- scale(birdData[, -which(names(birdData) == "howMany")])
# 
# # split the data into training and testing sets
# set.seed(123)
# trainingIndex <- createDataPartition(birdData$howMany, p = 0.8, list = FALSE)
# training <- birdData[trainingIndex, ]
# testing <- birdData[-trainingIndex, ]
# 
# # train a linear regression model
# lmModel <- train(howMany ~ ., data = training, method = "lm")
# 
# # test the model
# lmPredictions <- predict(lmModel, testing)
# 
# # Mean Absolute Error
# lmMae <- mean(abs(lmPredictions - testing$howMany))
# 
# # Root Mean Squared Error
# lmRmse <- sqrt(mean((lmPredictions - testing$howMany)^2))
# 
# # train a decision tree model
# treeModel <- train(howMany ~ ., data = training, method = "rpart")
# 
# # test the model
# treePredictions <- predict(treeModel, testing)
# 
# # Mean Absolute Error
# treeMae <- mean(abs(treePredictions - testing$howMany))
# 
# # Root Mean Squared Error
# treeRmse <- sqrt(mean((treePredictions - testing$howMany)^2))
