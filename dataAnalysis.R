birdData <- read.csv("assets/data/birdData.csv")

summary(birdData)

# List 10 more commonly observed birds
sort(table(birdData$sciName), decreasing = TRUE)[1:10]

# List 10 more populous bird species (sum of howMany)
sort(tapply(birdData$howMany, birdData$sciName, sum), decreasing = TRUE)[1:10]

# List the most observed bird on each month
sapply(1:12, function(m) {
  sort(table(birdData$sciName[birdData$month == m]), decreasing = TRUE)[1]
})

# List the most populous bird species on each month
sapply(1:12, function(m) {
  sort(tapply(birdData$howMany[birdData$month == m], birdData$sciName[birdData$month == m], sum),
       decreasing = TRUE)[1]
})

# Plot the distribution of observations by average temperature, precipitation, wind speed and month with the values of the average, maximum and minimum values of each plot as a line
par(mfrow = c(2, 2))
barplot(
  table(birdData$tmed),
  xlab = "Average temperature",
  ylab = "Number of observations",
  col = rainbow(length(table(birdData$tmed))),
  border = NA
)
abline(h = mean(table(birdData$tmed)), col = "red")
abline(h = max(table(birdData$tmed)), col = "blue")
abline(h = min(table(birdData$tmed)), col = "green")
legend(
  "topright",
  legend = c(
    paste("Average:", round(mean(
      table(birdData$tmed)
    ), 2)),
    paste("Maximum:", max(table(birdData$tmed))),
    paste("Minimum:", min(table(birdData$tmed)))
  ),
  col = c("red", "blue", "green"),
  lty = 1:1,
  cex = 0.8
)
barplot(
  table(birdData$prec),
  xlab = "Average precipitation",
  ylab = "Number of observations",
  col = rainbow(length(table(birdData$prec))),
  border = NA
)
abline(h = mean(table(birdData$prec)), col = "red")
abline(h = max(table(birdData$prec)), col = "blue")
abline(h = min(table(birdData$prec)), col = "green")
legend(
  "topright",
  legend = c(
    paste("Average:", round(mean(
      table(birdData$prec)
    ), 2)),
    paste("Maximum:", max(table(birdData$prec))),
    paste("Minimum:", min(table(birdData$prec)))
  ),
  col = c("red", "blue", "green"),
  lty = 1:1,
  cex = 0.8
)
barplot(
  table(birdData$velmedia),
  xlab = "Average wind speed",
  ylab = "Number of observations",
  col = rainbow(length(table(birdData$velmedia))),
  border = NA
)
abline(h = mean(table(birdData$velmedia)), col = "red")
abline(h = max(table(birdData$velmedia)), col = "blue")
abline(h = min(table(birdData$velmedia)), col = "green")
legend(
  "topright",
  legend = c(
    paste("Average:", round(mean(
      table(birdData$velmedia)
    ), 2)),
    paste("Maximum:", max(table(birdData$velmedia))),
    paste("Minimum:", min(table(birdData$velmedia)))
  ),
  col = c("red", "blue", "green"),
  lty = 1:1,
  cex = 0.8
)
barplot(
  table(birdData$month),
  xlab = "Month",
  ylab = "Number of observations",
  col = rainbow(length(table(birdData$month))),
  border = NA
)
abline(h = mean(table(birdData$month)), col = "red")
abline(h = max(table(birdData$month)), col = "blue")
abline(h = min(table(birdData$month)), col = "green")
legend(
  "bottomright",
  legend = c(
    paste("Average:", round(mean(
      table(birdData$month)
    ), 2)),
    paste("Maximum:", max(table(birdData$month))),
    paste("Minimum:", min(table(birdData$month)))
  ),
  col = c("red", "blue", "green"),
  lty = 1:1,
  cex = 0.8
)
