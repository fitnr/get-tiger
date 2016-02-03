# Get tiger

A `make`-based tool for downloading Census [Tiger Line](http://www.census.gov/geo/maps-data/data/tiger.html) Shapefiles and automatically joining them to data downloaded from the [Census API](http://www.census.gov/data/developers/data-sets.html). This Makefile does is automatically.

## Requirements

* ogr2ogr ([GDAL](http://www.gdal.org))
* [jq](https://stedolan.github.io/jq)

On OS X, install [Homebrew](http://brew.sh) and run: `brew install gdal jq`.

## Install

* Download the repo and put the contents in the folder you would like to fill with GIS data.
* Get a [Census API key](http://api.census.gov/data/key_signup.html) (yes, it's pretty bare-bones).
* Put that key in `key_example.ini`, and rename it `key.ini`.

## Use

Running `make` will produce a list of Census geographies available for download.

To download one or more, run with the `DOWNLOAD` variable, like so:

````bash
make DOWNLOAD=COUNTY
make DOWNLOAD="STATE NATION"
````

If you would like to only download some states, use the `STATE_FIPS` variable:

````bash
# Only New York
make DOWNLOAD=COUNTY STATE_FIPS=36

# Only DC, Virginia and Maryland
make DOWNLOAD=COUNTY STATE_FIPS="11 51 24"
````

If you would like a reference for state fips code, see [`fips.txt`](fips.txt).

## What data

A current weakness is that data is downloaded with no data dictionary, and cryptic field names. The [data.json](data.json) file has a data dictionary for the variables I've chosen. 

To download different fields, see the [Census API documentation](http://www.census.gov/data/developers/data-sets/acs-survey-5-year-data.html) for a complete list. Make your selection, then run:

````bash
make DOWNLOAD=STATE DATA_FIELDS="GEOID B24124_406E B24124_407E"
````
Note that `GEOID` must be the first field. This example will download employment figures for commercial divers and locksmiths.

### Vintage

By default, the Makefile downloads 2014 data, the most recent year for which [ACS](https://www.census.gov/programs-surveys/acs/) is available. For older years (or newer years, if it's the future), use the `YEAR` variable:
```bash
make YEAR=2013 DOWNLOAD=STATE
make YEAR=2015 DOWNLOAD=STATE
```

### Data series

The default data series is ACS 5-year data or `acs5`. To fetch another data set, use the `SERIES` variable.
```bash
make SERIES=acs1 DOWNLOAD=TRACT
```

(This isn't tested for all data series, but should work.)

To change any of these defaults permanently, just edit the Makefile. If you want to be cautious, add your changes to `key.ini`. Variables there will override ones in the [`Makefile`](Makefile).

### Interesting tidbits

* The Census API appends extra geography fields at the end of a request. For example, 'state', 'county', and 'tract' for a tract file. As part of the processing, these are converted to numbers, which reduces their usefulness. Use the GEOID field for joining.
* The AWATER (water area) and ALAND (land area) fields are given in square meters. `ogr2ogr` has trouble with values more than nine digits long, so these will return errors. The Makefile adds LANDKM and WATERKM fields (the same data in square kilometers) to get around this issue.