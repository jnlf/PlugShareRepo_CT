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
      const ChargNetwork = await page.locator('i.ng-binding').allTextContents();

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
  ChargNetwork
}

await Dataset.pushData(results);

},});

const {urls} = await Sitemap.load('https://www.plugshare.com/sitemap_new_850001.xml');


await crawler.addRequests(urls.slice(0,5));
await crawler.run();

await Dataset.exportToCSV('results');