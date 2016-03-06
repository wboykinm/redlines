// PENCIL

// Much of the design of this style is handled by image textures.
// These were drawn by hand on paper, scanned, and tweaked in
// image editing software.

Map {
  background-image:url(img/texture_3.png);
  font-directory: url('fonts');
  buffer-size: 1024px;
}

#waterway, {
  line-color: #7E93AE;
  line-width:1px;
  line-smooth:1.8;
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

#admin[admin_level=2] {
  ::glow[maritime=0] {
    opacity: 0.8;
    line-color: #e3e3e3;
    line-width: 6;
    line-join: round;
    [zoom>=5] { line-width: 7; }
    [zoom>=7] { line-width: 8; }
  }
  line-width:1.2;
  line-color: #666;
  line-opacity:0.8;
  line-dasharray:2,1,3,1,1,1,4,1,5,1;
  line-join: round;
  line-cap: round;
  [maritime=1] {
    line-dasharray:4,4,3,3;
    line-opacity: 0.5;
  }
  [disputed=1] {
    line-dasharray: 9,7;
  }
  [zoom>=5] { line-width: 1.8; }
  [zoom>=7] { line-width: 2.2; }
}

#admin[admin_level>=3][maritime=0] {
  ::glow[maritime=0] {
    opacity: 0.8;
    line-color: #e3e3e3;
    line-width: 4;
    line-join: round;
    [zoom>=5] { line-width: 5; }
    [zoom>=7] { line-width: 6; }
  }
  line-width: 1;
  line-color: #666;
  line-opacity:0.5;
  line-dasharray:2,1,3,1,1,1,4,1,5,1;
  line-join: round;
  line-cap: round;
  [zoom>=7] { line-width: 1.5; }
  [zoom>=10] { line-width: 2.2; }
}