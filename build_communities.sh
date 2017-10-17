# Build the dataset for a modern demographic map
# USAGE: bash build_communities.sh <state abbreviation (e.g. 'MA')> <county name (e.g. 'Suffolk')>

# params (ncluding ridiculous handlers for extra quotes, caps, spaces, and apostrophes)
set -eo pipefail
DATE=`date +%Y_%m_%d`
STATE_ABBRV=$(echo $1 | awk '{print tolower($0)}')
LOCATION_DETAILS=$(csvgrep -c 1 -m $1 data/census_fips_codes.csv | csvgrep -c 5 -m $2 | csvjson)
STATE_NAME=$(echo $LOCATION_DETAILS | jq '.[0].state_long')
STATE_NAME="${STATE_NAME%\"}"
STATE_NAME="${STATE_NAME#\"}"
STATE_FIPS=$(echo $LOCATION_DETAILS | jq '.[0].state_fips')
STATE_FIPS="${STATE_FIPS%\"}"
STATE_FIPS="${STATE_FIPS#\"}"
COUNTY_FIPS=$(echo $LOCATION_DETAILS | jq '.[0].county_fips')
COUNTY_FIPS="${COUNTY_FIPS%\"}"
COUNTY_FIPS="${COUNTY_FIPS#\"}"
COUNTY_NAME=$(echo $LOCATION_DETAILS | jq '.[0].county')
COUNTY_NAME="${COUNTY_NAME//[ ,\']/_}"
COUNTY_NAME=$(echo $COUNTY_NAME | awk '{print tolower($0)}')
COUNTY_NAME="${COUNTY_NAME%\"}"
COUNTY_NAME="${COUNTY_NAME#\"}"
TILE_ZOOM=11
CENSUS_KEY=6cf83ef5cf4401ace5c8dcccae0bd9ca2999aeb1
REDLINES_MB_TOKEN=sk.eyJ1IjoibGFuZHBsYW5uZXIiLCJhIjoiY2lsaXFkMng1M2NxMXY2bTBvaXQ0Z2N0eCJ9.dl5GmYgdPdNupaYxk8y16g
TILES_MB_TOKEN=sk.eyJ1IjoibGFuZHBsYW5uZXIiLCJhIjoiY2ltcjB0MmozMDB0MHY5a2t5c2Fsb3Q0diJ9.3qyTzT995P_Fo1fJ2tyr6A
MB_USER=landplanner

echo '------------cleaning house------------'
rm -rf data/tmp_$STATE_ABBRV"_"$COUNTY_NAME/

echo '------------creating temp location------------'
mkdir data/tmp_$STATE_ABBRV"_"$COUNTY_NAME/

echo '------------getting ancestry and race data------------'
cd processing/pull
npm install
echo 'getting decennial census data'
node index.js sf1 $CENSUS_KEY $STATE_FIPS $COUNTY_FIPS $STATE_ABBRV $COUNTY_NAME
echo 'getting american community survey data'
node index.js acs5 $CENSUS_KEY $STATE_FIPS $COUNTY_FIPS $STATE_ABBRV $COUNTY_NAME
cd ../../data/tmp_$STATE_ABBRV"_"$COUNTY_NAME/
csvjoin -c "tract" sf1.csv acs5.csv > community_attributes.csv
csvcut -c 49-51,1-48,52-104 community_attributes.csv > community_attributes_ordered.csv

echo '------------identifying the largest group in each tract------------'
cd ../../processing/parse
npm install
node index.js ../../data/tmp_$STATE_ABBRV"_"$COUNTY_NAME/community_attributes_ordered.csv

echo '------------joining literate group names------------'
cd ../../data/tmp_$STATE_ABBRV"_"$COUNTY_NAME
mv community_attributes_ordered.csv.tmp community_attributes_ordered_max.csv
csvjoin -c "largest_group,code" --left community_attributes_ordered_max.csv ../census_community_fields.csv > community_properties.csv
csvcut -c "1-4,103-109" community_properties.csv > community_properties_light.csv
sed -i tmp.bak 's/name,/largest_community_name,/g' community_properties_light.csv

echo '------------importing geodata (tracts)------------'
wget -c ftp://ftp2.census.gov/geo/tiger/TIGER2015/TRACT/tl_2015_$STATE_FIPS"_tract.zip"
unzip tl_2015_$STATE_FIPS"_tract.zip"
ogr2ogr -t_srs "EPSG:4326" -f GeoJSON -where "COUNTYFP = '$COUNTY_FIPS'" tracts_$COUNTY_FIPS.geojson tl_2015_$STATE_FIPS"_tract.shp"

#echo '------------importing geodata (OSM water)------------'
#cd ../../processing/water
#npm install
## get expanded bbox from tracts_$COUNTY_FIPS.geojson
#COMMUNITY_BBOX=$(node bbox.js ../../data/tmp_$STATE_ABBRV"_"$COUNTY_NAME/tracts_$COUNTY_FIPS.geojson)
## pipe it through a tile cruncher
#echo $COMMUNITY_BBOX | mercantile tiles $TILE_ZOOM > ../../data/tmp_$STATE_ABBRV"_"$COUNTY_NAME/tiles.txt
## . . . and then the mapbox api in 6x parallel to get geojson
#cat ../../data/tmp_$STATE_ABBRV"_"$COUNTY_NAME/tiles.txt | parallel -j6 node get.js {} ../../data/tmp_$STATE_ABBRV"_"$COUNTY_NAME/ $TILES_MB_TOKEN
## combine it all into one beastly geojson for the hell of it
#geojson-merge ../../data/tmp_$STATE_ABBRV"_"$COUNTY_NAME/osm_water*.geojson > ../../data/tmp_$STATE_ABBRV"_"$COUNTY_NAME/all_osm_water.geojson

echo '------------joining attributes to tract boundaries------------'
cd ../../processing/join
npm install
node index.js ../../data/tmp_$STATE_ABBRV"_"$COUNTY_NAME/tracts_$COUNTY_FIPS.geojson ../../data/tmp_$STATE_ABBRV"_"$COUNTY_NAME/community_properties_light.csv $STATE_ABBRV $COUNTY_NAME

echo '------------moving it all into postgis------------'
dropdb communities --if-exists
createdb communities
psql communities -c "CREATE EXTENSION IF NOT EXISTS postgis"
psql communities -c "CREATE EXTENSION IF NOT EXISTS postgis_topology"
cd ../../data/tmp_$STATE_ABBRV"_"$COUNTY_NAME/
psql communities -c "DROP TABLE IF EXISTS community_tracts"
ogr2ogr -t_srs "EPSG:4326" -f "PostgreSQL" PG:"host=localhost dbname=communities" community_tracts_$COUNTY_NAME.geojson -nln community_tracts -nlt PROMOTE_TO_MULTI -lco PRECISION=NO
psql communities -c "CREATE TABLE tracts_backfill AS (SELECT * FROM community_tracts)"

#echo '------------remove water polygons from the tract boundaries------------'
#for g in $(ls osm_water*.geojson); do
  #ogr2ogr -t_srs "EPSG:4326" -f "PostgreSQL" PG:"host=localhost dbname=communities" $g -nln water_tile -nlt PROMOTE_TO_MULTI -lco PRECISION=NO
  ## fix what polygons can be fixed
  #psql communities -c "DROP TABLE IF EXISTS valid_water"
  #psql communities -c "CREATE TABLE valid_water AS ( SELECT ST_Makevalid(wkb_geometry) AS the_geom FROM water_tile)"
  ## blow away the small ones
  #psql communities -c "DELETE FROM valid_water WHERE ST_Area( ST_Transform( the_geom, 3857 ) ) < 500000"
  #POND_COUNT=$(psql communities -t -c "SELECT count(*) FROM valid_water")
  #if [ $POND_COUNT = 0 ]; then 
    #echo "no large-ish water bodies"
    #psql communities -c "DROP TABLE IF EXISTS water_tile"
    #psql communities -c "DROP TABLE IF EXISTS valid_water"
  #else
    #psql communities -f ../../processing/water/piranha.sql
    #sleep 2
    #echo "chomped $POND_COUNT water bodies in tile $g"
  #fi
#done
psql communities -c "DROP TABLE IF EXISTS backfilled_tracts"
psql communities -c "CREATE TABLE backfilled_tracts AS (SELECT * FROM tracts_backfill WHERE geoid NOT IN (SELECT geoid FROM community_tracts) UNION ALL SELECT * FROM community_tracts)"
psql communities -c "DROP TABLE IF EXISTS community_tracts"
psql communities -c "ALTER TABLE backfilled_tracts RENAME TO community_tracts"
psql communities -c "ALTER TABLE community_tracts ALTER COLUMN p0010001 TYPE int USING p0010001::int"
psql communities -c "ALTER TABLE community_tracts RENAME COLUMN p0010001 TO total_population"
psql communities -c "ALTER TABLE community_tracts ALTER COLUMN largest_group_count TYPE int USING largest_group_count::int"
psql communities -c "ALTER TABLE community_tracts ALTER COLUMN largest_group_proportion TYPE float USING largest_group_proportion::float"
psql communities -c "ALTER TABLE community_tracts ADD COLUMN population_density int"
# calc populatioln density using albers because mercator was just comprehensively awful for everything
psql communities -c "UPDATE community_tracts SET population_density = round(total_population/(ST_Area(ST_Transform(wkb_geometry,2163))/1000000)) WHERE (ST_Area(ST_Transform(wkb_geometry,2163))/1000000) > 0"

echo '------------dissolving and eroding community boundaries------------'
psql communities -f ../../processing/form/form.sql

echo '------------exporting final geojson(s)------------'
# CLEAR THE DECKS
rm -f communities_polys.geojson
rm -f communities_points.geojson
rm -f communities_mask.geojson
rm -f communities_tracts.geojson

# EXPORT THE 3 MAP-READY FILES TO THE TMP DATA DIRECTORY
ogr2ogr -f "GeoJSON" communities_polys.geojson PG:"host=localhost dbname=communities" -sql "SELECT * from community_polys WHERE largest_group_count IS NOT NULL AND total_population IS NOT NULL"
ogr2ogr -f "GeoJSON" communities_points.geojson PG:"host=localhost dbname=communities" -sql "SELECT * from community_centroids WHERE largest_group_count IS NOT NULL AND total_population IS NOT NULL"
ogr2ogr -f "GeoJSON" communities_mask.geojson PG:"host=localhost dbname=communities" -sql "SELECT * from community_mask"
ogr2ogr -f "GeoJSON" communities_tracts.geojson PG:"host=localhost dbname=communities" -sql "SELECT * from community_tracts WHERE largest_group_count > 0 AND total_population > 0"

##########################################################################
# NEW THING: build map using d3js:
##########################################################################

##########################################################################

# DEFINE DATA LAYER NAMES
#POLYS=$MB_USER.rl_$STATE_ABBRV"_"$COUNTY_NAME
#POINTS=$MB_USER.rl_points_$STATE_ABBRV"_"$COUNTY_NAME
#MASK=$MB_USER.rl_mask_$STATE_ABBRV"_"$COUNTY_NAME
#TRACTS=$MB_USER.rl_tracts_$STATE_ABBRV"_"$COUNTY_NAME
#
#echo '------------uploading geojson to mapbox data'
#export MAPBOX_ACCESS_TOKEN=$REDLINES_MB_TOKEN
#mapbox upload communities_polys.geojson $POLYS --name communities_polys 
#mapbox upload communities_points.geojson $POINTS --name communities_points 
#mapbox upload communities_mask.geojson $MASK --name communities_mask 
#mapbox upload communities_tracts.geojson $TRACTS --name communities_tracts 
#
#echo "------------creating mapbox studio projects for $STATE_NAME county $COUNTY_FIPS------------"
#cd ../../cartography
## CREATE A COUNTY-SPECIFIC MAPBOX STUDIO CLASSIC PROJECT
#rm -rf rl_$STATE_ABBRV"_"$COUNTY_NAME.tm2
#cp -r redlines.tm2 rl_$STATE_ABBRV"_"$COUNTY_NAME.tm2
#
## GET CENTROID OF COUNTY
#COUNTY_LAT=$(psql communities -t -c "SELECT ST_Y(ST_Centroid(ST_Collect(the_geom))) FROM community_polys")
#COUNTY_LON=$(psql communities -t -c "SELECT ST_X(ST_Centroid(ST_Collect(the_geom))) FROM community_polys")
#
## REWRITE PROJECT CONFIG FILES
#cd rl_$STATE_ABBRV"_"$COUNTY_NAME.tm2/
#sed -i tmp2.bak "s/name: Tribes/name: Tribes - $COUNTY_NAME, $STATE_NAME/g" project.yml
#sed -i tmp3.bak "s/landplanner.0xsgug3g/$POLYS/g" project.yml
#sed -i tmp3.bak "s/landplanner.69rz84n1/$POINTS/g" project.yml
#sed -i tmp3.bak "s/landplanner.0ufuyubk/$MASK/g" project.yml
#sed -i tmp3.bak "s/landplanner.placeholder/$TRACTS/g" project.yml
#sed -i tmp4.bak "s/- -118.2437/-$COUNTY_LON/g" project.yml
#sed -i tmp5.bak "s/- 34.0522/-$COUNTY_LAT/g" project.yml

# EXPORT LEGEND WITH EMPTY GROUPS REMOVED
psql communities -c "\\copy (SELECT * FROM community_legend) TO STDOUT DELIMITER ',' CSV HEADER" | csvgrep -c 2 -r '\S' > legend/community_legend.csv 

cp legend/community_legend.csv bubbles/

# EXPORT LEGEND TO PNG FOR LAYOUT
#cd legend/
# START A WEB SERVER
#static-server -p 8000 "$output""$ext" &
#STATICPID=$!
#sleep 10
#echo 'waiting 10s for server to spin up'
# EXPORT THE IMAGE
# TODO rip out phantomjs, use puppeteer: https://github.com/ebidel/try-puppeteer

#phantomjs rasterize.js http://localhost:8000/index.html legend.png
# KILL THE WEBSERVER
#kill -s 9 $STATICPID
#cp legend.png ../img/
#cp legend.png ../exports/

# EXPORT BUBBLE CHART TO PNG FOR LAYOUT
#cd ../bubbles/
# START A WEB SERVER
#static-server -p 8000 "$output""$ext" &
#STATICPID=$!
#sleep 10
#echo 'waiting 10s for server to spin up'
## EXPORT THE IMAGE
#phantomjs rasterize.js http://localhost:8000/index.html bubbles.png
## KILL THE WEBSERVER
#kill -s 9 $STATICPID
#cp bubbles.png ../img/
#cp bubbles.png ../exports/
#cd ../../../

# CLEAR OUT THE TEMP DATA TO SAVE SPACE
#rm -rf data/tmp/

#echo "------------done! go add the project to mapbox studio and you're off to the races!------------"