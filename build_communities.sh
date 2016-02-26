# Build the dataset for a modern demographic map
# USAGE: bash build_communities.sh <State name> <state abbreviation> <state_fips> <county_fips> <census key>

# params
set -eo pipefail
DATE=`date +%Y_%m_%d`
STATE_NAME='Illinois'
STATE_ABBRV='il'
STATE_FIPS='17'
COUNTY_FIPS='031'
CENSUS_KEY='2651a9a403259ff8068723199a90b3060fd0127f'

echo 'cleaning house'
rm -rf data/tmp_$STATE_FIPS"_"$COUNTY_FIPS/

echo 'creating temp location'
mkdir data/tmp_$STATE_FIPS"_"$COUNTY_FIPS/

echo 'getting ancestry and race data'
cd processing/pull
npm install
echo 'getting decennial census data'
node index.js sf1 $CENSUS_KEY $STATE_FIPS $COUNTY_FIPS
echo 'getting american community survey data'
node index.js acs5 $CENSUS_KEY $STATE_FIPS $COUNTY_FIPS
cd ../../data/tmp_$STATE_FIPS"_"$COUNTY_FIPS/
csvjoin -c "tract" sf1.csv acs5.csv > community_attributes.csv
csvcut -c 49-51,1-48,52-104 community_attributes.csv > community_attributes_ordered.csv

echo 'identifying the largest group in each tract'
cd ../../processing/parse
npm install
node index.js ../../data/tmp_$STATE_FIPS"_"$COUNTY_FIPS/community_attributes_ordered.csv

echo 'joining literate group names'
cd ../../data/tmp_$STATE_FIPS"_"$COUNTY_FIPS
mv community_attributes_ordered.csv.tmp community_attributes_ordered_max.csv
csvjoin -c "largest_group,code" --left community_attributes_ordered_max.csv ../census_community_fields.csv > community_properties.csv
csvcut -c "1-4,103-106" community_properties.csv > community_properties_light.csv
sed -i tmp.bak 's/name/largest_community_name/g' community_properties_light.csv

echo 'grabbing and importing geodata (tracts)'
wget -c ftp://ftp2.census.gov/geo/tiger/TIGER2015/TRACT/tl_2015_$STATE_FIPS"_tract.zip"
unzip tl_2015_$STATE_FIPS"_tract.zip"
ogr2ogr -t_srs "EPSG:4326" -f GeoJSON -where "COUNTYFP = '$COUNTY_FIPS'" tracts_$COUNTY_FIPS.geojson tl_2015_$STATE_FIPS"_tract.shp"

echo 'joining attributes to tract boundaries'
cd ../../processing/join
npm install
node index.js ../../data/tmp_$STATE_FIPS"_"$COUNTY_FIPS/tracts_$COUNTY_FIPS.geojson ../../data/tmp_$STATE_FIPS"_"$COUNTY_FIPS/community_properties_light.csv $STATE_FIPS $COUNTY_FIPS

echo 'dissolving and eroding community boundaries'
cd ../dissolve
npm install
cd ../form
npm install
node index.js ../../data/tmp_$STATE_FIPS"_"$COUNTY_FIPS/tracts_$COUNTY_FIPS.geojson
mv dissolvedTracts.geojson ../../data/tmp_$STATE_FIPS"_"$COUNTY_FIPS/



echo 'exporting final geojson'
#ogr2ogr -f "GeoJSON" demographic_groups.geojson PG:"host=localhost dbname=communities" -sql "SELECT * from demographic_groups"