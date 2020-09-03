library(sp)
library(rgdal)
library(rgeos)
library(sf)
library(raster)
library(foreign)

require("raster")
require("rgdal")
require("foreign")
require("rgeos")
require("maptools")
require("parallel")
require("reshape2")

#PANEL DE DEFORESTACION MUNICIPAL
#mainPath<-'/scratch/PI/arungc/CommunalLand'
#mainPath<-'C:/Users/Santi/Dropbox/CommunalLand'
#mainPath<-'C:/Users/admin/Dropbox/CommunalLand'
mainPath<-'C:/DefoCobertura'
pathout<-'C:/DefoCobertura/CreatedData/prueba'
pathout2<-file.path(mainPath, 'CreatedData', 'prueba')

CRS <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")

x<-raster(paste0(mainPath, '/RawData/lossyear/Hansen_GFC-2017-v1.5_lossyear_10N_080W.tif'))

municipios <- readOGR(dsn=paste0(mainPath,'/RawData/Municipios'), layer='Municipios', encoding="utf-8", stringsAsFactors=F)
municipios <- spTransform(municipios, CRS)

source(paste0(mainPath,"/Codigos/mosaicPolygon.R"))

for (n in 1:1122){
  #mpio<-municipios[1,]
  mpio <- subset(municipios, id %in% municipios$id[n])
  
  rasterPredicted <- mosaicPolygon(mpio, paste0(mainPath,'/RawData/lossyear/'))
  
  year<-seq(2001,2017,by=1)
  areadefo <-rep(0,length(year))
  
  for (i in 1:length(areadefo)) {
    areadefo[i] <-30 * 30 * sum(rasterPredicted[]==i, na.rm=TRUE)
  }
  
  data<-data.frame(id=municipios@data$id[n],
                   CODANE=as.numeric(municipios@data$CODANE2[n]),
                   year=year,
                   areadefo=areadefo)
  
  saveRDS(object = data,file = file.path(pathout, paste0('DefoMuni',(n),'.Rda')))
  
}

i=1
allDf <- readRDS(file.path(pathout, paste0('DefoMuni',i, '.Rda')))
for (i in  2:1122) {
  Df <- readRDS(file.path(pathout, paste0('DefoMuni',i, '.Rda')))  
  allDf <- rbind(allDf, Df)
}

write.dta(allDf,file=file.path(pathout2,paste0("DefoMuni.dta",sep="")))
