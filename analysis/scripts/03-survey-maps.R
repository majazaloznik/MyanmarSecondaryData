require(rgdal)
require(rgeos)
require(RColorBrewer)
require(classInt)
require(dplyr)
library(maptools)
load(file = "sources/data/clean/pop.map.RData")
# source("analysis/scripts/02-Functions.R")
## mergin to state level 

# merge shapefile
state <- gUnaryUnion(ShpMMRTownship, id = ShpMMRTownship@data$ST)
lookup <- as.data.frame(row.names(state))
colnames(lookup) <- "ST"
row.names(state) <- as.character(1:length(state))
state <- SpatialPolygonsDataFrame(state, lookup)


# general parameters for chart
col1 <- rgb(0, 104, 139, max = 255)
col2 <- rgb(102, 170, 204, max = 255)
col3 <- rgb(236, 193, 19, max = 255)
pt.cex <- 0.5
pt.lwd <- 1.7
pt.bg <- "black"

# plot states
splitMat <- rbind(c(0,    1,  0,    1),
                  c(0, 0.3, 0.6, 1),
                  c(0.7,  1,    0.6,  1),
                  c(0,0.3, 0,0.4),
                  c(0.7,1, 0,0.4))
split.screen(splitMat)
screen(1)
par(mar = c(0,0,0,0))
par("usr")
plot(state, ylim = c(15.8, 22), xlim = c(89.56566, 101.77698), border = col2)
plot(state[state@data$ST == "Ayeyarwady",],col=col2, border = col2, add=TRUE, lwd = 1.5)
plot(state[state@data$ST == "Mandalay",],col=col2, border = "white",add=TRUE,lwd = 1.5)
plot(state[state@data$ST == "Magway",],col=col2, border = "white",add=TRUE, lwd = 1.5)

# plot townships Magway

plot(ShpMMRTownship[ShpMMRTownship@data$TS %in% c( "Pakokku") ,], col=col3, border = "white",add=TRUE)

# plot villages
Pt.Pakokku<- c(188000, 187993, 187951, 188075, 188057, 188037, 188014,188174)

plot(PntMagway[PntMagway@data$Vill_Pcode %in% Pt.Pakokku ,],  add=TRUE, pch = 21,
     bg = pt.bg, lwd = pt.lwd ,cex = pt.cex) 


# plot townships Mandalay
plot(ShpMMRTownship[ShpMMRTownship@data$TS %in% c("Natogyi") ,], 
     col=col3, border = "white",add=TRUE)

Pt.Natogyi <- c(191695, 191664, 191679, 191642, 191785, 191752, 191808)

plot(PntMandalay[PntMandalay@data$Vill_Pcode %in% Pt.Natogyi ,],  add=TRUE, pch = 21,
     bg = pt.bg, lwd = pt.lwd ,cex = pt.cex) 

# pointLabel(coordinates(PntMandalay[PntMandalay@data$Vill_Pcode %in% Pt.Natogyi ,]),
   #        labels=PntMandalay[PntMandalay@data$Vill_Pcode %in% Pt.Natogyi ,]$Vill)


# plot townships Ayayerwady, Pyapon
plot(ShpMMRTownship[ShpMMRTownship@data$TS %in% c("Pyapon") ,], col=col3, 
     border = "white",add=TRUE)

Pt.Pyapon <- c(162798, 151846, 155554, 150161, 155045, 154448, 162263,151497)

plot(PntAyeyarwady[PntAyeyarwady@data$Vill_Pcode %in% Pt.Pyapon ,],  add=TRUE, pch = 21,
     bg = pt.bg, lwd = pt.lwd ,cex = pt.cex) 


# pointLabel(coordinates(PntAyeyarwady[PntAyeyarwady@data$Vill_Pcode %in% Pt.Pyapon  ,]), 
# labels=PntAyeyarwady[PntAyeyarwady@data$Vill_Pcode %in% Pt.Pyapon ,]$Vill)

# plot townships Ayayerwady Pathein
plot(ShpMMRTownship[ShpMMRTownship@data$TS %in% c("Pathein") ,], col=col3, 
     border = "white",add=TRUE)

Pt.Pathein <- c(
  154452, 162886, 152762, 156736, 156817,160301, 160394
)

plot(PntAyeyarwady[PntAyeyarwady@data$Vill_Pcode %in% Pt.Pathein ,],  add=TRUE, pch = 21,
     bg = pt.bg, lwd = pt.lwd ,cex = pt.cex) 
u <- par("usr")
lines(x=u[1] + c(0.3, 0.43)*(u[2]-u[1]),
       y=u[3]+c(0.6, 0.79)*(u[4]-u[3]))

lines(x=u[1] + c(0.52, 0.7)*(u[2]-u[1]),
       y=u[3]+c(0.82, 0.6)*(u[4]-u[3]))

lines(x=u[1] + c(0.3, 0.41)*(u[2]-u[1]),
      y=u[3]+c(0.4, 0.25)*(u[4]-u[3]))


lines(x=u[1] + c(0.5, 0.7)*(u[2]-u[1]),
      y=u[3]+c(0.16, 0.4)*(u[4]-u[3]))

## create a layout to plot the subplot in the right bottom corner
screen(5)
par(mar = c(0,0,0,0))

## use xlim and ylim to zoom the subplot
plot(ShpMMRTownship[ShpMMRTownship@data$TS %in% c("Pyapon") ,], col=col3, 
     border = "white")

plot(state[state@data$ST == "Ayeyarwady",],col=col2, border = col2, add=TRUE, lwd = 1.5)

plot(ShpMMRTownship[ShpMMRTownship@data$TS %in% c("Pyapon") ,], col=col3, 
     border = "white", add=TRUE)
plot(PntAyeyarwady[PntAyeyarwady@data$Vill_Pcode %in% Pt.Pyapon ,],  add=TRUE, pch = 21,
     bg = pt.bg, lwd = pt.lwd ,cex = 1) 
pointLabel(coordinates(PntAyeyarwady[PntAyeyarwady@data$Vill_Pcode %in% Pt.Pyapon  ,]), 
 labels=paste0(" ",444444, letters[1:8], " "))
box()
## create a layout to plot the subplot in the left top corner
screen(2)
par(mar = c(0,0,0,0))
## use xlim and ylim to zoom the subplot
plot(ShpMMRTownship[ShpMMRTownship@data$TS %in% c( "Pakokku") ,], 
     col=col3, border = "white")

plot(state[state@data$ST == "Mandalay",],col=col2, border = "white",add=TRUE,lwd = 1.5)
plot(state[state@data$ST == "Magway",],col=col2, border = "white",add=TRUE, lwd = 1.5)
plot(ShpMMRTownship[ShpMMRTownship@data$TS %in% c( "Pakokku") ,], 
     col=col3, border = "white", add = TRUE)

lab1 <- paste0(" ",111111, letters[1:8], " ")
#lab1 <- c(lab1[1], NA, lab1[2:7])
plot(PntMagway[PntMagway@data$Vill_Pcode %in% Pt.Pakokku ,],  add=TRUE, pch = 21,
     bg = pt.bg, lwd = pt.lwd ,cex = 1) 
pointLabel(coordinates(PntMagway[PntMagway@data$Vill_Pcode %in% Pt.Pakokku  ,]), 
           labels=lab1)
box()
## create a layout to plot the subplot in the right top corner
screen(3)
par(mar = c(0,0,0,0))
## use xlim and ylim to zoom the subplot
plot(ShpMMRTownship[ShpMMRTownship@data$TS %in% c( "Natogyi") ,], 
     col=col3, border = "white")

plot(state[state@data$ST == "Mandalay",],col=col2, border = "white",add=TRUE,lwd = 1.5)
plot(ShpMMRTownship[ShpMMRTownship@data$TS %in% c( "Natogyi") ,], 
     col=col3, border = "white", add = TRUE)


plot(PntMandalay[PntMandalay@data$Vill_Pcode %in% Pt.Natogyi ,],  add=TRUE, pch = 21,
     bg = pt.bg, lwd = pt.lwd ,cex = 1) 
pointLabel(coordinates(PntMandalay[PntMandalay@data$Vill_Pcode %in% Pt.Natogyi  ,]), 
           labels=paste0(" ",222222, letters[1:7], " "))
box()
## create a layout to plot the subplot in the right top corner
screen(4)
par(mar = c(0,0,0,0))
## use xlim and ylim to zoom the subplot
plot(ShpMMRTownship[ShpMMRTownship@data$TS %in% c( "Pathein") ,], 
     col=col3, border = "white")

plot(state[state@data$ST == "Ayeyarwady",],col=col2, border = "white",add=TRUE,lwd = 1.5)
plot(ShpMMRTownship[ShpMMRTownship@data$TS %in% c( "Pathein") ,], 
     col=col3, border = "white", add = TRUE)


plot(PntAyeyarwady[PntAyeyarwady@data$Vill_Pcode %in% Pt.Pathein ,],  add=TRUE, pch = 21,
     bg = pt.bg, lwd = pt.lwd ,cex = 1) 
pointLabel(coordinates(PntAyeyarwady[PntAyeyarwady@data$Vill_Pcode %in% Pt.Pathein  ,]), 
           labels=paste0(" ",333333, letters[1:7], " "))

box()



close.screen(all.screens=TRUE)
dev.copy2eps(file = "../MyanmarFieldwork/reports/HAI-report/figures/map.eps", width = 10, height = 6)

getwd()
