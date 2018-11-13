library(sp)
library(RStoolbox)
library(raster)
library(tidyverse)
library(snow)
memory.limit(size=56000)
setwd("/home/yangao/Documents/L_8_7_5_PR2847")
dirs<-list.dirs(recursive = FALSE) #list dirs
dirs <- dirs[ grepl("L...", dirs)] # folder starts with L
#this is a template
dates = c()
a<-raster("valid_area_l578.tif")
#list bands L8 
#band 2 - Blue
#band 3 - green 
#band 4 - Red
#band 5 - Near Infrared (NIR)

#list bands L5-l7
#band 1 - Blue
#band 2 - green 
#band 3 - Red
#band 4 - Near Infrared (NIR)

#Values Fmask http://pythonfmask.org/en/latest/fmask_fmask.html#module-fmask.fmask 
#0 => Output pixel value for null
#1 => Output pixel value for clear land
#2 => Output pixel value for cloud
#3 => cloud shadow
#4 => snows
#255 => no observation

for (i in dirs) {
  print(i)
  pM<-paste(i,"/",list.files(i,pattern ="...MTL.txt$"),sep = "")
  M <- readMeta(pM)
  imagen <- stackMeta(M,quantity = "dn") 
  #qa <- stackMeta(M,category="qa")
  #plotRGB(imagen1,r=5,g=4,b=3,stretch = "lin")
  Fmask<-raster(paste(i,"/",substr(i,3,43),"_Fmask.TIF",sep = "")) %>% 
    reclassify(.,c(-Inf, 1, 1, 1, Inf, NA))
  if(M$SATELLITE =="LANDSAT8"){
    imagen2<- mask(imagen,Fmask)
    
    haze_a <- estimateHaze(imagen, hazeBands = 2:5, plot = FALSE, darkProp = 0.001)
    imagen_sdos_a <- radCor(imagen2, metaData = M, method = "sdos",
                            hazeValues=haze_a, bandSet=2:5)
    #imagen_sdos_a<-addLayer(imagen_sdos_a,Fmask)
    #ggRGB(imagen2,r=4,g=3,b=2,stretch = "lin")
    #nameimg<-paste(M$SCENE_ID,"conFmask.tif",sep = "")
    #writeRaster(imagen_sdos_a,nameimg,options="INTERLEAVE=BAND", overwrite=TRUE)
    e <- extent(a)
    #r <-files[[i]] # raster(files[i])
    rc <- crop(imagen_sdos_a, e)
    if(sum(as.matrix(extent(rc))!=as.matrix(e)) == 0){ # edited
      rc <- mask(rc, a) # You can't mask with extent, only with a Raster layer, RStack or RBrick
    }else{
      rc <- extend(rc,a)
      rc<- mask(rc, a)
    }
    
    nameimg_NDVI<-paste(i,"/",substr(i,3,43),"_NDVI",".tif",sep = "")  
    ndvi <- spectralIndices(rc, red = "B4_sre", nir = "B5_sre", indices = "NDVI",
                            filename = nameimg_NDVI,format="GTiff",datatype='FLT4S',overwrite=TRUE)
    #ndvi<-setZ(ndvi,as.Date(M$ACQUISITION_DATE),name="time")
    
    #stackSave(ndvi,filename = nameimg_NDVI,format="GTiff",datatype='FLT4S',overwrite=TRUE,zname='time')
    #a<-raster(nameimg_NDVI)
    nameimg_EVI<-paste(i,"/",substr(i,3,43),"_EVI",".tif",sep = "") 
   # EVI <- spectralIndices(rc, red = "B4_sre", blue ="B2_sre", nir = "B5_sre", indices = "EVI", 
    #                       filename = nameimg_EVI,format="GTiff",datatype='FLT4S',overwrite=TRUE)
    
  }
  #Landsat7
  if(M$SATELLITE =="LANDSAT007" | M$SATELLITE =="LANDSAT005"){
    imagen2<- mask(imagen,Fmask)
    
    haze_a <- estimateHaze(imagen, hazeBands = 1:4, plot = FALSE, darkProp = 0.001)
    imagen_sdos_a <- radCor(imagen2, metaData = M, method = "sdos", hazeValues=haze_a, bandSet=1:4)
    #imagen_sdos_a<-addLayer(imagen_sdos_a,Fmask)
    #ggRGB(imagen_sdos_a,r=4,g=3,b=2,stretch = "lin")
    #nameimg<-paste(M$SCENE_ID,"conFmask.tif",sep = "")
    #writeRaster(imagen_sdos_a,nameimg,options="INTERLEAVE=BAND", overwrite=TRUE)
    e <- extent(a)
    #r <-files[[i]] # raster(files[i])
    rc <- crop(imagen_sdos_a, e)
    if(sum(as.matrix(extent(rc))!=as.matrix(e)) == 0){ # edited
      rc <- mask(rc, a) # You can't mask with extent, only with a Raster layer, RStack or RBrick
    }else{
      rc <- extend(rc,a)
      rc<- mask(rc, a)
    }
    
    nameimg_NDVI<-paste(i,"/",substr(i,3,43),"_NDVI",".tif",sep = "")  
    ndvi <- spectralIndices(rc, red = "B3_sre", nir = "B4_sre", indices = "NDVI",
                            filename = nameimg_NDVI,format="GTiff",datatype='FLT4S',overwrite=TRUE)
    #ndvi<-setZ(ndvi,as.Date(M$ACQUISITION_DATE),name="time")
    
    #stackSave(ndvi,filename = nameimg_NDVI,format="GTiff",datatype='FLT4S',overwrite=TRUE,zname='time')
    #a<-raster(nameimg_NDVI)
    nameimg_EVI<-paste(i,"/",substr(i,3,43),"_EVI",".tif",sep = "") 
    EVI <- spectralIndices(rc, red = "B3_sre", blue ="B1_sre", nir = "B4_sre", indices = "EVI", 
                           filename = nameimg_EVI,format="GTiff",datatype='FLT4S',overwrite=TRUE)
    
  }
  date<-as.Date(M$ACQUISITION_DATE)
  df<-as.data.frame(date)
  ns<-M$SATELLITE
  satellite<-as.data.frame(ns)
  dates<-rbind(dates,cbind(date,satellite))
  print(dates)
}
saveRDS(dates, "dates.rds")

jpeg("Output/freq_total.jpg")
hist(dates$date,"years", freq = TRUE)
dev.off()
jpeg("Output/freq_l8.jpg")
hist(dates[dates$ns == "LANDSAT8",1],"years",main = "L8",freq = TRUE)
dev.off()
jpeg("Output/freq_l7.jpg")
hist(dates[dates$ns == "LANDSAT7",1],"years",main = "L7",freq = TRUE)
dev.off()
jpeg("Output/freq_l5.jpg")
hist(dates[dates$ns == "LANDSAT5",1],"years",main = "L5",freq = TRUE)
dev.off()





