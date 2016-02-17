-- collect largest ancestry group in each tract
CREATE TABLE tract_groups AS (
  SELECT DISTINCT ON (id2) id2, max_type, max_value,total
  FROM (
    SELECT
      id2,
      total,
      unnest(ARRAY['afghan', 'albanian', 'alsatian', 'american', 'arab', 'arab_egyptian', 'arab_iraqi', 'arab_jordanian', 'arab_lebanese', 'arab_moroccan', 'arab_palestinian', 'arab_syrian', 'arab_arab', 'arab_other_arab', 'armenian', 'assyrian_chaldean_syriac', 'australian', 'austrian', 'basque', 'belgian', 'brazilian', 'british', 'bulgarian', 'cajun', 'canadian', 'carpatho_rusyn', 'celtic', 'croatian', 'cypriot', 'czech', 'czechoslovakian', 'danish', 'dutch', 'eastern_european', 'english', 'estonian', 'european', 'finnish', 'french_except_basque', 'french_canadian', 'german', 'german_russian', 'greek', 'guyanese', 'hungarian', 'icelander', 'iranian', 'irish', 'israeli', 'italian', 'latvian', 'lithuanian', 'luxemburger', 'macedonian', 'maltese', 'new_zealander', 'northern_european', 'norwegian']) AS max_type,
      unnest(ARRAY[afghan, albanian, alsatian, american, arab, arab_egyptian, arab_iraqi, arab_jordanian, arab_lebanese, arab_moroccan, arab_palestinian, arab_syrian, arab_arab, arab_other_arab, armenian, assyrian_chaldean_syriac, australian, austrian, basque, belgian, brazilian, british, bulgarian, cajun, canadian, carpatho_rusyn, celtic, croatian, cypriot, czech, czechoslovakian, danish, dutch, eastern_european, english, estonian, european, finnish, french_except_basque, french_canadian, german, german_russian, greek, guyanese, hungarian, icelander, iranian, irish, israeli, italian, latvian, lithuanian, luxemburger, macedonian, maltese, new_zealander, northern_european, norwegian]) AS max_value
    FROM tract_ancestry
    ) s
  ORDER BY id2, max_value DESC
);

-- combine ancestry and race at the block level
CREATE TABLE block_parties AS (
  SELECT 
    b.ogc_fid,
    b.wkb_geometry AS the_geom,
    b.geoid10 AS block_geoid,
    t.id2 AS tract_geoid,
    t.total AS tract_total,
    t.max_type AS main_ancestry,
    t.max_value AS main_ancestry_count,
    d.d001 AS block_total,
    d.d002 AS non_hispanic,
    d.d003 AS white,
    d.d004 AS african_american,
    d.d005 AS american_indian,
    d.d006 AS asian,
    d.d007 AS hawaiian_pacific,
    d.d008 AS other,
    d.d009 AS mixed,
    d.d010 AS hispanic_latino
  FROM cook_county_blocks b
  LEFT JOIN tract_groups t ON t.id2 = LEFT(b.geoid10,11)
  LEFT JOIN chicago_race d ON d.geoid2 = b.geoid10
);

-- collect largest racial group in each block
CREATE TABLE block_tribes AS (
  SELECT DISTINCT ON (block_geoid) block_geoid, main_race, main_race_count,block_total
  FROM (
    SELECT
      block_geoid,
      block_total,
      unnest(ARRAY['white', 'african_american', 'american_indian', 'asian', 'hawaiian_pacific', 'other', 'mixed', 'hispanic_latino']) AS main_race,
      unnest(ARRAY[white, african_american, american_indian, asian, hawaiian_pacific, other, mixed, hispanic_latino]) AS main_race_count
    FROM block_parties
    ) s
  ORDER BY block_geoid,main_race_count DESC
);

-- append race and ancestry tables
CREATE TABLE block_final AS (
  SELECT
    p.*,
    t.main_race,
    t.main_race_count
  FROM block_parties p
  LEFT JOIN block_tribes t ON p.block_geoid = t.block_geoid
);

-- determine proportion of block population represented by the largest race
ALTER TABLE block_final ADD COLUMN main_race_fraction double precision;
UPDATE block_final SET main_race_fraction = main_race_count/block_total::float WHERE block_total > 0;
UPDATE block_final SET main_race_fraction = 0 WHERE block_total = 0;

-- crosswalk selected race identities to largest ancestry group in tract (disaggregate)
ALTER TABLE block_final ADD COLUMN main_aggregate text;
UPDATE block_final SET main_aggregate =
  CASE
    
  
  
    WHEN main_race = 'white' THEN main_ancestry
    WHEN main_race = 'hispanic_latino' THEN main_ancestry
    WHEN main_race = 'asian' THEN main_ancestry
    ELSE main_race
  END
;

-- clear (mostly) empty blocks
DELETE FROM block_final WHERE block_total <= 2;

-- expand then erode block borders
CREATE TABLE demographic_groups AS (
  SELECT
    main_aggregate,
    ST_Transform(
      ST_Buffer(
        ST_Buffer(
          ST_Transform(
            ST_Union(the_geom),
            3857
          ),
          -150
        ),
        50
      ),
      4326
    ) AS the_geom,
    avg(main_race_fraction) AS demo_fraction
  FROM block_final
  GROUP BY main_aggregate
);