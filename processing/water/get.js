// SPIT OUT A NAMED GEOJSON FILE FOR EACH INPUT TILE ADDRESS

var fs = require('fs');
var request = require('request');
var turf = require('turf');

var bigTile = process.argv[2];
var outDir = process.argv[3];
var mzUrlBase = 'http://vector.mapzen.com/osm/water/';
var mzUrlSuffix = '.json?api_key=vector-tiles-TE70otI';

var x = JSON.parse(bigTile)[0];
var y = JSON.parse(bigTile)[1];
var z = JSON.parse(bigTile)[2];

var getTile = request(mzUrlBase + z + '/' + x + '/' + y + mzUrlSuffix, function (error, response, body) {
  if (error) {
    console.error('encountered error', error instanceof Error ? error.stack : error);
  } else if (response.statusCode === 429) {
    console.log('error 429');
  } else if (response.statusCode !== 200) {
    console.error('non-200 status code: ' + response.statusCode);
  } else if (JSON.parse(body).features.length > 0 ) {
    body = JSON.parse(body);
    var outWater = {"type":"FeatureCollection","features":[]};
    for (var p = 0; p < body.features.length; p++) {
      if (body.features[p].geometry.type == 'Polygon' || body.features[p].geometry.type == 'MultiPolygon') {
        if (turf.kinks(body.features[p]).intersections.features.length > 0) {
          console.log('Self-intersecting polygon detected and removed. Intersection(s) at: ');
          console.log(JSON.stringify(turf.kinks(body.features[p]).intersections));
        }
        else {
          outWater.features.push(body.features[p]);
        }
      }
    }
    fs.writeFile(outDir + 'osm_water_' + x + '_' + y + '_' + z + '.geojson', JSON.stringify(outWater), 'utf-8');
    console.log('got tile ' + bigTile);
  } else {
    console.log('no water features');
  }
});

getTile;