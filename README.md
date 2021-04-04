# Get tiger

A `make`-based tool for downloading Census [Tiger Line](http://www.census.gov/geo/maps-data/data/tiger.html) Shapefiles.

Get-tiger uses `make`, a tried-and-true tool for processing series of files, to quickly download Census geodata. Then you have Shapefiles (or GeoJSON) ready to use in your favorite GIS.

## Requirements

* [Make](https://www.gnu.org/software/make/) (tested with GNU make 3.81, other versions should work fine)
* [wget](https://www.gnu.org/software/wget/): a utility for downloading files that's probably already installed on your machine

Some helper commands require [GDAL](https://gdal.org), is an open-source geospatial library that includes commmand-line tools for modifying GIS data. If you don't have access to GDAL, set the `GDAL=false` variable, and those commands will be skipped.

## Install

* Download or clone the repo and put the contents in the folder you would like to fill with GIS data.

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

Make will run the commands to download the shapefiles and data from the Census, then join them. You'll see the commands run on your screen, sit back and enjoy the show. The files will end up in a directory called `2019/`. 
```bash
> make NATION STATE
mkdir -p 2019/NATION
wget -q -nc -t 10 --waitretry 1 --timeout 2 ftp://ftp2.census.gov/geo/tiger/GENZ2019/shp/cb_2019_us_nation_5m.zip -o 2019/NATION/cb_2019_us_nation_5m.zip
mkdir -p 2019/STATE
wget -q -nc -t 10 --waitretry 1 --timeout 2 ftp://ftp2.census.gov/geo/tiger/GENZ2019/shp/cb_2019_us_state_500k.zip -o 2019/STATE/cb_2019_us_state_500k.zip
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

## Which maps

The Census publishes two sets of map data: [Cartographic Boundary](http://www.census.gov/geo/maps-data/data/tiger-cart-boundary.html) files and [TIGER/Line](http://www.census.gov/geo/maps-data/data/tiger-line.html). The main difference is that cartographic boundaries files are clipped to the coastline. These are the default for `get-tiger`. The cartographic files are only available for some data sets. To always fetch TIGER/Line files, set `CARTOGRAPHIC=false`:
```
make TRACT CARTOGRAPHIC=false
```

### Vintage

By default, the Makefile downloads 2019 data. For older years (or newer years, if it's the future), use the `YEAR` variable:
```bash
make STATE YEAR=2013
make STATE YEAR=2015
```

The `counties` folder contains a helper files for each year to track county FIPS codes. If you want to use a `YEAR` for which an `ini` file doesn't yet exist, use the small `ini.mk` Makefile try to create it by downloading the required county list:
```
make -f ini.mk YEAR=2020
```

### Secret bonus tasks for merging data

A relatively common task is to download a national set of geographies of a certain type. Run this to download a national dataset of block groups: 
```bash
make 2014/BG.shp
```
You can add in options for different `DATA_FIELDS` as described above. To run this task for a different year, you'll need to change the year twice (`make 2019/BG.shp YEAR=2019`).

Get-tiger includes shortcut tasks like this for the following geographies. They all follow the same pattern (`2014/<NAME>.shp`):

* American Indian / Alaska Native Areas / Hawaiian Home Lands (`AIANNH`, `AITSN`, `ANRC`)
* block groups and tribal block groups (`BG`, `TBG`)
* blocks (`TABBLOCK`)
* census tracts and tribal census tracts (`TRACT`, `TTRACT`)
* congressional districts (`CD`)
* consolidated cities (`CONCITY`)
* counties (`COUNTY`)
* counties within urban areas (`COUNTY_WITHIN_UA`)
* county subdivisions (`COUSUB`)
* metropolitan areas (`CBSA`, `CSA`, `METDIV`)
* military bases (`MIL`)
* New England stuff (`CNECTA`, `NECTA`, `NECTADIV`)
* places (`PLACE`)
* public use microdata areas (`PUMA`)
* Puerto-Rico-specific subdivisions (`ESTATE`, `SUBBARRIO`)
* railroads (`RAILS`)
* roads (`ROADS`)
* school districts (`UNSD`, `ELSD` and `SCSD`)
* states (`STATE`)
* state legislative districts (`SLDL`, `SLDU`)
* urbanized areas (`UAC`)
* water (`AREAWATER`, `LINEARWATER`)
* zip code tabulations areas (`ZCTA5`)
* high-level subdivisions (`NATION`, `DIVISION`, `REGION`)


### Format

This thing spits out the zipped shapefiles downloaded from the census. For AREAWATER, LINEARWATER and ROADS, which come packaged as one file per county, the data is automatically merged to state-level unzipped shape files.

## License

Copyright 2016-2021 Neil Freeman. Available under the GNU General Public License.
