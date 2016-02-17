# Build the dataset for a modern demographic map

# params
set -eo pipefail
DATE=`date +%Y_%m_%d`
STATE_FIPS='17'
COUNTY_FIPS='031'

echo 'cleaning house'

rm -r data/tmp/
dropdb communities

echo 'creating DB and schemas'
mkdir data/tmp/
createdb communities
psql communities -f schemas.sql

echo 'grabbing and importing geodata (blocks)'
cd data/tmp/
wget -c ftp://ftp2.census.gov/geo/tiger/TIGER2015/TABBLOCK/tl_2015_$STATE_FIPS"_tabblock10.zip"
unzip tl_2015_$STATE_FIPS"_tabblock10.zip"
ogr2ogr -where "COUNTYFP10 = '$COUNTY_FIPS'" blocks_$COUNTY_FIPS.shp tl_2015_$STATE_FIPS"_tabblock10.shp"
ogr2ogr -t_srs "EPSG:4326" -f "PostgreSQL" PG:"host=localhost dbname=communities" blocks_$COUNTY_FIPS.shp -nln blocks_$COUNTY_FIPS -nlt PROMOTE_TO_MULTI -lco PRECISION=NO

echo 'importing ancestry and race data'
#FIXME This data isn't block-level
sed -e 2d ../ACS_14_5YR_B03002_with_ann.csv > b03002.csv
sed -e 2d ../ACS_13_5YR_B04001_with_ann.csv > b04001.csv
psql communities -c "\\copy b03002 FROM 'b03002.csv' DELIMITER ',' CSV HEADER"
psql communities -c "\\copy b04001 FROM 'b04001.csv' DELIMITER ',' CSV HEADER"



echo 'exporting final geojson'
ogr2ogr -f "GeoJSON" demographic_groups.geojson PG:"host=localhost dbname=communities" -sql "SELECT * from demographic_groups"