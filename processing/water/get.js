// SPIT OUT A NAMED GEOJSON FILE FOR EACH INPUT TILE ADDRESS

var fs = require('fs');
var request = require('request');
var turf = require('turf');
var Protobuf = require('pbf');
var VectorTile = require('vector-tile').VectorTile;

var bigTile = process.argv[2];
var outDir = process.argv[3];
var mbToken = process.argv[4];
var mbUrlBase = 'http://a.tiles.mapbox.com/v4/mapbox.mapbox-streets-v7/';
var mbUrlSuffix = '.vector.pbf?access_token=' + mbToken;

var x = JSON.parse(bigTile)[0];
var y = JSON.parse(bigTile)[1];
var z = JSON.parse(bigTile)[2];

var getTile = request({url: mbUrlBase + z + '/' + x + '/' + y + mbUrlSuffix, gzip: true, encoding: null}, function (error, response, body) {
  if (error) {
    console.error('encountered error', error instanceof Error ? error.stack : error);
  } else if (response.statusCode === 429) {
    console.log('error 429');
  } else if (response.statusCode !== 200) {
    console.error('non-200 status code: ' + response.statusCode);
  } else {
    var buf = new Protobuf(body);
    var vt = new VectorTile(buf);
    var layer = vt.layers['water'];
    if (layer && layer.length > 0) {
      var waterSet = {"type":"FeatureCollection","features":[]};
      for (var i = 0; i < layer.length; i++) {
        var feature = layer.feature(i).toGeoJSON(x,y,z);      
        waterSet.features.push(feature);
      }
      fs.writeFile(outDir + 'osm_water_' + x + '_' + y + '_' + z + '.geojson', JSON.stringify(waterSet), 'utf-8');
      console.log('got tile {' + z + '}/{' + x + '}/{' + y + '}');
    }
    else {
      console.log('no water features at tile {' + z + '}/{' + x + '}/{' + y + '}')
    }
  }
});

getTile;