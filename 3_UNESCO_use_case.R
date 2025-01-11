# Note: the values given by this analyses may differ slightly from those given in the UNESCO report, due to minor differences in spatial polygons and the BIEN database.


library(wdpar)
library(BIEN)
library(tidyverse)
library(sf)
library(arrow)

# Make temp folder

temp_dir <- tempdir()

# Get PA data

wdpa <- wdpa_fetch("global", download_dir = temp_dir)

unesco <- wdpa %>% filter(grepl(pattern = "UNESCO", x = DESIG_ENG))

rm(wdpa)

gc()

# Check that the polygons are WGS4

st_crs(unesco)


# Download all observations falling within UNESCO polygons (if needed)

if(!file.exists(file.path(temp_dir,"all_unesco_obs.gz.parquet") )){
  
  
  # make a single polygon to simplify things
  
  sf_use_s2(FALSE)
  
  unesco %>%
    st_make_valid() %>%
    st_union() -> unesco_union
  
  # run the BIEN query
  
  all_unesco_obs <-      
    BIEN_occurrence_sf(sf = unesco_union,
                       cultivated = TRUE,
                       native.status = TRUE,
                       natives.only = FALSE,
                       observation.type = TRUE,
                       collection.info = TRUE,
                       new.world = NULL,
                       all.taxonomy = TRUE,
                       political.boundaries = FALSE,
                       fetch.query=FALSE)
  
  #save the output as a parquet file
  
  write_parquet(x = all_unesco_obs,
                sink = file.path(temp_dir,"all_unesco_obs.gz.parquet"),
                compression = "GZIP")
  
}else{
  
  
  all_unesco_obs <- read_parquet(file.path(temp_dir,"all_unesco_obs.gz.parquet"))
  
}

# Pull species list for each UNESCO site

# Convert obs to sf

all_unesco_obs %>%
  st_as_sf(coords = c("longitude","latitude"),
           crs  = 4326,
           remove = FALSE) -> all_unesco_obs


# Do a join to associate polygons with points      

all_unesco_obs %>%
  st_join(y = unesco,
          left = FALSE) -> all_unesco_obs

# write the output (sans the geometry)

all_unesco_obs %>%
  st_drop_geometry() %>%
  write.csv(file = "output/occurrences_in_UNESCO_sites.csv")

