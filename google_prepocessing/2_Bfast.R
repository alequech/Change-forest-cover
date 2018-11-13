library(raster)
require(bfast)
library(devtools)
#install_github('loicdtx/bfastSpatial')
require(bfastSpatial)
library(rasterVis)
library(rts)
library(RStoolbox)
library(tidyverse)

setwd("D:/Change-forest-cover")
dir.create("Output")
list.grid<-list.files(pattern = "*.tif$", recursive = T)


NDVI_S <-raster::stack(list.grid)
year<-substring(list.grid, 13, 16)
month<-substring(list.grid, 17, 18)
day<-substring(list.grid, 19, 20)

Date<-as.Date(paste(year, month, day, sep='-'))

NDVI_S<-setZ(NDVI_S,Date,name="time")

bfm0_2 <- bfmSpatial(NDVI_S, start=c(2016,1), order=1, mc.cores=1,returnLayers = c("breakpoint", "magnitude", "error"))
writeRaster(bfm0_2, filename="Output/bfm_chamela_16_18.tif", options="INTERLEAVE=BAND", overwrite=TRUE)
