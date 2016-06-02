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

calc.viewsheds <- function(dem, points, grass, cores=1){
  prep.dem.grass(dem, grass=grass)
  
  scale <- res(dem)[[1]]
  
  cat("n of Points:",length(points),"\n")
  for(i in (length(points):1)){
    if(file.exists(paste0('../OUTPUT/VIEWSHEDS/RAW/',points[i,]@coords[1],"_",points[i,]@coords[2],"_",scale,".tif"))){
      points <- points[c(-i),]
    }
  }
  
  coords <- paste0(points@coords[,1],',',points@coords[,2],collapse=' ')
  coords <- paste("'",coords,"'",sep='')
  
  cat("n of Points to calculate:",length(points),"\n")
  
  dir.create("/Volumes/ramdisk/OUTPUT/")
  
  system(paste0("bash ../PY/PARALLEL_VIEWSHED.sh ",cores," ",coords," ", res(dem)[1]))
  
  file.copy("/Volumes/ramdisk/OUTPUT/.", "../OUTPUT/VIEWSHEDS/RAW/", overwrite=F, recursive=T, copy.date=T)
  
  discard.grass()
}