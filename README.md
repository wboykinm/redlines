# Tribes
A map of aggregate racial/ancestral groups based on [a 1950 map of Chicago](https://upload.wikimedia.org/wikipedia/commons/b/b5/Chicago_Demographics_in_1950_Map.jpg)

![original](original.png)

## Data sources
 - [Census TIGER geographic boundaries](data/cook_county_blocks.geojson)
 - [Ancestry - table B04005](data/ACS_14_5YR_B04005_with_ann.csv)
 - [Race including Hispanic/Latino - table B03002](data/ACS_14_5YR_B03002_with_ann.csv)
 - [Zillow neighborhoods](data/zillow_neighborhoods.geojson)
 
 ## Assumptions (a running list)
 - __Meta-assumption: ancestry can be inferred by race.__ This is a dramatic oversimplification, to say the least.
 - The largest ancestral group in a tract is related to the largest racial group in a block contained by that tract.
 - "American" ancestry refers almost exclusively to African-Americans.
 - The "Mixed" racial group in a block is adequately represented by the largest ancestral group in the containing tract.