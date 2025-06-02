/*
Need to do the following
npm install crawlee
npm install playwright
npx playwright install
npm install fs
*/


import { PlaywrightCrawler,Dataset,ProxyConfiguration,Sitemap } from 'crawlee';
import {rename} from 'node:fs';
import fs from "fs";

//Still trying to find working proxies
//const proxyConfiguration = new ProxyConfiguration({
//  proxyUrls: ["https://178.18.248.104:49153"],
//});


const crawler = new PlaywrightCrawler({
    requestHandlerTimeoutSecs: 1800, /* timeout after 30 minutes */

    //proxyConfiguration,
    // Function called for each URL
    async requestHandler({waitForSelector, request, page}) {
      //Wait for the following selectors
      //Latitude
      await page.locator("[property='v:latitude']").locator('nth=-1').waitFor({state:"attached"}); // .locator('nth=-1') because we wait for last element to load
      //Longitude
      await page.locator("[property='v:longitude']").locator('nth=-1').waitFor({state:"attached"});
      //Address
      await page.locator("[property='v:address']").locator('nth=-1').waitFor({state:"attached"});
      //PlugType
      await page.locator("span.plug-name.ng-binding").locator('nth=-1').waitFor({state:"attached"});
      //PlugPower
      await page.locator("span.plug-power.ng-binding").locator('nth=-1').waitFor({state:"attached"});
      //StationCount
      await page.locator("span.station-count.ng-binding").locator('nth=-1').waitFor({state:"attached"});
      //Available Count
      await page.locator('div.status-dots div.many[title*="Available"] span.num.ng-binding').locator('nth=-1').waitFor({state:"attached"});
      //InUse Count
      await page.locator('div.status-dots div.many[title*="In Use"] span.num.ng-binding').locator('nth=-1').waitFor({state:"attached"});
      //Unavailable Count
      await page.locator('div.status-dots div.many[title*="Unavailable"] span.num.ng-binding').locator('nth=-1').waitFor({state:"attached"});
      //Charging Station Network
      await page.locator("[ng-show='connector.networks.length > 0']").locator('nth=-1').waitFor({state:"attached"});




      //Latitude
      const Latitude = await page.locator("[property='v:latitude']").allTextContents();
      //Longitude
      const Longitude = await page.locator("[property='v:longitude']").allTextContents();
      //Address
      const Address = await page.locator("[property='v:address']").allTextContents();
      //PlugType
      const PlugType = await page.locator("span.plug-name.ng-binding").allTextContents();
      //PlugPower
      const PlugPower = await page.locator("span.plug-power.ng-binding").allTextContents();
      //StationCount
      const StationCount = await page.locator("span.station-count.ng-binding").allTextContents();
      //Available Count
      const AvailableCount = await page.locator('div.status-dots div.many[title*="Available"] span.num.ng-binding').allTextContents();
      //InUse Count
      const InUseCount = await page.locator('div.status-dots div.many[title*="In Use"] span.num.ng-binding').allTextContents();
      //Unavailable Count
      const UnavailCount = await page.locator('div.status-dots div.many[title*="Unavailable"] span.num.ng-binding').allTextContents();
      //Charging Station Network
      const ChargNetwork = await page.locator("[ng-show='connector.networks.length > 0']").allTextContents();
      //Write Date of Scrape Also:
      const DatePull = new Date().toString();

const results={
  url:request.url,
  Latitude,
  Longitude,
  Address,
  PlugType,
  PlugPower,
  StationCount,
  AvailableCount,
  InUseCount,
  UnavailCount,
  ChargNetwork,
  DatePull
}

await Dataset.pushData(results);

},});

//Place individual state files in folder as txt files
const urls = fs.readFileSync('/home/void/Desktop/Research/PlugShareCrawleeProject/IndivStatesTXT/CT.txt',
   { encoding: 'utf8', flag: 'r' }).toString().split("\n");


for(let j=0;j<urls.length; j++){
  await crawler.run(urls.slice(j,j+1));
}

//this will push the completed csv into the project folder, under storage/key_value_stores/default/results2.csv

const finaldate= new Date().getTime().toString();
await Dataset.exportToCSV(finaldate);

//for test run
//await crawler.run(["https://www.plugshare.com/location/458314"]);

//change these to match your directory
const filename1='/home/void/Desktop/Research/PlugShareCrawleeProject/storage/key_value_stores/default/'+finaldate+'.csv';
const filename2='/home/void/Desktop/Research/PlugShareCrawleeProject/CompletedRuns/'+finaldate+'.csv';


//Pump this out to a different directory after finished running.
rename(filename1, filename2, (err) => {
  if (err) throw err;
  console.log('Rename complete!');
}); 



process.exit(); //Complete Process
