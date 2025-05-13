(Forked from jnlf PlugShareRepo)
Explanation of Directories:
- Figures
- just a code snippet of merging individual CSV files in linux (it is a png) file
- LocationIDs
- directory within three individal folders for testing how functions work
- OriginalPartsLabelUrls
- This is from scraping on multiple machines the names of the urls for each identified location ID from plugshare's robot.txt file
- ReviewInfo
- this is the review information that I started to collect just yesterday, 5/11/25 in individual files on multiple machines
- Successful Scrapes
- this contains latitude, longitude, availability of chargers at time of scrape over three machines starting from 5/8/2025
- Panasonic Station Files
- more individual csv files from my panasonic laptop
- Updated Plug Share Locs 5/12/25
- Updated plug share location ID urls
- The Main R files are:
- WebScraping... --> contains functions for scraping and tests of the functions (both for parallel and non-parallel, make sure to download chrome headless driver from this link: https://googlechromelabs.github.io/chrome-for-testing/
- PullValidLocations... --> update location IDs if you want
- MergingScrapesandCleaning --> clean initial scraping
