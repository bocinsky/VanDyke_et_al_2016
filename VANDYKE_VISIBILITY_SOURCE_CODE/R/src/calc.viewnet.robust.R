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

# This function builds an edge list between intervisible sites, and 
# exports it as an igraph object.
# This function allows for more than one viewpoint per "site," as in 
# the robust viewshed analysis performed above.
calc.viewnet.robust <- function(points,site.names){
  
  site.names <- as.character(unique(site.names))
  
  viewnet <- matrix(nrow=0,ncol=2)
  
  for(name in site.names){
    cat("\nCalculating network neighbors of site", name)
    temp.rast <- raster(paste("../OUTPUT/VIEWSHEDS/",name,"_50.tif",sep=''))
    connection <- as.character(unique(points$UNIQUE_ID[temp.rast[cellFromXY(temp.rast,cbind(points@coords[,1],points@coords[,2]))]>0]))
    if(length(connection)==0){
      next()
    }
    links <- cbind(name,connection)
    viewnet <- rbind(viewnet,links)
  }
  
  viewnet <- graph.edgelist(as.matrix(viewnet), directed=FALSE)
  viewnet <- simplify(viewnet)
  
  return(viewnet)
}