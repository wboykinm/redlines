DELETE FROM overpass_roads WHERE LEFT(id,3) != 'way';
ALTER TABLE overpass_roads RENAME COLUMN wkb_geometry TO the_geom;
DROP TABLE IF EXISTS ring_roads;
CREATE TABLE ring_roads AS (
  SELECT
    name,
    highway AS type,
    ST_Difference(
      the_geom,
      (
        ST_Collect(
          (
            SELECT
              ST_Transform(
                ST_Buffer(
                  ST_Transform(
                    ST_Collect(
                      the_geom
                    ),
                    3857
                  ),
                  100
                ),
                4326
              )
            FROM community_polys
          ),
          (
            SELECT
              the_geom
            FROM community_mask
          )
        )
      )
    ) as the_geom
  FROM overpass_roads
);