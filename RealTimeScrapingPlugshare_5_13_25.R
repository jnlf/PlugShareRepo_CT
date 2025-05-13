rm(list=ls())
setwd("/home/void/Desktop/Research/Chapter2Research/PlugShareRepo")
library(parallel) #scraping in parallel
library(xml2) #for reading html documents
library(chromote) #for starting new chrome sessions
library(rvest) #for reading html documents also and initializing chromote sesion
library(data.table) #for writing csv files
library(jsonlite) #for reading json
library(stringi) #for randomizing agent when making calls in parallel
#Found all location ids
#https://www.plugshare.com/sitemap_new_index.xml
#https://www.plugshare.com/robots.txt

n.cores=parallel::detectCores()

data=read.csv("/home/void/Desktop/Research/Chapter2Research/PlugShareRepo/plugsharelocs.csv")
names(data)[names(data)=='c.all_plugshare..1....all_plugshare..2....all_plugshare..3....']='locs'

#Code from stack exchange for randomizing a user agent
#https://stackoverflow.com/questions/73468632/r-coloring-individual-bars-in-barplots


#Function is for making a panel dataset of review information

#Function is for making a panel dataset of review information

#Get single row data, non-parallel
get_data_non_parallel=function(htmltoparse,plugbrows){
  url=htmltoparse
  plugbrows$go_to(url,delay = 12)
  #Latitude
  main_doc <- plugbrows$DOM$getDocument()
  x <- plugbrows$DOM$querySelector(main_doc$root$nodeId, "[property='v:latitude']")
  lat=plugbrows$DOM$getAttributes(x$nodeId)$attributes[[4]]
  
  
  #Longitude
  x <- plugbrows$DOM$querySelector(main_doc$root$nodeId, "[property='v:longitude']")
  long=plugbrows$DOM$getAttributes(x$nodeId)$attributes[[4]]
  #Checkins
  checkins=main_doc$root$nodeId %>% 
    plugbrows$DOM$querySelector("html") %>% 
    `[[`(1) %>% 
    plugbrows$DOM$getOuterHTML() %>% 
    `[[`(1) %>% 
    xml2::read_html() %>% 
    rvest::html_elements("[type='application/ld+json']")%>%
    html_text2() 
  checkins=fromJSON(toJSON(checkins)) %>% RJSONIO::fromJSON()
  checkins=as.numeric(checkins$aggregateRating$reviewCount)
  #Address
  x <- plugbrows$DOM$querySelector(main_doc$root$nodeId, "[property='v:address']")
  address=plugbrows$DOM$getAttributes(x$nodeId)$attributes[[14]]
  #Name
  x <- plugbrows$DOM$querySelector(main_doc$root$nodeId, "[property='og:title']")
  name=plugbrows$DOM$getAttributes(x$nodeId)$attributes[[4]]
  #Station Information - Implemented from SY's (5/12/25) Progress Report, Thanks!
  stat_info=main_doc$root$nodeId %>% 
    plugbrows$DOM$querySelector("html") %>% 
    `[[`(1) %>% 
    plugbrows$DOM$getOuterHTML() %>% 
    `[[`(1) %>% 
    xml2::read_html()
  #Plug_Type 
  plug_type=stat_info %>% html_elements('span.plug-name.ng-binding') %>%
    rvest::html_text2()
  #Plug Power
  plug_power=stat_info %>% html_elements('span.plug-power.ng-binding') %>%
    rvest::html_text2()
  #Station Count
  station_count=stat_info %>% html_elements('span.station-count.ng-binding') %>%
    rvest::html_text2()
  #Available Count
  available_count=stat_info %>% html_elements('div.status-dots div.many[title*="Available"] span.num.ng-binding') %>%
    rvest::html_text2()
  inuse_count=stat_info %>% html_elements('div.status-dots div.many[title*="In Use"] span.num.ng-binding') %>%
    rvest::html_text2()
  unavailable_count=stat_info %>% html_elements('div.status-dots div.many[title*="Unavailable"] span.num.ng-binding') %>%
    rvest::html_text2()
  #Charging Station Network
  charg_work=stat_info %>% html_elements("i.ng-binding") %>%
    rvest::html_text2()
  xy=data.table::data.table(lat=rep(lat,length(inuse_count)),
                            long=rep(long,length(inuse_count)),
                            checkins=rep(checkins,length(inuse_count)),
                            address=rep(address,length(inuse_count)),
                            name=rep(name,length(inuse_count)),
                            urlsave=rep(url,length(inuse_count)),
                            date_pull=rep(date(),length(inuse_count)),
                            station_no=paste0("Station ",seq(1:length(inuse_count))),
                            plug_type=plug_type,
                            plug_power=plug_power,
                            station_count=station_count,
                            available_count=available_count,
                            inuse_count=inuse_count,
                            unavailable_count=unavailable_count,
                            network_info=charg_work)
  
  fwrite(xy,
         paste0("/home/void/Desktop/Research/Chapter2Research/PlugShareRepo/LocationIDs/OneObsv/",
                "locationID",
                gsub("https://www.plugshare.com/location/","",url),
                ".csv"),col.names = T)
}




#For scraping in parallel 
get_singledata.mod_parallel=function(htmltoparse){
  url=htmltoparse
  plugbrows=ChromoteSession$new()
  plugbrows$default_timeout=20*1000
  plugbrows$Network$setUserAgentOverride(stri_rand_shuffle(paste0(paste(letters[sample(1:26,sample(1:26,1))],collapse=""),sample(size=1,100:sample(1000,1,100000)),collapse=""))) #change this or rotate this to avoid ban
  x=plugbrows$Page$loadEventFired(wait_ = F)

  plugbrows$Page$navigate(url,wait_=F)
  plugbrows$wait_for(x)
  #Sys.sleep(runif(1,2,4)) #change waiting time randomly to avoid ban
  #Latitude
  main_doc <- plugbrows$DOM$getDocument()
  x <- plugbrows$DOM$querySelector(main_doc$root$nodeId, "[property='v:latitude']")
  lat=plugbrows$DOM$getAttributes(x$nodeId)$attributes[[4]]

  
  #Longitude
  x <- plugbrows$DOM$querySelector(main_doc$root$nodeId, "[property='v:longitude']")
  long=plugbrows$DOM$getAttributes(x$nodeId)$attributes[[4]]
  #Checkins
  checkins=main_doc$root$nodeId %>% 
    plugbrows$DOM$querySelector("html") %>% 
    `[[`(1) %>% 
    plugbrows$DOM$getOuterHTML() %>% 
    `[[`(1) %>% 
    xml2::read_html() %>% 
    rvest::html_elements("[type='application/ld+json']")%>%
    html_text2() 
  checkins=fromJSON(toJSON(checkins)) %>% RJSONIO::fromJSON()
  checkins=as.numeric(checkins$aggregateRating$reviewCount)
  #Address
  x <- plugbrows$DOM$querySelector(main_doc$root$nodeId, "[property='v:address']")
  address=plugbrows$DOM$getAttributes(x$nodeId)$attributes[[14]]
  #Name
  x <- plugbrows$DOM$querySelector(main_doc$root$nodeId, "[property='og:title']")
  name=plugbrows$DOM$getAttributes(x$nodeId)$attributes[[4]]
  #Station Information - Implemented from SY's (5/12/25) Progress Report, Thanks!
  stat_info=main_doc$root$nodeId %>% 
    plugbrows$DOM$querySelector("html") %>% 
    `[[`(1) %>% 
    plugbrows$DOM$getOuterHTML() %>% 
    `[[`(1) %>% 
    xml2::read_html()
  #Plug_Type 
  plug_type=stat_info %>% html_elements('span.plug-name.ng-binding') %>%
    rvest::html_text2()
  #Plug Power
  plug_power=stat_info %>% html_elements('span.plug-power.ng-binding') %>%
    rvest::html_text2()
  #Station Count
  station_count=stat_info %>% html_elements('span.station-count.ng-binding') %>%
    rvest::html_text2()
  #Available Count
  available_count=stat_info %>% html_elements('div.status-dots div.many[title*="Available"] span.num.ng-binding') %>%
    rvest::html_text2()
  inuse_count=stat_info %>% html_elements('div.status-dots div.many[title*="In Use"] span.num.ng-binding') %>%
    rvest::html_text2()
  unavailable_count=stat_info %>% html_elements('div.status-dots div.many[title*="Unavailable"] span.num.ng-binding') %>%
    rvest::html_text2()
  #Charging Station Network
  charg_work=stat_info %>% html_elements("i.ng-binding") %>%
    rvest::html_text2()
    xy=data.table::data.table(lat=rep(lat,length(inuse_count)),
                              long=rep(long,length(inuse_count)),
                              checkins=rep(checkins,length(inuse_count)),
                              address=rep(address,length(inuse_count)),
                              name=rep(name,length(inuse_count)),
                              urlsave=rep(url,length(inuse_count)),
                              date_pull=rep(date(),length(inuse_count)),
                              station_no=paste0("Station ",seq(1:length(inuse_count))),
                              plug_type=plug_type,
                              plug_power=plug_power,
                              station_count=station_count,
                              available_count=available_count,
                              inuse_count=inuse_count,
                              unavailable_count=unavailable_count,
                              network_info=charg_work)
  
  fwrite(xy,
              paste0("/home/void/Desktop/Research/Chapter2Research/PlugShareRepo/LocationIDs/OneObsv/",
                     "locationID",
                     gsub("https://www.plugshare.com/location/","",url),
                     ".csv"),col.names = T)
  plugbrows$close()
}


####### Trying with Chromote #####
url="https://plugshare.com/location/100" #just for a test
#Download chrome headless shell for optimizing code
Sys.setenv(CHROMOTE_CHROME="/home/void/Desktop/Research/Chapter2Research/chrome-headless-shell-linux64/chrome-headless-shell")

#Initialize plug_sesh for non-parallel scraping
test1=rvest::read_html_live(url)
plug_sesh=test1$session
rm(test1)
plug_sesh$default_timeout=20*1000

mclapply(data$locs,mc.cores=2,get_singledata.mod_parallel)

