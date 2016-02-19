// USAGE: node index.js
var fs = require('fs');
var through2Concurrent = require('through2-concurrent');
var csv = require('fast-csv');
var request = require('request');

var urlBase = 'http://api.census.gov/data/2010/sf1?key=';
var censusKey = '2651a9a403259ff8068723199a90b3060fd0127f';
var stateFips = '17';
var countyFips = '031';
var fields = 'P0030002,P0030003,P0030004,P0030005,P0030006,P0030007,P0030008,P0040002,P0040003,PCT0110004,PCT0110005,PCT0110006,PCT0110007,PCT0110008,P0010001';

var p001 = fs.createWriteStream("../../data/tmp/p0010001.csv");

// grab data by tract, pipe to csv in data/tmp/
request(urlBase + censusKey + '&get=' + fields + '&for=tract:*&in=state:' + stateFips + '+county:' + countyFips, function (error, response, body) {
  if (error) {
    console.error('encountered error', error instanceof Error ? error.stack : error);
  } else if (response.statusCode === 429) {
    console.log('error 429')
  } else if (response.statusCode !== 200) {
    console.error('non-200 status code: ' + response.statusCode);
  } else {
    body = JSON.parse(body);
    var header = body[0];
    Object.keys(body).map( function(i) {
      return body[i];
    })
    .forEach( function(row) {
      var countRange = row.slice(0,(header.length - 4))
      var maxIndex = countRange.indexOf('' + Math.max.apply(null, countRange));
      console.log(header[maxIndex]);
    })
    //console.log(body);
    //csv.write(body, {headers: true})
     //.pipe(p001);
  }
})