# Build the dataset for a modern demographic map

# params
set -eo pipefail
DATE=`date +%Y_%m_%d`
STATE_NAME='Illinois'
STATE_ABBRV='il'
STATE_FIPS='17'
COUNTY_FIPS='031'
CENSUS_KEY='2651a9a403259ff8068723199a90b3060fd0127f'

echo 'cleaning house'

rm -r data/tmp/
dropdb communities

echo 'creating DB and schemas'
mkdir data/tmp/
createdb communities
psql communities -f schemas.sql

echo 'grabbing and importing geodata (tracts)'
cd data/tmp/
wget -c ftp://ftp2.census.gov/geo/tiger/TIGER2015/TRACT/tl_2015_$STATE_FIPS"_tract.zip"
unzip tl_2015_$STATE_FIPS"_tract.zip"
ogr2ogr -where "COUNTYFP10 = '$COUNTY_FIPS'" tracts_$COUNTY_FIPS.shp tl_2015_$STATE_FIPS"_tract.shp"
ogr2ogr -t_srs "EPSG:4326" -f "PostgreSQL" PG:"host=localhost dbname=communities" tracts_$COUNTY_FIPS.shp -nln tracts_$COUNTY_FIPS -nlt PROMOTE_TO_MULTI -lco PRECISION=NO

echo 'getting ancestry and race data'
cd ../../processing/pull
npm install
node index.js

echo 'exporting final geojson'
ogr2ogr -f "GeoJSON" demographic_groups.geojson PG:"host=localhost dbname=communities" -sql "SELECT * from demographic_groups"