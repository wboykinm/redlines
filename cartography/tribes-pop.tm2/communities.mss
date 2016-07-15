#communities_polys {
  line-color: #FFF;
  line-width: 0;
  line-opacity: 1;
  //polygon-smooth:0.4; 
  polygon-comp-op:overlay; 
  image-filters:agg-stack-blur(3,3);
  polygon-fill: #b35806;
  [largest_group_proportion < 0.1] {  polygon-opacity:0.1; }
  [largest_group_proportion < 0.2][largest_group_proportion >= 0.1] {  polygon-opacity:0.2; }
  [largest_group_proportion < 0.3][largest_group_proportion >= 0.2] {  polygon-opacity:0.3; }
  [largest_group_proportion < 0.4][largest_group_proportion >= 0.3] {  polygon-opacity:0.4; }
  [largest_group_proportion < 0.5][largest_group_proportion >= 0.4] {  polygon-opacity:0.5; }
  [largest_group_proportion < 0.6][largest_group_proportion >= 0.5] {  polygon-opacity:0.6; }
  [largest_group_proportion < 0.7][largest_group_proportion >= 0.6] {  polygon-opacity:0.7; }
  [largest_group_proportion < 0.8][largest_group_proportion >= 0.7] {  polygon-opacity:0.8; }
  [largest_group_proportion < 0.9][largest_group_proportion >= 0.8] {  polygon-opacity:0.9; }
  [largest_group_proportion >= 0.9] {  polygon-opacity:1; }
}

#communities_mask {
  polygon-opacity: 0;
  polygon-comp-op: src;
  line-width:8px;
  line-color:#F1EDE1;
  line-opacity: 0.2;
  line-smooth: 0.2;
}