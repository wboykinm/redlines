var fs = require('fs');
var joiner = require('joiner');
var csv = require('fast-csv');

var geo_key = 'TRACTCE';
var tab_key = 'tract';

var geo_data = JSON.parse(fs.readFileSync(process.argv[2]));
var tab_data = [];
var joined_data;

csv
 .fromPath(process.argv[3], { 
   objectMode: true, 
   headers: true 
 })
 .on("data", function(data){
   tab_data.push(data);
 })
 .on("end", function(){
   joined_data = joiner.geoJson(geo_data, geo_key, tab_data, tab_key);
   console.log(joined_data);
 });