#!/bin/bash
# Create tempfile to hold the data
LATITUDE=51.985
LONGITUDE=5.665

tempfoo=`basename $0`
TMPFILE=`mktemp /tmp/${tempfoo}.XXXXXX` || exit 1
# Fetch the data and put it in tempfile
curl --silent "http://gps.buienradar.nl/getrr.php?lat=${LATITUDE}&lon=${LONGITUDE}" | sed 's/|/ /'  > $TMPFILE
# Plot the data in the tempfile
gnuplot 2>/dev/null << EOF
set term dumb 72 20;
set key off;
set xdata time;
set timefmt "%H:%M";
set format x "%H:%M";
set yrange [0:]
plot "${TMPFILE}" using 2:(10**((\$1-109)/32));
EOF

# Remove tempfile
rm -f $TMPFILE