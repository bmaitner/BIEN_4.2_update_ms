# Code to generate BIEN annotation statistics

library(BIEN)

# Total number of records in view_full_occurrence_individual

BIEN:::.BIEN_sql(query = "SELECT count(*)
                          FROM view_full_occurrence_individual ;")

#284466171

# Total number of records in vfoi


BIEN:::.BIEN_sql(query = "SELECT distinct observation_type FROM view_full_occurrence_individual ;")

#284466171

# Total of different observation types

occurrence_type_breakdown <- 
BIEN:::.BIEN_sql(query = "SELECT observation_type, COUNT(*) AS total
                          FROM view_full_occurrence_individual
                          GROUP BY observation_type
                          ORDER BY total DESC;")


# Total number of trait observations
BIEN:::.BIEN_sql(query = "SELECT COUNT(*)
                          FROM agg_traits ;")

#25932628

#Total number of plots

plot_md <- BIEN_plot_metadata()
length(unique(plot_md$plot_name))

# Total number of ranges
  nrow(BIEN_ranges_list()) #98829
  
  OpenRange:::ranges_sql("Select COUNT(*) from ranges.range;")  #289743
  OpenRange:::ranges_sql("Select COUNT(DISTINCT(species)) from ranges.range;") #112953
  
  #"Select species from ranges.range;"
  
# Number of species by hpg
  
  #Angiosperms
  #Gymnosperms
  #Ferns
  #Bryophytes
  

hpg_breakdown <- 
    BIEN:::.BIEN_sql(query = "SELECT higher_plant_group, COUNT(*) AS total
                          FROM view_full_occurrence_individual
                          GROUP BY higher_plant_group
                          ORDER BY total DESC;")

hpg_breakdown_by_spp <- 
  BIEN:::.BIEN_sql(query = "SELECT higher_plant_group, COUNT(DISTINCT(scrubbed_species_binomial)) AS total
                          FROM view_full_occurrence_individual
                          WHERE scrubbed_species_binomial IS NOT NULL
                          GROUP BY higher_plant_group
                          ORDER BY total DESC;")


hpg_breakdown_by_spp_only_accepts <- 
  BIEN:::.BIEN_sql(query = "SELECT higher_plant_group, COUNT(DISTINCT(scrubbed_species_binomial)) AS total
                          FROM view_full_occurrence_individual
                          WHERE scrubbed_species_binomial IS NOT NULL
                          AND scrubbed_taxonomic_status = 'accepted' 
                          GROUP BY higher_plant_group
                          ORDER BY total DESC;")

  

bien_head <- BIEN:::.BIEN_sql("SELECT * FROM view_full_occurrence_individual LIMIT 1 ;")

tax_status_breakdown <- BIEN:::.BIEN_sql("SELECT scrubbed_taxonomic_status, count(*) AS total
                               FROM view_full_occurrence_individual
                              WHERE scrubbed_species_binomial IS NOT NULL
                              GROUP BY scrubbed_taxonomic_status
                              ORDER By total DESC ;")

# scrubbed_taxonomic_status     total
# 1                  Accepted 259265077
# 2                No opinion  10270675

