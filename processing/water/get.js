// SPIT OUT A NAMED GEOJSON FILE FOR EACH INPUT TILE ADDRESS

var fs = require('fs');
var request = require('request');
var turf = require('turf');
var Protobuf = require('pbf');
var VectorTile = require('vector-tile').VectorTile;;

var bigTile = process.argv[2];
var outDir = process.argv[3];
var mbToken = process.argv[4];
var mbUrlBase = 'http://a.tiles.mapbox.com/v4/mapbox.mapbox-streets-v6/';
var mbUrlSuffix = '.vector.pbf?access_token=' + mbToken;

var x = JSON.parse(bigTile)[0];
var y = JSON.parse(bigTile)[1];
var z = JSON.parse(bigTile)[2];

var getTile = request(mbUrlBase + z + '/' + x + '/' + y + mbUrlSuffix, function (error, response, body) {
  if (error) {
    console.error('encountered error', error instanceof Error ? error.stack : error);
  } else if (response.statusCode === 429) {
    console.log('error 429');
  } else if (response.statusCode !== 200) {
    console.error('non-200 status code: ' + response.statusCode);
  } else {
    //console.log(body);
    var geojson = geobuf.decode(new Pbf(body));
    console.log(geojson);
    //geojson = JSON.parse(geojson);
  }
});

getTile;