-- special centroid-in-polygon function: http://postgis.17.x6.nabble.com/Centroid-Within-tp3518773p3518776.html
CREATE OR REPLACE FUNCTION point_inside_geometry(param_geom geometry)
  RETURNS geometry AS
$$
  DECLARE 
     var_cent geometry := ST_Centroid(param_geom); 
     var_result geometry := var_cent;
  BEGIN
  -- If the centroid is outside the geometry then 
  -- calculate a box around centroid that is guaranteed to intersect the geometry
  -- take the intersection of that and find point on surface of intersection
 IF NOT ST_Intersects(param_geom, var_cent) THEN
  var_result := ST_PointOnSurface(ST_Intersection(param_geom, ST_Expand(var_cent, ST_Distance(var_cent,param_geom)*2) ));
 END IF;
 RETURN var_result;
  END;
  $$
  LANGUAGE plpgsql IMMUTABLE STRICT
  COST 100;

ALTER TABLE community_tracts ALTER COLUMN p0010001 TYPE int USING (p0010001::int);
ALTER TABLE community_tracts ALTER COLUMN largest_group_count TYPE int USING (largest_group_count::int);
ALTER TABLE community_tracts ALTER COLUMN largest_group_proportion TYPE double precision USING (largest_group_proportion::float);
ALTER TABLE community_tracts RENAME COLUMN wkb_geometry TO the_geom;
DELETE FROM community_tracts WHERE p0010001 < 1;
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
              50
            )
          ),
          -150
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
    ST_Simplify(e.the_geom,0.0005) AS the_geom,
    avg(c.largest_group_proportion) AS largest_group_proportion,
    sum(c.largest_group_count) AS largest_group_count,
    sum(c.p0010001) AS total_population
  FROM explosions e
  LEFT JOIN community_tracts c 
  ON ST_Intersects(e.the_geom,ST_Centroid(c.the_geom))
  GROUP BY e.largest_community_name,e.the_geom
  ORDER BY ST_Area(e.the_geom) ASC
);

CREATE TABLE community_centroids AS (
  SELECT
    largest_community_name,
    point_inside_geometry(the_geom) AS the_geom,
    largest_group_proportion,
    largest_group_count,
    total_population
  FROM
    community_polys
);

CREATE TABLE community_mask AS (
  SELECT
    ST_Transform(
      ST_Difference(
        (ST_Expand(
          ST_Transform(
            ST_Collect(the_geom),
            3857
          ),
          300000
        )),
        (ST_Buffer(
          ST_Transform(
            ST_Collect(the_geom),
            3857
          ),
          3000
        ))
      ),
      4326
    ) AS the_geom
  FROM
    community_polys
)