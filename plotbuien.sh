#!/bin/bash
# This script plots the predicted rainfall, as described at http://gratisweerdata.buienradar.nl/
# TODO : do not create tempfile, but only create a new file if old one is stale
# According to http://en.wikipedia.org/wiki/Rain#Intensity , intensity of rain is this:
#	Light rain — when the precipitation rate is < 2.5 millimetres per hour
#	Moderate rain — when the precipitation rate is between 2.5 millimetres - 7.6 millimetres or 10 millimetres per hour
#	Heavy rain — when the precipitation rate is > 7.6 millimetres per hour, or between 10 millimetres and 50 millimetres per hour
#	Violent rain — when the precipitation rate is > 50 millimetres per hour

LATITUDE=51.985
LONGITUDE=5.665
XSIZE=72
YSIZE=30
# Create tempfile to hold the data
tempfoo=`basename $0`
TMPFILE=`mktemp /tmp/${tempfoo}.XXXXXX` || exit 1
# Fetch the data and put it in tempfile
curl --silent "http://gps.buienradar.nl/getrr.php?lat=${LATITUDE}&lon=${LONGITUDE}" | sed 's/|/ /'  > $TMPFILE
# Plot the data in the tempfile
gnuplot 2>/dev/null << EOF
	set term dumb ${XSIZE} ${YSIZE};
	set key off;													# Remove legend
	set xdata time;													# x-axis is time data
	set timefmt "%H:%M";											# Format of input data
	set format x "%H:%M";											# How do we show the time
	set ytics nomirror												# Remove right tics
	unset border													# Remove border from plot
	set yrange [0:]													# Let the plot start at 0
	set offsets graph 0, 0, 0.05, 0.05								# Add some space around the points
	plot "${TMPFILE}" using 2:(10**((\$1-109)/32)) with impulse;	# Plot the data, calculate mm from measurements
EOF

# Remove tempfile
rm -f $TMPFILE
