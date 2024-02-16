# https://cran.r-project.org/web/packages/meteospain/vignettes/aemet.html
# store apy key in keyring
# install.packages(c("keyring", "httr", "climaemet"))
library(keyring)
# key_set(service = 'ebird')
# key_set(service = 'aemet')
library(httr)
library(climaemet)


# headers with the api key
# headers = c('X-eBirdApiToken' = key_get(service = "ebird"))

# list of region codes for Spanish communities
# res <- VERB("GET", url = "https://api.ebird.org/v2/ref/region/list/subnational1/ES", add_headers(headers))
# list of region codes for Spanish provinces
# res <- VERB("GET", url = "https://api.ebird.org/v2/ref/region/list/subnational2/ES", add_headers(headers))
# cat(content(res, "text"))

# res <-
#   VERB("GET", url = "https://api.ebird.org/v2/data/obs/ES-PV/historic/2024/1/26", add_headers(headers))

# Documentation for aemet_daily_clim(...)
# meta <- aemet_daily_clim(extract_metadata = TRUE)

getLastDateEbird <- function() {
  lastDate <- NULL
  if (file.exists("assets/data/ebird.csv")) {
    # read last date from file
    df <- read.csv("assets/data/ebird.csv")
    lastDate <- as.Date(tail(df$obsDt, 1))
  }
  return(lastDate)
}

getLastDateWeather <- function() {
  lastDate <- NULL
  if (file.exists("assets/data/weather.csv")) {
    # read last date from file
    df <- read.csv("assets/data/weather.csv")
    lastDate <- as.Date(tail(df$fecha, 1))
  }
  return(lastDate)
}

updateBirdData <- function(fromDate = as.Date("2010-01-01")) {
  library(jsonlite)
  colnames <-
    c(
      "speciesCode",
      "comName",
      "sciName",
      "locId",
      "locName",
      "obsDt",
      "howMany",
      "lat",
      "lng",
      "obsValid",
      "obsReviewed",
      "locationPrivate",
      "subId",
      "exoticCategory"
    )
  if (!file.exists("assets/data/ebird.csv")) {
    # create empty file and write headers
    df <- data.frame(matrix(ncol = length(colnames), nrow = 0))
    colnames(df) <- colnames
    write.table(
      df,
      "assets/data/ebird.csv",
      sep = ",",
      row.names = FALSE,
      col.names = colnames
    )
  }
  headers = c('X-eBirdApiToken' = key_get(service = "ebird"))
  while (fromDate < Sys.Date()) {
    # get data
    res <-
      VERB(
        "GET",
        url = paste0(
          "https://api.ebird.org/v2/data/obs/ES-PV/historic/",
          gsub("-", "/", as.character(fromDate))
        ),
        add_headers(headers)
      )
    # convert to data frame
    dfTemp <- fromJSON(content(res, "text"), flatten = TRUE)
    if (!is.null(nrow(dfTemp))) {
      # add missing columns
      for (name in colnames) {
        if (!(name %in% colnames(dfTemp))) {
          dfTemp[[name]] <- NA
        }
      }
      # reorder columns
      dfTemp <- dfTemp[, colnames]
      # append to file
      write.table(
        dfTemp,
        "assets/data/ebird.csv",
        sep = ",",
        row.names = FALSE,
        col.names = !file.exists("assets/data/ebird.csv"),
        append = T
      )
    }
    fromDate <- fromDate + 1
  }
}

updateWeatherData <- function(fromDate = as.Date("2010-01-01")) {
  colnames <-
    c("indicativo",
      "fecha",
      "tmed",
      "prec",
      "velmedia",
      "longitud",
      "latitud")
  if (!file.exists("assets/data/weather.csv")) {
    # create empty file and write headers
    df <- data.frame(matrix(ncol = length(colnames), nrow = 0))
    colnames(df) <- colnames
    write.table(
      df,
      "assets/data/weather.csv",
      sep = ",",
      row.names = FALSE,
      col.names = colnames
    )
  }
  # list station codes for aemet
  aemet_api_key(key_get('aemet'))
  stations <- aemet_stations()
  # get stations from araba/alava, bizkaia and gipuzkoa
  stations <-
    stations[stations$provincia %in% c('ARABA/ALAVA', 'BIZKAIA', 'GIPUZKOA'),]
  # clean unnecessary columns for weather and stations
  stations <- stations[, c('indicativo', 'longitud', 'latitud')]
  weatherData <- aemet_daily_clim(start = fromDate)
  weatherData <-
    weatherData[, c('fecha', 'tmed', 'prec', 'velmedia', 'indicativo')]
  # merge weather data with stations
  weatherData <- merge(weatherData, stations, by = 'indicativo')
  write.table(
    weatherData,
    "assets/data/weather.csv",
    sep = ",",
    row.names = FALSE,
    col.names = !file.exists("assets/data/weather.csv"),
    append = T
  )
}

lastDateEbird <- getLastDateEbird()
fromDateEbird <-
  as.Date(ifelse(is.null(lastDateEbird), "2010-01-01", lastDateEbird + 1))
lastDateWeather <- getLastDateWeather()
fromDateWeather <-
  as.Date(ifelse(is.null(lastDateWeather), "2010-01-01", lastDateWeather + 1))

updateBirdData(fromDateEbird)
updateWeatherData(fromDateWeather)
