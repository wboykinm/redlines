Map {
  //background-image:url(img/texture_3.png);
  font-directory: url('fonts');
  buffer-size: 1024px;
}

#water {
  ::light14[zoom<=14],
  ::light15[zoom=15],
  ::light16[zoom=16],
  ::light17[zoom>=17] {
    polygon-fill: #ddd9ce;
    polygon-gamma: 0.3;
    polygon-opacity:0.6;
    image-filters: agg-stack-blur(8,8);
    image-filters-inflate: true;
  }
  ::light15[zoom=15] { image-filters: agg-stack-blur(16,16); }
  ::light16[zoom=16] { image-filters: agg-stack-blur(32,32); }
  ::light17[zoom<=17] { image-filters: agg-stack-blur(64,64); }
  // Pencil shading texture:
  ::texture {
    polygon-pattern-opacity:0.5;
    comp-op: multiply;
    polygon-pattern-alignment: global;
    polygon-pattern-file:url(img/hatch.png);
  }
}

#waterway [class!='river'] {
  line-color: #7E93AE;
  line-width:1px;
  line-smooth:1.8;
  line-opacity:0.2;
  line-cap:round;
  [class='canal'] { line-width:1.5px; }
  [class='river'] { line-width:3px; }
}

#aeroway['mapnik::geometry_type'=2][zoom>=12] {
  comp-op: multiply;
  opacity:0.5;
  [type='taxiway'] {
    [zoom=12] { line-pattern-file:url(img/line_solid_6.png); }
    [zoom=13] { line-pattern-file:url(img/line_solid_7.png); }
    [zoom=15] { line-pattern-file:url(img/line_shade_22_1.png); }
    [zoom=16] { line-pattern-file:url(img/line_shade_22_2.png); }
    [zoom>16] { line-pattern-file:url(img/line_shade_22_4.png); }
  }
  [type='runway'] {
    line-pattern-file:url(img/line_shade_22.png);
    [zoom>=15] { line-pattern-file:url(img/line_shade_22_2.png); }
    [zoom>=16] { line-pattern-file:url(img/line_shade_22_4.png); }
  }
}