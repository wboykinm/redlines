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
  //text-avoid-edges: true;
  text-margin: 10px;
  text-fill: #333;
  text-size: 16;
  //text-comp-op: grain-merge;
}

#communities_points_06_037 {
  //marker-width:20px;
  text-name: "[largest_community_name]";
  text-transform: uppercase;
  text-face-name: @normal;
  text-wrap-width: 100;
  text-wrap-before: true;
  text-fill: #222;
  text-halo-fill:#777;
  text-halo-radius:1.8px;
  text-halo-rasterizer:fast;
  text-size: 24;
  text-avoid-edges: true;
  text-repeat-distance: 200px;
  text-margin:30px;
  text-comp-op:grain-extract;
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