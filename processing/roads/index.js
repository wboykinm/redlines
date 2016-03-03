var fs = require('fs');
var overpass = require('query-overpass');
var bBox = process.argv[2];
var fipsState = process.argv[3];
var fipsCounty = process.argv[4];
var outFile = process.argv[5];

overpass('[out:json];way[highway="motorway"]' + bBox + ';way[highway="primary"]' + bBox + ';(._;>;);out;', function(err, data) {
  if (err) {
    console.log('Unknown Error');
    console.log(err);
    return;
  }
  fs.writeFile(outFile, JSON.stringify(data) , 'utf-8');
}, {
  flatProperties: true
});