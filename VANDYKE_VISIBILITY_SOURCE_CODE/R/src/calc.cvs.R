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

calc.cvs <- function(raster.files.list, out.file){
  old.wd <- getwd()
  unlink("./TEMP/", recursive=T, force=T)
  dir.create("./TEMP/")
  
  iter <- 1
  
  chunks <- split(raster.files.list, ceiling(seq_along(raster.files.list)/26))
  
  cl <- makeCluster(8)
  junk <- parLapply(cl,1:length(chunks),function(i,chunks){
    system(paste0("gdal_calc.py ",paste0("-",toupper(letters)[1:length(chunks[[i]])]," ",chunks[[i]], collapse=' ')," --outfile ./TEMP/temp.",iter,".",i,".tif --calc='",paste0(toupper(letters)[1:length(chunks[[i]])],collapse="+"),"' --type=UInt16 --overwrite --co='COMPRESS=DEFLATE' --co='ZLEVEL=9' --co='INTERLEAVE=BAND'"))
  }, chunks=chunks)
  stopCluster(cl)
  
  out.files <- list.files("./TEMP/", full.names=T)

  while(length(out.files)>26){
    iter <- iter+1
    chunks <- split(out.files, ceiling(seq_along(out.files)/26))
    
    cl <- makeCluster(8)
    junk <- parLapply(cl,1:length(chunks),function(i,chunks){
      system(paste0("gdal_calc.py ",paste0("-",toupper(letters)[1:length(chunks[[i]])]," ",chunks[[i]], collapse=' ')," --outfile ./TEMP/temp.",iter,".",i,".tif --calc='",paste0(toupper(letters)[1:length(chunks[[i]])],collapse="+"),"' --type=UInt16 --overwrite --co='COMPRESS=DEFLATE' --co='ZLEVEL=9' --co='INTERLEAVE=BAND'"))
    }, chunks=chunks)
    stopCluster(cl)
    
    file.remove(out.files)
    out.files <- list.files("./TEMP/", full.names=T)
  }
  
  system(paste0("gdal_calc.py ",paste0("-",toupper(letters)[1:length(out.files)]," ",out.files, collapse=' ')," --outfile ",out.file," --calc='",paste0(toupper(letters)[1:length(out.files)],collapse="+"),"' --type=UInt16 --overwrite --co='COMPRESS=DEFLATE' --co='ZLEVEL=9' --co='INTERLEAVE=BAND'"))
  
  out <- raster(out.file)
  unlink("./TEMP/", recursive=T, force=T)
  return(out)
}