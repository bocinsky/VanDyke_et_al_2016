## This is a script for processing and mapping data from the Chaco Outlier Database,
## available at 
## http://www.chacoarchive.org/cra/outlier-database/
## The data are first standardized in a single UTM zone (12) using the NAD83 projection.

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

# SET THE WORKING DIRECTORY TO THE LOCATION OF THIS FILE
setwd("/Volumes/BOCINSKY_DATA/WORKING/VanDykeEtAl2015/FINAL_PAPER/R/")

# The packages we will use.
# Load the functions for all analyses below
install.packages("FedData", dependencies=T, repos = "http://cran.rstudio.com")
library(FedData)
pkg_test("parallel")
pkg_test("igraph")
pkg_test("rgrass7")
pkg_test("gdata")

junk <- lapply(list.files("./src", full.names=T),source)

# Suppress use of scientific notation
options(scipen=999)

# Force Raster to load large rasters into memory
rasterOptions(chunksize=2e+07,maxmemory=2e+08)

###### PARAMETERS ######
# Toggling functions
CALC_VIEWSHEDS <- TRUE # (Re)calculate all viewsheds?
MERGE <- TRUE # Merge all viewsheds into site-level viewsheds?
CALC_VIEWNET <- TRUE # Compute intervisibility network?
CALC_CVS <- TRUE # Calculate cumulative viewshed?

# Set the projection information for the study area
master.proj <- CRS("+proj=utm +datum=NAD83 +zone=12")

dir.create("../OUTPUT/VIEWSHEDS/RAW/", recursive=T, showWarnings=F)
dir.create("../OUTPUT/NETWORKS/", recursive=T, showWarnings=F)

###### END PARAMETERS ######
# Create the study area
sim.poly <- polygon_from_extent(extent(460000,860000,3780000,4180000), proj4string=projection(master.proj))

# Create a raster template of study area at 50-m resolution
sim.rast <- raster(sim.poly,resolution=50)

## Prepare the DEM, if it doesn't already exist
## Reproject and resample the DEM to the simulation raster (using bilinear interpolation), and save
if(!file.exists("../OUTPUT/DEM50.tif")){
  DEM <- get_ned(template=sim.rast, label="CHACO_VIS", raw.dir="/Volumes/DATA/NED/", extraction.dir="/Volumes/DATA/NED/EXTRACTIONS/")
  sim.dem <- raster::projectRaster(from=DEM, to=sim.rast, filename="../OUTPUT/DEM50.tif",datatype = "FLT4S", options = c("COMPRESS=DEFLATE", "ZLEVEL=9", "INTERLEAVE=BAND"), overwrite = T, setStatistics = FALSE)
}else{
  sim.dem <- raster("../OUTPUT/DEM50.tif")
}

# Read in the raw, untransformed data
sites <- read.xls("../DATA/VanDykeEtAl2015_SITE_DATA.xlsx", sheet=1, stringsAsFactors=F)

# Create some blank variables
sites$PROJECTED_EASTING <- ""
sites$PROJECTED_NORTHING <- ""
sites$PROJECTED_PROJ4STRING <- ""

# For each site, transform to the master.projection and 
# add those data to the table
for(i in 1:dim(sites)[1]){
  if(!(is.na(sites[i,]$ORIG_EASTING) | sites[i,]$ORIG_EASTING=="")){
    site <- as.data.frame(t(as.matrix(c(as.numeric(sites[i,]$ORIG_EASTING),as.numeric(sites[i,]$ORIG_NORTHING)))))
    colnames(site) <- c("EASTING","NORTHING")
    string <- gsub("'","",as.character(sites[i,]$ORIG_PROJ4STRING))
    site <- SpatialPointsDataFrame(coords=site, data=sites[i,], proj4string=CRS(string))
    site <- spTransform(site,master.proj)
    sites[i,]$PROJECTED_EASTING <- round(site@coords[1],digits=0)
    sites[i,]$PROJECTED_NORTHING <- round(site@coords[2],digits=0)
    sites[i,]$PROJECTED_PROJ4STRING <- projection(master.proj)
  }
}

# Write all of the updated data, for our records
write.csv(sites,"../OUTPUT/VanDykeEtAl2015_SITE_DATA_UPDATE.csv",row.names=F)

sites <- read.csv("../OUTPUT/VanDykeEtAl2015_SITE_DATA_UPDATE.csv")

# Purge sites that have no location data
sites <- sites[!(is.na(sites$PROJECTED_EASTING) | sites$PROJECTED_EASTING==""),]

# Turn the sites table into a SpatialPointsDataFrame
sp_point <- matrix(NA, nrow=nrow(sites),ncol=2)
sp_point[,1] <- as.numeric(sites$PROJECTED_EASTING)
sp_point[,2] <- as.numeric(sites$PROJECTED_NORTHING)
colnames(sp_point) <- c("EASTING","NORTHING")
sp_point <- round(sp_point,digits=0)
sites <- SpatialPointsDataFrame(coords=sp_point,sites,proj4string=master.proj)

# How many great houses are visible from Google Earth?
sum(sites[sites$SITE_TYPE %in% c("GH_CORE","GH_OUTLIER"),]$GE_VISIBLE)

# Export a version for Google Earth verification.
# sites.kml <- sites[is.na(sites$GE_VISIBLE),]
sites.kml <- spTransform(sites,CRS("+proj=longlat +ellps=WGS84 +no_defs"))
sites.kml$GE_VISIBLE <- as.character(sites.kml$GE_VISIBLE)
sites.kml$NAME <- sites.kml$UNIQUE_ID
suppressWarnings(writeOGR(sites.kml,"../OUTPUT/VanDykeEtAl2015_SITE_DATA.kml","VanDykeEtAl2015_SITE_DATA", driver="KML", overwrite_layer=TRUE))


# Output publication-ready table
sites.sanitized <- as.data.frame(sites)
sites.sanitized$SITE_NUMBER <- paste(sites.sanitized$SITE_NUMBER_SMITHSONIAN, sites.sanitized$SITE_NUMBER_OTHER, sep=", ")
sites.sanitized$SITE_NUMBER[sites.sanitized$SITE_NUMBER_SMITHSONIAN==""] <- as.character(sites.sanitized$SITE_NUMBER_OTHER[sites.sanitized$SITE_NUMBER_SMITHSONIAN==""])
sites.sanitized$SITE_NUMBER[sites.sanitized$SITE_NUMBER_OTHER==""] <- as.character(sites.sanitized$SITE_NUMBER_SMITHSONIAN[sites.sanitized$SITE_NUMBER_OTHER==""])
sites.sanitized$SITE_NUMBER[sites.sanitized$SITE_NUMBER==" "] <- ""
sites.sanitized <- sites.sanitized[sites.sanitized$PRIMARY_LOCATION==TRUE & sites.sanitized$SITE_TYPE!="LANDFORM",c("SITE_NAME","SITE_NUMBER","SITE_TYPE","DATE","GE_VISIBLE", "AUTHOR_VISITED")]
sites.sanitized <- data.frame(lapply(sites.sanitized, as.character), stringsAsFactors=FALSE)
sites.sanitized <- sites.sanitized[order(sites.sanitized$SITE_NAME, decreasing=FALSE),]
sites.sanitized <- sites.sanitized[order(sites.sanitized$SITE_TYPE, decreasing=FALSE),]
sites.sanitized.names <- c("Site Name","Site Number(s)","Site Type","Year Range", "GE Visible?", "Author Visited?")
sites.sanitized$SITE_TYPE[sites.sanitized$SITE_TYPE=="GH_CORE"] <- "Great House - Chaco Core"
sites.sanitized$SITE_TYPE[sites.sanitized$SITE_TYPE=="GH_OUTLIER"] <- "Great House - Outlier"
sites.sanitized$SITE_TYPE[sites.sanitized$SITE_TYPE=="SHRINE"] <- "Shrine"
sites.sanitized$SITE_TYPE[sites.sanitized$SITE_TYPE=="STONE_CIRCLE"] <- "Stone Circle"
sites.sanitized$SITE_TYPE[sites.sanitized$SITE_TYPE=="HERRADURA"] <- "Herradura"
sites.sanitized$SITE_TYPE[sites.sanitized$SITE_TYPE=="CRESCENT"] <- "Crescent"
sites.sanitized$DATE[sites.sanitized$DATE==1] <- "850-1040"
sites.sanitized$DATE[sites.sanitized$DATE==2] <- "850-1150"
sites.sanitized$DATE[sites.sanitized$DATE==3] <- "850-1300"
sites.sanitized$DATE[sites.sanitized$DATE==4] <- "1040-1150"
sites.sanitized$DATE[sites.sanitized$DATE==5] <- "1040-1300"
sites.sanitized$DATE[sites.sanitized$DATE==6] <- "1150-1300"
sites.sanitized$DATE[is.na(sites.sanitized$DATE)] <- "Unknown"
sites.sanitized$GE_VISIBLE[sites.sanitized$GE_VISIBLE==T] <- "Yes"
sites.sanitized$GE_VISIBLE[sites.sanitized$GE_VISIBLE==F] <- "No"
sites.sanitized$AUTHOR_VISITED[sites.sanitized$AUTHOR_VISITED==T] <- "Yes"
sites.sanitized$AUTHOR_VISITED[sites.sanitized$AUTHOR_VISITED==F] <- "No"
write.table(sites.sanitized,"../OUTPUT/VanDykeEtAl2015_SITE_DATA_PUBLICATION.csv", sep=",", row.names=F, col.names=sites.sanitized.names)

## This section applies the "robust logic" rules to calculating viewsheds
## The rules are defined thusly:
## 1) calculate viewsheds from all coordinates where sites exist
## 2) for great houses and landforms, calculate viewsheds from
##      cells bordering each site's cell (its "Moore Neighborhood")
# Make a copy of the sites data
sites.calc <- sites
sites.cells <- data.frame(sites.calc$UNIQUE_ID,cellFromXY(sim.rast,sites.calc))
names(sites.cells) <- c("UNIQUE_ID","CELL")
# Get neighboring cells in Moore (Queen's case) neighborhood
sites.neighbors <- adjacent(sim.rast,sites.cells$CELL[sites.calc$SITE_TYPE %in% c("GH_CORE","GH_OUTLIER","LANDFORM")],directions=8, include=T,sorted=T)
sites.calc <- merge(sites.cells,sites.neighbors,by.x="CELL",by.y="from",all=T)
sites.calc$to[is.na(sites.calc$to)] <- sites.calc$CELL[is.na(sites.calc$to)]
sites.calc <- sites.calc[,c(2,3)]
names(sites.calc) <- c("UNIQUE_ID","CELL")
# Remove any NA cells
sites.calc <- sites.calc[!is.na(sites.calc$CELL),]

# Create a final SPDF of the cells to be calculated
sites.final <- xyFromCell(sim.rast,sites.calc$CELL,spatial=T)
sites.final <- SpatialPointsDataFrame(coords=sites.final,sites.calc[,1:2],proj4string=master.proj)

sites.final.kml <- spTransform(sites.final,CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"))
sites.final.kml$NAME <- sites.final.kml$UNIQUE_ID
suppressWarnings(writeOGR(sites.final.kml,"../OUTPUT/VanDykeEtAl2015_SITE_DATA_ROBUST.kml","VanDykeEtAl2015_SITE_DATA_ROBUST",driver="KML", overwrite_layer=TRUE))


# Finally, calculate all of the viewsheds. This algorithm only calculates viewsheds
# that haven't already been calculated
# NOTE: Must use GRASS version 7.0.0 or above
if(CALC_VIEWSHEDS){
  dir.create("../OUTPUT/VIEWSHEDS/RAW/", recursive=T, showWarnings=F)
  calc.viewsheds(dem=sim.dem, points=sites.final, grass="/usr/local/opt/grass-70/grass-7.0.0", cores=4)
}

# Merge viewsheds for single sites, using the "UNIQUE_ID" value
sites.names <- as.character(unique(sites.final$UNIQUE_ID))

if(MERGE){
  for(name in sites.names){
    if(file.exists(paste("../OUTPUT/VIEWSHEDS/",name,"_",res(sim.dem)[[1]],'.tif',sep=''))){next}
    
    temp.sites <- sites.final[sites.final$UNIQUE_ID==name,]
    raster.list <- paste0("../OUTPUT/VIEWSHEDS/RAW/",temp.sites@coords[,1],"_",temp.sites@coords[,2],"_",res(sim.dem)[[1]],".tif")
    temp.brick <- stack(raster.list, quick=T)
    
    temp.sum <- sum(temp.brick, na.rm=T) > 0
    
    writeRaster(temp.sum,paste0("../OUTPUT/VIEWSHEDS/",name,"_",res(sim.dem)[[1]],'.tif'),datatype="INT1U", options=c("COMPRESS=DEFLATE","ZLEVEL=9","INTERLEAVE=BAND","NBITS=1","PHOTOMETRIC=MINISWHITE"), overwrite=T, setStatistics = FALSE)
  }  
}

# Create a "stack," or representation, of all merged viewsheds
file.names <- as.list(paste(paste0("../OUTPUT/VIEWSHEDS/",unique(sites$UNIQUE_ID),"_",res(sim.dem)[[1]],'.tif')))
stack.available <- vector("logical", length(file.names))
stack.available[] <- FALSE
for(i in 1:length(file.names)){
  if(file.exists(file.names[[i]])){
    stack.available[i] <- TRUE
  }else{
    cat("File ",file.names[[i]]," does not exist!\n")
  }
}
file.names <- file.names[stack.available]
sites.stack <- stack(file.names,quick=T)

# Calculate the cumulative viewshed of all great houses
if(CALC_CVS){
  # Calculate CVS of just great houses
  GH.files <- paste0("../OUTPUT/VIEWSHEDS/",sites[sites$SITE_TYPE %in% c("GH_CORE","GH_OUTLIER"),]$UNIQUE_ID,"_50.tif")
  system.time(GH.cvs <- calc.cvs(GH.files,"../OUTPUT/GH.cvs.tif"))
  
  # Calculate CVS of just shrines
  SHRINE.files <- paste0("../OUTPUT/VIEWSHEDS/",sites[sites$SITE_TYPE %in% c("SHRINE","STONE_CIRCLE", "CRESCENT","HERRADURA"),]$UNIQUE_ID,"_50.tif")
  SHRINE.cvs <- calc.cvs(raster.files.list=SHRINE.files,"../OUTPUT/SHRINE.cvs.tif")
  
}

# Calculate the viewnet between all sites
if(CALC_VIEWNET){
  dir.create("../OUTPUT/NETWORKS/", recursive=T, showWarnings=F)
  sites.final<- sites[stack.available,]
  # sites.final <- sites.final[sites.final$UNIQUE_ID %in% sites.names.types$UNIQUE_ID,]
  
  sites.attributes <- sites@data[sites$PRIMARY_LOCATION==1,]
  sites.attributes$UNIQUE_ID <- as.character(sites.attributes$UNIQUE_ID)
  sites.viewnet <- calc.viewnet.robust(sites.final,sites.final$UNIQUE_ID)
  V(sites.viewnet)$name
  
  sites.attributes <- sites.attributes[c(match(V(sites.viewnet)$name,sites.attributes$UNIQUE_ID)),]
  
  V(sites.viewnet)$EASTING <- as.numeric(as.character(sites.attributes$PROJECTED_EASTING))
  V(sites.viewnet)$NORTHING <- as.numeric(as.character(sites.attributes$PROJECTED_NORTHING))
  V(sites.viewnet)$SITE_TYPE <- as.character(sites.attributes$SITE_TYPE)
  
  write.graph(sites.viewnet,paste0("../OUTPUT/NETWORKS/ALL_SITES_",res(sim.dem)[[1]],".graphml"),format="graphml")
}

