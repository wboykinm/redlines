@normal: 'MAW Medium';

#place_label [scalerank<3],[name_en='downtown'] {
  text-name: "[name_en]";
  text-transform: uppercase;
  text-face-name: @normal;
  text-wrap-width: 20;
  text-wrap-before: true;
  text-avoid-edges: true;
  text-min-padding:50px;
  text-fill: #333;
  text-size: 14;
  //text-comp-op: grain-merge;
}

#poi_label[scalerank<2] {
  text-name: "[name]";
  text-transform: uppercase;
  text-face-name: @normal;
  text-wrap-width: 20;
  text-wrap-before: true;
  text-avoid-edges: true;
  text-margin: 10px;
  text-fill: #333;
  text-size: 16;
  //text-comp-op: grain-merge;
}


#road_label [class='main'] {
  text-name: "[name]";
  text-transform: uppercase;
  text-face-name: @normal;
  text-placement: line;
  text-fill: #555;
  text-size: 10;
  //text-allow-overlap: true;
  text-avoid-edges: true;
  text-margin:50px;
  text-repeat-distance:500px;
  text-min-padding:50px;
  //text-comp-op:grain-merge;
}

// Water bodies //
#water_label {
  [zoom<=13],  // automatic area filtering @ low zooms
  [zoom>=14][area>500000],
  [zoom>=16][area>10000],
  [zoom>=17] {
    text-name: "[name]";
    text-face-name: @normal;
    text-fill: #555;
    text-character-spacing: 0.5; 
    text-size: 9;
    text-transform: uppercase;
    text-wrap-width: 60;
    text-wrap-before: true;
  }
  [zoom>=15][area>500000],
  [zoom>=17][area>10000],
  [zoom>=18]  {
    text-size: 10;
    text-wrap-width: 70;
  }
  [zoom>=16][area>500000],
  [zoom>=18][area>10000],
  [zoom>=19]  {
    text-size: 11;
    text-wrap-width: 80;
  }
  [zoom>=12][area>10000000],
  [zoom>=14][area>5000000]  {
    text-size: 12;
    text-wrap-width: 90;
  }
  [zoom>=10][area>100000000]  {
    text-size: 13;
    text-wrap-width: 90;
  }
}

// Waterways //
#waterway_label {
  [class="river"][zoom>=13],
  [class="canal"][zoom>=15],
  [class="stream"][zoom>=17], 
  [class="stream_intermittent"][zoom>=17] {
    text-placement: line;
    text-avoid-edges:true;
    text-transform: uppercase;
    text-margin: 150px;
    text-name: "[name]";
    text-face-name: @normal;
    text-fill: #555;
    text-size: 10;
    text-allow-overlap: false;
    text-character-spacing: 0.5; 
  } 
  [class="river"][zoom>=14],
  [class="canal"][zoom>=16],
  [class="stream"][zoom>=18], 
  [class="stream_intermittent"][zoom>=18] {
    text-size: 11;
  }
  [class='river'][zoom=15],
  [class='canal'][zoom>=17] {
    text-size: 12;
  }
  [class='river'][zoom>=16],
  [class='canal'][zoom>=18] {
    text-size: 13;
  }
}