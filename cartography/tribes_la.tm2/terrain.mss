#hillshade {
  opacity: 0.5;
  [class='medium_shadow'] {
    polygon-pattern-file:url(img/shade_medium.png);
    polygon-pattern-comp-op: multiply;
  }
  [class='full_shadow'] {
    polygon-pattern-file:url(img/shade_medium.png);
    polygon-pattern-comp-op: multiply;
  }
  [class='medium_highlight'] {
    polygon-fill: fadeout(#fff,90);
  }
  [class='full_highlight'] {
    polygon-fill: fadeout(#fff,80);
  }
}