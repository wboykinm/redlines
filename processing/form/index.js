var turf = require('turf');
var fs = require('fs');
var dissolve = require ('../dissolve/index.js')

var basicTracts = fs.readFileSync(process.argv[2]);
basicTracts = JSON.parse(basicTracts);

// FIXME THIS WHOLE STRING IS A MEMORY FAIL, EVEN EACH OPERATION ON ITS OWN
console.log('buffering out')
var expandedTracts = turf.buffer(basicTracts, 250, 'meters');
console.log('dissolving by largest community')
var dissolvedTracts = dissolve(expandedTracts, 'largest_community_name');
console.log('eroding boundaries')
var erodedTracts = turf.buffer(dissolvedTracts, -275, 'meters');
fs.writeFileSync('./erodedTracts.geojson', JSON.stringify(erodedTracts));

console.log('done');