/*@name: '[name_en]';

#place_label[type='city'][localrank=1] {
  text-face-name: 'Schulschrift A OT Normal';
  text-name: @name;
  text-opacity: 0.75;
  text-size: 20;
  text-halo-fill: fadeout(#eee,90);
  text-halo-rasterizer: fast;
  text-halo-radius: 4;
  text-character-spacing: -4;
  [scalerank>=0][scalerank<=1] { text-size: 30; }
  [scalerank>=2][scalerank<=3] { text-size: 28; }
  [scalerank>=4][scalerank<=5] { text-size: 26; }
  [scalerank>=6][scalerank<=7] { text-size: 24; }
  [scalerank>=8][scalerank<=9] { text-size: 22; }
}

#place_label[type!='city'][localrank=1] {
  text-face-name: 'Providence Sans Offc Pro Bold';
  text-name: @name;
  text-opacity: 0.75;
  text-halo-fill: fadeout(#eee,90);
  text-halo-rasterizer: fast;
  text-halo-radius: 4;
  text-character-spacing: -2;
  [type='town'] { text-size: 20; }
  [type='village'],[type='suburb'] { text-size: 18; }
  [type='hamlet'],[type='neighbourhood'] { text-size: 16; }
}

#poi_label[maki='park'] {
  [zoom>=15][scalerank<=2] {
    text-face-name: 'Providence Sans Offc Pro Regular';
    text-name: @name;
    text-opacity: 0.80;
    text-size: 14;
    text-halo-fill: fadeout(#eee,85);
    text-halo-rasterizer: fast;
    text-halo-radius: 4;
    text-character-spacing: -3;
    [scalerank=3] { text-size: 16; }
    [scalerank=2] { text-size: 18; }
    [scalerank=1] { text-size: 20; }
    [zoom>=17] {
      text-size: 16;
      [scalerank=3] { text-size: 18; }
      [scalerank=2] { text-size: 20; }
      [scalerank=1] { text-size: 22; }
    }
  }
}

#road_label {
  [class='main'][zoom>=16] {
    text-face-name: 'Providence Sans Offc Pro Regular';
    text-name: @name;
    text-opacity: 0.80;
    text-size: 14;
    text-halo-fill: fadeout(#eee,60);
    text-halo-rasterizer: fast;
    text-halo-radius: 2;
    text-character-spacing: -2;
    text-placement: line;
    text-transform: uppercase;
  }
}*/