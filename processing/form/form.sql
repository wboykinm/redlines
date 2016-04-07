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

-- Lay the groundwork
ALTER TABLE community_tracts ALTER COLUMN p0010001 TYPE int USING (p0010001::int);
ALTER TABLE community_tracts ALTER COLUMN largest_group_count TYPE int USING (largest_group_count::int);
ALTER TABLE community_tracts ALTER COLUMN largest_group_proportion TYPE double precision USING (largest_group_proportion::float);
ALTER TABLE community_tracts RENAME COLUMN wkb_geometry TO the_geom;
-- clear tracts with < 30 people (this specifically targets central park)
DELETE FROM community_tracts WHERE p0010001 < 30;
-- expand then erode block borders
DROP TABLE IF EXISTS community_polys;
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

-- Create cartographic labeling layer
DROP TABLE IF EXISTS community_centroids;
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

-- create mask for static compositions
DROP TABLE IF EXISTS community_mask;
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
);

-- import raw counts by tract
DROP TABLE IF EXISTS community_properties;
CREATE TABLE community_properties (
  state text,
  county text,
  tract text,
  P0010001 int,
  P0030002 int,
  P0030003 int,
  P0030004 int,
  P0030005 int,
  P0030006 int,
  P0030007 int,
  P0030008 int,
  P0040003 int,
  PCT0050002 int,
  PCT0050003 int,
  PCT0050004 int,
  PCT0050005 int,
  PCT0050006 int,
  PCT0050007 int,
  PCT0050008 int,
  PCT0050009 int,
  PCT0050010 int,
  PCT0050011 int,
  PCT0050012 int,
  PCT0050013 int,
  PCT0050014 int,
  PCT0050015 int,
  PCT0050016 int,
  PCT0050017 int,
  PCT0050018 int,
  PCT0050019 int,
  PCT0050020 int,
  PCT0110004 int,
  PCT0110005 int,
  PCT0110006 int,
  PCT0110007 int,
  PCT0110009 int,
  PCT0110010 int,
  PCT0110011 int,
  PCT0110012 int,
  PCT0110013 int,
  PCT0110014 int,
  PCT0110017 int,
  PCT0110018 int,
  PCT0110019 int,
  PCT0110020 int,
  PCT0110021 int,
  PCT0110022 int,
  PCT0110023 int,
  PCT0110024 int,
  PCT0110025 int,
  PCT0110029 int,
  B04006_002E int,
  B04006_003E int,
  B04006_007E int,
  B04006_008E int,
  B04006_010E int,
  B04006_011E int,
  B04006_012E int,
  B04006_013E int,
  B04006_016E int,
  B04006_019E int,
  B04006_022E int,
  B04006_025E int,
  B04006_029E int,
  B04006_031E int,
  B04006_033E int,
  B04006_034E int,
  B04006_036E int,
  B04006_039E int,
  B04006_040E int,
  B04006_041E int,
  B04006_042E int,
  B04006_044E int,
  B04006_045E int,
  B04006_046E int,
  B04006_048E int,
  B04006_049E int,
  B04006_050E int,
  B04006_051E int,
  B04006_053E int,
  B04006_059E int,
  B04006_060E int,
  B04006_061E int,
  B04006_062E int,
  B04006_063E int,
  B04006_064E int,
  B04006_067E int,
  B04006_070E int,
  B04006_074E int,
  B04006_075E int,
  B04006_076E int,
  B04006_079E int,
  B04006_082E int,
  B04006_084E int,
  B04006_089E int,
  B04006_090E int,
  B04006_091E int,
  B04006_092E int,
  B04006_093E int,
  B04006_101E int,
  B04006_102E int,
  largest_group text,
  largest_group_count int,
  largest_group_proportion double precision,
  id text,
  code text,
  name text,
  collection text,
  map_color text,
  groupname text
);

\COPY community_properties FROM 'community_properties.csv' DELIMITER ',' CSV HEADER;
DELETE FROM community_properties WHERE P0010001 < 1;

-- create legend
DROP TABLE IF EXISTS community_legend;
CREATE TABLE community_legend AS (
  WITH grouptotals AS (
    SELECT
      sum(P0010001) AS P0010001,
      sum(P0030002) AS P0030002,
      sum(P0030003) AS P0030003,
      sum(P0030004) AS P0030004,
      sum(P0030005) AS P0030005,
      sum(P0030006) AS P0030006,
      sum(P0030007) AS P0030007,
      sum(P0030008) AS P0030008,
      sum(P0040003) AS P0040003,
      sum(PCT0050002) AS PCT0050002,
      sum(PCT0050003) AS PCT0050003,
      sum(PCT0050004) AS PCT0050004,
      sum(PCT0050005) AS PCT0050005,
      sum(PCT0050006) AS PCT0050006,
      sum(PCT0050007) AS PCT0050007,
      sum(PCT0050008) AS PCT0050008,
      sum(PCT0050009) AS PCT0050009,
      sum(PCT0050010) AS PCT0050010,
      sum(PCT0050011) AS PCT0050011,
      sum(PCT0050012) AS PCT0050012,
      sum(PCT0050013) AS PCT0050013,
      sum(PCT0050014) AS PCT0050014,
      sum(PCT0050015) AS PCT0050015,
      sum(PCT0050016) AS PCT0050016,
      sum(PCT0050017) AS PCT0050017,
      sum(PCT0050018) AS PCT0050018,
      sum(PCT0050019) AS PCT0050019,
      sum(PCT0050020) AS PCT0050020,
      sum(PCT0110004) AS PCT0110004,
      sum(PCT0110005) AS PCT0110005,
      sum(PCT0110006) AS PCT0110006,
      sum(PCT0110007) AS PCT0110007,
      sum(PCT0110009) AS PCT0110009,
      sum(PCT0110010) AS PCT0110010,
      sum(PCT0110011) AS PCT0110011,
      sum(PCT0110012) AS PCT0110012,
      sum(PCT0110013) AS PCT0110013,
      sum(PCT0110014) AS PCT0110014,
      sum(PCT0110017) AS PCT0110017,
      sum(PCT0110018) AS PCT0110018,
      sum(PCT0110019) AS PCT0110019,
      sum(PCT0110020) AS PCT0110020,
      sum(PCT0110021) AS PCT0110021,
      sum(PCT0110022) AS PCT0110022,
      sum(PCT0110023) AS PCT0110023,
      sum(PCT0110024) AS PCT0110024,
      sum(PCT0110025) AS PCT0110025,
      sum(PCT0110029) AS PCT0110029,
      sum(B04006_002E) AS B04006_002E,
      sum(B04006_003E) AS B04006_003E,
      sum(B04006_007E) AS B04006_007E,
      sum(B04006_008E) AS B04006_008E,
      sum(B04006_010E) AS B04006_010E,
      sum(B04006_011E) AS B04006_011E,
      sum(B04006_012E) AS B04006_012E,
      sum(B04006_013E) AS B04006_013E,
      sum(B04006_016E) AS B04006_016E,
      sum(B04006_019E) AS B04006_019E,
      sum(B04006_022E) AS B04006_022E,
      sum(B04006_025E) AS B04006_025E,
      sum(B04006_029E) AS B04006_029E,
      sum(B04006_031E) AS B04006_031E,
      sum(B04006_033E) AS B04006_033E,
      sum(B04006_034E) AS B04006_034E,
      sum(B04006_036E) AS B04006_036E,
      sum(B04006_039E) AS B04006_039E,
      sum(B04006_040E) AS B04006_040E,
      sum(B04006_041E) AS B04006_041E,
      sum(B04006_042E) AS B04006_042E,
      sum(B04006_044E) AS B04006_044E,
      sum(B04006_045E) AS B04006_045E,
      sum(B04006_046E) AS B04006_046E,
      sum(B04006_048E) AS B04006_048E,
      sum(B04006_049E) AS B04006_049E,
      sum(B04006_050E) AS B04006_050E,
      sum(B04006_051E) AS B04006_051E,
      sum(B04006_053E) AS B04006_053E,
      sum(B04006_059E) AS B04006_059E,
      sum(B04006_060E) AS B04006_060E,
      sum(B04006_061E) AS B04006_061E,
      sum(B04006_062E) AS B04006_062E,
      sum(B04006_063E) AS B04006_063E,
      sum(B04006_064E) AS B04006_064E,
      sum(B04006_067E) AS B04006_067E,
      sum(B04006_070E) AS B04006_070E,
      sum(B04006_074E) AS B04006_074E,
      sum(B04006_075E) AS B04006_075E,
      sum(B04006_076E) AS B04006_076E,
      sum(B04006_079E) AS B04006_079E,
      sum(B04006_082E) AS B04006_082E,
      sum(B04006_084E) AS B04006_084E,
      sum(B04006_089E) AS B04006_089E,
      sum(B04006_090E) AS B04006_090E,
      sum(B04006_091E) AS B04006_091E,
      sum(B04006_092E) AS B04006_092E,
      sum(B04006_093E) AS B04006_093E,
      sum(B04006_101E) AS B04006_101E,
      sum(B04006_102E) AS B04006_102E
    FROM community_properties
  ),
  
  grouptotals_transposed AS (
    SELECT
      unnest(array['P0010001', 'P0030002', 'P0030003', 'P0030004', 'P0030005', 'P0030006', 'P0030007', 'P0030008', 'P0040003', 'PCT0050002', 'PCT0050003', 'PCT0050004', 'PCT0050005', 'PCT0050006', 'PCT0050007', 'PCT0050008', 'PCT0050009', 'PCT0050010', 'PCT0050011', 'PCT0050012', 'PCT0050013', 'PCT0050014', 'PCT0050015', 'PCT0050016', 'PCT0050017', 'PCT0050018', 'PCT0050019', 'PCT0050020', 'PCT0110004', 'PCT0110005', 'PCT0110006', 'PCT0110007', 'PCT0110009', 'PCT0110010', 'PCT0110011', 'PCT0110012', 'PCT0110013', 'PCT0110014', 'PCT0110017', 'PCT0110018', 'PCT0110019', 'PCT0110020', 'PCT0110021', 'PCT0110022', 'PCT0110023', 'PCT0110024', 'PCT0110025', 'PCT0110029', 'B04006_002E', 'B04006_003E', 'B04006_007E', 'B04006_008E', 'B04006_010E', 'B04006_011E', 'B04006_012E', 'B04006_013E', 'B04006_016E', 'B04006_019E', 'B04006_022E', 'B04006_025E', 'B04006_029E', 'B04006_031E', 'B04006_033E', 'B04006_034E', 'B04006_036E', 'B04006_039E', 'B04006_040E', 'B04006_041E', 'B04006_042E', 'B04006_044E', 'B04006_045E', 'B04006_046E', 'B04006_048E', 'B04006_049E', 'B04006_050E', 'B04006_051E', 'B04006_053E', 'B04006_059E', 'B04006_060E', 'B04006_061E', 'B04006_062E', 'B04006_063E', 'B04006_064E', 'B04006_067E', 'B04006_070E', 'B04006_074E', 'B04006_075E', 'B04006_076E', 'B04006_079E', 'B04006_082E', 'B04006_084E', 'B04006_089E', 'B04006_090E', 'B04006_091E', 'B04006_092E', 'B04006_093E', 'B04006_101E', 'B04006_102E']) AS type,
      unnest(array[P0010001, P0030002, P0030003, P0030004, P0030005, P0030006, P0030007, P0030008, P0040003, PCT0050002, PCT0050003, PCT0050004, PCT0050005, PCT0050006, PCT0050007, PCT0050008, PCT0050009, PCT0050010, PCT0050011, PCT0050012, PCT0050013, PCT0050014, PCT0050015, PCT0050016, PCT0050017, PCT0050018, PCT0050019, PCT0050020, PCT0110004, PCT0110005, PCT0110006, PCT0110007, PCT0110009, PCT0110010, PCT0110011, PCT0110012, PCT0110013, PCT0110014, PCT0110017, PCT0110018, PCT0110019, PCT0110020, PCT0110021, PCT0110022, PCT0110023, PCT0110024, PCT0110025, PCT0110029, B04006_002E, B04006_003E, B04006_007E, B04006_008E, B04006_010E, B04006_011E, B04006_012E, B04006_013E, B04006_016E, B04006_019E, B04006_022E, B04006_025E, B04006_029E, B04006_031E, B04006_033E, B04006_034E, B04006_036E, B04006_039E, B04006_040E, B04006_041E, B04006_042E, B04006_044E, B04006_045E, B04006_046E, B04006_048E, B04006_049E, B04006_050E, B04006_051E, B04006_053E, B04006_059E, B04006_060E, B04006_061E, B04006_062E, B04006_063E, B04006_064E, B04006_067E, B04006_070E, B04006_074E, B04006_075E, B04006_076E, B04006_079E, B04006_082E, B04006_084E, B04006_089E, B04006_090E, B04006_091E, B04006_092E, B04006_093E, B04006_101E, B04006_102E]) AS totals
    FROM grouptotals
    ORDER BY totals
  ),
  
  polygroups AS (
    SELECT 
      largest_community_name,
      avg(largest_group_proportion) AS avg_plurality
    FROM community_polys
    GROUP BY largest_community_name
  ) 

  SELECT 
    p.largest_community_name, 
    max(t.code) AS code,
    max(p.avg_plurality) AS avg_plurality, 
    max(g.totals) AS membership,
    max(t.map_color) AS map_color 
  FROM polygroups p 
  LEFT JOIN community_tracts t ON t.largest_community_name = p.largest_community_name
  LEFT JOIN grouptotals_transposed g ON g.type = t.code
  WHERE g.totals > 0
  GROUP BY p.largest_community_name
  ORDER BY p.largest_community_name ASC 
);
