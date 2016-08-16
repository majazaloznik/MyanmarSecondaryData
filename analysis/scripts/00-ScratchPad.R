load(file = "sources/data/clean/pop.map.RData")
source("analysis/scripts/02-Functions.R")

## VAR NAMES

colnames(ShpMMRTownship@data)[58]


## var range

range(unlist(ShpMMRTownship@data[309]), na.rm = TRUE)

FunMNTownMap(var = 308, 
             town = c("Mandalay", "Ayeyarwady"), n = 10, breaks = seq(0,10,1))

FunMNTownMap(var = 308, 
             town = "Ayeyarwady", n = 10, breaks = seq(0,10,1))

var =306
town = "Ayeyarwady"
town = "Mandalay"
range(unlist(ShpMMRTownship@data[ShpMMRTownship@data$ST %in% town,var]), na.rm = TRUE)
length(ShpMMRTownship@data[ShpMMRTownship@data$ST %in% town,var])

FunMNTownHistS(var = 306, 
               town = "Ayeyarwady", col = "red")

main = 
FunMNTownHistS <- function( var, town = "Naypyitaw Council", main = "", col = "black"){
  h.save <- hist(unlist(ShpMMRTownship@data[var]), main = main,
       col = "gray", border = "white", xlab = "")
  hist(ShpMMRTownship@data[ShpMMRTownship@data$ST %in% town,var], add = TRUE, col = col, 
       border ="white", breaks = h.save$breaks)
}

var =309
town = "Mandalay"

hist(ShpMMRTownship@data[ShpMMRTownship@data$ST %in% town,var], col = "gray", border = "white")
FunMNTownHistS(var = var, town = town)

# scatterplot
plot(unlist(ShpMMRTownship@data[59]), unlist(ShpMMRTownship@data[309]), pch = 19, col= "gray")
town = "Ayeyarwady"
points(unlist(ShpMMRTownship@data[ShpMMRTownship@data$ST %in% town,46]), 
       unlist(ShpMMRTownship@data[ShpMMRTownship@data$ST %in% town,309]),
       col= "red", pch = 19)
town = "Mandalay"
points(unlist(ShpMMRTownship@data[ShpMMRTownship@data$ST %in% town,46]), 
       unlist(ShpMMRTownship@data[ShpMMRTownship@data$ST %in% town,309]),
       col= "orange", pch = 19)


plot(irri.data$Year[irri.data$Variable == "FERTILIZER CONSUMPTION" & 
                      irri.data$Unit == "000 t"  ], 
     irri.data$Value[irri.data$Variable == "FERTILIZER CONSUMPTION" & 
                       irri.data$Unit == "000 t"  ], 
     type = "l")
lines(irri.data$Year[irri.data$Variable == "FERTILIZER CONSUMPTION" & 
                      irri.data$Unit == "kg/ha of arable land"  ], 
     irri.data$Value[irri.data$Variable == "FERTILIZER CONSUMPTION" & 
                       irri.data$Unit == "kg/ha of arable land"  ], 
     type = "l")
plot(irri.data$Year[irri.data$Variable == "YIELD - PADDY"  ], 
      irri.data$Value[irri.data$Variable == "YIELD - PADDY"  ], 
      type = "l")

par(mfrow=c(3,1))
par(mar = c(3,4,1,1))
plot(irri.data$Year[irri.data$Variable == "YIELD - PADDY"  ], 
     irri.data$Value[irri.data$Variable == "YIELD - PADDY"  ], 
     type = "l", xlim = c(1960, 2015), bty = "n", xlab = "",
     ylab = "Yield")
plot(irri.data$Year[irri.data$Variable == "EXPORT QUANTITY"  &
                      irri.data$Source == "USDA"], 
     irri.data$Value[irri.data$Variable == "EXPORT QUANTITY" &
                       irri.data$Source == "USDA" ] , 
     type = "l", xlim = c(1960, 2015),
     bty = "n", xlab = "",
     ylab = "Export quantity")
lines(irri.data$Year[irri.data$Variable == "EXPORT QUANTITY"  &
                      irri.data$Source == "FAO"], 
     irri.data$Value[irri.data$Variable == "EXPORT QUANTITY" &
                       irri.data$Source == "FAO" ] , 
     type = "l", xlim = c(1960, 2015), lty = 3)
plot(irri.data$Year[irri.data$Variable == "RICE CONSUMPTION PER CAPITA"  ], 
     irri.data$Value[irri.data$Variable == "RICE CONSUMPTION PER CAPITA"  ], 
     type = "l", xlim = c(1960, 2015), bty = "n", xlab = "",
     ylab = "Per capita consumption")


  irri.data[irri.data$Variable == "YIELD - PADDY",]
  irri.data[irri.data$Variable == "EXPORT QUANTITY",  ]
  