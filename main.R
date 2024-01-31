# store apy key in keyring
library(keyring)
# key_set(service = 'ebird')

library(httr)

# headers with the api key
headers = c('X-eBirdApiToken' = key_get(service = "ebird"))

# list of region codes for Spanish communities
# res <- VERB("GET", url = "https://api.ebird.org/v2/ref/region/list/subnational1/ES", add_headers(headers))
# list of region codes for Spanish provinces
# res <- VERB("GET", url = "https://api.ebird.org/v2/ref/region/list/subnational2/ES", add_headers(headers))
# cat(content(res, "text"))

# res <-
#   VERB("GET", url = "https://api.ebird.org/v2/data/obs/ES-PV/historic/2024/1/26", add_headers(headers))


# create function to get the species name
updateData <- function() {
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
  lastDate <- as.Date("2010-01-01")
  if (!file.exists("ebird.csv")) {
    # create empty file, write headers
    df <- data.frame(matrix(ncol = length(colnames), nrow = 0))
    colnames(df) <- colnames
    write.table(
      df,
      "ebird.csv",
      sep = ",",
      row.names = FALSE,
      col.names = colnames
    )
  } else {
    # read last date from file
    df <- read.csv("ebird.csv")
    lastDate <- as.Date(tail(df$obsDt, 1)) + 1
  }
  while (lastDate < Sys.Date()) {
    # get data
    res <-
      VERB(
        "GET",
        url = paste0(
          "https://api.ebird.org/v2/data/obs/ES-PV/historic/",
          gsub("-", "/", as.character(lastDate))
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
    # increment date
    lastDate <- lastDate + 1
  }
}

updateData()