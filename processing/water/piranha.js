var turf = require('turf')
var fs = require('fs')

// wow. such vars.
var tractPolys = JSON.parse(fs.readFileSync(process.argv[2]));
var piranhas = JSON.parse(fs.readFileSync(process.argv[3]));
var piranhaPolys = {"type":"FeatureCollection","features":[]};
var tractsEaten = {"type":"FeatureCollection","features":[]};

console.log('Processing ' + process.argv[3] + ' with ' + piranhas.features.length + ' water features');

if (piranhas.features.length > 0) {
  // Isolate the water polygons from all that other osm noise
  for (var p = 0; p < piranhas.features.length; p++) {
    if (piranhas.features[p].geometry.type == 'Polygon' || piranhas.features[p].geometry.type == 'MultiPolygon') {
      piranhaPolys.features.push(piranhas.features[p]);
    } 
  };

  // dissolve the water polygons
  var piranhaPolys = turf.merge(piranhaPolys);

  // loop through all tracts looking for intersection
  for (var i = 0; i < tractPolys.features.length; i++) {
    // chomp water from tract polygon if intersecting
    if (turf.intersect(piranhaPolys,tractPolys.features[i])) {
      console.log('Tract ' + tractPolys.features[i].properties.TRACTCE + ' is wet. Chomping . . .')
      tractsEaten.features.push(turf.erase(tractPolys.features[i],piranhaPolys));
    } 
    // otherwise just write the tract polygon as is
    else {
      //console.log('Tract ' + tractPolys.features[i].properties.TRACTCE + ' is dry.')
      tractsEaten.features.push(tractPolys.features[i])
    }
  }

  //cut and print to file
  fs.writeFileSync(process.argv[2], JSON.stringify(tractsEaten));
} else {
  fs.writeFileSync(process.argv[2], JSON.stringify(tractPolys));
}