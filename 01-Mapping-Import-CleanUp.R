###############################################################################
## MAPPING
###############################################################################

## 00. PRELIMINARIES
###############################################################################
require(rgdal)
require(readxl)
require(tidyr)
require(dplyr)
## 01. DOWNLOAD, UNZIP 
###############################################################################
## shape file source: DIVA GIS www.diva-gis.org
## Country: Myanmar
## Subject: Administrative areas (GADM)
## http://biogeo.ucdavis.edu/data/diva/adm/MMR_adm.zip - downloaded 11.8.2016
## this one seems like it doens't fit census admin divisions...
## looks like themimu.info has both census and maps that match..

## 01.1 map 
###############################################################################
map.path <- "sources/data/original/maps"
data.url <-"http://geonode.themimu.info/geoserver/wfs?format_options=charset%3AUTF-8&typename=geonode%3Amyanmar_township_boundaries&outputFormat=SHAPE-ZIP&version=1.0.0&service=WFS&request=GetFeature"
temp <- tempfile()
download.file(data.url, temp)
unzip(temp, exdir = map.path)
ShpMMRTownship <- readOGR(dsn=map.path, "myanmar_township_boundaries")

## 01.2 merge regions/states 

## 01.1 census 
###############################################################################
data.path <- "sources/data/original"
# data.url <-paste0("http://www.themimu.info/sites/themimu.info/files/documents/", 
#                   "BaselineData_Census_Dataset_Township_MIMU_16Jun2016_ENG.xlsx")
# data.location <- paste(data.path, "BaselineData_Census_Dataset_Township_MIMU_16Jun2016_ENG.xlsx", sep="/")
# download.file(data.url, data.location, mode = "wb")
estimates.data <- read_excel(data.location, sheet = 1, skip=1 )
## right, so this table has a 2 row-header, which makes importing directly
## pretty useless, as the column names become useless. 
## so need to first fill in the NAs, but..
## the last columns - 259 - end don't have merged cells in first row
## and have to be treated diff... 
# first 258 cols:
colnames(estimates.data)[1:258] <- zoo::na.locf(colnames(estimates.data)[1:258], from.last=TRUE)

# manually last 6 sets of 4 cols
colnames(estimates.data)[259:262] <- paste(colnames(estimates.data)[260], colnames(estimates.data)[261])
colnames(estimates.data)[263:266] <- paste(colnames(estimates.data)[264], colnames(estimates.data)[265])
colnames(estimates.data)[267:270] <- paste(colnames(estimates.data)[268], colnames(estimates.data)[269])
colnames(estimates.data)[271:274] <- paste(colnames(estimates.data)[272], colnames(estimates.data)[273])
colnames(estimates.data)[275:278] <- paste(colnames(estimates.data)[276], colnames(estimates.data)[277])
colnames(estimates.data)[279:282] <- paste(colnames(estimates.data)[280], colnames(estimates.data)[281])
# merge with 2 row of header and remove it from data
colnames(estimates.data) <- paste(colnames(estimates.data), estimates.data[1,], sep=" - ")
estimates.data<- estimates.data[-1,]
# now we have to change the col types back to numeric
estimates.data[, c(7:282)] <- sapply(estimates.data[, c(7:282)], as.numeric)

## 02. test map
###############################################################################
colnames(ShpMMRTownship@data)
plot(ShpMMRTownship)

ShpMMRTownship@data <- left_join(ShpMMRTownship@data, estimates.data, by = c("TS_PCODE"="MIMU - Township Pcode"))

col <- ShpMMRTownship@data$`Type of disability (Male) - Remembering.y`/max(ShpMMRTownship@data$`Type of disability (Male) - Remembering.y`, na.rm = TRUE)
col[is.na(col)] <- 1
plot(ShpMMRTownship, col = gray(col) )
