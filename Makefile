# This file is part of get-tiger
# https://github.com/fitnr/get-tiger

# Licensed under the GNU General Public License v3 (GPLv3) license:
# http://opensource.org/licenses/GPL-3.0
# Copyright (c) 2016, Neil Freeman <contact@fakeisthenewreal.org>

# Year of census data.
# Check API for most recent year available
SHELL := bash

YEAR := 2019
CONGRESS := 116

include counties/$(YEAR).ini

export KEY YEAR

.SUFFIXES:

comma = ,
STATE_FIPS = 01 02 04 05 06 08 09 10 11 12 13 15 16 17 18 19 20 \
			 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 \
			 38 39 40 41 42 44 45 46 47 48 49 50 51 53 54 55 56 72

SERIES = acs5

DATASETS = AREAWATER NATION REGION DIVISION AIANNH AITSN ANRC \
	BG CBSA CD CNECTA CONCITY COUNTY COUNTY_WITHIN_UA COUSUB CSA \
	ELSD ESTATE LINEARWATER METDIV MIL NECTA NECTADIV PLACE \
	PUMA RAILS ROADS SCSD SLDL SLDU STATE SUBBARRIO \
	TABBLOCK TBG TTRACT TRACT UAC UNSD ZCTA5

# Some files can be drawn from the cartographic boundary or tiger geodata.
# Default is non-cartographic.
CARTOGRAPHIC ?= true
# Other valid values: 20m, 5m
RESOLUTION := 500k

ifeq ($(CARTOGRAPHIC),true)

base      = cb_$(YEAR)_$(2)_$(3)_$(RESOLUTION).zip
url      := ftp://ftp2.census.gov/geo/tiger/GENZ$(YEAR)/shp

# Set cartographic-only slugs
DIVISION := DIVISION/cb_$(YEAR)_us_division_5m.zip
NATION   := NATION/cb_$(YEAR)_us_nation_5m.zip
REGION   := REGION/cb_$(YEAR)_us_region_500k.zip
COUNTY_WITHIN_UA := $(foreach f,$(STATE_FIPS),COUNTY_WITHIN_UA/cb_$(YEAR)_$f_county_within_ua_$(RESOLUTION).zip)

else

base      = $(1)/tl_$(YEAR)_$(2)_$(3).zip
url      := ftp://ftp2.census.gov/geo/tiger/TIGER$(YEAR)
# Set tigerline-only slugs
AITSN    := AITSN/tl_$(YEAR)_us_aitsn.zip
CBSA     := CBSA/tl_$(YEAR)_us_cbsa.zip
CNECTA   := CNECTA/tl_$(YEAR)_us_cnecta.zip
ESTATE   := ESTATE/tl_$(YEAR)_78_estate.zip
METDIV   := METDIV/tl_$(YEAR)_us_metdiv.zip
MIL      := MIL/tl_$(YEAR)_us_mil.zip
NECTA    := NECTA/tl_$(YEAR)_us_necta.zip
NECTADIV := NECTADIV/tl_$(YEAR)_us_nectadiv.zip
RAILS    := RAILS/tl_$(YEAR)_us_rails.zip
SCSD     := $(foreach f,$(scsds),SCSD/tl_$(YEAR)_$f_scsd.zip)
TABBLOCK := $(foreach f,$(STATE_FIPS),TABBLOCK/tl_$(YEAR)_$f_tabblock10.zip)
TBG      := TBG/tl_$(YEAR)_us_tbg.zip
TTRACT   := TTRACT/tl_$(YEAR)_us_ttract.zip
UAC      := UAC/tl_$(YEAR)_us_uac10.zip
UNSD     := $(foreach f,$(STATE_FIPS),UNSD/tl_$(YEAR)_$f_unsd.zip)

ifeq ($(wildcard counties/$(YEAR)/*),"")

else

COUNTY_FIPS   ?= $(foreach a,$(STATE_FIPS),$(addprefix $a,$(COUNTIES_$(a))))
areawatercounty = $(foreach f,$(COUNTY_FIPS),AREAWATER/tl_$(YEAR)_$f_areawater.zip)
AREAWATER     := $(foreach f,$(STATE_FIPS),AREAWATER/tl_$(YEAR)_$f_areawater.shp)
LINEARWATER   := $(foreach f,$(STATE_FIPS),LINEARWATER/tl_$(YEAR)_$f_linearwater.shp)
linearwatercounty = $(foreach f,$(COUNTY_FIPS),LINEARWATER/tl_$(YEAR)_$f_linearwater.zip)
ROADS         := $(foreach f,$(STATE_FIPS),ROADS/tl_$(YEAR)_$f_roads.shp)
roadscounty = $(foreach f,$(COUNTY_FIPS),ROADS/tl_$(YEAR)_$f_roads.zip)

endif # ifeq ($(wildcard counties/$(YEAR)/*),"")
endif # ifeq ($(CARTOGRAPHIC),true)

# general file definitions
AIANNH   := $(call base,AIANNH,us,aiannh)
ANRC     := $(call base,ANRC,02,anrc)
BG       := $(foreach f,$(STATE_FIPS),$(call base,BG,$f,bg))
CD       := $(call base,CD,us,cd$(CONGRESS))
CONCITY  := $(foreach f,09 13 18 20 21 30 47,$(call base,CONCITY,$f,concity))
COUNTY   := $(call base,COUNTY,us,county)
COUSUB   := $(foreach f,$(STATE_FIPS),$(call base,COUSUB,$f,cousub))
CSA      := $(call base,CSA,us,csa)
elsdfp   := 60 69 04 06 09 13 17 21 23 25 26 27 29 30 33 34 36 38 40 41 44 45 47 48 50 51 55 56
ELSD     := $(foreach f,$(filter $(elsdfp),$(STATE_FIPS)),$(call base,ELSD,$f,elsd))
PLACE    := $(foreach f,$(STATE_FIPS),$(call base,PLACE,$(f),place))
PUMA     := $(foreach f,$(filter-out 60 69,$(STATE_FIPS)),$(call base,PUMA,$f,puma10))
scsdfp   := 04 06 09 13 17 21 23 25 27 30 33 34 36 40 41 44 45 47 48 50 55
scsds    := $(filter $(scsdfp),$(STATE_FIPS))
# Remove DC and Nebraska, which have no lower legislative houses.
SLDL     := $(foreach f,$(filter-out 11 31,$(STATE_FIPS)),$(call base,SLDL,$(f),sldl))
SLDU     := $(foreach f,$(STATE_FIPS),$(call base,SLDU,$(f),sldu))
STATE    := $(call base,STATE,us,state)
SUBBARRIO:= $(call base,SUBBARRIO,72,subbarrio)
TRACT    := $(foreach f,$(STATE_FIPS),$(call base,TRACT,$(f),tract))
ZCTA5    := $(call base,ZCTA5,us,zcta510.zip)

# National data sets - one file for the country
zip_national = \
	$(AIANNH) \
	$(AITSN) \
	$(CBSA) \
	$(CD) \
	$(CNECTA) \
	$(COUNTY) \
	$(CSA) \
	$(DIVISION) \
	$(METDIV) \
	$(MIL) \
	$(NATION) \
	$(NECTA) \
	$(NECTADIV) \
	$(RAILS) \
	$(REGION) \
	$(TBG) \
	$(UAC) \
	$(ZCTA5)

# State data sets - one file per state-equivalent
zip_state = \
	$(BG) \
	$(CONCITY) \
	$(COUNTY_WITHIN_UA) \
	$(COUSUB) \
	$(ELSD) \
	$(ESTATE) \
	$(PLACE) \
	$(PUMA) \
	$(SCSD) \
	$(SLDL) \
	$(SLDU) \
	$(TABBLOCK) \
	$(TRACT) \
	$(TTRACT) \
	$(UNSD)

# County data sets - one file per county-equivalent
zip_county = \
	$(areawatercounty) \
	$(linearwatercounty) \
	$(roadscounty)

zipfiles = $(addprefix $(YEAR)/,$(zip_national) $(zip_state) $(zip_county))

export CPL_MAX_ERROR_REPORTS=3

.PHONY: all $(DATASETS)

# Print shortcut commands
all: commands.txt
	@cat $<
	@echo default year is $(YEAR)

.SECONDEXPANSION:

$(DATASETS): $$(addprefix $(YEAR)/,$$($$@))

# define combinecountyfiles
# $(foreach x,$($1),$(YEAR)/$x.$(format)): \
# $(YEAR)/$1/$(call $(1)_base,%).$(format): $$$$(foreach x,$$$$(COUNTIES_$$$$*),$(YEAR)/$1/$(call $(1)_base,$$$$*$$$$x).zip)
# 	@rm -f $$@
# 	for c in $$(COUNTIES_$$*); do \
# 	  ogr2ogr -f 'ESRI Shapefile' $$@ /vsizip/$$(<D)/$$(call $(1)_base,$$*$$$${c}).zip $$(call $(1)_base,$$*$$$${c}) $(OGRFLAGS) -update -append; \
# 	done
# endef

# $(foreach x,AREAWATER LINEARWATER ROADS,$(eval $(call combinecountyfiles,$x)))

$(addprefix $(YEAR)/,$(AREAWATER)): $(YEAR)/LINEARWATER
	echo foo

$(addprefix $(YEAR)/,$(LINEARWATER)):
	echo foo

$(addprefix $(YEAR)/,$(ROADS)): $(YEAR)/ROADS/tl_$(YEAR)_%_roads.shp: $$(foreach x,$$(COUNTIES_$$*),$(YEAR)/ROADS/tl_$(YEAR)_$$*$$x_roads.zip)
	ogrmerge.py -f 'ESRI Shapefile' -single -o $@ $(foreach f,$^,/vsizip/$f/$(notdir $(f:zip=shp)))

# Download ZIP files

$(zipfiles): $(YEAR)/%.zip: | $$(@D)
	curl -Lo $@ -sS --retry 10 --retry-delay 1 --connect-timeout 2 $(url)/$(subst $(YEAR)/,,$@)

$(addprefix $(YEAR)/,$(DATASETS)): $(YEAR)
	-mkdir -p $@

$(YEAR):
	-mkdir -p $@
