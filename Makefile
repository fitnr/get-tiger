# This file is part of get-tiger
# https://github.com/fitnr/get-tiger

# Licensed under the GNU General Public License v3 (GPLv3) license:
# http://opensource.org/licenses/GPL-3.0
# Copyright (c) 2016, Neil Freeman <contact@fakeisthenewreal.org>

# Year of census data.
# Check API for most recent year available
include key.ini

YEAR = 2014
export KEY YEAR

STATE_FIPS = 01 02 04 05 06 08 09 10 11 12 13 15 16 17 18 19 20 \
			 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 \
			 38 39 40 41 42 44 45 46 47 48 49 50 51 53 54 55 56 72

ifeq ($(wildcard counties/$(YEAR)/*),"")
AREAWATER =
AREAWATERCOUNTY =
else
COUNTY_FIPS = $(foreach a,$(STATE_FIPS),$(addprefix $a,$(shell cat counties/$(YEAR)/$a)))
AREAWATERCOUNTY = $(foreach f,$(COUNTY_FIPS),AREAWATER/tl_$(YEAR)_$f_areawater)
AREAWATER = $(foreach f,$(STATE_FIPS),AREAWATER/tl_$(YEAR)_$f_areawater)
endif

DIVISION = DIVISION/cb_$(YEAR)_us_division_5m
NATION = NATION/cb_$(YEAR)_us_nation_5m
REGION = REGION/cb_$(YEAR)_us_region_500k

AIANNH = AIANNH/cb_$(YEAR)_us_aiannh_500k
AITSN = AITSN/tl_$(YEAR)_us_aitsn
ANRC = ANRC/cb_$(YEAR)_02_anrc_500k

BG = $(foreach f,$(STATE_FIPS),BG/tl_$(YEAR)_$f_bg)
CBSA = CBSA/tl_$(YEAR)_us_cbsa
CD = CD/cb_$(YEAR)_us_cd114_500k
CNECTA = CNECTA/tl_$(YEAR)_us_cnecta

_concity_fips = 09 13 18 20 21 30 47
CONCITY = $(addprefix CONCITY/,$(filter $(_concity_fips),$(STATE_FIPS)))

COUNTY = COUNTY/cb_$(YEAR)_us_county_500k
COUSUB = $(foreach f,$(STATE_FIPS),COUSUB/cb_$(YEAR)_$f_cousub_500k)
CSA = CSA/tl_$(YEAR)_us_csa

_elsd_fips = 60 69 04 06 09 13 17 21 23 25 26 27 29 30 33 34 36 38 40 41 44 45 47 48 50 51 55 56
_elsds = $(filter $(_elsd_fips),$(STATE_FIPS))
ELSD = $(addprefix ELSD/,$(foreach f,$(_elsds),tl_$(YEAR)_$f_elsd))

ESTATE = ESTATE/tl_$(YEAR)_78_estate
METDIV = METDIV/tl_$(YEAR)_us_metdiv
MIL = MIL/tl_$(YEAR)_us_mil
NECTA = NECTA/tl_$(YEAR)_us_necta
NECTADIV = NECTADIV/tl_$(YEAR)_us_nectadiv

PLACE = $(foreach f,$(STATE_FIPS),PLACE/cb_$(YEAR)_$f_place_500k)
PRISECROADS = $(foreach f,$(STATE_FIPS),PRISECROADS/tl_$(YEAR)_$f_prisecroads)
PRIMARYROADS = PRIMARYROADS/tl_$(YEAR)_us_primaryroads
PUMA = $(foreach f,$(filter-out 60 69,$(STATE_FIPS)),PUMA/cb_$(YEAR)_$f_puma10_500k)
RAILS = RAILS/tl_$(YEAR)_us_rails

_scsd_fips = 04 06 09 13 17 21 23 25 27 30 33 34 36 40 41 44 45 47 48 50 55
_scsds = $(filter $(_scsd_fips),$(STATE_FIPS))
SCSD = $(addprefix SCSD/,$(foreach f,$(_scsds),tl_$(YEAR)_$f_scsd))

# Remove DC and Nebraska.
_sldls = $(filter-out 11 31,$(STATE_FIPS))
SLDL = $(addprefix SLDL/,$(foreach f,$(_sldls),cb_$(YEAR)_$f_sldl_500k))

SLDU = $(addprefix SLDU/,$(foreach f,$(STATE_FIPS),cb_$(YEAR)_$f_sldu_500k))

STATE = cb_$(YEAR)_us_state_500k
SUBBARRIO = cb_$(YEAR)_72_subbarrio_500k

TABBLOCK = $(foreach f,$(STATE_FIPS),TABBLOCK/tl_$(YEAR)_$f_tabblock10)
TBG = TBG/tl_$(YEAR)_us_tbg
TTRACT = TTRACT/tl_$(YEAR)_us_ttract
TRACT = $(foreach f,$(STATE_FIPS),TRACT/cb_$(YEAR)_$f_tract_500k)

UAC = UAC/cb_$(YEAR)_us_uac10_500k
UNSD = $(foreach f,$(STATE_FIPS),UNSD/tl_$(YEAR)_$f_unsd)

ZCTA5 = ZCTA5/cb_$(YEAR)_us_zcta510_500k

CARTO_BASE = ftp://ftp2.census.gov/geo/tiger/GENZ$(YEAR)/shp
SHP_BASE = ftp://ftp2.census.gov/geo/tiger/TIGER$(YEAR)
API_BASE = http://api.census.gov/data

SERIES = acs5

DATASETS = AREAWATER NATION REGION DIVISION AIANNH AITSN ANRC \
	BG CBSA CD CNECTA CONCITY COUNTY COUSUB CSA ELSD \
	ESTATE METDIV MIL NECTA NECTADIV PLACE PRISECROADS \
	PRIMARYROADS PUMA RAILS SCSD SLDL SLDU STATE SUBBARRIO \
	TABBLOCK TBG TTRACT TRACT UAC UNSD ZCTA5

# Cartographic boundary files
# National data sets
CARTO_NATIONAL = $(DIVISION) $(REGION) $(AIANNH) $(ANRC) $(COUNTY) $(CD) $(STATE)

# Data sets that need to be joined w/ 'GEOID10' instead of GEOID.
CARTO_2010 = $(UAC) $(ZCTA5)

# Per-state data sets
CARTO_BY_STATE = $(COUSUB) $(PLACE) $(SLDL) $(SLDU) $(TRACT)

# Per-state data sets that need to be joined w/ 'GEOID10' instead of GEOID.
CARTO_2010_STATE = $(PUMA)

CARTO_NODATA = $(NATION) $(SUBBARRIO)

CARTO = $(CARTO_NATIONAL) $(CARTO_2010) $(CARTO_BY_STATE) $(CARTO_2010_STATE)

# National data sets
TIGER_NATIONAL = $(AITSN) $(CNECTA) $(CBSA) \
	$(CSA) $(METDIV) $(NECTA) $(NECTADIV) $(TBG)

# Per-state data sets.
TIGER_BY_STATE = $(BG) $(CONCITY) $(ELSD) \
	$(SCSD) $(TTRACT) $(UNSD)

# Geodata with no survey data available from the API
TIGER_NODATA = $(ESTATE) $(MIL) $(PRIMARYROADS) \
	$(PRISECROADS) $(RAILS) $(TABBLOCK)

TIGER = $(TIGER_NATIONAL) $(TIGER_BY_STATE)

comma = ,

DATA_FIELDS ?= GEOID B06011_001E B25105_001E B25035_001E B01003_001E \
	B25001_001E B25002_002E B25002_003E B25003_001E B25003_002E B25003_003E \
	B08101_001E B08101_009E B08101_017E B08101_025E B08101_033E B08101_041E \
	B08101_049E B25024_001E B25024_002E B25024_003E B25024_004E B25024_005E \
	B25024_006E B25024_007E B25024_008E B25024_009E B25024_010E B25024_011E

OUTPUT_FIELDS ?= ROUND(B01003_001/(ALAND/1000000.), 2) AS PopDensKm, \
	ROUND(B25001_001/(ALAND/1000000.), 2) AS HuDensKm, \
	ROUND(B08101_001/B01003_001, 2) AS WrkForcPct,

CENSUS_DATA_FIELDS = $(subst $( ) $( ),$(comma),$(DATA_FIELDS))

CURL = curl $(CURLFLAGS)
CURLFLAGS = --get $(API_BASE)/$(YEAR)/$(SERIES) \
	-o $@ \
	--data key=$(KEY) \
	--data get=$(CENSUS_DATA_FIELDS)

format = shp
driver.shp  = 'ESRI Shapefile'
driver.json = GeoJSON

export CPL_MAX_ERROR_REPORTS=3
OGRFLAGS = -f $(driver.$(format)) -dialect sqlite

.PHONY: all $(DATASETS)

all:
	@echo Available data sets:
	@echo '(run with "make DATASET")'
	@echo NATION - United States
	@echo DIVISION - four very broad sections of the country
	@echo REGION - nine broad sections of the country
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
	@echo AREAWATER - water. Downloads one file for each county, so run with STATE_FIPS='"x y z"'

.SECONDEXPANSION:

$(DATASETS): $$(addprefix $(YEAR)/,$$(addsuffix .$(format),$$($$@)))
	@echo $^

# Merge shp and acs data, e.g:
# 2014/AIANNH/tl_2014_us_aiannh.shp: 2014/AIANNH/tl_2014_us_aiannh.zip 2014/AIANNH/tl_2014_us_aiannh_acs5.csv

NODATA = $(addsuffix .$(format),$(addprefix $(YEAR)/,$(CARTO_NODATA) $(TIGER_NODATA)))

$(NODATA): $(YEAR)/%.$(format): $(YEAR)/%.zip
	unzip -oqd $(@D) $<
	@touch $@

SHPS_2010 = $(addprefix $(YEAR)/,$(addsuffix .$(format),$(CARTO_2010) $(CARTO_2010_STATE)))

$(SHPS_2010): $(YEAR)/%.$(format): $(YEAR)/%.zip $(YEAR)/%_$(SERIES).dbf
	@rm -f $@
	ogr2ogr $@ /vsizip/$</$(@F) $(OGRFLAGS) \
	-sql "SELECT *, \
	$(OUTPUT_FIELDS) \
	ROUND(ALAND/1000000., 6) LANDKM, ROUND(AWATER/1000000., 6) WATERKM \
	FROM $(basename $(@F)) a \
	LEFT JOIN '$(lastword $^)'.$(basename $(lastword $(^F))) b ON (a.GEOID10=b.GEOID)"

SHPS = $(addprefix $(YEAR)/,$(addsuffix .$(format),$(CARTO_NATIONAL) $(CARTO_BY_STATE) $(TIGER_NATIONAL) $(TIGER_BY_STATE)))

$(SHPS): $(YEAR)/%.$(format): $(YEAR)/%.zip $(YEAR)/%_$(SERIES).dbf
	@rm -f $@
	ogr2ogr $@ /vsizip/$</$(@F) $(OGRFLAGS) \
	-sql "SELECT *, \
	$(OUTPUT_FIELDS) \
	ROUND(ALAND/1000000., 2) as LANDKM, ROUND(AWATER/1000000., 2) as WATERKM \
	FROM $(basename $(@F)) \
	LEFT JOIN '$(lastword $^)'.$(basename $(lastword $(^F))) USING (GEOID)"

%.dbf: %.csv
	ogr2ogr -f 'ESRI Shapefile' $@ $< -overwrite -dialect sqlite \
	-sql "SELECT GEOID $(foreach f,$(wordlist 2,100,$(DATA_FIELDS)),, CAST($f AS INTEGER) $f) \
	FROM $(basename $(@F))"
	@rm -f $(basename $@).{ind,idm}
	ogrinfo $@ -sql "CREATE INDEX ON $(basename $(@F)) USING GEOID"

# County by State files
waters = $(foreach x,$(AREAWATER),$(YEAR)/$x.$(format))
wfp := $(YEAR)/AREAWATER/tl_$(YEAR)_$$*$$x_areawater.zip
$(waters): $(YEAR)/AREAWATER/tl_$(YEAR)_%_areawater.$(format): $$(foreach x,$$(shell cat counties/$(YEAR)/$$*),$(wfp))
	@rm -fr $@
	for base in $(basename $(^F)); do \
	ogr2ogr $@ /vsizip/$(<D)/$$base.zip/$$base.shp $(OGRFLAGS) -update -append; \
	done;

$(YEAR)/BG/tl_$(YEAR)_%_bg_$(SERIES).csv: counties/$(YEAR)/% | $$(@D)
	$(eval FILES= $(shell sed 's,^\(.*\)$$,$(@D)/tl_$(YEAR)_$*_\1_bg_$(SERIES).csv,' $<))

	$(MAKE) $(FILES)

	@rm -rf $@
	head -1 $(lastword $(FILES)) > $@
	for CSV in $(FILES); do \
	tail +2 $$CSV; \
	done >> $@

# Census API has a strange CSV-like format, includes "YY000US" prefix on GEOID.
TOCSV = ([.[0]] + ( \
			.[1:] | map( \
				[ .[0] | sub("^[0-9]+US"; "") ] + .[1:] \
			) \
		)) | \
	.[] | @csv

%.csv: %.json
	jq --raw-output '$(TOCSV)' $< > $@

# Download ACS data

# Carto boundary files

$(YEAR)/$(NATION)_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=us:*'

$(YEAR)/$(REGION)_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=region:*'

$(YEAR)/$(DIVISION)_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=division:*'

# National data files

$(YEAR)/$(AIANNH)_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=american+indian+area/alaska+native+area/hawaiian+home+land:*'

$(YEAR)/AITSN/tl_$(YEAR)_us_aitsn_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=tribal+subdivision/remainder:*'

# Not actually national, there's just one state with Alaska Native Regional Corps (Guess which one!)
$(YEAR)/$(ANRC)_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=alaska+native+regional+corporation:*'

$(YEAR)/$(CD)_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=congressional+district:*' --data in=state:$*

$(YEAR)/$(CBSA)_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=metropolitan+statistical+area/micropolitan+statistical+area:*'

$(YEAR)/$(CNECTA)_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=combined+new+england+city+and+town+area:*'

$(YEAR)/$(COUNTY)_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=county:*'

$(YEAR)/$(CSA)_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=combined+statistical+area:*'

$(YEAR)/$(METDIV)_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=metropolitan+division:*'

$(YEAR)/$(NECTA)_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=new+england+city+and+town+area:*'

$(YEAR)/$(NECTADIV)_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=necta+division:*'

$(YEAR)/$(STATE)_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=state:*'

$(YEAR)/$(TBG)_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=tribal+block+group:*'

$(YEAR)/$(TTRACT)_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=tribal+census+tract:*'

$(YEAR)/$(UAC)_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=urban+area:*'

$(YEAR)/$(ZCTA5)_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=zip+code+tabulation+area:*'

# County by state

# e.g. 2014/BG/36_047_acs5.json
$(YEAR)/BG/tl_$(YEAR)_%_bg_$(SERIES).json: | $$(@D)
	$(CURL) --data for='block+group:*' --data in=state:$(firstword $(subst _, ,$*))+county:$(lastword $(subst _, ,$*))

# State by state files

$(YEAR)/CONCITY/tl_$(YEAR)_%_concity_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=consolidated+city:*' --data in=state:$*

$(YEAR)/COUSUB/cb_$(YEAR)_%_cousub_500k_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=county+subdivision:*' --data in=state:$*

$(YEAR)/ELSD/tl_$(YEAR)_%_elsd_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=school+district+(elementary):*' --data in=state:$*

$(YEAR)/PLACE/cb_$(YEAR)_%_place_500k_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=place:*' --data in=state:$*

$(YEAR)/PUMA/cb_$(YEAR)_%_puma10_500k_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=public+use+microdata+area:*' --data in=state:$*

$(YEAR)/SCSD/tl_$(YEAR)_%_scsd_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=school+district+(secondary):*' --data in=state:$*

$(YEAR)/SLDL/cb_$(YEAR)_%_sldl_500k_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=state+legislative+district+(lower+chamber):*' --data in=state:$*

$(YEAR)/SLDU/cb_$(YEAR)_%_sldu_500k_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=state+legislative+district+(upper+chamber):*' --data in=state:$*

$(YEAR)/TRACT/cb_$(YEAR)_%_tract_500k_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=tract:*' --data in=state:$*

$(YEAR)/UNSD/tl_$(YEAR)_%_unsd_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=school+district+(unified):*' --data in=state:$*

# Lists of county FIPS
COFIPS = $(addprefix counties/$(YEAR)/,$(STATE_FIPS))
.PHONY: countyfips
countyfips: $(COFIPS)

$(COFIPS): counties/$(YEAR)/%: | $$(@D)
	curl --get $(API_BASE)/$(YEAR)/$(SERIES) --data key=$(KEY) \
		--data 'for=county:*' --data in=state:$* --data get=GEOID | \
	jq --raw-output '$(TOCSV)' | \
	sed 's/"//g' | cut -d, -f3 | tail +2 > $@

# Download ZIP files

$(addsuffix .zip,$(addprefix $(YEAR)/,$(TIGER) $(TIGER_NODATA) $(AREAWATERCOUNTY))): $(YEAR)/%: | $$(@D)
	curl -o $@ $(SHP_BASE)/$*

$(addsuffix .zip,$(addprefix $(YEAR)/,$(CARTO) $(CARTO_NODATA))): $(YEAR)/%: | $$(@D)
	curl -o $@ $(CARTO_BASE)/$(*F)

$(sort $(dir $(addprefix $(YEAR)/,$(TIGER) $(TIGER_NODATA) $(CARTO) $(CARTO_NODATA)))): $(YEAR)
	-mkdir $@

$(YEAR) counties/$(YEAR):; -mkdir $@
