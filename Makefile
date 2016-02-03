# Year of census data.
# Check API for most recent year available
YEAR = 2014

STATE_FIPS = 01 02 04 05 06 08 09 10 11 12 13 15 16 17 18 19 20 \
			 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 \
			 38 39 40 41 42 44 45 46 47 48 49 50 51 53 54 55 56 72

CARTO_BASE = ftp://ftp2.census.gov/geo/tiger/GENZ$(YEAR)/shp
SHP_BASE = ftp://ftp2.census.gov/geo/tiger/TIGER$(YEAR)
API_BASE = http://api.census.gov/data

SERIES = acs5

FOLDERS = DIVISION NATION REGION \
	AIANNH AITSN ANRC BG CNECTA \
	CBSA CD CONCITY COUNTY COUSUB CSA \
	ELSD ESTATE METDIV MIL NECTA NECTADIV \
	PLACE PRIMARYROADS PRISECROADS PUMA RAILS \
	SCSD SLDL SLDU STATE SUBBARRIO TABBLOCK TBG \
	TRACT TTRACT UAC UNSD ZCTA5

# Cartographic boundary files
CARTO = $(DIVISION) $(NATION) $(REGION)

# Geodata with no survey data available from the API
NODATA = $(ESTATE) $(MIL) $(PRIMARYROADS) $(PRISECROADS) \
	$(RAILS) $(SUBBARRIO) $(TABBLOCK)

# National data sets
TIGER_NATIONAL = $(AIANNH) $(AITSN) $(ANRC) $(CNECTA) $(CBSA) $(CD) \
	$(COUNTY) $(CSA) $(METDIV) $(NECTA) $(NECTADIV) $(STATE) $(TBG)

# One data set for each state
TIGER_BY_STATE = $(BG) $(CONCITY) $(COUSUB) $(ELSD) $(PLACE) \
	$(SCSD) $(SLDL) $(SLDU) $(TRACT) $(TTRACT) $(UNSD)

TIGER_2010_NATIONAL = $(ZCTA5) $(UAC)
TIGER_2010_STATE = $(PUMA)

TIGER = $(TIGER_NATIONAL) $(TIGER_BY_STATE) \
	$(TIGER_2010_NATIONAL) $(TIGER_2010_STATE)

comma = ,
null =
space = $(null) $(null)

DATA_FIELDS = GEOID B06011_001E B25105_001E B25035_001E B01003_001E \
	B25001_001E B25002_002E B25002_003E B25003_001E B25003_002E B25003_003E \
	B08101_001E B08101_009E B08101_017E B08101_025E B08101_033E B08101_041E \
	B08101_049E B25024_001E B25024_002E B25024_003E B25024_004E B25024_005E \
	B25024_006E B25024_007E B25024_008E B25024_009E B25024_010E B25024_011E

CENSUS_DATA_FIELDS = $(subst $(space),$(comma),$(DATA_FIELDS))

CURL = curl $(CURLFLAGS)
CURLFLAGS = --get $(API_BASE)/$(YEAR)/$(SERIES) \
	-o $@ \
	--data key=$(KEY) \
	--data get=$(CENSUS_DATA_FIELDS)

include geographies.ini
include key.ini

.PHONY: all fips

ifdef DOWNLOAD

TARGETS = $(addprefix tl_$(YEAR)/,$(addsuffix .shp,$(foreach i,$(DOWNLOAD),$($i))))

endif

all: $(TARGETS)
ifndef DOWNLOAD
	@echo Available data sets:
	@echo Download with "make DOWNLOAD=DATASET"
	@echo NATION - United States
	@echo DIVISION
	@echo REGION
	@echo AIANNH - American Indian areas, Alaska Native areas, Hawaiian home lands
	@echo AITSN - American Indian tribal subvidisions
	@echo ANRC - Alaska Native regional corporations
	@echo BG - Block groups
	@echo CNECTA - Combined New England city and town areas
	@echo CBSA - Core-based statistical qreas
	@echo CD - Congressional districts 
	@echo CONCITY - Consolidated cities 
	@echo COUNTY - Counties
	@echo COUSUB - County subvidisions
	@echo CSA - Consolidated statistical areas
	@echo ELSD - Elementary school districts
	@echo ESTATE - Estates [US Virgin Islands]
	@echo METDIV - Metropolitan Divisions
	@echo MIL - Military areas
	@echo NECTA - New England city and town areas
	@echo NECTADIV - New England city and town area divisions
	@echo PLACE - Places
	@echo PRIMARYROADS - Primary roads [national]
	@echo PRISECROADS - Primary and secondary roads [by state]
	@echo PUMA - Public use microdata areas
	@echo SCSD - Secondary school districts 
	@echo SLDL - State legislative districts [lower chamber]
	@echo SLDU - State legislative districts [upper chamber]
	@echo STATE - States and territories
	@echo SUBBARRIO - Sub-barrios [Puerto Rico]
	@echo TABBLOCK - Blocks
	@echo TBG - Tribal block groups
	@echo TRACT - Census tracts
	@echo TTRACT - Tribal Census tracts
	@echo UAC - Urbanized areas
	@echo UNSD - Unified school districts
	@echo ZCTA5 - Zip code tabulation areas
endif
# Merge shp and acs data
# e.g. tl_$(YEAR)/AIANNH/tl_$(YEAR)_us_aiannh.zip: \
#  tl_$(YEAR)/AIANNH/tl_$(YEAR)_us_aiannh.shp
#  tl_$(YEAR)/AIANNH/acs5.shp

$(addsuffix .shp,$(addprefix tl_$(YEAR)/,$(NODATA) $(NATION))): tl_$(YEAR)/%.shp: tl_$(YEAR)/%.zip
	unzip -oqd $(@D) $<
	@touch $@

SHPS_2010 = $(addprefix tl_$(YEAR)/,$(addsuffix .shp,$(TIGER_2010_NATIONAL) $(TIGER_2010_STATE)))

$(SHPS_2010): tl_$(YEAR)/%.shp: tl_$(YEAR)/%.zip tl_$(YEAR)/%_$(SERIES).csv
	ogr2ogr -f 'ESRI Shapefile' $@ /vsizip/$</$(@F) \
	-overwrite -lco RESIZE=YES -dialect sqlite \
	-sql "SELECT *, ALAND10/1000000 LANDKM, AWATER10/1000000 WATERKM FROM $(basename $(@F)) a LEFT JOIN \
	'$(lastword $^)'.$(basename $(lastword $(^F))) b ON (a.GEOID10=b.GEOID)"

SHPS = $(addprefix tl_$(YEAR)/,$(addsuffix .shp,$(REGION) $(DIVISION) $(TIGER_NATIONAL) $(TIGER_BY_STATE)))

$(SHPS): tl_$(YEAR)/%.shp: tl_$(YEAR)/%.zip tl_$(YEAR)/%_$(SERIES).csv
	ogr2ogr -f 'ESRI Shapefile' $@ /vsizip/$</$(@F) \
	-overwrite -lco RESIZE=YES -dialect sqlite \
	-sql "SELECT *, ALAND/1000000 LANDKM, AWATER/1000000 WATERKM FROM $(basename $(@F)) LEFT JOIN \
	'$(lastword $^)'.$(basename $(lastword $(^F))) USING (GEOID)"

# Census API has a strange CSV-like format, and passes numbers as strings. This fixed that

TOCSV = ([.[0]] + ( \
			.[1:] | map( \
				[ .[0] | sub("^[0-9]+US"; "") ] + \
				( .[1:] | map(if . == null then null else tonumber end) ) \
			) \
		)) | \
	.[] | @csv

%.csv: %.json
	jq --raw-output '$(TOCSV)' $< > $@

.SECONDEXPANSION:
# Download ACS data

# Carto boundary files

tl_$(YEAR)/$(NATION)_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=us:*'

tl_$(YEAR)/$(REGION)_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=region:*'

tl_$(YEAR)/$(DIVISION)_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=division:*'

# National data files

tl_$(YEAR)/AIANNH/tl_$(YEAR)_us_aiannh_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=american+indian+area/alaska+native+area/hawaiian+home+land:*'

tl_$(YEAR)/AITSN/tl_$(YEAR)_us_aitsn_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=tribal+subdivision/remainder:*'

# Not actually national, there's just one state with Alaska Native Regional Corps (Guess which one!)
tl_$(YEAR)/ANRC/tl_$(YEAR)_02_anrc_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=alaska+native+regional+corporation:*'

tl_$(YEAR)/CD/tl_$(YEAR)_us_cd114_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=congressional+district:*' --data in=state:$*

tl_$(YEAR)/CBSA/tl_$(YEAR)_us_cbsa_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=metropolitan+statistical+area/micropolitan+statistical+area:*'

tl_$(YEAR)/CNECTA/tl_$(YEAR)_us_cnecta_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=combined+new+england+city+and+town+area:*'

tl_$(YEAR)/COUNTY/tl_$(YEAR)_us_county_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=county:*'

tl_$(YEAR)/CSA/tl_$(YEAR)_us_csa_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=combined+statistical+area:*'

tl_$(YEAR)/METDIV/tl_$(YEAR)_us_metdiv_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=metropolitan+division:*'

tl_$(YEAR)/NECTA/tl_$(YEAR)_us_necta_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=new+england+city+and+town+area:*'

tl_$(YEAR)/NECTADIV/tl_$(YEAR)_us_nectadiv_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=necta+division:*'

tl_$(YEAR)/STATE/tl_$(YEAR)_us_state_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=state:*'

tl_$(YEAR)/TBG/tl_$(YEAR)_us_tbg_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=tribal+block+group:*'

tl_$(YEAR)/TTRACT/tl_$(YEAR)_us_ttract_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=tribal+census+tract:*'

tl_$(YEAR)/UAC/tl_$(YEAR)_us_uac10_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=urban+area:*'

tl_$(YEAR)/ZCTA5/tl_$(YEAR)_us_zcta510_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=zip+code+tabulation+area:*'

# State by state files

tl_$(YEAR)/BG/tl_$(YEAR)_%_bg_$(SERIES).json: | $$(@D)
	$(CURL) --data for='block+group:*' --data in=state:$*

tl_$(YEAR)/CONCITY/tl_$(YEAR)_%_concity_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=consolidated+city:*' --data in=state:$*

tl_$(YEAR)/COUSUB/tl_$(YEAR)_%_cousub_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=county+subdivision:*' --data in=state:$*

tl_$(YEAR)/ELSD/tl_$(YEAR)_%_elsd_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=school+district+(elementary):*' --data in=state:$*

tl_$(YEAR)/PLACE/tl_$(YEAR)_%_place_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=place:*' --data in=state:$*

tl_$(YEAR)/PUMA/tl_$(YEAR)_%_puma_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=public+use+microdata+area:*' --data in=state:$*

tl_$(YEAR)/SCSD/tl_$(YEAR)_%_scsd_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=school+district+(secondary):*' --data in=state:$*

tl_$(YEAR)/SLDL/tl_$(YEAR)_%_sldl_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=state+legislative+district+(lower+chamber):*' --data in=state:$*

tl_$(YEAR)/SLDU/tl_$(YEAR)_%_sldu_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=state+legislative+district+(upper+chamber):*' --data in=state:$*

tl_$(YEAR)/TRACT/tl_$(YEAR)_%_tract_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=tract:*' --data in=state:$*

tl_$(YEAR)/UNSD/tl_$(YEAR)_%_unsd_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=school+district+(unified):*' --data in=state:$*

# Download ZIP files

$(addsuffix .zip,$(addprefix tl_$(YEAR)/,$(TIGER) $(NODATA))): tl_$(YEAR)/%: | $$(@D)
	curl -o $@ $(SHP_BASE)/$*

$(addsuffix .zip,$(addprefix tl_$(YEAR)/,$(CARTO))): tl_$(YEAR)/%: | $$(@D)
	curl -o $@ $(CARTO_BASE)/$(*F)

$(addprefix tl_$(YEAR)/,$(FOLDERS)): tl_$(YEAR) ; mkdir $@
tl_$(YEAR): ; mkdir $@
