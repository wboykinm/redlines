var turf = require('turf');
var fs = require('fs');

var mainPolys = JSON.parse(fs.readFileSync(process.argv[2]));
var polysValidated = {"type":"FeatureCollection","features":[]};

for (var p = 0; p < mainPolys.features.length; p++) {
  if (turf.kinks(mainPolys.features[p]).intersections.features.length > 0) {
    console.log('Self-intersecting polygon detected and removed. Intersection(s) at: ');
    console.log(JSON.stringify(turf.kinks(mainPolys.features[p]).intersections));
  }
  else {
    polysValidated.features.push(mainPolys.features[p]);
  } 
}

fs.writeFileSync(process.argv[2], JSON.stringify(polysValidated));
