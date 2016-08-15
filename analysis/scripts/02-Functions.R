
## simple township map one var, bpy pallete
FunMNTownMap <- function(var, n, breaks, pal = bpy.colors()) {
  classInts <- classIntervals(var, 
                              style = "fixed", 
                              n = n, 
                              fixedBreaks = breaks)
  col  <- findColours(classInts, pal)
  par(mar = c(0,0,0,0))
  plot(ShpMMRTownship, col = col)
  return(col)
}

## simple township map one var Yangon, without Cocokyun islands (OBJECTID ==2)

FunMNTownMapY <- function(var, n, breaks, pal = bpy.colors(), mar = c(0,0,0,0)) {
  classInts <- classIntervals(var, 
                              style = "fixed", 
                              n = n, 
                              fixedBreaks = breaks)
  col  <- findColours(classInts, pal)
  par(mar = mar)
  plot(ShpMMRTownship[ShpMMRTownship@data$ST %in% c("Yangon") &
                        ShpMMRTownship@data$OBJECTID !=2 ,])
  plot(ShpMMRTownship, add = TRUE, border = "gray")
  plot(ShpMMRTownship[ShpMMRTownship@data$ST %in% c("Yangon")&
                        ShpMMRTownship@data$OBJECTID !=2 ,], col=col[ShpMMRTownship@data$ST %in% c("Yangon")&
                                                                       ShpMMRTownship@data$OBJECTID !=2 ], add = TRUE)
  return(col)
}

## simple township map one var Naypyitaw

FunMNTownMapN <- function(var, n, breaks, pal = bpy.colors(), mar = c(0,0,0,0)) {
  classInts <- classIntervals(var, 
                              style = "fixed", 
                              n = n, 
                              fixedBreaks = breaks)
  col  <- findColours(classInts, pal)
  par(mar = mar)
  plot(ShpMMRTownship[ShpMMRTownship@data$ST %in% c("Naypyitaw  Council"),])
  plot(ShpMMRTownship, add = TRUE, border = "gray")
  plot(ShpMMRTownship[ShpMMRTownship@data$ST %in% c("Naypyitaw  Council"),], 
       col=col[ShpMMRTownship@data$ST %in% c("Naypyitaw  Council")], add = TRUE)
  return(col)
}

FunMNTownHistY <- function( var, main = ""){
  hist(unlist(ShpMMRTownship@data[var]), main = main,
       col = "gray", border = "white", xlab = "")
  hist(ShpMMRTownship@data[ShpMMRTownship@data$ST %in% c("Yangon"),var], add = TRUE, col = "orange", 
       border ="white")
}

FunMNTownHistN <- function( var, main = ""){
  hist(unlist(ShpMMRTownship@data[var]), main = main,
       col = "gray", border = "white", xlab = "")
  hist(ShpMMRTownship@data[ShpMMRTownship@data$ST %in% c("Naypyitaw  Council"),var], add = TRUE, col = "red", 
       border ="white")
}

