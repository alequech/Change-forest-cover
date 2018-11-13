library(raster)
require(bfast)
library(devtools)
#install_github('loicdtx/bfastSpatial')
require(bfastSpatial)
library(rasterVis)
library(rts)
library(RStoolbox)
library(dbplyr)

#rasterOptions(tmpdir="/media/nrbv3/Data/Modis_MX/temp_raster")
#setwd("/Users/alexanderquevedo/Google Drive/Colima_NDVI")
setwd("/home/yangao/Documents/L_8_7_5_PR2847")
mask<-shapefile("Mini_mask.shp")
list.grid<-list.files(pattern = "_NDVI.tif$", recursive = TRUE)
date_NDVI<-readRDS("dates.rds")
NDVI_S <-stack(list.grid)
NDVI_S<-setZ(NDVI_S,as.Date(date_NDVI$date),name="time")


con_NA <- function(x){
    Nna<-sum(!is.na(x))
} 

beginCluster(n=7)
Nna <- clusterR(NDVI_S, calc, args=list(fun=con_NA))
endCluster()

percet_NA<- Nna/nlayers(NDVI_S) * 100
writeRaster(percNA,"Output/percNA.tif")

  
  
#summary(NDVI_S)
#obs <- countObs(NDVI_S, as.perc=TRUE)
#summary(obs)
#percNA <- 100 - countObs(NDVI_S, as.perc=TRUE)
plot(percet_NA, main="percent NA per pixel")
writeRaster(percet_NA,"Output/percNA.tif")

bfm0_2 <- bfmSpatial(NDVI_S, start=c(2018,1), order=1, mc.cores=8,returnLayers = c("breakpoint", "magnitude", "error"))
writeRaster(bfm0_2, filename="Output/bfm_2018.tif", options="INTERLEAVE=BAND", overwrite=TRUE)

