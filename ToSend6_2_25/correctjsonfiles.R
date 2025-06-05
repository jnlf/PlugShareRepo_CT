#run this if things don't merge afterwards
#run python code mergejsonfiles.py
library(magrittr)
library(tidyverse)
merged_file <- read.csv("~/Desktop/Research/PlugShareCrawleeProject/output.csv", header=FALSE)
lk=dim(merged_file)[1]
merged_file1=data.frame(merged_file[2:lk,])
new_names=c("url","Latitude","Longitude","Address","PlugType",
            "PlugPower","StationCount","AvailableCount","InUseCount",
            "UnavailCount","ChargNetwork","DatePull")
new_column=rep(new_names,lk/length(new_names))
merged_file1=cbind(merged_file1,new_column)
names(merged_file1)=c("datapoints","new_column")

final_ct=merged_file1 %>% group_by(new_column) %>% mutate(row=row_number()) %>%
  tidyr::pivot_wider(names_from=new_column,values_from=datapoints)
write.csv(final_ct,file = paste0("/home/void/Desktop/Research/PlugShareCrawleeProject/CompletedRuns/",as.numeric(Sys.time()),".csv"))
