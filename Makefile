# This file is part of get-tiger
# https://github.com/fitnr/get-tiger

# Licensed under the GNU General Public License v3 (GPLv3) license:
# http://opensource.org/licenses/GPL-3.0
# Copyright (c) 2016, Neil Freeman <contact@fakeisthenewreal.org>
SHELL := /bin/bash

# Year of census data - check Census site for most recent year available.
YEAR := 2020

# Congressional districts are updated every two years.
CONGRESS := 116

# Some files can be drawn from the cartographic boundary or tiger geodata. Default is cartographic.
CARTOGRAPHIC ?= false

# Other valid values: 20m, 5m
RESOLUTION := 500k

# user-reported flag for the presence of GDAL. We assume it is installed.
GDAL := true

include counties/$(YEAR).ini

.SUFFIXES:

comma = ,
STATE_FIPS = 01 02 04 05 06 08 09 10 11 12 13 15 16 17 18 19 20 \
			 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 \
			 38 39 40 41 42 44 45 46 47 48 49 50 51 53 54 55 56 72

DATASETS = AREAWATER NATION REGION DIVISION AIANNH AITSN ANRC \
	BG CBSA CD CNECTA CONCITY COUNTY COUNTY_WITHIN_UA COUSUB CSA \
	ELSD ESTATE LINEARWATER METDIV MIL NECTA NECTADIV PLACE \
	PUMA RAILS ROADS SCSD SLDL SLDU STATE SUBBARRIO \
	TABBLOCK TBG TTRACT TRACT UAC UNSD ZCTA5

carto-base  = $(1)/cb_$(YEAR)_$(2)_$(3)_$(RESOLUTION).zip
carto-url  := ftp://ftp2.census.gov/geo/tiger/GENZ$(YEAR)/shp

tiger-base  = $(1)/tl_$(YEAR)_$(2)_$(3).zip
tiger-url  := ftp://ftp2.census.gov/geo/tiger/TIGER$(YEAR)

ifeq ($(CARTOGRAPHIC),true)
base = $(carto-base)
else
base  = $(tiger-base)
endif # ifeq ($(CARTOGRAPHIC),true)

# cartographic-only slugs
DIVISION := DIVISION/cb_$(YEAR)_us_division_5m.zip
NATION   := NATION/cb_$(YEAR)_us_nation_5m.zip
REGION   := REGION/cb_$(YEAR)_us_region_500k.zip
COUNTY_WITHIN_UA := $(foreach f,$(STATE_FIPS),COUNTY_WITHIN_UA/cb_$(YEAR)_$f_county_within_ua_$(RESOLUTION).zip)

# Set tiger-line-only slugs
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
roadscounty    = $(foreach f,$(COUNTY_FIPS),ROADS/tl_$(YEAR)_$f_roads.zip)

endif # ifeq ($(wildcard counties/$(YEAR)/*),"")

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

# data sets that could be cartographic or tiger-line
carto-or-tiger = \
	$(AIANNH) \
	$(ANRC) \
	$(BG) \
	$(CD) \
	$(CONCITY) \
	$(COUNTY) \
	$(COUSUB) \
	$(CSA) \
	$(ELSD) \
	$(PLACE) \
	$(PUMA) \
	$(SLDL) \
	$(SLDU) \
	$(STATE) \
	$(SUBBARRIO) \
	$(TRACT) \
	$(ZCTA5) \

cartographic-only = \
	$(DIVISION) \
	$(NATION) \
	$(REGION) \
	$(COUNTY_WITHIN_UA)

tiger-only = \
	$(AITSN) \
	$(CBSA) \
	$(CNECTA) \
	$(ESTATE) \
	$(METDIV) \
	$(MIL) \
	$(NECTA) \
	$(NECTADIV) \
	$(RAILS) \
	$(SCSD) \
	$(TABBLOCK) \
	$(TBG) \
	$(TTRACT) \
	$(UAC) \
	$(UNSD) \
	$(areawatercounty) \
	$(linearwatercounty) \
	$(roadscounty)

export CPL_MAX_ERROR_REPORTS=3

.PHONY: help $(DATASETS)

# Print shortcut commands
help: commands.txt
	@cat $<
	@echo
	@echo current variable settings:
	@echo YEAR         = $(YEAR)
	@echo CONGRESS     = $(CONGRESS)
	@echo CARTOGRAPHIC = $(CARTOGRAPHIC)
	@echo RESOLUTION   = $(RESOLUTION)
	@echo STATE_FIPS   = $(STATE_FIPS)
	@echo GDAL         = $(GDAL)

.SECONDEXPANSION:

# Dataset commands, e.g. BG and TRACT
$(DATASETS): $$(addprefix $(YEAR)/,$$($$@))

# Merged file shortcuts

merges = BG COUNTY_WITHIN_UA COUSUB ELSD PLACE PRISECROADS PUMA SCSD SLDL SLDU TABBLOCK TRACT UNSD AREAWATER
merge-shp = $(foreach x,$(merges),$(YEAR)/$x.shp)

ifeq ($(GDAL),true)
merge-command = ogrmerge.py -f 'ESRI Shapefile' -overwrite_ds -single -o $@
merge-zip-command = $(merge-command) $(foreach f,$^,/vsizip/$(f)/$(notdir $(f:zip=shp)))
merge-shp-command = $(merge-command) $^
else

define merge-zip-command
@echo "unable to create $@ because GDAL isn't installed. These source files have been downloaded:"
@echo $^
endef

merge-shp-command = $(merge-zip-command)

endif # ifeq ($(GDAL),true)

$(merge-shp): $(YEAR)/%.shp: $$(addprefix $(YEAR)/,$$($$*))
	$(merge-zip-command)

$(YEAR)/RAILS.shp $(YEAR)/ROADS.shp: $(YEAR)/%.shp: $$(addprefix $(YEAR)/,$$($$*))
	$(merge-shp-command)

# commands that merge county-level files

$(addprefix $(YEAR)/,$(AREAWATER)): $(YEAR)/AREAWATER/tl_$(YEAR)_%_areawater.shp: $$(foreach x,$$(COUNTIES_$$*),$(YEAR)/AREAWATER/tl_$(YEAR)_$$*$$x_areawater.zip)
	$(merge-zip-command)

$(addprefix $(YEAR)/,$(LINEARWATER)): $(YEAR)/LINEARWATER/tl_$(YEAR)_%_linearwater.shp: $$(foreach x,$$(COUNTIES_$$*),$(YEAR)/LINEARWATER/tl_$(YEAR)_$$*$$x_linearwater.zip)
	$(merge-zip-command)

$(addprefix $(YEAR)/,$(ROADS)): $(YEAR)/ROADS/tl_$(YEAR)_%_roads.shp: $$(foreach x,$$(COUNTIES_$$*),$(YEAR)/ROADS/tl_$(YEAR)_$$*$$x_roads.zip)
	$(merge-zip-command)

# Download ZIP files

get = curl -o $@ -LsS --retry 10 --retry-delay 1 --connect-timeout 2

carto-get = $(get) $(carto-url)/$(@F)
tiger-get = $(get) $(tiger-url)/$(subst $(YEAR)/,,$@)

$(addprefix $(YEAR)/,$(carto-or-tiger)): $(YEAR)/%.zip: | $$(@D)
ifeq ($(CARTOGRAPHIC),true)
	$(carto-get)
else
	$(tiger-get)
endif

$(addprefix $(YEAR)/,$(cartographic-only)): $(YEAR)/%.zip: | $$(@D)
	$(carto-get)

$(addprefix $(YEAR)/,$(tiger-only)): $(YEAR)/%.zip: | $$(@D)
	$(tiger-get)

$(addprefix $(YEAR)/,$(DATASETS)): $(YEAR)
	-mkdir -p $@

$(YEAR):
	-mkdir -p $@
