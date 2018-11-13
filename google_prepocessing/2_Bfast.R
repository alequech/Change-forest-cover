library(raster)
require(bfast)
library(devtools)
#install_github('loicdtx/bfastSpatial')
require(bfastSpatial)
library(rasterVis)
library(rts)
library(RStoolbox)
library(tidyverse)


MinimunA<-function(x,min_pixel=1){
  rc <- clump(x,directions=8) 
  #freq(rc)
  clumpD <- data.frame(freq(rc))
  
  clumpD <- clumpD[ clumpD$count < min_pixel, ] 
  clumpD <- as.vector(clumpD$value) 
  rc[rc %in% clumpD] <- NA
  return(rc)
}



setwd("D:/Change-forest-cover")
dir.create("Output")
list.grid<-list.files(pattern = "*.tif$", recursive = F)


NDVI_S <-raster::stack(list.grid)
year<-substring(list.grid, 13, 16)
month<-substring(list.grid, 17, 18)
day<-substring(list.grid, 19, 20)

Date<-as.Date(paste(year, month, day, sep='-'))

NDVI_S<-setZ(NDVI_S,Date,name="time")

bfm0_2 <- bfmSpatial(NDVI_S, start=c(2016,1), order=1, mc.cores=1,returnLayers = c("breakpoint", "magnitude", "error"))
writeRaster(bfm0_2, filename="Output/bfm_chamela_16_18.tif", options="INTERLEAVE=BAND", overwrite=TRUE)


change <-raster(bfm0_2, 1)

months <- changeMonth(change)
monthlabs <- c("jan", "feb", "mar", "apr", "may", "jun", 
               "jul", "aug", "sep", "oct", "nov", "dec")
cols <- rainbow(12)
plot(months, col=cols, breaks=c(1:12), legend=FALSE)
legend("bottomright", legend=monthlabs, cex=0.5, fill=cols, ncol=2)

magn_bkp <- raster(bfm0_2, 2)
magn_bkp[is.na(change)] <- NA
loss<-magn_bkp
#Magmitudes less than -0.2 are consistent with observed losses in site verifications. 
loss[magn_bkp > -0.2] <- NA
plot(loss)

#minimum area 
Am<-MinimunA(loss,min_pixel=4)
lossMA<-mask(loss,Am)
writeRaster(lossMA,filename="Output/lossMA.tif",datatype="FLT4S",bylayer=TRUE, format="GTiff",overwrite=TRUE)
