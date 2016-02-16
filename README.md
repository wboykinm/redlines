# Tribes
A map of aggregate racial/ancestral groups based on [a 1950 map of Chicago](https://upload.wikimedia.org/wikipedia/commons/b/b5/Chicago_Demographics_in_1950_Map.jpg). The reason for using an aggregate approach is that the census [only reports ancestry for slightly more than half of the US population](http://factfinder.census.gov/faces/tableservices/jsf/pages/productview.xhtml?pid=ACS_13_5YR_B04001&prodType=table), including in configurations that fail to represent whole racial/ethnic groups. In order to capture the conceptual spirit and geographic detail of the original map, it is worthwhile to combine the two in the most-representative way possible.

[Current demo](https://geosprocket.cartodb.com/viz/b0441962-d398-11e5-a592-0e3ff518bd15/embed_map)

![original](original.png)

## Data sources
 - [Census TIGER geographic boundaries - block-level](data/cook_county_blocks.geojson)
 - [Ancestry - table B04001](data/ACS_14_5YR_B04005_with_ann.csv)
 - [Race including Hispanic/Latino - table B03002](data/ACS_14_5YR_B03002_with_ann.csv)
 - [Zillow neighborhoods](data/zillow_neighborhoods.geojson)
 
## Processing steps
_[scratchpad](processing/community_map_steps.sql)_
 1. Import all above data to PostgreSQL
 2. Order ancestries in each census tract by proportion of the population; retain proportion stats
 3. Order racial/ethnic groups in each census block by proportion of the population; retain proportion stats
 4. Join block geometries, ancestry and race tables on block/tract geoid
 5. Delete empty blocks
 6. Add "community" aggregate field, mapping ancestry to the block level
 7. Expand block boundaries by 250m, dissolve, then erode by 275m for cartographic effect
 8. Map [according to original style](cartography/chicago_demographics.mss)
 
## Assumptions (a running list)
 - __Meta-assumption: ancestry can be inferred by race.__ This is a dramatic oversimplification, to say the least.
 - The largest ancestral group in a tract is related to the largest racial group in a block contained by that tract.
 - The [first ancestry reported](http://factfinder.census.gov/faces/tableservices/jsf/pages/productview.xhtml?pid=ACS_13_5YR_B04001&prodType=table) is admissible as the only ancestry.
 - Asian and Hispanic/Latino groups can be represented by race in the absence of ancestral categories encompassing them.
 - In majority-black census blocks, "American" ancestry refers almost exclusively to African-Americans.
 - The "Mixed" racial group in a block is adequately represented by the largest ancestral group in the containing tract.
 - "Hispanic/Latino" can be [represented as a race-like category](http://censusreporter.org/topics/race-hispanic/)
 - Margin of error can be ignored