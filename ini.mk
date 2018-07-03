YEAR = 2017

# INI files with lists of county FIPS
counties/$(YEAR).ini: $(YEAR)/COUNTY/$(YEAR)_Gaz_counties_national.zip | counties
	unzip -p $< | \
	iconv -f Windows-1252 -t UTF-8 | tail -n+2 | cut -f 2 | \
	awk '{ arr[substr($$1, 1, 2)] = arr[substr($$1, 1, 2)] FS substr($$1, 3) } END \
	  {for (i in arr) {print "COUNTIES_" i " ="arr[i] } }' | \
	sort > $@

$(YEAR)/COUNTY/2017_Gaz_counties_national.zip: | $(YEAR)/COUNTY
	curl -Lo $@ http://www2.census.gov/geo/docs/maps-data/data/gazetteer/$(YEAR)_Gazetteer/$(@F)

$(YEAR)/COUNTY counties: ; mkdir -p $@
