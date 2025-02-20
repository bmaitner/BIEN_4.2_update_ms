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
  
  # Union, buffer, and simplify to make things easier on the BIEN server.
  # Complicated polygons are taxing.
  
  unesco %>%
    st_make_valid() %>%
    st_union() -> unesco_union
  
  st_buffer(x = unesco_union,dist = 1) %>%
    st_simplify(dTolerance = 1) -> unesco_union_small
  
  # run the BIEN query
  
  all_unesco_obs <-      
    BIEN_occurrence_sf(sf = unesco_union_small,
                       cultivated = TRUE,
                       native.status = TRUE,
                       natives.only = FALSE,
                       observation.type = TRUE,
                       collection.info = TRUE,
                       new.world = NULL,
                       all.taxonomy = TRUE,
                       political.boundaries = FALSE,
                       fetch.query=FALSE,
                       only.geovalid = FALSE)
  
  
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

# How many taxa, going by the verbatim name?

  length(unique(all_unesco_obs$verbatim_scientific_name)) #90414

# How many names after taxonomic cleaning?
  
  all_unesco_obs %>%
    filter(is_geovalid == 1)%>%
    pull(scrubbed_species_binomial)%>%
    unique()%>%
    length() #59475
  

  
# write the output (sans the geometry)

all_unesco_obs %>%
  st_drop_geometry() %>%
  write.csv(file = "output/occurrences_in_UNESCO_sites.csv")

####################################################

# What about without cleaning?

  # need to update the occurrences sf function to optionally return non-geovalid stuff