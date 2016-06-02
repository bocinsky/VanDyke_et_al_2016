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

prep.dem.grass <- function(dem, grass){
  # Create a RAM disk for quick read/write in GRASS
  system("diskutil erasevolume HFS+ 'ramdisk' `hdiutil attach -nomount ram://16384000`")
  # Create GRASS things on RAM disk
  system("mkdir /Volumes/ramdisk/home")
  system("mkdir /Volumes/ramdisk/gisDbase")
  
  # Location of your GRASS installation:
  #   loc <- spgrass6::initGRASS(grass, home="/Volumes/ramdisk/home", gisDbase="/Volumes/ramdisk/gisDbase",mapset="PERMANENT",override=TRUE)
  loc <- rgrass7::initGRASS(grass, home="/Volumes/ramdisk/home", gisDbase="/Volumes/ramdisk/gisDbase",mapset="PERMANENT",override=TRUE)
  
  rgrass7::gmeta()
  
  gc()
  # Import the DEM to GRASS:
  DEM.sp <- as(dem, 'SpatialGridDataFrame')
  
  suppressWarnings(rgrass7::writeRAST(DEM.sp, flags=c("overwrite","quiet"), "DEM", useGDAL=TRUE))
  rgrass7::execGRASS("g.proj", flags=c("c"), parameters=list(georef=filename(dem)))
  rgrass7::execGRASS("g.region", flags=c("quiet"), parameters=list(raster="DEM"))
}