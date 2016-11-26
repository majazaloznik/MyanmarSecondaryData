
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

# single region cloropleth map (actually works with multipe townhsips as well)
FunMNTownMapS <- function(var, town = "Naypyitaw  Council", n, breaks, pal = bpy.colors(), mar = c(0,0,0,0)) {
  classInts <- classIntervals(unlist(ShpMMRTownship@data[var]), 
                              style = "fixed", 
                              n = n, 
                              fixedBreaks = breaks)
  col  <- findColours(classInts, pal)
  par(mar = mar)
  plot(ShpMMRTownship[ShpMMRTownship@data$ST %in% town,])
  plot(ShpMMRTownship, add = TRUE, border = "gray")
  plot(ShpMMRTownship[ShpMMRTownship@data$ST %in% town,], 
       col=col[ShpMMRTownship@data$ST %in% town], add = TRUE)
  return(col)
}

# single region highlighted on national histogram of townships
FunMNTownHistS <- function( var, town = "Naypyitaw Council", main = "", col = "black"){
  hist.save <- hist(unlist(ShpMMRTownship@data[var]), main = main,
       col = "gray", border = "white", xlab = "")
  hist(ShpMMRTownship@data[ShpMMRTownship@data$ST %in% town,var], add = TRUE, col = col, 
       border ="white", breaks = hist.save$breaks)
}

FunMNTownHistN <- function( var, main = ""){
  hist(unlist(ShpMMRTownship@data[var]), main = main,
       col = "gray", border = "white", xlab = "")
  hist(ShpMMRTownship@data[ShpMMRTownship@data$ST %in% c("Naypyitaw  Council"),var], add = TRUE, col = "red", 
       border ="white")
}

