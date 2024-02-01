# install.packages("geosphere")
# install.packages("caret")
library(geosphere)
library(caret)
library(readr)

birdData <- read_csv("ebird.csv")
weatherData <- read_csv("weather.csv")

# Read coordinates as text
options(digits = 12)

# Remove unnecessary columns
birdData <- birdData[, c("obsDt", "sciName", "howMany", "locName", "lat", "lng", "exoticCategory")]

# Add numeric id to birdData to be able to clean duplicates after merge
birdData$id <- 1:nrow(birdData)

# Remove rows with missing weather data
weatherData <- weatherData[!is.na(weatherData$tmed), ]

# Convert dates to Date format
birdData$obsDt <- as.Date(birdData$obsDt)
weatherData$fecha <- as.Date(weatherData$fecha)

# Merge data, some birdData will be lost because weatherData is never up to date
birdData <- merge(birdData, weatherData, by.x = "obsDt", by.y = "fecha")

# Add column with distance from observation point to weather station
birdData$distance <- distHaversine(
  cbind(birdData$lng, birdData$lat),
  cbind(birdData$longitud, birdData$latitud)
)

# For each id keep only the row with the minimum distance
birdData <- birdData[order(birdData$distance), ]
birdData <- birdData[!duplicated(birdData$id), ]

# Remove unnecessary columns
birdData <- birdData[, c("obsDt", "sciName", "howMany", "locName", "lat", "lng", "exoticCategory", "tmed", "prec", "velmedia")]

weatherData$latitud <- as.character(weatherData$latitud)
weatherData$longitud <- as.character(weatherData$longitud)

# Divide dates into year, month and day as separate columns of integers
birdData$year <- as.integer(format(birdData$obsDt, "%Y"))
birdData$month <- as.integer(format(birdData$obsDt, "%m"))
birdData$day <- as.integer(format(birdData$obsDt, "%d"))
birdData$obsDt <- NULL

# Convert exoticCategory to one-hot encoding creating a column for each category (N, P, X)
dmy <- dummyVars(" ~ exoticCategory", data = birdData)
oh <- data.frame(predict(dmy, newdata = birdData))
# NA to 0
oh[is.na(oh)] <- 0
birdData <- cbind(birdData, oh)
birdData$exoticCategory <- NULL

# Convert NA on howMany to 1
birdData$howMany[is.na(birdData$howMany)] <- 1

# Conver NA and IP on prec to 0 and the rest to numeric using , as decimal separator
birdData$prec[is.na(birdData$prec)] <- 0
birdData$prec[birdData$prec == "Ip"] <- 0
birdData$prec <- as.numeric(gsub(",", ".", birdData$prec))

# Convert NA on velmedia to the median
birdData$velmedia[is.na(birdData$velmedia)] <- median(birdData$velmedia, na.rm = TRUE)

# Describe birdData
summary(birdData)

# Save birdData
write.csv(birdData, "birdData.csv", row.names = FALSE)

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
