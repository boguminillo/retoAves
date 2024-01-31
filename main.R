# https://cran.r-project.org/web/packages/meteospain/vignettes/aemet.html
# store apy key in keyring
# install.packages(c("keyring", "httr", "units", "sf", "meteospain"))
library(keyring)
# key_set(service = 'ebird')
# key_set(service = 'aemet')
library(httr)
library(meteospain)


# headers with the api key
# headers = c('X-eBirdApiToken' = key_get(service = "ebird"))

# list of region codes for Spanish communities
# res <- VERB("GET", url = "https://api.ebird.org/v2/ref/region/list/subnational1/ES", add_headers(headers))
# list of region codes for Spanish provinces
# res <- VERB("GET", url = "https://api.ebird.org/v2/ref/region/list/subnational2/ES", add_headers(headers))
# cat(content(res, "text"))

# res <-
#   VERB("GET", url = "https://api.ebird.org/v2/data/obs/ES-PV/historic/2024/1/26", add_headers(headers))

# list station codes for aemet
# get_stations_info_from('aemet', api_options)

getLastDate <- function() {
  lastDate <- NULL
  if (file.exists("ebird.csv")) {
    # read last date from file
    df <- read.csv("ebird.csv")
    lastDate <- as.Date(tail(df$obsDt, 1))
  }
  return(lastDate)
}

updateBirdData <- function(fromDate = as.Date("2010-01-01") {
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
  if (!file.exists("ebird.csv")) {
    # create empty file and write headers
    df <- data.frame(matrix(ncol = length(colnames), nrow = 0))
    colnames(df) <- colnames
    write.table(
      df,
      "ebird.csv",
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
        "ebird.csv",
        sep = ",",
        row.names = FALSE,
        col.names = !file.exists("ebird.csv"),
        append = T
      )
    }
    fromDate <- fromDate + 1
  }
}

updateWeatherData <- function(fromDate = as.Date("2010-01-01"){
  colnames <-
    c(
      # TODO: add column names
    )
  if (!file.exists("weather.csv")) {
    # create empty file and write headers
    df <- data.frame(matrix(ncol = length(colnames), nrow = 0))
    colnames(df) <- colnames
    write.table(
      df,
      "weather.csv",
      sep = ",",
      row.names = FALSE,
      col.names = colnames
    )
  }
  api_options <- aemet_options(
    resolution = 'daily',
    start_date = fromDate, end_date = Sys.Date() - 1,
    # station = '8200', TODO: add station codes
    api_key = key_get('aemet')
  )
  weatherData <- get_meteo_from('aemet', options = api_options)
  write.table(
    weatherData,
    "weather.csv",
    sep = ",",
    row.names = FALSE,
    col.names = !file.exists("weather.csv"),
    append = T
  )
}

lastDate <- getLastDate()
fromDate <- as.Date(ifelse(is.null(lastDate), "2010-01-01", lastDate + 1))

updateBirdData(fromDate)

