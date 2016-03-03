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

#communities_17_031 {
  //[largest_group_proportion < 0.5] {polygon-opacity: 0.4;}
  //[largest_group_proportion >= 0.5][largest_group_proportion < 0.7] {polygon-opacity: 0.6;}
  //[largest_group_proportion >= 0.7][largest_group_proportion < 0.9] {polygon-opacity: 0.7;}
  //[largest_group_proportion >= 0.9]{polygon-opacity: 0.98;}
  line-color: #FFF;
  line-width: 0;
  line-opacity: 1;
  polygon-smooth:0.4;
  polygon-opacity:0.9; 
  polygon-comp-op:overlay; 
  image-filters:agg-stack-blur(3,3);
  [largest_community_name='African American']{ polygon-fill: #5A89A1; } 
  [largest_community_name='Chinese']{ polygon-fill: #574752;}         
  [largest_community_name='Filipino']{ polygon-fill: #B9A450;}        
  [largest_community_name='German']{ polygon-fill: #D99E39;}          
  [largest_community_name='Greek']{ polygon-fill: #1F1C2D;}           
  [largest_community_name='Indian']{ polygon-fill: #352B6C;}          
  [largest_community_name='Irish']{ polygon-fill: #405A56;}           
  [largest_community_name='Italian']{ polygon-fill: #696935;}         
  [largest_community_name='Korean']{ polygon-fill: #E0C087;}          
  [largest_community_name='Mexican']{ polygon-fill: #B87824;}         
  [largest_community_name='Polish']{ polygon-fill: #AB4C3C;}          
  [largest_community_name='Puerto Rican']{ polygon-fill: #363A3D;}    
  [largest_community_name='Romanian']{ polygon-fill: #8B9CB3;}        
  [largest_community_name='Russian']{ polygon-fill: #AF6235;}         
  [largest_community_name='Ukrainian']{ polygon-fill: #3E5779;}  
}

#communities_mask_17_031 {
  polygon-pattern-file: url(img/texture_3.png);
  image-filters:agg-stack-blur(50,50);
}