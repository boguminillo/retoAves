library(caret)

birdData <- read.csv("assets/data/birdData.csv")

# drop locName column
birdData$locName <- NULL

# drop the sciName column
birdData$sciName <- NULL

# drop the exoticCategory columns
birdData$exoticCategoryN <- NULL
birdData$exoticCategoryP <- NULL
birdData$exoticCategoryX <- NULL

# goup the data by date and cooridnates and sum the howMany column
birdData <- aggregate(howMany ~ ., birdData, sum)

# scale all the data except the howMany column
birdData[, -which(names(birdData) == "howMany")] <- scale(birdData[, -which(names(birdData) == "howMany")])

# split the data into training and testing sets
set.seed(123)
trainingIndex <- createDataPartition(birdData$howMany, p = 0.8, list = FALSE)
training <- birdData[trainingIndex, ]
testing <- birdData[-trainingIndex, ]

# train the model
library(neuralnet)
model <- neuralnet(howMany ~ ., data = training, hidden = 5, act.fct = "tanh")

# make predictions
predictions <- predict(model, testing)

# calculate the RMSE
RMSE(predictions, testing$howMany)


# # Get the names of the 50 most common birds
# commonBirds <- names(sort(tapply(birdData$howMany, birdData$sciName, sum), decreasing = TRUE))[1:10]
# 
# # remove all birds that are not in the 50 most common
# birdData <- birdData[birdData$sciName %in% commonBirds, ]
# 
# # convert sciName to labels
# birdData$sciName <- as.factor(birdData$sciName)


