
##### Organizing URLS ######
full_locationnames_urls <- read.csv("~/Desktop/Research/Chapter2Research/full_locationnames_urls.csv")
full_locationnames_urls$locationIDs=as.numeric(gsub("https://www.plugshare.com/location/","",full_locationnames_urls$url_location))
full_locationnames_urls=full_locationnames_urls[order(full_locationnames_urls$locationIDs),]

#Merge to successful scrapes
library(readxl)
FullSuccess <- read_excel("Desktop/Research/Chapter2Research/FullSuccess.xlsx")
FullSuccess1=FullSuccess[,c(2:7)]

testing2=list(FullSuccess1,full_locationnames_urls) %>%
  purrr::reduce(plyr::join, type='left',match='all', by = c("name"))

#Drop all duplicated names
testing2=testing2[-c(which(duplicated(testing2$name))),]
testing2=na.omit(testing2)
write.csv(testing2,file="/home/void/Desktop/Research/Chapter2Research/CleanedFullSuccessesinR.csv")

#Try with scrape on big desktop
