ALTER TABLE community_tracts ALTER COLUMN p0010001 TYPE int USING (p0010001::int);
ALTER TABLE community_tracts ALTER COLUMN largest_group_count TYPE int USING (largest_group_count::int);
ALTER TABLE community_tracts ALTER COLUMN largest_group_proportion TYPE double precision USING (largest_group_proportion::float);
ALTER TABLE community_tracts RENAME COLUMN wkb_geometry TO the_geom;
DELETE FROM community_tracts WHERE p0010001 < 5;
-- expand then erode block borders
CREATE TABLE community_polys AS (
  WITH erosions AS (
    SELECT
      largest_community_name,
      ST_Transform(
        ST_Buffer(
          ST_Union(
            ST_Buffer(
              ST_Transform(
                the_geom,
                3857
              ),
              250
            )
          ),
          -325
        ),
        4326
      ) AS the_geom
    FROM community_tracts
    GROUP BY largest_community_name
  ),
  
  explosions AS (
    SELECT
      largest_community_name,
      (ST_Dump(the_geom)).geom AS the_geom
    FROM erosions
  )
  
  SELECT
    e.largest_community_name,
    e.the_geom,
    avg(c.largest_group_proportion) AS largest_group_proportion,
    sum(c.largest_group_count) AS largest_group_count,
    sum(c.p0010001) AS total_population
  FROM explosions e
  LEFT JOIN community_tracts c 
  ON ST_Intersects(e.the_geom,ST_Centroid(c.the_geom))
  GROUP BY e.largest_community_name,e.the_geom
  ORDER BY ST_Area(e.the_geom) ASC
);