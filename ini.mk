YEAR = 2015

# Create INI files with lists of county FIPS
counties/$(YEAR).ini: $(YEAR)/COUNTY/cb_$(YEAR)_us_county_20m.zip | counties
	ogr2ogr /dev/stdout /vsizip/$< -dialect sqlite -f CSV \
	    -sql "SELECT 'COUNTIES_' || STATEFP || ' = ' || group_concat(COUNTYFP, ' ') \
	    FROM (SELECT * FROM $(basename $(<F)) ORDER BY COUNTYFP) a GROUP BY STATEFP" | \
	tail -n+2 > $@
