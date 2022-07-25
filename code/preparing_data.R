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


#---------------------------------------------------------------------------------------
## PREPARING SPATIAL FEATURES:
#
#---------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------
# Preparing Administrative boundaries:
#---------------------------------------------------------------------------------------
current_path ='C:/Users/juami/Dropbox/My-Research/Deforestation/data/Gis'
setwd(current_path)

#Importing El salvador shapefile
muniShp <- st_read(dsn = "Colombia", layer = "Municipios")
muni_crs <- st_crs(muniShp)

colShp <- st_read(dsn = "Colombia", layer = "Departamentos")
colShp <-st_union(colShp)

#Transforming sf object to sp object 
colShp_sp <- as(colShp, Class='Spatial')

#---------------------------------------------------------------------------------------
# Preparing Raster Layers:
#---------------------------------------------------------------------------------------
#Directory: 
current_path ='C:/Users/juami/Dropbox/My-Research/Deforestation/data/Gis/Hansen'
setwd(current_path)

#Importing the rasters 
flossp1 <- raster('Hansen_GFC-2021-v1.9_lossyear_00N_070W.tif')
flossp2 <- raster('Hansen_GFC-2021-v1.9_lossyear_00N_080W.tif')
flossp3 <- raster('Hansen_GFC-2021-v1.9_lossyear_00N_090W.tif')
flossp4 <- raster('Hansen_GFC-2021-v1.9_lossyear_10N_070W.tif')
flossp5 <- raster('Hansen_GFC-2021-v1.9_lossyear_10N_080W.tif')
flossp6 <- raster('Hansen_GFC-2021-v1.9_lossyear_10N_090W.tif')
flossp7 <- raster('Hansen_GFC-2021-v1.9_lossyear_20N_070W.tif')
flossp8 <- raster('Hansen_GFC-2021-v1.9_lossyear_20N_080W.tif')
flossp9 <- raster('Hansen_GFC-2021-v1.9_lossyear_20N_090W.tif')

#Merging all granulates together
floss <- merge(flossp1, flossp2, flossp3, flossp4, flossp5, flossp6, flossp7, flossp8, flossp9)

#Cropping the image to Colombia's boundary 
floss_crop <- crop(floss, colShp_sp)

#Loss by year
floss1 <- floss_crop %in% 0
floss1 <- floss_crop %in% 1
floss2 <- floss_crop %in% 2
floss3 <- floss_crop %in% 3
floss4 <- floss_crop %in% 4
floss5 <- floss_crop %in% 5
floss6 <- floss_crop %in% 6
floss7 <- floss_crop %in% 7
floss8 <- floss_crop %in% 8
floss9 <- floss_crop %in% 9





#END