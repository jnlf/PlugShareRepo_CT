/*
Need to do the following
npm install crawlee
npm install playwright
npx playwright install
npm install fs
*/


import { PlaywrightCrawler,Dataset,ProxyConfiguration,Sitemap,Configuration } from 'crawlee';
import fs from "fs";

//Still trying to find working proxies
/*const proxyConfiguration = new ProxyConfiguration({
  proxyUrls: ["http://127.0.0.1:9150/"],
});
*/
function getRandomDecimal(min, max) {
  return Math.random() * (max - min) + min;
}

const config = Configuration.getGlobalConfig();
config.set('purgeOnStart',0);

const crawler = new PlaywrightCrawler({
    requestHandlerTimeoutSecs: 1800, /* timeout after 30 minutes */
    maxRequestsPerMinute: Math.floor(getRandomDecimal(8,15)),
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
      const url = request.url;

const results={
  url,
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
  DatePull,
};

await Dataset.pushData(results);

},});



var argument=process.argv.slice(2);

//Place individual state files in folder as txt files
const urls = fs.readFileSync('/home/void/Desktop/Research/PlugShareCrawleeProject/RealTimeChunk/'+argument,
   { encoding: 'utf8', flag: 'r' }).toString().split("\n");


const chunkSize = urls.slice(0,urls.length-1); //last line is blank (!)


await new Promise(r => setTimeout(r, (Math.floor((getRandomDecimal(2,5)*1000)))));
await crawler.addRequests(chunkSize);
await crawler.run();



process.exit(); //Complete Process
