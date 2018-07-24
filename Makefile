# This file is part of get-tiger
# https://github.com/fitnr/get-tiger

# Licensed under the GNU General Public License v3 (GPLv3) license:
# http://opensource.org/licenses/GPL-3.0
# Copyright (c) 2016, Neil Freeman <contact@fakeisthenewreal.org>

# Year of census data.
# Check API for most recent year available
include key.ini

YEAR = 2016
CONGRESS = 114

include counties/$(YEAR).ini

export KEY YEAR

comma = ,
STATE_FIPS = 01 02 04 05 06 08 09 10 11 12 13 15 16 17 18 19 20 \
			 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 \
			 38 39 40 41 42 44 45 46 47 48 49 50 51 53 54 55 56 72

CARTO_BASE = ftp://ftp2.census.gov/geo/tiger/GENZ$(YEAR)/shp
SHP_BASE = ftp://ftp2.census.gov/geo/tiger/TIGER$(YEAR)
API_BASE = https://api.census.gov/data

SERIES = acs5

DATASETS = AREAWATER NATION REGION DIVISION AIANNH AITSN ANRC \
	BG CBSA CD CNECTA CONCITY COUNTY COUNTY_WITHIN_UA COUSUB CSA \
	ELSD ESTATE LINEARWATER METDIV MIL NECTA NECTADIV PLACE PRISECROADS \
	PRIMARYROADS PUMA RAILS ROADS SCSD SLDL SLDU STATE SUBBARRIO \
	TABBLOCK TBG TTRACT TRACT UAC UNSD ZCTA5

# Some files can be drawn from the cartographic boundary or tiger datasets.
# Default is cartographic.
CARTOGRAPHIC ?= true

ifeq ($(CARTOGRAPHIC),true)
    base = $(1)/cb_$(YEAR)_$(2)_$(3)_500k

    carto_national = $(AIANNH) $(ANRC) $(COUNTY) $(CD) $(STATE)
    CARTO_BY_STATE = $(COUSUB) $(PLACE) $(SLDL) $(SLDU) $(TRACT)
    carto_nodata = $(SUBBARRIO)

else
    base = $(1)/tl_$(YEAR)_$(2)_$(3)

    tiger_national = $(AIANNH) $(ANRC) $(COUNTY) $(CD) $(STATE)
    tiger_by_state = $(COUSUB) $(PLACE) $(SLDL) $(SLDU) $(TRACT)
    tiger_nodata = $(SUBBARRIO)
endif

ifeq ($(wildcard counties/$(YEAR)/*),"")
    AREAWATER =
    AREAWATERCOUNTY =
    LINEARWATER =
    LINEARWATERCOUNTY =
    ROADS =
    ROADSCOUNTY =

else
    COUNTY_FIPS = $(foreach a,$(STATE_FIPS),$(addprefix $a,$(COUNTIES_$(a))))
    AREAWATERCOUNTY = $(foreach f,$(COUNTY_FIPS),AREAWATER/tl_$(YEAR)_$f_areawater)
    AREAWATER = $(foreach f,$(STATE_FIPS),AREAWATER/tl_$(YEAR)_$f_areawater)
    LINEARWATER = $(foreach f,$(STATE_FIPS),LINEARWATER/tl_$(YEAR)_$f_linearwater)
    LINEARWATERCOUNTY = $(foreach f,$(COUNTY_FIPS),LINEARWATER/tl_$(YEAR)_$f_linearwater)
    ROADS = $(foreach f,$(STATE_FIPS),ROADS/tl_$(YEAR)_$f_roads)
    ROADSCOUNTY = $(foreach f,$(COUNTY_FIPS),ROADS/tl_$(YEAR)_$f_roads)
endif

# general file definitions
DIVISION = DIVISION/cb_$(YEAR)_us_division_5m
NATION = NATION/cb_$(YEAR)_us_nation_5m
REGION = REGION/cb_$(YEAR)_us_region_500k

AIANNH = $(call base,AIANNH,us,aiannh)
AITSN = AITSN/tl_$(YEAR)_us_aitsn
ANRC = $(call base,ANRC,02,anrc)

BG = $(foreach f,$(STATE_FIPS),BG/tl_$(YEAR)_$f_bg)
CBSA = CBSA/tl_$(YEAR)_us_cbsa
CD = $(call base,CD,us,cd$(CONGRESS))
CNECTA = CNECTA/tl_$(YEAR)_us_cnecta

CONCITY = $(foreach f,09 13 18 20 21 30 47,CONCITY/tl_2014_$f_concity)

COUNTY = $(call base,COUNTY,us,county)
COUNTY20m = COUNTY/cb_$(YEAR)_us_county_20m

COUSUB = $(foreach f,$(STATE_FIPS),$(call base,COUSUB,$f,cousub))
COUNTY_WITHIN_UA = $(foreach f,$(STATE_FIPS),COUNTY_WITHIN_UA/cb_$(YEAR)_$f_county_within_ua_500k)
CSA = CSA/tl_$(YEAR)_us_csa

_elsd_fips = 60 69 04 06 09 13 17 21 23 25 26 27 29 30 33 34 36 38 40 41 44 45 47 48 50 51 55 56
ELSD = $(foreach f,$(filter $(_elsd_fips),$(STATE_FIPS)),ELSD/tl_$(YEAR)_$f_elsd)

ESTATE = ESTATE/tl_$(YEAR)_78_estate
METDIV = METDIV/tl_$(YEAR)_us_metdiv
MIL = MIL/tl_$(YEAR)_us_mil
NECTA = NECTA/tl_$(YEAR)_us_necta
NECTADIV = NECTADIV/tl_$(YEAR)_us_nectadiv

PLACE = $(foreach f,$(STATE_FIPS),$(call base,PLACE,$(f),place))
PRISECROADS = $(foreach f,$(STATE_FIPS),PRISECROADS/tl_$(YEAR)_$f_prisecroads)
PRIMARYROADS = PRIMARYROADS/tl_$(YEAR)_us_primaryroads
PUMA = $(foreach f,$(filter-out 60 69,$(STATE_FIPS)),PUMA/cb_$(YEAR)_$f_puma10_500k)
RAILS = RAILS/tl_$(YEAR)_us_rails

_scsd_fips = 04 06 09 13 17 21 23 25 27 30 33 34 36 40 41 44 45 47 48 50 55
_scsds = $(filter $(_scsd_fips),$(STATE_FIPS))
SCSD = $(foreach f,$(_scsds),SCSD/tl_$(YEAR)_$f_scsd)

# Remove DC and Nebraska.
SLDL = $(foreach f,$(filter-out 11 31,$(STATE_FIPS)),$(call base,SLDL,$(f),sldl))

SLDU = $(foreach f,$(STATE_FIPS),$(call base,SLDU,$(f),sldu))
STATE = $(call base,STATE,us,state)
SUBBARRIO = $(call base,SUBBARRIO,72,subbarrio)

TABBLOCK = $(foreach f,$(STATE_FIPS),TABBLOCK/tl_$(YEAR)_$f_tabblock10)
TBG = TBG/tl_$(YEAR)_us_tbg
TTRACT = TTRACT/tl_$(YEAR)_us_ttract
TRACT = $(foreach f,$(STATE_FIPS),$(call base,TRACT,$(f),tract))

UAC = UAC/cb_$(YEAR)_us_ua10_500k
UNSD = $(foreach f,$(STATE_FIPS),UNSD/tl_$(YEAR)_$f_unsd)

ZCTA5 = ZCTA5/cb_$(YEAR)_us_zcta510_500k

# lists of data (two kinds of files)

# 1. Cartographic boundary files
# National data sets
CARTO_NATIONAL = $(carto_national) $(DIVISION) $(REGION)
# Data sets that need to be joined w/ 'GEOID10' instead of GEOID.
CARTO_2010 = $(UAC) $(ZCTA5)
# Per-state data sets that need to be joined w/ 'GEOID10' instead of GEOID.
CARTO_2010_STATE = $(PUMA)
CARTO_NODATA = $(carto_nodata) $(NATION) $(COUNTY_WITHIN_UA) $(COUNTY20m)

CARTO = $(CARTO_NATIONAL) $(CARTO_2010) $(CARTO_BY_STATE) $(CARTO_2010_STATE)

# 2. TIGER data files
# National data sets
TIGER_NATIONAL = $(tiger_national) $(AITSN) $(CNECTA) $(CBSA) \
	$(CSA) $(METDIV) $(NECTA) $(NECTADIV) $(TBG)
# Per-state data sets.
TIGER_BY_STATE = $(tiger_by_state) $(BG) $(CONCITY) $(ELSD) \
	$(SCSD) $(TTRACT) $(UNSD)
# Geodata with no survey data available from the API
TIGER_NODATA = $(tiger_nodata) $(ESTATE) $(MIL) $(PRIMARYROADS) \
	$(PRISECROADS) $(RAILS) $(ROADSCOUNTY) $(TABBLOCK) \
	$(AREAWATERCOUNTY) $(LINEARWATERCOUNTY)

TIGER = $(TIGER_NATIONAL) $(TIGER_BY_STATE)

# data fields #

DATA_FIELDS ?= B06011_001E B25105_001E B25035_001E B01003_001E \
	B25001_001E B25002_002E B25002_003E B25003_001E B25003_002E B25003_003E \
	B08101_001E B08101_009E B08101_017E B08101_025E B08101_033E B08101_041E \
	B08101_049E B25024_001E B25024_002E B25024_003E B25024_004E B25024_005E \
	B25024_006E B25024_007E B25024_008E B25024_009E B25024_010E B25024_011E \
	B25033_001E B25033_002E B25033_008E B05012_001E B05012_002E B05012_003E

OUTPUT_FIELDS ?= ROUND(B01003001E/(ALAND/1000000.), 2) AS PopDensKm, \
	ROUND(B25001001E/(ALAND/1000000.), 2) AS HuDensKm, \
	ROUND(B08101001E/B01003001E, 2) AS WrkForcPct, \
	ROUND(B25033008E / B25033001E, 2) AS RentPct,

OUTPUT_FIELDS_10 ?= ROUND(B01003001E / (ALAND10 / 1000000.), 2) AS PopDensKm, \
	ROUND(B25001001E / (ALAND10 / 1000000.), 2) AS HuDensKm, \
	ROUND(B08101001E / B01003001E, 2) AS WrkForcPct, \
	ROUND(B25033008E / B25033001E, 2) AS RentPct,

CENSUS_DATA_FIELDS = GEO_ID,$(subst $( ) $( ),$(comma),$(DATA_FIELDS))

CURL = curl $(CURLFLAGS)
CURLFLAGS = -o $@ \
	--silent --show-error \
	--get $(API_BASE)/$(YEAR)/acs/$(SERIES) \
	--data key=$(KEY) \
	--data get=$(CENSUS_DATA_FIELDS)

format = shp
driver.shp  = 'ESRI Shapefile'
driver.json = GeoJSON

export CPL_MAX_ERROR_REPORTS=3
OGRFLAGS = -f $(driver.$(format))

.PHONY: all $(DATASETS)

# Print shortcut commands
all: commands.txt; @cat $<

.SECONDEXPANSION:

$(DATASETS): $$(addprefix $(YEAR)/,$$(addsuffix .$(format),$$($$@)))
	@echo $^

merge = BG CONCITY COUNTY_WITHIN_UA COUSUB ELSD PLACE PRISECROADS PUMA SCSD SLDL SLDU TABBLOCK TRACT UNSD

$(foreach x,$(merge),$(YEAR)/$x.$(format)): $(YEAR)/%.$(format): $$(foreach x,$$($$*),$(YEAR)/$$x.$(format))
	@rm -rf $@
	for f in $(basename $(^F)); do \
	    ogr2ogr $@ $(<D)/$$f.$(format) -update -append; \
	done;

# Merge shp and acs data, e.g:
# 2014/AIANNH/tl_2014_us_aiannh.shp: 2014/AIANNH/tl_2014_us_aiannh.zip 2014/AIANNH/tl_2014_us_aiannh_acs5.csv

NODATA = $(addsuffix .$(format),$(addprefix $(YEAR)/,$(CARTO_NODATA) $(TIGER_NODATA)))

$(NODATA): $(YEAR)/%.$(format): $(YEAR)/%.zip
	unzip -oqd $(@D) $<
	@touch $@

SELECTION = -dialect sqlite -sql "SELECT *, \
    $(1) \
    ROUND(ALAND$(2)/1000000., 3) LANDKM, ROUND(AWATER$(2)/1000000., 3) WATERKM \
    FROM $(*F) a LEFT JOIN '$(lastword $^)'.$(basename $(lastword $(^F))) b ON (a.GEOID$(2) = b.GEOID)"

SHPS_2010 = $(CARTO_2010) $(CARTO_2010_STATE)

$(foreach x,$(SHPS_2010),$(YEAR)/$x.$(format)): $(YEAR)/%.$(format): $(YEAR)/%.zip $(YEAR)/%_$(SERIES).dbf
	@rm -f $@
	ogr2ogr $@ /vsizip/$< $(OGRFLAGS) $(call SELECTION,$(OUTPUT_FIELDS_10),10)

SHPS = $(CARTO_NATIONAL) $(CARTO_BY_STATE) $(TIGER_NATIONAL) $(TIGER_BY_STATE))

$(foreach x,$(SHPS),$(YEAR)/$x.$(format)): $(YEAR)/%.$(format): $(YEAR)/%.zip $(YEAR)/%_$(SERIES).dbf
	@rm -f $@
	ogr2ogr $@ /vsizip/$< $(OGRFLAGS) $(call SELECTION,$(OUTPUT_FIELDS))

%.dbf: %.csv %.csvt
	ogr2ogr -f 'ESRI Shapefile' $@ $< -overwrite -select $(subst _,,$(CENSUS_DATA_FIELDS))
	@rm -f $(basename $@).{ind,idm}
	ogrinfo -q $@ -sql "CREATE INDEX ON $(basename $(@F)) USING GEOID"

# Totally fake type hinting. A String for GEOID, every other column is an Integer
%.csvt: %.csv
	head -n1 $< | \
	sed 's/^GEOID/"String"/; s/,[A-Za-z0-9_ ]*/,"Integer"/g' > $@

# County by State files
AREAWATER_base = tl_$(YEAR)_$1_areawater
LINEARWATER_base = tl_$(YEAR)_$1_linearwater
ROADS_base = tl_$(YEAR)_$1_roads

define combinecountyfiles
$(foreach x,$($1),$(YEAR)/$x.$(format)): \
$(YEAR)/$1/$(call $(1)_base,%).$(format): $$$$(foreach x,$$$$(COUNTIES_$$$$*),$(YEAR)/$1/$(call $(1)_base,$$$$*$$$$x).zip)
	@rm -f $$@
	for c in $$(COUNTIES_$$*); do \
	  ogr2ogr $$@ /vsizip/$$(<D)/$$(call $(1)_base,$$*$$$${c}).zip $$(call $(1)_base,$$*$$$${c}) $(OGRFLAGS) -update -append; \
	done
endef

$(foreach x,AREAWATER LINEARWATER ROADS,$(eval $(call combinecountyfiles,$x)))

$(foreach x,$(STATE_FIPS),$(YEAR)/BG/tl_$(YEAR)_$x_bg_$(SERIES).csv): \
$(YEAR)/BG/tl_$(YEAR)_%_bg_$(SERIES).csv: $$(foreach x,$$(COUNTIES_$$*),$$(@D)/$$*/tl_$(YEAR)_$$*_$$x_$(SERIES).csv) | $$(@D)
	@rm -f $@
	head -n1 $< > $@
	for COUNTY in $(COUNTIES_$*); do \
	    tail -n+2 $(@D)/tl_$(YEAR)_$*_$${COUNTY}_bg_$(SERIES).csv; \
	done >> $@

# Census API json has a strange CSV-like format, includes "YY000US" prefix on GEOID.
# Luckily, this makes it fairly easy to brute force into CSV
TOCSV = 's/,null,/,,/g; \
	s/[["_]//g; \
	s/\]//g; \
	s/,$$//g; \
	s/-666666666//; \
	s/^[0-9]*US//'

%.csv: %.json
	sed $(TOCSV) $< > $@

# Download ACS data
.PRECIOUS: $(YEAR)/%_$(SERIES).json

# County by state

# e.g. 2014/BG/tl_2016_36_047_acs5.json
define BG_task
$$(foreach x,$$(COUNTIES_$(1)),$(YEAR)/BG/$(1)/tl_$(YEAR)_$(1)_$$(x)_$(SERIES).json): \
$(YEAR)/BG/$(1)/tl_$(YEAR)_$(1)_%_$(SERIES).json: | $(YEAR)/BG/$(1)
	$$(CURL) --create-dirs --data for='block+group:*' --data in=state:$(1)+county:$$*
$(YEAR)/BG/$(1): ; mkdir $$@
endef

$(foreach x,$(STATE_FIPS),$(eval $(call BG_task,$(x))))

# State by state files

$(YEAR)/CONCITY/tl_$(YEAR)_%_concity_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=consolidated+city:*' --data in=state:$*

$(YEAR)/$(call base,COUSUB,%,cousub)_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=county+subdivision:*' --data in=state:$*

$(YEAR)/ELSD/tl_$(YEAR)_%_elsd_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=school+district+(elementary):*' --data in=state:$*

$(YEAR)/$(call base,PLACE,%,place)_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=place:*' --data in=state:$*

$(YEAR)/PUMA/cb_$(YEAR)_%_puma10_500k_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=public+use+microdata+area:*' --data in=state:$*

$(YEAR)/SCSD/tl_$(YEAR)_%_scsd_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=school+district+(secondary):*' --data in=state:$*

$(YEAR)/$(call base,SLDL,%,sldl)_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=state+legislative+district+(lower+chamber):*' --data in=state:$*

$(YEAR)/$(call base,SLDU,%,sldu)_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=state+legislative+district+(upper+chamber):*' --data in=state:$*

$(YEAR)/$(call base,TRACT,%,tract)_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=tract:*' --data in=state:$*

$(YEAR)/UNSD/tl_$(YEAR)_%_unsd_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=school+district+(unified):*' --data in=state:$*

# Carto boundary files and National data files

data_NATION = us
data_REGION = region
data_DIVISION = division
data_AIANNH = american+indian+area/alaska+native+area/hawaiian+home+land
data_AITSN = tribal+subdivision/remainder
data_ANRC = alaska+native+regional+corporation
data_CD = congressional+district
data_CBSA = metropolitan+statistical+area/micropolitan+statistical+area
data_CNECTA = combined+new+england+city+and+town+area
data_COUNTY = county
data_CSA = combined+statistical+area
data_METDIV = metropolitan+division
data_NECTA = new+england+city+and+town+area
data_NECTADIV = necta+division
data_STATE = state
data_TBG = tribal+block+group
data_TTRACT = tribal+census+tract
data_UAC = urban+area
data_ZCTA5 = zip+code+tabulation+area

direct_data = NATION REGION DIVISION AIANNH AITSN ANRC \
	CD CBSA CNECTA COUNTY CSA METDIV NECTA NECTADIV \
	STATE TBG TTRACT UAC ZCTA5 

$(foreach x,$(direct_data),$(YEAR)/$($x)_$(SERIES).json): $(YEAR)/%_$(SERIES).json: | $$(@D)
	$(CURL) --data 'for=$(data_$(*D)):*'

# Download ZIP files

$(addsuffix .zip,$(addprefix $(YEAR)/,$(TIGER) $(TIGER_NODATA))): $(YEAR)/%: | $$(@D)
	curl -o $@ --silent --show-error --connect-timeout 3 $(SHP_BASE)/$*

$(addsuffix .zip,$(addprefix $(YEAR)/,$(CARTO) $(CARTO_NODATA))): $(YEAR)/%: | $$(@D)
	curl -o $@ --silent --show-error --connect-timeout 3 $(CARTO_BASE)/$(*F)

$(sort $(dir $(addprefix $(YEAR)/,$(TIGER) $(TIGER_NODATA) $(CARTO) $(CARTO_NODATA)))): $(YEAR)
	-mkdir $@

$(YEAR): ; -mkdir -p $@
