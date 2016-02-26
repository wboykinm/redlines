var turf = require('turf');
var fs = require('fs');
var dissolve = require ('../dissolve/index.js')

var basicTracts = fs.readFileSync(process.argv[2]);
basicTracts = JSON.parse(basicTracts);

var dissolvedTracts = dissolve(basicTracts, 'largest_community_name');
fs.writeFileSync('./dissolvedTracts.geojson', JSON.stringify(dissolvedTracts));

console.log('done');