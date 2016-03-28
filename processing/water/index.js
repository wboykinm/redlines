var fs = require('fs');
var sm = new (require('sphericalmercator'));
var request = require('request');

var bBox = process.argv[2];
var outFile = process.argv[3];
var mzUrlBase = 'http://vector.mapzen.com/osm/water/';
var mzUrlSuffix = '.json?api_key=vector-tiles-TE70otI';

/*var merc = new sm({
    size: 256
});
*/
console.log(sm.xyz(bBox,14,true,'WGS84'));
/*
request(mzUrlBase + z + '/' + x + '/' + y + mzUrlSuffix, function (error, response, body) {
  if (error) {
    console.error('encountered error', error instanceof Error ? error.stack : error);
  } else if (response.statusCode === 429) {
    console.log('error 429')
  } else if (response.statusCode !== 200) {
    console.error('non-200 status code: ' + response.statusCode);
  } else {
    fs.writeFile(outFile, JSON.stringify(body) , 'utf-8');
  }
});*/