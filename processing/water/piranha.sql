-- fix what polygons can be fixed
/*DROP TABLE IF EXISTS valid_water;
CREATE TABLE valid_water AS (
  SELECT
    ST_Makevalid(wkb_geometry) AS the_geom
  FROM water_tile
);

DELETE FROM valid_water
WHERE ST_Area(
  ST_Transform(
    the_geom,
    3857
  )
) < 500000;
*/
-- speed up the processing
DROP INDEX IF EXISTS idx_tracts;
DROP INDEX IF EXISTS idx_water;
CREATE INDEX idx_tracts ON community_tracts USING GIST (wkb_geometry);
CREATE INDEX idx_water ON valid_water USING GIST (the_geom);
VACUUM ANALYZE;

-- remove water from tracts geo
DROP TABLE IF EXISTS community_tracts_eaten;
CREATE TABLE community_tracts_eaten AS (
  SELECT
    ogc_fid,
    ST_Difference(
      wkb_geometry,(
      SELECT 
        ST_Union(
          ST_Buffer(
            the_geom,
            0.0001
          )
        )
      FROM valid_water
    )) AS wkb_geometry,
    statefp,
    countyfp,
    tractce,
    geoid,
    name,
    namelsad,
    mtfcc,
    funcstat,
    aland,
    awater,
    intptlat,
    intptlon,
    state,
    county,
    p0010001,
    largest_group_count,
    largest_group_proportion,
    id,
    code,
    largest_community_name,
    collection,
    map_color
  FROM community_tracts
);

-- clean house for the next tile
DROP TABLE IF EXISTS water_tile;
DROP TABLE IF EXISTS valid_water;
DROP TABLE IF EXISTS community_tracts;
ALTER TABLE community_tracts_eaten RENAME TO community_tracts;