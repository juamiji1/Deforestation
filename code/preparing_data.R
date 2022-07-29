#--------------------------------------------------------------------------------------------------
# PROJECT: Deforestation and CARs
# AUTHOR: JMJR
# TOPIC: Calculating forest loss
#--------------------------------------------------------------------------------------------------


#---------------------------------------------------------------------------------------
## PACKAGES AND LIBRARIES:
#
#---------------------------------------------------------------------------------------
#install.packages('bit64')

library(data.table)
library(rgdal)
library(rgeos)
library(ggplot2)
library(ggrepel)
library(sf)
library(spdep)
library(sp)
library(ggpubr)
library(dplyr)
library(tidyr)
library(scales) 
library(tidyverse)
library(lubridate)
library(gtools)
library(foreign)
library(ggmap)
library(maps)
library(gganimate)
library(gifski)
library(transformr)
library(tmap)
library(raster)
library(exactextractr)
library(matrixStats)
library(rgeos)
library(rmapshaper)
library(geojsonio)
library(plyr)
library(spatialEco)
library(terra)


#---------------------------------------------------------------------------------------
## PREPARING SPATIAL FEATURES:
#
#---------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------
# Preparing Administrative boundaries:
#---------------------------------------------------------------------------------------
current_path ='C:/Users/juami/Dropbox/My-Research/Deforestation/data/Gis'
setwd(current_path)

#Importing boundaries shapefile
colShp <- st_read(dsn = "Colombia", layer = "Departamentos")
colShp <-st_union(colShp)

muniShp <- st_read(dsn = "Colombia", layer = "Municipios")
muniShp <- st_transform(muniShp, crs=st_crs(colShp))

#Transforming sf object to sp object 
colShp_sp <- as(colShp, Class='Spatial')

#---------------------------------------------------------------------------------------
# Preparing Raster Layers:
#---------------------------------------------------------------------------------------
#Importing the loss year rasters 
flossFiles <- list.files(path = "C:/Users/juami/Dropbox/My-Research/Deforestation/data/Gis/Hansen/lossyear", pattern='.tif$', all.files=TRUE, full.names=TRUE)

flossList <- list() 

for(i in 1:length(flossFiles)){
  flossList[[i]] <- raster(flossFiles[i])
}

floss <- do.call(raster::merge, flossList)

#Importing the primary forest cover rasters 
fcoverFiles <- list.files(path = "C:/Users/juami/Dropbox/My-Research/Deforestation/data/Gis/Hansen/treecover00", pattern='.tif$', all.files=TRUE, full.names=TRUE)

fcoverList <- list() 

for(i in 1:length(fcoverFiles)){
  fcoverList[[i]] <- raster(fcoverFiles[i])
}

fcover00 <- do.call(raster::merge, fcoverList)

#Importing the GLAD primary forest cover raster
fcover01 <- raster('C:/Users/juami/Dropbox/My-Research/Deforestation/data/Gis/GLAD_primary/SouthAmerica_2001_primary.tif')

#Cropping the image to Colombia's boundary 
floss_crop <- crop(floss, colShp_sp)
fcover00_crop <- crop(fcover00, colShp_sp)
fcover01_crop <- crop(fcover01, colShp_sp)

#---------------------------------------------------------------------------------------
# Preparing Primary Forest:
#---------------------------------------------------------------------------------------
#Pixels with more than 50% of primary forest
fcover00_50p <- fcover00_crop %in% 50:100

#All pixels greater than one 
fcover00_1p <- fcover00_crop %in% 1:100

#Extracting primary forest area by municipality
fcoverDf=list()
fcoverDf[[1]] <- exact_extract(fcover00_1p, muniShp, 'sum')
fcoverDf[[2]] <- exact_extract(fcover00_50p, muniShp, 'sum')
fcoverDf[[3]] <- exact_extract(fcover01_crop, muniShp, 'sum')
fcoverDf <- as.data.frame(fcoverDf)
names(fcoverDf)<- c('fcover00_1p','fcover00_50p','fcover01')
fcoverDf <- fcoverDf*30*30/1000000
fcoverDf$IDDANE <- muniShp$IDDANE

#---------------------------------------------------------------------------------------
# Preparing All Kind of Yearly Forest Loss:
#---------------------------------------------------------------------------------------
#Separating pixels of loss by year
floss_stack=list()

for(i in 1:21){
  floss_stack[[i]] <- floss_crop %in% i
}

floss_stack = stack(floss_stack)

#Extracting forest loss area 
flossYearly <- exactextractr::exact_extract(floss_stack, muniShp, 'sum')
flossDf <- flossYearly*30*30/1000000
flossDf$IDDANE <- muniShp$IDDANE
names(flossDf)<- c('floss01','floss02','floss03','floss04','floss05','floss06','floss07','floss08','floss09','floss10','floss11','floss12','floss13','floss14',
                   'floss15','floss16','floss17','floss18','floss19','floss20','floss21', 'IDDANE')

#---------------------------------------------------------------------------------------
# Merging info to Shape
#---------------------------------------------------------------------------------------
#Merging info to municipality shapefile 
muniShp_info<-muniShp
muniShp_info<-left_join(muniShp_info, flossDf, by='IDDANE')
muniShp_info<-left_join(muniShp_info, fcoverDf, by='IDDANE')

# Converting from sf to sp object
muniShp_info_sp <- as(muniShp_info, Class='Spatial')

#Exporting the all data shapefile
writeOGR(obj=muniShp_info_sp, dsn="C:/Users/juami/Dropbox/My-Research/Deforestation/data/Gis/workinprogress", layer="muniShp_defoinfo_sp", driver="ESRI Shapefile",  overwrite_layer=TRUE)























#END




# #---------------------------------------------------------------------------------------
# # Preparing Yearly Forest Loss Conditional of being Primary Forest (diff versions):
# #---------------------------------------------------------------------------------------
# #Conditioning forest lost rasters to pixels with primary forest 
# flossPrim001p <- overlay(floss_crop, fcover00_1p, fun=function(r1, r2){return(r1*r2)})
# flossPrim0050p <- overlay(floss_crop, fcover00_50p, fun=function(r1, r2){return(r1*r2)})
# flossPrim01 <- overlay(floss_crop, fcover01_crop, fun=function(r1, r2){return(r1*r2)})
# 
# #Separating pixels of loss by year
# flossPrim001p_stack=list()
# 
# for(i in 1:21){
#   flossPrim001p_stack[[i]] <- flossPrim001p %in% i
# }
# 
# flossPrim001p_stack = stack(flossPrim001p_stack)
# 
# 
# flossPrim001p <- overlay(floss_stack, fcover00_1p, fun=function(r1, r2){return(r1*r2)})
# 
# 
# flossPrim001p <- lapply(1:3, FUN = function(i) overlay(floss_stack[[i]], fcover00_1p, fun=function(r1, r2){return(r1*r2)}))
#   
# fcover00_1p2 <-fcover00_1p
# values(fcover00_1p2)[values(fcover00_1p2) == 0] = NA
# 
# 
# fcover00_1p2[fcover00_1p2 == 0] <- NA 
# plot(fcover00_1p2)
# flossPrim001p <-mask(floss_crop, fcover00_1p2)
# 
# f1 <- floss_stack[[1]]
# flossPrim001p2 <-mask
# 
# 
# f1 <- overlay(floss_stack[[1]], fcover00_1p, fun=function(r1, r2){return(r1*r2)})
# f1x <- exactextractr::exact_extract(f1, muniShp, 'sum')
# 
# 
# 
# 
# 
# #Extracting forest loss Area using 1% of pixel in Hansen primary forest raster of 2000
# flossDf_v1 <- exactextractr::exact_extract(flossPrim001p_stack, muniShp, 'sum')
# flossDf_v1 <- flossDf_v1*30*30/1000000
# names(flossDf_v1)<- c('flossp101','flossp102','flossp103','flossp104','flossp105','flossp106','flossp107','flossp108','flossp109','flossp110','flossp111','flossp112','flossp113','flossp114',
#                       'flossp115','flossp116','flossp117','flossp118','flossp119','flossp120','flossp121')
# flossDf_v1$IDDANE <- muniShp$IDDANE
# 
# #Separating pixels of loss by year
# flossPrim0050p_stack=list()
# 
# for(i in 1:21){
#   flossPrim0050p_stack[[i]] <- flossPrim0050p %in% i
# }
# 
# flossPrim0050p_stack = stack(flossPrim0050p_stack)
# 
# #Extracting forest loss Area using 50% of pixel in Hansen primary forest raster of 2000
# flossDf_v2 <- exactextractr::exact_extract(flossPrim0050p_stack, muniShp, 'sum')
# flossDf_v2 <- flossDf_v2*30*30/1000000
# names(flossDf_v2)<- c('flossp5001','flossp5002','flossp5003','flossp5004','flossp5005','flossp5006','flossp5007','flossp5008','flossp5009','flossp5010','flossp5011','flossp5012','flossp5013','flossp5014',
#                       'flossp5015','flossp5016','flossp5017','flossp5018','flossp5019','flossp5020','flossp5021')
# flossDf_v2$IDDANE <- muniShp$IDDANE
# 
# #Separating pixels of loss by year
# flossPrim01_stack=list()
# 
# for(i in 1:21){
#   flossPrim01_stack[[i]] <- flossPrim01 %in% i
# }
# 
# flossPrim01_stack = stack(flossPrim01_stack)
# 
# #Extracting forest loss Area using GLAD primary forest in 2001
# flossDf_v3 <- exactextractr::exact_extract(flossPrim01_stack, muniShp, 'sum')
# flossDf_v3 <- flossDf_v3*30*30/1000000
# names(flossDf_v3)<- c('floss0101','floss0102','floss0103','floss0104','floss0105','floss0106','floss0107','floss0108','floss0109','floss0110','floss0111','floss0112','floss0113','floss0114',
#                       'floss0115','floss0116','floss0117','floss0118','floss0119','floss0120','floss0121')
# flossDf_v3$IDDANE <- muniShp$IDDANE
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# #END