birdData <- read.csv("assets/data/birdData.csv")

# drop locName column
birdData$locName <- NULL

# drop howMany column
# birdData$howMany <- NULL

# drop the exoticCategory columns
birdData$exoticCategoryN <- NULL
birdData$exoticCategoryP <- NULL
birdData$exoticCategoryX <- NULL

# drop lat, prec, velmedia, tmed, day and scriName columns
birdData$lat <- NULL
birdData$prec <- NULL
birdData$velmedia <- NULL
birdData$tmed <- NULL
birdData$day <- NULL
birdData$sciName <- NULL

# find outliers on howMany
boxplot(birdData$howMany)

# remove rows outliers
birdData <- birdData[birdData$howMany < 5, ]

# drop the date columns
# birdData$year <- NULL
# birdData$month <- NULL
# birdData$day <- NULL

# scale data
birdData[, -which(names(birdData) == "howMany")] <- scale(birdData[, -which(names(birdData) == "howMany")])

# count the number of unique species
length(unique(birdData$sciName))

# use the elbow method to find the optimal number of clusters
wcss <- vector()
for (i in 1:10) {
  wcss[i] <- sum(kmeans(birdData[, -which(names(birdData) == "sciName")], i)$withinss)
}

plot(1:10, wcss, type = "b", xlab = "Number of clusters", ylab = "WCSS")

# train a k-means model
kmeansModel <- kmeans(birdData[, -which(names(birdData) == "sciName")], 5)

# find what species are in each cluster
speciesInCluster <- data.frame(sciName = birdData$sciName, cluster = kmeansModel$cluster)

# remove duplicates
speciesInCluster <- unique(speciesInCluster)

# plot the clusters on a map
plot(birdData$lng, birdData$lat, col = kmeansModel$cluster, pch = 20, main = "Clusters of Bird Species", xlab = "Longitude", ylab = "Latitude")

# plot a venn diagram of the species in each cluster without logging the output
library(VennDiagram)
vennDiagram <- venn.diagram(
  x = list(
    speciesInCluster[speciesInCluster$cluster == 1, "sciName"],
    speciesInCluster[speciesInCluster$cluster == 2, "sciName"],
    speciesInCluster[speciesInCluster$cluster == 3, "sciName"],
    speciesInCluster[speciesInCluster$cluster == 4, "sciName"],
    speciesInCluster[speciesInCluster$cluster == 5, "sciName"]
  ),
  category.names = c("Cluster 1", "Cluster 2", "Cluster 3", "Cluster 4", "Cluster 5"),
  filename = NULL,
  disable.logging = TRUE
)

grid.draw(vennDiagram)

# find how many times each species appears in each cluster
speciesInCluster <- aggregate(sciName ~ cluster + sciName, speciesInCluster, length)

# cross validation
library(caret)

trainControl <- trainControl(
  method = "cv",
  number = 10
)

# train a linear regression model
linearRegressionModel <- train(
  howMany ~ .,
  data = birdData,
  method = "lm",
  trControl = trainControl
)

# summarize linear regression model
print(linearRegressionModel)

# train a neural network
library(neuralnet)

# split the data into training and testing sets
set.seed(123)
trainingIndices <- createDataPartition(birdData$howMany, p = 0.8, list = FALSE)
trainingData <- birdData[trainingIndices, ]
testingData <- birdData[-trainingIndices, ]

neneuralNetModel <- neuralnet(
  howMany ~ .,
  data = trainingData,
  hidden = 2,
  linear.output = TRUE
)

# test the neural network
predictedValues <- compute(neneuralNetModel, testingData[, -which(names(testingData) == "howMany")])

# mean absolute error
mean(abs(predictedValues$net.result - testingData$howMany))

# root mean squared error
sqrt(mean((predictedValues$net.result - testingData$howMany)^2))

# plot the neural network
plot(neneuralNetModel)
