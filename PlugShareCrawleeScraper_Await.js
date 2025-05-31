/*npm install crawlee*/
/*npm install playwright*/
/*npm install papaparse*/ /*experiment with bringing in csv*/
/*npm install jquery-csv*/ /*experiment with bringing in csv*/

import { PlaywrightCrawler,Dataset,ProxyConfiguration,Sitemap } from 'crawlee';



/*const proxyConfiguration = new ProxyConfiguration({
  proxyUrls: ["http://2001:67c:e60:c0c:192:42:116:174:9004"],
});*/


const crawler = new PlaywrightCrawler({
  //proxyConfiguration,
    // Function called for each URL
    async requestHandler({waitForSelector, request, page}) {
      //Wait for the following selectors

      /*await waitForSelector(`
        [property='v:latitude'],
        [property='v:longitude'],
        [property='v:address'],
        [property='og:title'],
        span.plug-name.ng-binding,
        span.plug-power.ng-binding,
        span.station-count.ng-binding,
        div.status-dots div.many[title*="Available"] span.num.ng-binding,
        div.status-dots div.many[title*="In Use"] span.num.ng-binding,
        div.status-dots div.many[title*="Unavailable"] span.num.ng-binding,
        i.ng-binding`);*/
      //Latitude
      const Latitude = await page.locator("[property='v:latitude']");
      //await Latitude.waitFor({state:"visible"});
      const Latitude1 = await Latitude.allTextContents();
      //Longitude
      const Longitude = await page.locator("[property='v:longitude']");
      //await Longitude.waitFor({state:"visible"});
      const Longitude1 = await Longitude.allTextContents();
      //Address
      const Address = await page.locator("[property='v:address']");
      //await Address.waitFor({state:"attached"});
      const Address1 = await Address.allTextContents();
      //PlugType
      const PlugType = await page.locator("span.plug-name.ng-binding");
      //await PlugType.waitFor({state:"attached"});
      const PlugType1 = await PlugType.allTextContents();
      //PlugPower
      const PlugPower = await page.locator("span.plug-power.ng-binding");
      //await PlugPower.waitFor({state:"attached"});
      const PlugPower1 = await PlugPower.allTextContents();
      //StationCount
      const StationCount = await page.locator("span.station-count.ng-binding");
      //await StationCount.waitFor({state:"attached"});
      const StationCount1 = await StationCount.allTextContents();
      //Available Count
      const AvailableCount = await page.locator('div.status-dots div.many[title*="Available"] span.num.ng-binding');
      //await AvailableCount.waitFor({state:"attached"});
      const AvailableCount1 = AvailableCount.allTextContents();
      //InUse Count
      const InUseCount = await page.locator('div.status-dots div.many[title*="In Use"] span.num.ng-binding');
      //await InUseCount.waitFor({state:"attached"});
      const InUseCount1 = await InUseCount.allTextContents();
      //Unavailable Count
      const UnavailCount = await page.locator('div.status-dots div.many[title*="Unavailable"] span.num.ng-binding');
      //await UnavailCount.waitFor({state:"attached"});
      const UnavailCount1 = await UnavailCount.allTextContents();
      //Charging Station Network
      const ChargNetwork = await page.locator('i.ng-binding');
      //await ChargNetwork.waitFor({state:"attached"});
      const ChargNetwork1 = await ChargNetwork.allTextContents();
headless: false
const results={
  url:request.url,
  Latitude1,
  Longitude1,
  Address1,
  PlugType1,
  PlugPower1,
  StationCount1,
  AvailableCount1,
  InUseCount1,
  UnavailCount1,
  ChargNetwork1
}

await Dataset.pushData(results);

},});

//testing with sitemap

const {urls} = await Sitemap.load('https://www.plugshare.com/sitemap_new_850001.xml');


await crawler.addRequests(urls.slice(0,50));
await crawler.run();

await Dataset.exportToCSV('results');