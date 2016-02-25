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
rm -rf data/tmp/

echo 'creating temp location'
mkdir data/tmp/

echo 'grabbing and importing geodata (tracts)'
cd data/tmp/
wget -c ftp://ftp2.census.gov/geo/tiger/TIGER2015/TRACT/tl_2015_$STATE_FIPS"_tract.zip"
unzip tl_2015_$STATE_FIPS"_tract.zip"
ogr2ogr -where "COUNTYFP = '$COUNTY_FIPS'" tracts_$COUNTY_FIPS.shp tl_2015_$STATE_FIPS"_tract.shp"
#ogr2ogr -t_srs "EPSG:4326" -f "PostgreSQL" PG:"host=localhost dbname=communities" tracts_$COUNTY_FIPS.shp -nln tracts_$COUNTY_FIPS -nlt PROMOTE_TO_MULTI -lco PRECISION=NO

echo 'getting ancestry and race data'
cd ../../processing/pull
npm install
echo 'getting decennial census data'
node index.js sf1
echo 'getting american community survey data'
node index.js acs5

cd ../../data/tmp/
csvjoin -c "tract" sf1.csv acs5.csv > community_attributes.csv
# reorder for slicing
csvcut -c 49-51,1-48,52-104 community_attributes.csv > community_attributes_ordered.csv

echo 'identifying the largest group in each tract'
cd ../../processing/parse
npm install
node index.js ../../data/tmp/community_attributes_ordered.csv

echo 'joining literate group names'
cd ../../data/tmp
mv community_attributes_ordered.csv.tmp community_attributes_ordered_max.csv
csvjoin -c "largest_group,code" --left community_attributes_ordered_max.csv ../census_community_fields.csv > community_properties.csv

echo 'joining attributes to tract boundaries'

echo 'dissolving and eroding community boundaries'

echo 'exporting final geojson'
#ogr2ogr -f "GeoJSON" demographic_groups.geojson PG:"host=localhost dbname=communities" -sql "SELECT * from demographic_groups"