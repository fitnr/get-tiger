# Get tiger

A `make`-based tool for downloading Census [Tiger Line](http://www.census.gov/geo/maps-data/data/tiger.html) Shapefiles and automatically joining them to data downloaded from the [Census API](http://www.census.gov/data/developers/data-sets.html). If you want to make maps with US Census data, but find downloading it a pain, this is for you.

Get-tiger uses `make`, a tried-and-true tool for processing series of files, to quickly download Census geodata and survey data, then join them. Then you have Shapefiles (or GeoJSON) ready to use in your favorite GIS.

## Requirements

* Make (tested with GNU make 3.81, other versions should work fine)
* `ogr2ogr` ([GDAL](http://www.gdal.org)) (v1.10+)

GDAL is an open-source geospatial library that includes `ogr2ogr`, a commmand-line tool for modifying GIS data. We'll be using it to join CSVs to Shapefiles.

OS X:
* install make with: `xcode-select --install`.
* For GDAL, install [Homebrew](http://brew.sh) and run: `brew install gdal`.

Windows:
* Download [make](http://gnuwin32.sourceforge.net/packages/make.htm)
* Install [OSGeo4W](http://trac.osgeo.org/osgeo4w/) to get GDAL

Linux (CentOS):
* `sudo apt-get install build-essential g++ libgdal1-dev gdal-bin`

## Install

* Download or clone the repo and put the contents in the folder you would like to fill with GIS data.
* Get a [Census API key](http://api.census.gov/data/key_signup.html) (yes, it's pretty bare-bones).
* Put that key in `key_example.ini`, and rename it `key.ini`.

## Use

Running `make` will produce a list of Census geographies available for download:
```bash
make
Available data sets:
Download with make DATASET
NATION - United States
...
UNSD - Unified school districts
ZCTA5 - Zip code tabulation areas
```

To download one or more, run with name of the dataset, like so:
````bash
# Download the national and state files and data
make NATION STATE
# Download county data and each state's tract data
make COUNTY TRACT
````

Make will run the commands to download the shapefiles and data from the Census, then join them. You'll see the commands run on your screen, sit back and enjoy the show. The files will end up in a directory called `2014/`. At the end, you'll get a list of the files created, e.g.:
```bash
make NATION STATE
...
2014/NATION/cb_2014_us_nation_5m.shp 2014/STATE/tl_2014_us_state.shp
```

Some commands will download many files. For instance, this will download files for the fifty states, DC and Puerto Rico:
````bash
make PLACE
````

To download only some states and territories, use the `STATE_FIPS` variable:
````bash
# Only New York
make PLACE STATE_FIPS=36

# Only DC, Maryland and Virginia
make PLACE STATE_FIPS="11 24 51"
````

You may find a [list of state fips codes](https://en.wikipedia.org/wiki/Federal_Information_Processing_Standard_state_code) handy.

## What data

A current weakness is that data is downloaded with no data dictionary, and cryptic field names. I've included a data dictionary ([data.json](data.json)) for the default fields.

To download different data, see the [Census API documentation](http://www.census.gov/data/developers/data-sets/acs-survey-5-year-data.html) for a complete list. You must select each field separately. Due to the way the Census API is set up, one cannot just download an entire table.

Make your selection, then run it, e.g.:

````bash
make STATE DATA_FIELDS="GEOID B24124_406E B24124_407E"
````
Note that `GEOID` must be the first field. This example will download state-level geodata and employment figures for commercial divers and locksmiths.

You could also add these fields to `key.ini`:
````make
DATA_FIELDS= GEOID B24124_406E B24124_407E
````
This will override the defaults in the [`Makefile`](Makefile).

Sometimes you want to make summaries based on the raw data fields. For instance, you might want to divide population by land area to get population density. The variable `OUTPUT_FIELDS` can be used to add this kind of summary field.

This example adds a field called `TransitCommutePct`, which is produced by dividing `B08101_025E` (estimated number of workers who commuted by transit) by the `B08101_001E` (estimated number of workers)
```
OUTPUT_FIELDS= B08101_025 / B08101_001 AS TransitCommutePct,
```

Note that in the expression, the `E` is dropped from the variable names. This is due to a limitation of the Shape format - only the first 10 letters of field names are used. Also, the expression must end in a comma.

Another example:
```
OUTPUT_FIELDS= B01003_001/(ALAND/1000000.) AS PopDensityKm,
```

The field `B01003_001` is population. The census calls it `B01003_001E`, but has been shortened to 10 characters. We divide it by `ALAND/1000000.`, because the `ALAND` field is given in meters. The `AS PopDensityKm` gives the name of the new field. Finally, it must end with a comma (`,`).

### Vintage

By default, the Makefile downloads 2014 data, the most recent year for which [ACS](https://www.census.gov/programs-surveys/acs/) is available. For older years (or newer years, if it's the future), use the `YEAR` variable:
```bash
make STATE YEAR=2013
make STATE YEAR=2015 
```

### Data series

The default data series is ACS 5-year data or `acs5`. To fetch another data set, use the `SERIES` variable.
```bash
make TRACT SERIES=acs1 
```
(This isn't tested for all data series, but should work.)

### Secret bonus tasks for merging data

A relatively common task is to download a national set of geographies of a certain type. Run this to download a national dataset of block groups: 
```bash
make 2014/BG.shp
```

You can add in options for different `DATA_FIELDS` as described above. To run this task for a different year, you'll need to change the year twice (`make 2013/BG.shp YEAR=2013`).

Get-tiger includes shortcut tasks like this for the following geographies. They all follow the same pattern (`2014/<NAME>.shp`):

* blockgroups (`BG`)
* consolidated cities (`CONCITY`)
* counties within urban areas (`COUNTY_WITHIN_UA`)
* county subdivisions (`COUSUB`)
* school districts (`UNSD`, `ELSD` and `SCSD`)
* places (`PLACE`)
* primary/secondary roads (`PRISECROADS`)
* public use microdata areas (`PUMA`)
* state legislative districts (`SLDL`, `SLDU`)
* blocks (`TABBLOCK`)
* census tracts (`TRACT`) 

### Format

By default, this thing spits out Shapefiles. To get GeoJSON, set `format` to `json`:
````bash
make TRACT format=json
make TRACT format=shp # default
make 2014/COUSUB.json format=json
````

## Integration

`Get-tiger` will integrate well with just about any workflow. For instance, here's a basic make recipe to automatically download the repository and then get data county-level data:

```makefile
# Census API key
export KEY=12345 
# chosen data fields
export DATA_FIELDS="GEOID B24124_406E B24124_407E"

# If you do this, you should probably fork the repository and clone your fork
census-data:
	git clone --single-branch https://github.com/fitnr/get-tiger.git census-data
	touch census-data/key.ini # You'll need to create the key.ini file to prevent an error
	$(MAKE) -C census-data COUNTY
```

Your data will be available in `census-data/2014/COUNTY`. These steps can be readily performed by the scripting language of your choice.

## Interesting tidbits

* The Census API appends extra geography fields at the end of a request. For example, 'state', 'county', and 'tract' for a tract file. As part of the processing, these are converted to numeric values, which reduces their usefulness. Use the GEOID field for joining.
* The AWATER (water area) and ALAND (land area) fields are given in square meters. The Shapefile format has trouble with values more than nine digits long, so these will trigger warnings in `ogrogr`. The Makefile adds LANDKM and WATERKM fields (the same data in square kilometers) to get around this issue. Also, `get-tiger` squelches the warning messages on these operations.
* Where available, get-tiger will download the [cartographic boundary](https://www.census.gov/geo/maps-data/data/tiger-cart-boundary.html) files, rather than [Tiger/Line](https://www.census.gov/geo/maps-data/data/tiger-line.html) files. The cartographic files are clipped to the shoreline, Tiger/Line files are not. If you would prefer the Tiger/Line files, open an issue and I'll add a way to download them.
* Run tasks with the `--jobs` option (e.g. `make --jobs 3`) to take advantage of a fast connection and/or computer.
* Downloading data for blockgroups requires downloading data county-by-county. This means get-tiger needs a list of all the counties in the US. A list of 2014 counties is included. If you're downloading blockgroups for other years, run `make countyfips YEAR=2525` before running `make BG`.

## License

Copyright 2016 Neil Freeman. Available under the GNU General Public License.
