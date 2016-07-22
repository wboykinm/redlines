#road['mapnik::geometry_type'=2]::line,
#bridge['mapnik::geometry_type'=2]::line,
#tunnel['mapnik::geometry_type'=2]::line {
  [class='motorway'] {
    [zoom>=7][zoom<=12] {
      a/line-width:0.6;
      a/line-opacity:0.2;
      a/line-dasharray:2,1;
      b/line-width:0.8;
      b/line-opacity:0.2;
      b/line-dasharray:12,1;
      [zoom>=9] {
        a/line-opacity:0.1;
        b/line-opacity:0.1;
      }
      [zoom>=8] {
        a/line-width:1;
        b/line-width:1.2;
      }
      [zoom>=10] {
        a/line-width:1.6;
        b/line-width:2.0;
      }
    }
    [zoom=12] { line-pattern-file:url(img/line_solid_7.png); }
  }
  [class='motorway_link'],
  [class='main'] {
    [zoom>=7][zoom<=12] {
      a/line-color: #222;
      a/line-opacity: 0.25;
      a/line-width: 0.8;
      [zoom=8] { a/line-width: 0.9; }
      [zoom=9] { a/line-width: 1; }
      [zoom=10] { a/line-width: 1.1; }
      [zoom=11] { a/line-width: 1.2; }
    }
    [zoom=12] { line-pattern-file:url(img/line_solid_6.png); }
    [zoom=13] { line-pattern-file:url(img/line_solid_7.png); }
  }
  [class='major_rail'][zoom>=14],
    [class='minor_rail'][zoom>=16] {
    ['mapnik::geometry_type'=2] {
      a/line-width:1;
      a/line-opacity:0.05;
      a/line-dasharray:2,1;
      b/line-width:1.5;
      b/line-opacity:0.05;
      b/line-dasharray:12,1;
      c/line-width:2;
      c/line-opacity:0.05;
      c/line-dasharray:20,3;
    }
  }
}

#road::case,
#bridge::case,
#tunnel::case {
  ['mapnik::geometry_type'=2][zoom>=12][zoom<=20] {
    [class='motorway'] {
      [zoom=12] { line-pattern-file:url(img/line_double_14.png); }
      [zoom=13] { line-pattern-file:url(img/line_double_16.png); }
      [zoom=14] { line-pattern-file:url(img/line_double_18.png); }
      [zoom>15] { line-pattern-file:url(img/line_double_20.png); }
    }
  }
}

#road::dot['mapnik::geometry_type'=1][class='turning_circle'][zoom>=15] {
  marker-width: 6;
  [zoom>=16] { marker-width: 9; }
  [zoom>=17] { marker-width: 12; }
  marker-fill: #e6e6e6;
  marker-line-color: #707070;
  marker-line-width: 1.5;
}

#road::fill,
#bridge::fill {
  ['mapnik::geometry_type'=2][zoom>=12][zoom<=20] {
    [class='motorway'] {
      [zoom>=12] { line-pattern-file:url(img/line_double_14_mask.png); }
      [zoom=14] { line-pattern-file:url(img/line_double_16_mask.png); }
      [zoom=15] { line-pattern-file:url(img/line_double_18_mask.png); }
      [zoom>15] { line-pattern-file:url(img/line_double_20_mask.png); }
    }
    [class='motorway_link'],
    [class='main'] {
      [zoom=14] { line-pattern-file:url(img/line_double_14_mask.png); }
      [zoom=15] { line-pattern-file:url(img/line_double_16_mask.png); }
      [zoom>15] { line-pattern-file:url(img/line_double_20_mask.png); }
    }
    [class='street'],
    [class='street_limited'] {
      [zoom>=15] { line-pattern-file:url(img/line_double_14_mask.png); }
      [zoom>=16] { line-pattern-file:url(img/line_double_16_mask.png); }
    }
  }
}

#tunnel::case { opacity:0.25; }