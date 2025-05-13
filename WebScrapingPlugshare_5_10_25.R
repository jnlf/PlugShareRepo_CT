rm(list=ls())
setwd("/home/void/Desktop/Research/Chapter2Research/PlugShareRepo")
library(parallel)
library(xml2)
library(chromote)
library(rvest)
library(data.table)
library(jsonlite)
#Found all location ids
#https://www.plugshare.com/sitemap_new_index.xml
#https://www.plugshare.com/robots.txt

n.cores=parallel::detectCores()

data=read.csv("/home/void/Desktop/Research/Chapter2Research/PlugShareRepo/plugsharelocs.csv")
names(data)[names(data)=='c.all_plugshare..1....all_plugshare..2....all_plugshare..3....']='locs'

#Code from stack exchange for randomizing a user agent
#https://stackoverflow.com/questions/73468632/r-coloring-individual-bars-in-barplots

myFun <- function(n = 5000) {
  a <- do.call(paste0, replicate(5, sample(LETTERS, n, TRUE), FALSE))
  paste0(a, sprintf("%04d", sample(9999, n, TRUE)), sample(LETTERS, n, TRUE))
}
#Station Information
#(x) problem with charging (Correct count, no duplicates) --> span.problem.ng-scope
#(x) car of user (Inorrect count, duplicates, (Ex., correct = 7, new length 12 (+5))) --> div.car.ng-binding
#(x)connector used (correct count, no duplicates) --> span.connector.ng-binding
#(x)username (correct count, no duplicates, make sure to remove my username (!)) --> span.name.ng-binding
#(x)date when charging (incorrect count, duplicates (Ex., correct = 7, new length 12 (+5))) --> div.date.ng-binding
#(x)kilowatts used while charging (correct count, no duplicates) --> span.kilowatts.ng-scope
# in summary, first 5 entries are duplicates, if checkins are < 5, actual checkin count (1+1, in example, where
# station only has one checkin) -- 2 checkins, adds additional 2


#Function is for making a panel dataset of review information
get_review_info_non_parallel=function(htmltoparse,plugbrows,username,password){ 
  url=htmltoparse
  plugbrows$go_to(url,delay = 12)

  #Avoiding Duplicates
  x <- plugbrows$DOM$getDocument()
  checkins=x$root$nodeId %>% 
    plugbrows$DOM$querySelector("html") %>% 
    `[[`(1) %>% 
    plugbrows$DOM$getOuterHTML() %>% 
    `[[`(1) %>% 
    xml2::read_html() %>% 
    rvest::html_elements("[type='application/ld+json']")%>%
    html_text2() 
  checkins=fromJSON(toJSON(checkins)) %>% RJSONIO::fromJSON()
  checkins=as.numeric(checkins$aggregateRating$reviewCount)


  tryandcatchme<- plugbrows$DOM$getDocument()
  gotit <- plugbrows$DOM$querySelector(tryandcatchme$root$nodeId, "[class='continuing ng-binding']")
  if(gotit$nodeId!=0){
    login_func(plugbrows,username,password)
    Sys.sleep(20) 

    ###Click Review Controller
    x1<- plugbrows$DOM$getDocument()
    x2 <- plugbrows$DOM$querySelector(x1$root$nodeId, "[ng-controller='ReviewsController']")
    
    box=plugbrows$DOM$getBoxModel(x2$nodeId)
    plugbrows$DOM$scrollIntoViewIfNeeded(x2$nodeId,wait_ = T,timeout_ = 60*1000)
    
    #RESET DOM
    
    x1<- plugbrows$DOM$getDocument()
    x2 <- plugbrows$DOM$querySelector(x1$root$nodeId, "[ng-controller='ReviewsController']")

    box=plugbrows$DOM$getBoxModel(x2$nodeId)
    
    br=box$model$border
    x=(br[[1]]+br[[5]])/2
    y=(br[[2]]+br[[6]])/2
    plugbrows$Input$dispatchMouseEvent(type = "mousePressed", x = x, y = y, button="left",clickCount = 1,wait_ = T,timeout_ = 60*1000)
    plugbrows$Input$dispatchMouseEvent(type = "mouseReleased", x = x, y = y, button="left",clickCount = 1,wait_ = T,timeout_ = 60*1000)

    if(checkins<5){
      #CORRECT COUNTS ONLY::
      #(1) Kilowatts When Charging
      x <- plugbrows$DOM$getDocument()
      kilowatt=x$root$nodeId %>% 
        plugbrows$DOM$querySelector("html") %>% 
        `[[`(1) %>% 
        plugbrows$DOM$getOuterHTML() %>% 
        `[[`(1) %>% 
        xml2::read_html() %>% 
        html_elements('span.kilowatts.ng-scope')%>%
        rvest::html_text()
      #(2) Problem with Charging
      x <- plugbrows$DOM$getDocument()
      probcharg=x$root$nodeId %>% 
        plugbrows$DOM$querySelector("html") %>% 
        `[[`(1) %>% 
        plugbrows$DOM$getOuterHTML() %>% 
        `[[`(1) %>% 
        xml2::read_html() %>% 
        html_elements('span.problem.ng-scope')%>%
        rvest::html_text()
      #(3) Connector Used
      x <- plugbrows$DOM$getDocument()
      connector=x$root$nodeId %>% 
        plugbrows$DOM$querySelector("html") %>% 
        `[[`(1) %>% 
        plugbrows$DOM$getOuterHTML() %>% 
        `[[`(1) %>% 
        xml2::read_html() %>% 
        html_elements('span.connector.ng-binding')%>%
        rvest::html_text()
      #(4) Username
      x <- plugbrows$DOM$getDocument()
      usernames=x$root$nodeId %>% 
        plugbrows$DOM$querySelector("html") %>% 
        `[[`(1) %>% 
        plugbrows$DOM$getOuterHTML() %>% 
        `[[`(1) %>% 
        xml2::read_html() %>% 
        html_elements('span.name.ng-binding')%>%
        rvest::html_text()
      usernames=usernames[usernames!="solarpower"]
      
      #INCORRECT COUNTS
      #(5) User's Car
      x <- plugbrows$DOM$getDocument()
      usercars=x$root$nodeId %>% 
        plugbrows$DOM$querySelector("html") %>% 
        `[[`(1) %>% 
        plugbrows$DOM$getOuterHTML() %>% 
        `[[`(1) %>% 
        xml2::read_html() %>% 
        html_elements('div.car.ng-binding')%>%
        rvest::html_text()
      idx=checkins+1
      usercars=usercars[idx:length(usercars)]
      #(6) Date
      x <- plugbrows$DOM$getDocument()
      dates=x$root$nodeId %>% 
        plugbrows$DOM$querySelector("html") %>% 
        `[[`(1) %>% 
        plugbrows$DOM$getOuterHTML() %>% 
        `[[`(1) %>% 
        xml2::read_html() %>% 
        html_elements('div.date.ng-binding')%>%
        rvest::html_text()
      idx=checkins+1
      dates=dates[idx:length(dates)]
      #(7) Comment
      x <- plugbrows$DOM$getDocument()
      comments=x$root$nodeId %>% 
        plugbrows$DOM$querySelector("html") %>% 
        `[[`(1) %>% 
        plugbrows$DOM$getOuterHTML() %>% 
        `[[`(1) %>% 
        xml2::read_html() %>% 
        html_elements("[ng-repeat='checkin in maps.all_reviews']")%>%
        rvest::html_text()
    }
    else{
      #CORRECT COUNTS ONLY::
      #(1) Kilowatts When Charging
      x <- plugbrows$DOM$getDocument()
      kilowatt=x$root$nodeId %>% 
        plugbrows$DOM$querySelector("html") %>% 
        `[[`(1) %>% 
        plugbrows$DOM$getOuterHTML() %>% 
        `[[`(1) %>% 
        xml2::read_html() %>% 
        html_elements('span.kilowatts.ng-scope')%>%
        rvest::html_text()
      #(2) Problem with Charging
      x <- plugbrows$DOM$getDocument()
      probcharg=x$root$nodeId %>% 
        plugbrows$DOM$querySelector("html") %>% 
        `[[`(1) %>% 
        plugbrows$DOM$getOuterHTML() %>% 
        `[[`(1) %>% 
        xml2::read_html() %>% 
        html_elements('span.problem.ng-scope')%>%
        rvest::html_text()
      #(3) Connector Used
      x <- plugbrows$DOM$getDocument()
      connector=x$root$nodeId %>% 
        plugbrows$DOM$querySelector("html") %>% 
        `[[`(1) %>% 
        plugbrows$DOM$getOuterHTML() %>% 
        `[[`(1) %>% 
        xml2::read_html() %>% 
        html_elements('span.connector.ng-binding')%>%
        rvest::html_text()
      #(4) Username
      x <- plugbrows$DOM$getDocument()
      usernames=x$root$nodeId %>% 
        plugbrows$DOM$querySelector("html") %>% 
        `[[`(1) %>% 
        plugbrows$DOM$getOuterHTML() %>% 
        `[[`(1) %>% 
        xml2::read_html() %>% 
        html_elements('span.name.ng-binding')%>%
        rvest::html_text()
      usernames=usernames[usernames!="solarpower"]
      
      #INCORRECT COUNTS
      #(5) User's Car
      x <- plugbrows$DOM$getDocument()
      usercars=x$root$nodeId %>% 
        plugbrows$DOM$querySelector("html") %>% 
        `[[`(1) %>% 
        plugbrows$DOM$getOuterHTML() %>% 
        `[[`(1) %>% 
        xml2::read_html() %>% 
        html_elements('div.car.ng-binding')%>%
        rvest::html_text()
      idx=5+1
      usercars=usercars[idx:length(usercars)]
      #(6) Date
      x <- plugbrows$DOM$getDocument()
      dates=x$root$nodeId %>% 
        plugbrows$DOM$querySelector("html") %>% 
        `[[`(1) %>% 
        plugbrows$DOM$getOuterHTML() %>% 
        `[[`(1) %>% 
        xml2::read_html() %>% 
        html_elements('div.date.ng-binding')%>%
        rvest::html_text()
      idx=5+1
      dates=dates[idx:length(dates)]
      #(7) Comment
      x <- plugbrows$DOM$getDocument()
      comments=x$root$nodeId %>% 
        plugbrows$DOM$querySelector("html") %>% 
        `[[`(1) %>% 
        plugbrows$DOM$getOuterHTML() %>% 
        `[[`(1) %>% 
        xml2::read_html() %>% 
        html_elements("[ng-repeat='checkin in maps.all_reviews']")%>%
        rvest::html_text()
    }
  }
  else{

    ###Click Review Controller
    x1<- plugbrows$DOM$getDocument()
    x2 <- plugbrows$DOM$querySelector(x1$root$nodeId, "[ng-controller='ReviewsController']")
    
    box=plugbrows$DOM$getBoxModel(x2$nodeId)
    plugbrows$DOM$scrollIntoViewIfNeeded(x2$nodeId,wait_ = T,timeout_ = 60*1000)
    
    #RESET DOM
    
    x1<- plugbrows$DOM$getDocument()
    x2 <- plugbrows$DOM$querySelector(x1$root$nodeId, "[ng-controller='ReviewsController']")

    box=plugbrows$DOM$getBoxModel(x2$nodeId)
    
    br=box$model$border
    x=(br[[1]]+br[[5]])/2
    y=(br[[2]]+br[[6]])/2
    plugbrows$Input$dispatchMouseEvent(type = "mousePressed", x = x, y = y, button="left",clickCount = 1,wait_ = T,timeout_ = 60*1000)
    plugbrows$Input$dispatchMouseEvent(type = "mouseReleased", x = x, y = y, button="left",clickCount = 1,wait_ = T,timeout_ = 60*1000)
    if(checkins<5){
      #CORRECT COUNTS ONLY::
      #(1) Kilowatts When Charging
      x <- plugbrows$DOM$getDocument()
      kilowatt=x$root$nodeId %>% 
        plugbrows$DOM$querySelector("html") %>% 
        `[[`(1) %>% 
        plugbrows$DOM$getOuterHTML() %>% 
        `[[`(1) %>% 
        xml2::read_html() %>% 
        html_elements('span.kilowatts.ng-scope')%>%
        rvest::html_text()
      #(2) Problem with Charging
      x <- plugbrows$DOM$getDocument()
      probcharg=x$root$nodeId %>% 
        plugbrows$DOM$querySelector("html") %>% 
        `[[`(1) %>% 
        plugbrows$DOM$getOuterHTML() %>% 
        `[[`(1) %>% 
        xml2::read_html() %>% 
        html_elements('span.problem.ng-scope')%>%
        rvest::html_text()
      #(3) Connector Used
      x <- plugbrows$DOM$getDocument()
      connector=x$root$nodeId %>% 
        plugbrows$DOM$querySelector("html") %>% 
        `[[`(1) %>% 
        plugbrows$DOM$getOuterHTML() %>% 
        `[[`(1) %>% 
        xml2::read_html() %>% 
        html_elements('span.connector.ng-binding')%>%
        rvest::html_text()
      #(4) Username
      x <- plugbrows$DOM$getDocument()
      usernames=x$root$nodeId %>% 
        plugbrows$DOM$querySelector("html") %>% 
        `[[`(1) %>% 
        plugbrows$DOM$getOuterHTML() %>% 
        `[[`(1) %>% 
        xml2::read_html() %>% 
        html_elements('span.name.ng-binding')%>%
        rvest::html_text()
      usernames=usernames[usernames!="solarpower"]
      
      #INCORRECT COUNTS
      #(5) User's Car
      x <- plugbrows$DOM$getDocument()
      usercars=x$root$nodeId %>% 
        plugbrows$DOM$querySelector("html") %>% 
        `[[`(1) %>% 
        plugbrows$DOM$getOuterHTML() %>% 
        `[[`(1) %>% 
        xml2::read_html() %>% 
        html_elements('div.car.ng-binding')%>%
        rvest::html_text()
      idx=checkins+1
      usercars=usercars[idx:length(usercars)]
      #(6) Date
      x <- plugbrows$DOM$getDocument()
      dates=x$root$nodeId %>% 
        plugbrows$DOM$querySelector("html") %>% 
        `[[`(1) %>% 
        plugbrows$DOM$getOuterHTML() %>% 
        `[[`(1) %>% 
        xml2::read_html() %>% 
        html_elements('div.date.ng-binding')%>%
        rvest::html_text()
      idx=checkins+1
      dates=dates[idx:length(dates)]
      #(7) Comment
      x <- plugbrows$DOM$getDocument()
      comments=x$root$nodeId %>% 
        plugbrows$DOM$querySelector("html") %>% 
        `[[`(1) %>% 
        plugbrows$DOM$getOuterHTML() %>% 
        `[[`(1) %>% 
        xml2::read_html() %>% 
        html_elements("[ng-repeat='checkin in maps.all_reviews']")%>%
        rvest::html_text()
    }
    else{
      #CORRECT COUNTS ONLY::
      #(1) Kilowatts When Charging
      x <- plugbrows$DOM$getDocument()
      kilowatt=x$root$nodeId %>% 
        plugbrows$DOM$querySelector("html") %>% 
        `[[`(1) %>% 
        plugbrows$DOM$getOuterHTML() %>% 
        `[[`(1) %>% 
        xml2::read_html() %>% 
        html_elements('span.kilowatts.ng-scope')%>%
        rvest::html_text()
      #(2) Problem with Charging
      x <- plugbrows$DOM$getDocument()
      probcharg=x$root$nodeId %>% 
        plugbrows$DOM$querySelector("html") %>% 
        `[[`(1) %>% 
        plugbrows$DOM$getOuterHTML() %>% 
        `[[`(1) %>% 
        xml2::read_html() %>% 
        html_elements('span.problem.ng-scope')%>%
        rvest::html_text()
      #(3) Connector Used
      x <- plugbrows$DOM$getDocument()
      connector=x$root$nodeId %>% 
        plugbrows$DOM$querySelector("html") %>% 
        `[[`(1) %>% 
        plugbrows$DOM$getOuterHTML() %>% 
        `[[`(1) %>% 
        xml2::read_html() %>% 
        html_elements('span.connector.ng-binding')%>%
        rvest::html_text()
      #(4) Username
      x <- plugbrows$DOM$getDocument()
      usernames=x$root$nodeId %>% 
        plugbrows$DOM$querySelector("html") %>% 
        `[[`(1) %>% 
        plugbrows$DOM$getOuterHTML() %>% 
        `[[`(1) %>% 
        xml2::read_html() %>% 
        html_elements('span.name.ng-binding')%>%
        rvest::html_text()
      usernames=usernames[usernames!="solarpower"]
      
      #INCORRECT COUNTS
      #(5) User's Car
      x <- plugbrows$DOM$getDocument()
      usercars=x$root$nodeId %>% 
        plugbrows$DOM$querySelector("html") %>% 
        `[[`(1) %>% 
        plugbrows$DOM$getOuterHTML() %>% 
        `[[`(1) %>% 
        xml2::read_html() %>% 
        html_elements('div.car.ng-binding')%>%
        rvest::html_text()
      idx=5+1
      usercars=usercars[idx:length(usercars)]
      #(6) Date
      x <- plugbrows$DOM$getDocument()
      dates=x$root$nodeId %>% 
        plugbrows$DOM$querySelector("html") %>% 
        `[[`(1) %>% 
        plugbrows$DOM$getOuterHTML() %>% 
        `[[`(1) %>% 
        xml2::read_html() %>% 
        html_elements('div.date.ng-binding')%>%
        rvest::html_text()
      idx=5+1
      dates=dates[idx:length(dates)]
      
      #(7) Comment
      x <- plugbrows$DOM$getDocument()
      comments=x$root$nodeId %>% 
        plugbrows$DOM$querySelector("html") %>% 
        `[[`(1) %>% 
        plugbrows$DOM$getOuterHTML() %>% 
        `[[`(1) %>% 
        xml2::read_html() %>% 
        html_elements("[ng-repeat='checkin in maps.all_reviews']")%>%
        rvest::html_text()
      
  
    }

  
  fwrite(data.table::data.table(urlsave=rep(url,length(kilowatt)),
                                probcharg=probcharg,
                                kilowatt=kilowatt,
                                connector=connector,
                                usernames=usernames,
                                usercars=usercars,
                                dates=dates,
                                comments=comments),
         paste0("/home/void/Desktop/Research/Chapter2Research/PlugShareRepo/LocationIDs/ReviewInfo/",
                "locationID",gsub("https://www.plugshare.com/location/","",url),
                ".csv"), 
         col.names = T)
  }
}


#Get single row data, non-parallel
get_data_non_parallel=function(htmltoparse,plugbrows){
  url=htmltoparse
  plugbrows$go_to(url,delay = 12)
  #Latitude
  x <- plugbrows$DOM$getDocument()
  x <- plugbrows$DOM$querySelector(x$root$nodeId, "[property='v:latitude']")
  lat=plugbrows$DOM$getAttributes(x$nodeId)$attributes[[4]]
  #Longitude
  x <- plugbrows$DOM$getDocument()
  x <- plugbrows$DOM$querySelector(x$root$nodeId, "[property='v:longitude']")
  long=plugbrows$DOM$getAttributes(x$nodeId)$attributes[[4]]
  #Checkins
  x <- plugbrows$DOM$getDocument()
  checkins=x$root$nodeId %>% 
    plugbrows$DOM$querySelector("html") %>% 
    `[[`(1) %>% 
    plugbrows$DOM$getOuterHTML() %>% 
    `[[`(1) %>% 
    xml2::read_html() %>% 
    rvest::html_elements("[ng-show='maps.user && maps.checkinType == 2']")%>%
    rvest::html_text()
  #Address
  x <- plugbrows$DOM$getDocument()
  x <- plugbrows$DOM$querySelector(x$root$nodeId, "[property='v:address']")
  address=plugbrows$DOM$getAttributes(x$nodeId)$attributes[[14]]
  #Name
  x <- plugbrows$DOM$getDocument()
  x <- plugbrows$DOM$querySelector(x$root$nodeId, "[property='og:title']")
  name=plugbrows$DOM$getAttributes(x$nodeId)$attributes[[4]]
  #Station Information
  x <- plugbrows$DOM$getDocument()
  stat_info=x$root$nodeId %>% 
    plugbrows$DOM$querySelector("html") %>% 
    `[[`(1) %>% 
    plugbrows$DOM$getOuterHTML() %>% 
    `[[`(1) %>% 
    xml2::read_html() %>% 
    xml_find_all("//*[@class='connector ng-scope']")%>%
    rvest::html_text()
  
  
  fwrite(data.table::data.table(lat=lat,long=long,checkins=checkins,
                                     address=address,name=name,
                                     station_info=Reduce(paste,stat_info),
                                     urlsave=url),
              paste0("/home/void/Desktop/Research/Chapter2Research/PlugShareRepo/LocationIDs/OneObsv/",
                     "locationID",gsub("https://www.plugshare.com/location/","",url),
                     ".csv"), 
              col.names = T)
}


#For labeling the URLs
get_singledata.mod_parallel_simplerev=function(htmltoparse){
  url=htmltoparse
  name=xml2::read_html(url) %>% xml_find_all("//*[@property='og:title']") %>% 
    xml2::xml_attrs() %>% .[[1]] %>% .[[2]]
  
  xy=data.table::data.table(name=name,
                            url_location=url)
  fwrite(xy,
         paste0("/home/void/Desktop/Research/Chapter2Research/PlugShareRepo/LocationIDs/LabelURLS/",
                "locationID",
                gsub("https://www.plugshare.com/location/","",url),
                ".csv"),col.names = T)
}


#For scraping in parallel - can get you banned from the website
get_singledata.mod_parallel=function(htmltoparse){
  url=htmltoparse
  plugbrows=ChromoteSession$new()
  plugbrows$default_timeout=20*1000
  plugbrows$Network$setUserAgentOverride("starfox86") #change this or rotate this to avoid ban
  x=plugbrows$Page$loadEventFired(wait_ = F)

  plugbrows$Page$navigate(url,wait_=F)
  plugbrows$wait_for(x)
  
  #Latitude
  x <- plugbrows$DOM$getDocument()
  x <- plugbrows$DOM$querySelector(x$root$nodeId, "[property='v:latitude']")
  lat=plugbrows$DOM$getAttributes(x$nodeId)$attributes[[4]]

  
  #Longitude
  x <- plugbrows$DOM$getDocument()
  x <- plugbrows$DOM$querySelector(x$root$nodeId, "[property='v:longitude']")
  long=plugbrows$DOM$getAttributes(x$nodeId)$attributes[[4]]
  #Checkins
  x <- plugbrows$DOM$getDocument()
  checkins=x$root$nodeId %>% 
    plugbrows$DOM$querySelector("html") %>% 
    `[[`(1) %>% 
    plugbrows$DOM$getOuterHTML() %>% 
    `[[`(1) %>% 
    xml2::read_html() %>% 
    rvest::html_elements("[ng-show='maps.user && maps.checkinType == 2']")%>%
    rvest::html_text()
  #Address
  x <- plugbrows$DOM$getDocument()
  x <- plugbrows$DOM$querySelector(x$root$nodeId, "[property='v:address']")
  address=plugbrows$DOM$getAttributes(x$nodeId)$attributes[[14]]
  #Name
  x <- plugbrows$DOM$getDocument()
  x <- plugbrows$DOM$querySelector(x$root$nodeId, "[property='og:title']")
  name=plugbrows$DOM$getAttributes(x$nodeId)$attributes[[4]]
  #Station Information
  x <- plugbrows$DOM$getDocument()
  stat_info=x$root$nodeId %>% 
    plugbrows$DOM$querySelector("html") %>% 
    `[[`(1) %>% 
    plugbrows$DOM$getOuterHTML() %>% 
    `[[`(1) %>% 
    xml2::read_html() %>% 
    xml_find_all("//*[@class='connector ng-scope']")%>%
    rvest::html_text()
    xy=data.table::data.table(lat=lat,long=long,checkins=checkins,
                              address=address,name=name,
                              station_info=Reduce(paste,stat_info),
                              urlsave=url,
                              date_pull=date())
  
  fwrite(xy,
              paste0("/home/void/Desktop/Research/Chapter2Research/PlugShareRepo/LocationIDs/OneObsv/",
                     "locationID",
                     gsub("https://www.plugshare.com/location/","",url),
                     ".csv"),col.names = T)
  plugbrows$close()
}

login_func=function(plugbrows,username,password){ #If you get logged out, use this function

  #Click login
  x1<- plugbrows$DOM$getDocument()
  x2 <- plugbrows$DOM$querySelector(x1$root$nodeId, "div.clickable.ng-binding")
  box=plugbrows$DOM$getBoxModel(x2$nodeId)
  br=box$model$border
  x=(br[[1]]+br[[5]])/2
  y=(br[[2]]+br[[6]])/2
  plugbrows$Input$dispatchMouseEvent(type = "mousePressed", x = x, y = y, button="left",clickCount = 1,wait_ = T,timeout_ = 60*1000)
  plugbrows$Input$dispatchMouseEvent(type = "mouseReleased", x = x, y = y, button="left",clickCount = 1,wait_ = T,timeout_ = 60*1000)
  #Click email
  x1<- plugbrows$DOM$getDocument()
  x2 <- plugbrows$DOM$querySelector(x1$root$nodeId, "#email")
  box=plugbrows$DOM$getBoxModel(x2$nodeId)
  br=box$model$border
  x=(br[[1]]+br[[5]])/2
  y=(br[[2]]+br[[6]])/2
  plugbrows$Input$dispatchMouseEvent(type = "mousePressed", x = x, y = y, button="left",clickCount = 1,wait_ = T,timeout_ = 60*1000)
  plugbrows$Input$dispatchMouseEvent(type = "mouseReleased", x = x, y = y, button="left",clickCount = 1,wait_ = T,timeout_ = 60*1000)
  plugbrows$Input$insertText(username)
  #Password
  x1<- plugbrows$DOM$getDocument()
  x2 <- plugbrows$DOM$querySelector(x1$root$nodeId, "#input_259")
  box=plugbrows$DOM$getBoxModel(x2$nodeId)
  br=box$model$border
  x=(br[[1]]+br[[5]])/2
  y=(br[[2]]+br[[6]])/2
  plugbrows$Input$dispatchMouseEvent(type = "mousePressed", x = x, y = y, button="left",clickCount = 1,wait_ = F,timeout_ = 60*1000)
  plugbrows$Input$dispatchMouseEvent(type = "mouseReleased", x = x, y = y, button="left",clickCount = 1,wait_ = F,timeout_ = 60*1000)
  plugbrows$Input$insertText(password)
  #Now login!
  x1<- plugbrows$DOM$getDocument()
  x2 <- plugbrows$DOM$querySelector(x1$root$nodeId, "button.md-primary.md-raised.md-button.ng-scope.md-ink-ripple")
  box=plugbrows$DOM$getBoxModel(x2$nodeId)
  br=box$model$border
  x=(br[[1]]+br[[5]])/2
  y=(br[[2]]+br[[6]])/2
  plugbrows$Input$dispatchMouseEvent(type = "mousePressed", x = x, y = y, button="left",clickCount = 1,wait_ = F,timeout_ = 60*1000)
  plugbrows$Input$dispatchMouseEvent(type = "mouseReleased", x = x, y = y, button="left",clickCount = 1,wait_ = F,timeout_ = 60*1000)
  
}




####### Trying with Chromote #####
url="https://plugshare.com/location/100" #just for a test
#Download chrome headless shell for optimizing code
Sys.setenv(CHROMOTE_CHROME="/home/void/Desktop/Research/Chapter2Research/chrome-headless-shell-linux64/chrome-headless-shell")

test1=rvest::read_html_live(url)
plug_sesh=test1$session
rm(test1)
plug_sesh$default_timeout=20*1000

#Testing functions:
url1="https://www.plugshare.com/location/5"
url2="https://www.plugshare.com/location/100"
url3="https://www.plugshare.com/location/101"
url4="https://www.plugshare.com/location/140578"

#may need to run this twice, if not already logged in, works fine after, will not work if station has 0 reviews
lapply(data$locs[1:10],get_review_info_non_parallel,plug_sesh,
       username="**********",
       password="**********")

lapply(url1,get_data_non_parallel,plug_sesh)

mclapply(url3,mc.cores=2,get_singledata.mod_parallel_simplerev)

get_singledata.mod_parallel(url1)


##### Organizing by State ####
full_locations=read.csv("~/Desktop/Research/Chapter2Research/PlugShareRepo/full_locationnames_urls.csv")
#Create vector to match states by string
state_plug=paste0(", ",state.abb," ","\\|","|",state.name)
state_plug=c(state_plug,paste0("United States","|",", USA \\|"))
#match string containing state pattern to charging station's location name
labelmatch=function(pat,data1){ 
  (grepl(pat,data1,fixed = F))
}



b1=mclapply(state_plug,labelmatch,full_locations$name,
         mc.cores = 7)


check_this=function(x){
  which(x==TRUE)
}

us_obs=mclapply(b1,check_this,mc.cores = 7)
names(us_obs)=c(state.abb,"UnsortedUSA")

sort_indiv_states=function(idxs,df,filter1){
  fwrite(df[filter1[[idxs]],],
         file=paste0("/home/void/Desktop/Research/Chapter2Research/PlugShareRepo/IndivStates/",
                                  idxs,".csv"),col.names = T)
}

lapply(names(us_obs),sort_indiv_states,full_locations,us_obs)

####################### CT ONLY ##############################
CleanedFullSuccessesinR <-
  read.csv("~/Desktop/Research/Chapter2Research/PlugShareRepo/CleanedFullSuccessesinR.csv")

CTOnly=CleanedFullSuccessesinR[which(grepl(state_plug[7],CleanedFullSuccessesinR$name)),]

fwrite(CTOnly,file=paste0("/home/void/Desktop/Research/Chapter2Research/PlugShareRepo_CT/Scrape_5_8_25_CTOnly/",
                                        "CT",".csv"),col.names = T)

############ For Review Info Scrape on 5/11/25 ######################
xy=CleanedFullSuccessesinR[order(CleanedFullSuccessesinR$locationIDs),]
xy=(xy[!xy$checkins=="All Checkins (0)",])
lapply(xy$url_location[1:1000],get_review_info_non_parallel,plug_sesh)

##### Merge Review Info -- CT Only ######
CT$urlsave=CT$url_location
df=list(ReviewInfoSofar,CT) %>%
  purrr::reduce(plyr::join, type='left',match='first', by = c("urlsave"))
fwrite(na.omit(df),file="/home/void/Desktop/Research/Chapter2Research/PlugShareRepo/CTReviewsOnly.csv",col.names = T)
