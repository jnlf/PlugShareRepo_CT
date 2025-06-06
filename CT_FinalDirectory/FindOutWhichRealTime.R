library(stringr)
library(sp)
library(rworldmap)
library(rworldxtra)
rm(list=ls())
dataf1 <- read.csv("~/Desktop/Research/PlugShareCrawleeProject/CT.csv")

#Four possible strings if station not reporting
notreporting=c("['0', '0', '0', '0']['0', '0', '0', '0']['0', '0', '0', '0']",
"['0', '0', '0']['0', '0', '0']['0', '0', '0']",
"['0', '0']['0', '0']['0', '0']",
"['0']['0']['0']")
dataf1$notrep=(paste0(dataf1$AvailableCount,dataf1$InUseCount,dataf1$UnavailCount))

dataf1_finalscrape=dataf1
rm(dataf1)

dataf1_finalscrape$NumericLatitude=as.numeric(sapply(str_split(dataf1_finalscrape$Latitude,"'"),"[[",2))
dataf1_finalscrape$NumericLongitude=as.numeric(sapply(str_split(dataf1_finalscrape$Longitude,"'"),"[[",2))

library(sp)
library(rworldmap)
library(rworldxtra)

# The single argument to this function, points, is a data.frame in which:
#   - column 1 contains the longitude in degrees
#   - column 2 contains the latitude in degrees
coords2continent = function(points)
{  
  #countriesSP <- getMap(resolution='low')
  countriesSP <- getMap(resolution='high') #you could use high res map from rworldxtra if you were concerned about detail
  
  # converting points to a SpatialPoints objedataf1
  # setting CRS directly to that from rworldmap
  pointsSP = SpatialPoints(points, proj4string=CRS(proj4string(countriesSP)))  
  
  
  # use 'over' to get indices of the Polygons containing each point 
  indices = over(pointsSP, countriesSP)
  
  #indices$continent   # returns the continent (6 continent model)
  #indices$REGION   # returns the continent (7 continent model)
  indices$ADMIN  #returns country name
  #indices$ISO3 # returns the ISO3 code 
}
points=data.frame(lon=dataf1_finalscrape$NumericLongitude,lat=dataf1_finalscrape$NumericLatitude)
dataf1_finalscrape$location1=coords2continent(points)
#Find remaining unmatched
dataf1_finalscrape[which(is.na(dataf1_finalscrape$location1)&grepl("CT ",dataf1_finalscrape$Address)),18]="United States of America"
dataf1_finalscrape=na.omit(dataf1_finalscrape[dataf1_finalscrape$location1=="United States of America",])
#Real Time Value
RTS_CT=dataf1_finalscrape[which(!dataf1_finalscrape$notrep %in% notreporting),]

chunkedCT_RealTime=RTS_CT %>% dplyr::group_split(grp = as.integer(gl(dplyr::n(), 25, dplyr::n())), .keep = FALSE)
for(j in 1:length(chunkedCT_RealTime)){
  data.table::fwrite(x=data.table::data.table(chunkedCT_RealTime[[j]][,"url"]),
         file=paste0("/home/void/Desktop/Research/PlugShareCrawleeProject/RealTimeChunk/",
                     "CT_RealTimeChunk",j,".txt"),sep=",",col.names=F,append=F)
}

write.csv(RTS_CT,file = "/home/void/Desktop/Research/PlugShareCrawleeProject/RTS_CT.csv")


#Create TXT File
data.table::fwrite(data.table::data.table(RTS_CT$url),
                   file=paste0("/home/void/Desktop/Research/PlugShareCrawleeProject/FullCTRT.txt"),
                   sep=",",col.names=F,append=F)
