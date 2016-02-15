#cook_county_demographic_groups {
  [demo_fraction < 0.5] {polygon-opacity: 0.5;}
  [demo_fraction >= 0.5][demo_fraction < 0.7] {polygon-opacity: 0.6;}
  [demo_fraction >= 0.7][demo_fraction < 0.9] {polygon-opacity: 0.8;}
  [demo_fraction >= 0.9]{polygon-opacity: 0.95;}
  line-color: #FFF;
  line-width: 0;
  line-opacity: 1;
  //image-filters:agg-stack-blur(1,1);
  [main_aggregate="german"] { polygon-fill: #D79C37; }
  [main_aggregate="irish"] { polygon-fill: #3D584F; }
  [main_aggregate="czech"] { polygon-fill: #253241; }
  [main_aggregate="black"],[main_aggregate="american"] { polygon-pattern-file: url(https://c2.staticflickr.com/2/1472/24942692391_46cabfdf91_s.jpg); }
  [main_aggregate="italian"] { polygon-fill: #867B41; }
  [main_aggregate="asian"] { polygon-fill: #53424D; }
  [main_aggregate="hispanic_latino"] { polygon-fill: #BB3922; }
  [main_aggregate="french_except_basque"] { polygon-fill: #6C7497; }
  [main_aggregate="hungarian"] { polygon-fill: #383B60; }
  [main_aggregate="american_indian"] { polygon-fill: #758E86; }
  [main_aggregate="arab"] { polygon-fill: #564833; }
  [main_aggregate="croatian"] { polygon-fill: #242E38; }
  [main_aggregate="danish"] { polygon-fill: #AB997F; }
  [main_aggregate="english"] { polygon-fill: #3A2C6B; }
  [main_aggregate="israeli"] { polygon-fill: #9A7731; }
}

#zillow_neighborhoods[zoom>11]{
  polygon-fill: #FF6600;
  polygon-opacity: 0;
  line-color: #000000;
  line-width: 1.5;
  line-opacity: 1;
  ::labels[zoom>11] {
    text-name: [name];
    text-face-name: 'Lato Bold';
    text-size: 12;
    text-label-position-tolerance: 0;
    text-fill: #000;
    text-halo-fill: #FFF;
    text-halo-radius: 0.5;
    text-dy: -10;
    text-allow-overlap: true;
    text-placement: point;
    text-placement-type: dummy;
  }
}
