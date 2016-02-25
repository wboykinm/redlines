// USAGE: node index.js <inFile>
var fs = require('fs');
var csv = require('fast-csv');
var through2 = require('through2');

var inFile = process.argv[2];
var outFile = inFile + '.tmp'
var outStream = fs.createWriteStream(outFile);

var getMax = function(row, callback) {
  // Get just the flattened category values:
  var rowLength = Object.keys(row).length;
  var rowNew = JSON.parse(JSON.stringify(row));
  var extraneous = Object.keys(row).sort().slice(rowLength - 3);
  // remove aggregate categories ("white", "hispanic", etc.) from calculation:
  extraneous.push('P0010001','P0030002','P0030005','P0030007','P0030008','P0040003');
  var remove = function(e, i, a) {
    delete row[e];
  };
  extraneous.forEach(remove);
  
  // Find the maximum of those
  var maxKey = Object.keys(row).reduce(function(a, b){ return row[a] > row[b] ? a : b });
  
  // Append to the row:
  rowNew['largest_group'] = maxKey;
  rowNew['largest_group_count'] = rowNew[maxKey];
  rowNew['largest_group_proportion'] = (rowNew[maxKey] / rowNew.P0010001) || 0;
  callback(null, rowNew);
};

csv
  .fromPath(inFile, {objectMode: true, headers: true})
  .pipe(through2.obj(
    function (row, enc, callback) {
      getMax(row, callback);
    })
  )
  .pipe(csv.createWriteStream({headers: true}))
  .pipe(outStream);
  