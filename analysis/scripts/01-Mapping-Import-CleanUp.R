###############################################################################
## MAPPING
###############################################################################

## 00. PRELIMINARIES
###############################################################################
require(rgdal)
require(readxl)
require(tidyr)
require(dplyr)
require(RColorBrewer)
require(classInt)
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
# data.url <-"http://geonode.themimu.info/geoserver/wfs?format_options=charset%3AUTF-8&typename=geonode%3Amyanmar_township_boundaries&outputFormat=SHAPE-ZIP&version=1.0.0&service=WFS&request=GetFeature"
# temp <- tempfile()
# download.file(data.url, temp)
# unzip(temp, exdir = map.path)
ShpMMRTownship <- readOGR(dsn=map.path, "myanmar_township_boundaries")

## 01.2 villages
map.path <- "sources/data/original/maps"
#http://geonode.themimu.info/layers/geonode%3Amagway_region_village_points
#http://geonode.themimu.info/layers/geonode%3Aayeyarwady_region_village_points
#http://geonode.themimu.info/layers/geonode%3AMandalay_region_village_points
PntMagway <- readOGR(dsn=map.path, "magway_region_village_points")
PntAyeyarwady <- readOGR(dsn=map.path, "ayeyarwady_region_village_points")
PntMandalay <- readOGR(dsn=map.path, "mandalay_region_village_points")


## 01.1 census - population based dataset
###############################################################################
# data.path <- "sources/data/original"
# # data.url <-paste0("http://www.themimu.info/sites/themimu.info/files/documents/",
# #                   "BaselineData_Census_Dataset_Township_MIMU_16Jun2016_ENG.xlsx")
# # data.location <- paste(data.path, "BaselineData_Census_Dataset_Township_MIMU_16Jun2016_ENG.xlsx", sep="/")
# # download.file(data.url, data.location, mode = "wb")
# estimates.data <- read_excel(data.location, sheet = 1, skip=1 )
# ## right, so this table has a 2 row-header, which makes importing directly
# ## pretty useless, as the column names become useless.
# ## so need to first fill in the NAs, but..
# ## the last columns - 259 - end don't have merged cells in first row
# ## and have to be treated diff...
# # first 258 cols:
# colnames(estimates.data)[1:258] <- zoo::na.locf(colnames(estimates.data)[1:258], from.last=TRUE)
# 
# # manually last 6 sets of 4 cols
# colnames(estimates.data)[259:262] <- paste(colnames(estimates.data)[260], colnames(estimates.data)[261])
# colnames(estimates.data)[263:266] <- paste(colnames(estimates.data)[264], colnames(estimates.data)[265])
# colnames(estimates.data)[267:270] <- paste(colnames(estimates.data)[268], colnames(estimates.data)[269])
# colnames(estimates.data)[271:274] <- paste(colnames(estimates.data)[272], colnames(estimates.data)[273])
# colnames(estimates.data)[275:278] <- paste(colnames(estimates.data)[276], colnames(estimates.data)[277])
# colnames(estimates.data)[279:282] <- paste(colnames(estimates.data)[280], colnames(estimates.data)[281])
# # merge with 2 row of header and remove it from data
# colnames(estimates.data) <- paste(colnames(estimates.data), estimates.data[1,], sep=" - ")
# estimates.data<- estimates.data[-1,]
# # now we have to change the col types back to numeric
# estimates.data[, c(7:282)] <- sapply(estimates.data[, c(7:282)], as.numeric)
# # save clean table
# write.csv(estimates.data, file = "sources/data/clean/census.population.csv")
# # als save clean column names
# varz <- colnames(estimates.data)
# save(varz, file= "sources/data/clean/census.pop.varz.RData")

## 01.2 census - household based dataset
###############################################################################
# data.path <- "sources/data/original"
# # data.url <-paste0("http://www.themimu.info/sites/themimu.info/files/documents/",
# #                   "BaselineData_Census_Dataset_Township_MIMU_16Jun2016_ENG.xlsx")
# data.location <- paste(data.path, "BaselineData_Census_Dataset_Township_MIMU_16Jun2016_ENG.xlsx", sep="/")
# # download.file(data.url, data.location, mode = "wb")
# household.data <- read_excel(data.location, sheet = 2, skip=1 )
# ## right, so this table has a 2 row-header, which makes importing directly
# ## pretty useless, as the column names become useless.
# ## so need to first fill in the NAs, but..
# ## some manual cleaning 
# colnames(household.data)[7:10] <- paste(colnames(household.data)[8], colnames(household.data)[9])
# colnames(household.data)[11:12] <- paste(colnames(household.data)[11], colnames(household.data)[12])
# 
# colnames(household.data)[14:123] <- zoo::na.locf(colnames(household.data)[14:123], from.last=TRUE)
# # merge with 2 row of header and remove it from data
# colnames(household.data) <- paste(colnames(household.data), household.data[1,], sep=" - ")
# household.data<- household.data[-1,]
# # just fix name in col 13:
# colnames(household.data)[13] <- "Mean household size"
# 
# # now we have to change the col types back to numeric
# household.data[, c(7:123)] <- sapply(household.data[, c(7:123)], as.numeric)
# # save clean table
# write.csv(household.data, file = "sources/data/clean/census.household.csv")
# # als save clean column names
# varz <- colnames(household.data)
# save(varz, file= "sources/data/clean/census.hh.varz.RData")



## 01.3 IRRI world rice stats 
###############################################################################
 data.path <- "sources/data/original"
# # data.url <-paste0("")
 data.location <- paste(data.path, "IRRI-ALL-MYANMAR-DATA.xls", sep="/")
# # download.file(data.url, data.location, mode = "wb")
 irri.data <- read_excel(data.location, sheet = 1, skip=3 )
irri.data$Value <- as.numeric(irri.data$Value)
write.csv(irri.data, file = "sources/data/clean/irri.data.csv")

## 02. merge map and pop.data, save
###############################################################################
# ShpMMRTownship@data <- left_join(ShpMMRTownship@data, estimates.data, by = c("TS_PCODE"="MIMU...Township.Pcode"))
# ShpMMRTownship@data <- left_join(ShpMMRTownship@data, household.data, by = c("TS_PCODE"="MIMU - Township Pcode"))
 save(ShpMMRTownship, PntMagway, PntAyeyarwady,PntMandalay , file = "sources/data/clean/pop.map.RData")
range(unlist(ShpMMRTownship@data[306]), rm.na = TRUE)
