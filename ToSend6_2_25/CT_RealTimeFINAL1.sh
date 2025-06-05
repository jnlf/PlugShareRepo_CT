node CTScraper.js CT_RealTimeChunk9.txt
node CTScraper.js CT_RealTimeChunk8.txt
node CTScraper.js CT_RealTimeChunk7.txt
node CTScraper.js CT_RealTimeChunk6.txt
node CTScraper.js CT_RealTimeChunk5.txt
node CTScraper.js CT_RealTimeChunk4.txt
node CTScraper.js CT_RealTimeChunk3.txt
node CTScraper.js CT_RealTimeChunk2.txt
node CTScraper.js CT_RealTimeChunk29.txt
node CTScraper.js CT_RealTimeChunk28.txt
node CTScraper.js CT_RealTimeChunk27.txt
node CTScraper.js CT_RealTimeChunk26.txt
sleep $(shuf -i 100-200 -n 1)
node CTScraper.js CT_RealTimeChunk25.txt
node CTScraper.js CT_RealTimeChunk24.txt
node CTScraper.js CT_RealTimeChunk23.txt
node CTScraper.js CT_RealTimeChunk22.txt
node CTScraper.js CT_RealTimeChunk21.txt
node CTScraper.js CT_RealTimeChunk20.txt
node CTScraper.js CT_RealTimeChunk1.txt
node CTScraper.js CT_RealTimeChunk19.txt
node CTScraper.js CT_RealTimeChunk18.txt
node CTScraper.js CT_RealTimeChunk17.txt
node CTScraper.js CT_RealTimeChunk16.txt
node CTScraper.js CT_RealTimeChunk15.txt
sleep $(shuf -i 100-200 -n 1)
node CTScraper.js CT_RealTimeChunk14.txt
node CTScraper.js CT_RealTimeChunk13.txt
node CTScraper.js CT_RealTimeChunk12.txt
node CTScraper.js CT_RealTimeChunk11.txt
node CTScraper.js CT_RealTimeChunk10.txt
python mergejsonfiles.py
Rscript correctjsonfiles.R
rm -rf storage
sleep 1h
