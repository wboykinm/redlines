var turfMerge = require('turf-merge');
var turfFC = require('turf-featurecollection');
var turfOverlaps = require('turf-overlaps');
var turfE = require('turf-extent');
var rbush = require('rbush');

module.exports = function(featureCollection, propertyName){
	var fcLength = featureCollection.features.length;
	var rtree = new rbush();
	
	var treeItems = [];

	for (var fcIndex = 0; fcIndex < fcLength; fcIndex++) {
		var polyBeingChecked2 = featureCollection.features[fcIndex];
		var inputFeatureBbox = turfE(polyBeingChecked2);
		inputFeatureBbox.push({oldPolyID: fcIndex});
		treeItems.push(inputFeatureBbox);
		rtree.insert(inputFeatureBbox);
	}

	for (var polyIndex = 0; polyIndex < fcLength; polyIndex++) {

		var polyBeingChecked = featureCollection.features[polyIndex];

		if(!polyBeingChecked || !polyBeingChecked.properties.hasOwnProperty(propertyName)){
			continue;
		}	
			
		var polyBoundingBox = turfE(polyBeingChecked);

		var result = rtree.search([polyBoundingBox[0], polyBoundingBox[1], polyBoundingBox[2], polyBoundingBox[3]]);

		var featureChanged = false;
		var loopLength = result.length;

		for (var secondPolyIndex = 0; secondPolyIndex < loopLength; secondPolyIndex++) {
			
			var otherPolyID = result[secondPolyIndex][4].oldPolyID;

			if(polyIndex === otherPolyID){
				continue;
			}

			polyBeingChecked = featureCollection.features[polyIndex];
			var otherPolyBeingChecked = featureCollection.features[otherPolyID];	

			if(!otherPolyBeingChecked || !otherPolyBeingChecked.properties.hasOwnProperty(propertyName) || polyBeingChecked.properties[propertyName] !== otherPolyBeingChecked.properties[propertyName]){
				continue;
			}

			var overlapCheck = turfOverlaps(polyBeingChecked, otherPolyBeingChecked);

			if(overlapCheck === false){
				continue;
			}

			var mergedFeature = turfMerge(turfFC([polyBeingChecked, otherPolyBeingChecked]) );
			polyBeingChecked = mergedFeature;
			featureChanged = true;

			otherPolyBeingChecked = null;
			
			rtree.remove(treeItems[otherPolyID]);		
			treeItems[otherPolyID] = [0, 0, 0, 0, {oldPolyID: polyIndex, relevant: "no"}];
			rtree.insert(treeItems[otherPolyID]);
		}

		if(featureChanged === true){
			var mergedFeatureBbox = turfE(polyBeingChecked);
			rtree.remove(treeItems[polyIndex]);
			treeItems[polyIndex] = [mergedFeatureBbox[0], mergedFeatureBbox[1], mergedFeatureBbox[2], mergedFeatureBbox[3], {oldPolyID: polyIndex}];
			rtree.insert(treeItems[polyIndex]);

			polyIndex--;
		}
	}

	function cleanArray(actual) {
		var newArray = new Array();
		for (var i = 0; i < actual.length; i++) {
			if (actual[i]) {
				newArray.push(actual[i]);
			}
		}
		return newArray;
	}

	featureCollection.features = cleanArray(featureCollection.features);

	return featureCollection;

};