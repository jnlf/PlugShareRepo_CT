
##### For pulling in new location IDs, if needed ####
#Retrieving all location ids
links_to_ids=read_html("https://www.plugshare.com/sitemap_new_index.xml")
links_to_ids=links_to_ids %>% rvest::html_elements("loc") %>% html_text2()

getallcharg_locs=function(htmltoparse){
  print(htmltoparse)
  plughtml=read_html(htmltoparse) %>% rvest::html_elements("loc") %>% html_text2()
}

n.cores=parallel::detectCores()
clust=parallel::makeCluster(n.cores)
parallel::clusterEvalQ(clust, library("rvest"))
all_plugshare=parSapply(cl=clust,links_to_ids,getallcharg_locs)

plug_sharelocs=data.frame(c(all_plugshare[[1]],all_plugshare[[2]],
                            all_plugshare[[3]],all_plugshare[[4]],
                            all_plugshare[[5]],all_plugshare[[6]],
                            all_plugshare[[7]],all_plugshare[[8]],
                            all_plugshare[[9]],all_plugshare[[10]],
                            all_plugshare[[11]],all_plugshare[[12]],
                            all_plugshare[[13]],all_plugshare[[14]],
                            all_plugshare[[15]],all_plugshare[[16]],
                            all_plugshare[[17]]))
write.csv(plug_sharelocs,file="/home/void/Desktop/Research/Chapter2Research/testing/plugsharelocs.csv")
