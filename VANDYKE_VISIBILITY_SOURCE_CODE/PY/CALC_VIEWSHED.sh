#!/bin/bash
# Author: R. Kyle Bocinsky, 16 June 2015

# Author: R. Kyle Bocinsky, 16 June 2015
# The MIT License (MIT)
# Copyright (c) 2015 Ronald Kyle Bocinsky
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# Purpose: Calculate a view shed and return it as a network
# Usage: CALC_VIEWSHED.sh rastermap coordinates resolution


OIFS=$IFS                   # store old IFS in buffer
IFS=','                     # set IFS to '-'

COORD=($2)

## Calculate a view shed
r.viewshed -cb input=$1 output="${COORD[0]}_${COORD[1]}" coordinates="${COORD[0]},${COORD[1]}" observer_elevation="5" target_elevation="5" max_distance="-1" memory="8192" --overwrite --quiet

r.out.gdal -c input="${COORD[0]}_${COORD[1]}" output="/Volumes/BOCINSKY_DATA/WORKING/VanDykeEtAl2015/FINAL_PAPER/OUTPUT/VIEWSHEDS/RAW/${COORD[0]}_${COORD[1]}_$3.tif" type="Byte" createopt="COMPRESS=DEFLATE,ZLEVEL=9,INTERLEAVE=BAND,NBITS=1,PHOTOMETRIC=MINISWHITE" --overwrite --quiet

IFS=$OIFS                   # reset IFS to default (whitespace)