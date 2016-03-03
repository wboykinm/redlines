# Build the dataset for a modern demographic map
# USAGE: bash build_communities.sh <State name> <state abbreviation> <state_fips> <county_fips> <census key>

# params
set -eo pipefail
DATE=`date +%Y_%m_%d`
STATE_NAME=$1
STATE_ABBRV=$2
STATE_FIPS=$3
COUNTY_FIPS=$4
CENSUS_KEY=$5

echo '------------cleaning house------------'
rm -rf data/tmp_$STATE_FIPS"_"$COUNTY_FIPS/

echo '------------creating temp location------------'
mkdir data/tmp_$STATE_FIPS"_"$COUNTY_FIPS/

echo '------------getting ancestry and race data------------'
cd processing/pull
npm install
echo 'getting decennial census data'
node index.js sf1 $CENSUS_KEY $STATE_FIPS $COUNTY_FIPS
echo 'getting american community survey data'
node index.js acs5 $CENSUS_KEY $STATE_FIPS $COUNTY_FIPS
cd ../../data/tmp_$STATE_FIPS"_"$COUNTY_FIPS/
csvjoin -c "tract" sf1.csv acs5.csv > community_attributes.csv
csvcut -c 49-51,1-48,52-104 community_attributes.csv > community_attributes_ordered.csv

echo '------------identifying the largest group in each tract------------'
cd ../../processing/parse
npm install
node index.js ../../data/tmp_$STATE_FIPS"_"$COUNTY_FIPS/community_attributes_ordered.csv

echo '------------joining literate group names------------'
cd ../../data/tmp_$STATE_FIPS"_"$COUNTY_FIPS
mv community_attributes_ordered.csv.tmp community_attributes_ordered_max.csv
csvjoin -c "largest_group,code" --left community_attributes_ordered_max.csv ../census_community_fields.csv > community_properties.csv
csvcut -c "1-4,103-106" community_properties.csv > community_properties_light.csv
sed -i tmp.bak 's/name/largest_community_name/g' community_properties_light.csv

echo '------------importing geodata (tracts)------------'
wget -c ftp://ftp2.census.gov/geo/tiger/TIGER2015/TRACT/tl_2015_$STATE_FIPS"_tract.zip"
unzip tl_2015_$STATE_FIPS"_tract.zip"
ogr2ogr -t_srs "EPSG:4326" -f GeoJSON -where "COUNTYFP = '$COUNTY_FIPS'" tracts_$COUNTY_FIPS.geojson tl_2015_$STATE_FIPS"_tract.shp"

echo '------------joining attributes to tract boundaries------------'
cd ../../processing/join
npm install
node index.js ../../data/tmp_$STATE_FIPS"_"$COUNTY_FIPS/tracts_$COUNTY_FIPS.geojson ../../data/tmp_$STATE_FIPS"_"$COUNTY_FIPS/community_properties_light.csv $STATE_FIPS $COUNTY_FIPS

echo '------------dissolving and eroding community boundaries------------'
# TODO wanted this to be a DB-free joint, but memory limits are hampering turf. PostGIS for now.
#cd ../dissolve
#npm install
cd ../form
#npm install
#node index.js ../../data/tmp_$STATE_FIPS"_"$COUNTY_FIPS/tracts_$COUNTY_FIPS.geojson
#mv erodedTracts.geojson ../../data/tmp_$STATE_FIPS"_"$COUNTY_FIPS/
dropdb communities
createdb communities
psql communities -c "CREATE EXTENSION IF NOT EXISTS postgis"
psql communities -c "CREATE EXTENSION IF NOT EXISTS postgis_topology"
ogr2ogr -t_srs "EPSG:4326" -f "PostgreSQL" PG:"host=localhost dbname=communities" ../../data/tmp_$STATE_FIPS"_"$COUNTY_FIPS/community_tracts_$COUNTY_FIPS.geojson -nln community_tracts -nlt PROMOTE_TO_MULTI -lco PRECISION=NO
psql communities -f form.sql

#echo '------------importing geodata (OSM roads)------------'
#cd ../roads
#npm install
## get the desired area from OSM:
#COMMUNITY_BBOX=$(psql communities -t -c "SELECT '(' || ST_YMin(ST_Transform(ST_Expand(ST_Collect(ST_Transform(the_geom,3857)),2000),4326)) || ',' || ST_XMin(ST_Transform(ST_Expand(ST_Collect(ST_Transform(the_geom,3857)),2000),4326)) || ',' || ST_YMax(ST_Transform(ST_Expand(ST_Collect(ST_Transform(the_geom,3857)),2000),4326)) || ',' || ST_XMax(ST_Transform(ST_Expand(ST_Collect(ST_Transform(the_geom,3857)),2000),4326)) || ')' FROM community_tracts ;")
#node index.js $COMMUNITY_BBOX $STATE_FIPS $COUNTY_FIPS ../../data/tmp_$STATE_FIPS"_"$COUNTY_FIPS/overpass_$county_FIPS.geojson
#ogr2ogr -t_srs "EPSG:4326" -f "PostgreSQL" PG:"host=localhost dbname=communities" #../../data/tmp_$STATE_FIPS"_"$COUNTY_FIPS/overpass_$county_FIPS.geojson -nln overpass_roads -lco PRECISION=NO
#
#echo '------------generating an exterior ring of roads------------'
#psql communities -f roads.sql

echo '------------exporting final geojson(s) and legend summary file------------'
rm -f ../../data/communities_$STATE_FIPS"_"$COUNTY_FIPS.geojson
rm -f ../../data/communities_points_$STATE_FIPS"_"$COUNTY_FIPS.geojson
rm -f ../../data/communities_mask_$STATE_FIPS"_"$COUNTY_FIPS.geojson
rm -f ../../data/communities_roads_$STATE_FIPS"_"$COUNTY_FIPS.geojson

rm -f ../../data/community_legend_$STATE_FIPS"_"$COUNTY_FIPS.csv
ogr2ogr -f "GeoJSON" ../../data/communities_$STATE_FIPS"_"$COUNTY_FIPS.geojson PG:"host=localhost dbname=communities" -sql "SELECT * from community_polys"
ogr2ogr -f "GeoJSON" ../../data/communities_points_$STATE_FIPS"_"$COUNTY_FIPS.geojson PG:"host=localhost dbname=communities" -sql "SELECT * from community_centroids"
ogr2ogr -f "GeoJSON" ../../data/communities_mask_$STATE_FIPS"_"$COUNTY_FIPS.geojson PG:"host=localhost dbname=communities" -sql "SELECT * from community_mask"
#ogr2ogr -f "GeoJSON" ../../data/communities_roads_$STATE_FIPS"_"$COUNTY_FIPS.geojson PG:"host=localhost dbname=communities" -sql "SELECT * from ring_roads"
psql communities -c "\\copy (SELECT largest_community_name,sum(largest_group_count) AS membership, avg(largest_group_proportion) AS avg_plurality FROM community_polys GROUP BY largest_community_name ORDER BY largest_community_name ASC) TO STDOUT DELIMITER ',' CSV HEADER" > ../../data/community_legend_$STATE_FIPS"_"$COUNTY_FIPS.csv
rm -rf ../../data/tmp/

echo '------------done!------------'