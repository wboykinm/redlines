// USAGE: node index.js <collectionType>
var fs = require('fs');
var csv = require('fast-csv');
var request = require('request');

var collectionType = process.argv[2];
var urlBase = 'https://api.census.gov/data/2010/';
var censusKey = process.argv[3];
var stateFips = parseInt(process.argv[4]);
var countyFips = parseInt(process.argv[5]);
var stateAbbrv = process.argv[6];
var countyName = process.argv[7];
var fields = [];

var outFile = fs.createWriteStream('../../data/tmp_' + stateAbbrv + '_' + countyName + '/' + collectionType + '.csv');

// get fields from key csv
csv
 .fromPath('../../data/census_community_fields.csv', {headers : true})
 .validate(function(data){
    return data.collection == collectionType;
  })
  .on("data", function(data){
    fields.push(data.code);
  })
  .on("end", function(){
    fields = JSON.stringify(fields)
      .replace('[','')
      .replace(']','')
      .replace(/"/g,'');
    var url = urlBase + collectionType + '?key=' + censusKey + '&get=' + fields + '&for=tract:*&in=state:' + stateFips + '+county:' + countyFips;

    // grab data by tract, pipe to csv in data/tmp/
    request(url, function (error, response, body) {
      if (error) {
        console.error('encountered error', error instanceof Error ? error.stack : error);
      } else if (response.statusCode === 429) {
        console.log('error 429')
      } else if (response.statusCode !== 200) {
        console.error('non-200 status code: ' + response.statusCode);
      } else {
        body = JSON.parse(body);
        csv.write(body, {headers: true})
         .pipe(outFile);
      }
    })
  })