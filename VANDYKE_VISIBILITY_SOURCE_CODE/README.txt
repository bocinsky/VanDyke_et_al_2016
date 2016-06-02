This directory contains all of the source code necessary to replicate the visibility analyses presented in

"Great Houses, Shrines, and High Places: Intervisibility in the Chacoan World"
by Ruth M. Van Dyke, R. Kyle Bocinsky, Thomas C. Windes, and Tucker G. RobinsonThe "R" directory contains R source code, including the master script, VANDYKE_VISIBILITY.R. Code has been tested on Apple machines running OS 10.10 only. All scripts require GDAL (version 2.1.0, with Python bindings), GRASS (version 7.0.1), and GNU Parallel to be installed. The "src" subdirectory contains several custom functions:

calc.cvs.R – A multicore wrapper for calc_gdal.py that calculates cumulative viewsheds from many individual viewshed rasters.

calc.viewnet.robust.R – A function to generate an edgelist from several individual viewshed rasters.

calc.viewsheds.R – A function that initiates a GRASS 7 session on a virtual disk, imports a DEM, and calculated viewsheds from a list of observer points on that DEM.

discard.grass.R – A function that ends a GRASS session

prep.dem.grass.R – A function that initiates a RAM disk for quick read/write in GRASS and imports a given DEM from R using the "raster" package.



In the "PY" directory, there are two Bash scripts that run the GRASS viewshed analyses:

PARALLEL_VIEWSHED.sh – A wrapper script that allows for parallel processing of viewshed calculation in GRASS.

CALC_VIEWSHED.sh – A function that accepts a raster map, set of coordinates (x,y), and resolution as input, calculates the viewshed, and writes a binary GeoTIFF as output.




The MIT License (MIT)

Copyright (c) 2015 Ronald Kyle Bocinsky

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.