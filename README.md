(Forked from jnlf PlugShareRepo)
Explanation of Directories:
- Figures
- just a code snippet of merging individual CSV files in linux (it is a png) file
- LocationIDs
- directory within three individal folders for testing how functions work
- CTReviewsOnly
- this is the review information that I started to collect just yesterday, 5/11/25 in individual files on multiple machines
- Scrape_5_8_25_CTOnly/CT.csv
- this contains latitude, longitude, availability of chargers at time of scrape over three machines starting from 5/8/2025
- IndivStates_CT_only/CT.csv
- contains labeled urls for CT only
- The Main R files are:
- WebScraping... --> contains functions for scraping and tests of the functions (both for parallel and non-parallel, make sure to download chrome headless driver from this link: https://googlechromelabs.github.io/chrome-for-testing/
- PullValidLocations... --> update location IDs if you want
- MergingScrapesandCleaning --> clean initial scraping
