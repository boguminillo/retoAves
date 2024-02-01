# install.packages("geosphere")
library(geosphere)

birdData <- read.csv("ebird.csv", header = TRUE, sep = ",")
weatherData <- read.csv("weather.csv", header = TRUE, sep = ",")
# Add numeric id to birdData to be able to clean duplicates after merge
birdData$id <- 1:nrow(birdData)

# Merge data, some birdData will be lost because weatherData is never up to date
birdData$obsDt <- as.Date(birdData$obsDt)
weatherData$fecha <- as.Date(weatherData$fecha)
birdData <- merge(birdData, weatherData, by.x = "obsDt", by.y = "fecha")

# Add column with distance from observation point to weather station
birdData$distance <- distHaversine(
  cbind(birdData$lng, birdData$lat),
  cbind(birdData$longitud, birdData$latitud)
)

# For each id keep only the row with the minimum distance
birdData <- birdData[order(birdData$distance), ]
birdData <- birdData[!duplicated(birdData$id), ]

# system.time({
#   library(dplyr)
#   birdDataDplyr <- birdData %>% group_by(id) %>% slice(which.min(distance))
# })
# 
# system.time({
#   birdDataSystem <- birdData[order(birdData$distance), ]
#   birdDataSystem <- birdDataSystem[!duplicated(birdDataSystem$id), ]
# })
# birdDataSystem <- birdDataSystem[order(birdDataSystem$id), ]
# all.equal(birdDataDplyr, birdDataSystem)
