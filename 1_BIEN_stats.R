# Code to generate BIEN annotation statistics

library(BIEN)
library(tidyverse)

# Total number of records in view_full_occurrence_individual

total <- BIEN:::.BIEN_sql(query = "SELECT count(*)
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
# higher_plant_group  total
# 1          flowering plants 404043
# 2                bryophytes  31556
# 3          ferns and allies  20921
# 4    gymnosperms (conifers)    978
# 5                      <NA>    957
# 6 gymnosperms (non-conifer)    451
# 7                     Fungi     13
# 8                     Algae      2
# 9                  Bacteria      1


hpg_breakdown_by_spp_only_accepts <- 
  BIEN:::.BIEN_sql(query = "SELECT higher_plant_group, COUNT(DISTINCT(scrubbed_species_binomial)) AS total
                          FROM view_full_occurrence_individual
                          WHERE scrubbed_species_binomial IS NOT NULL
                          AND scrubbed_taxonomic_status = 'Accepted' 
                          GROUP BY higher_plant_group
                          ORDER BY total DESC;")

# 1          flowering plants 323377
# 2                bryophytes  26808
# 3          ferns and allies  12102
# 4    gymnosperms (conifers)    856
# 5                      <NA>    786
# 6 gymnosperms (non-conifer)    424
# 7                     Fungi     12  

bien_head <- BIEN:::.BIEN_sql("SELECT * FROM view_full_occurrence_individual LIMIT 1 ;")

tax_status_breakdown <- BIEN:::.BIEN_sql("SELECT scrubbed_taxonomic_status, count(*) AS total
                               FROM view_full_occurrence_individual
                              WHERE scrubbed_species_binomial IS NOT NULL
                              GROUP BY scrubbed_taxonomic_status
                              ORDER By total DESC ;")

# scrubbed_taxonomic_status     total
# 1                  Accepted 259265077
# 2                No opinion  10270675


# How many species have the verbatim name correct?

verbatim_correct <- BIEN:::.BIEN_sql("SELECT count(*) FROM view_full_occurrence_individual
                                     WHERE verbatim_scientific_name = scrubbed_taxon_name_no_author ;"
                              )

verbatim_correct <- BIEN:::.BIEN_sql("SELECT count(*) FROM view_full_occurrence_individual
                                     WHERE (verbatim_scientific_name = name_matched) AND
                                     verbatim_scientific_name != ;"
)



# annotation table

#geovalidation
  geovalid <- BIEN:::.BIEN_sql("SELECT is_geovalid, count(*)
                               FROM view_full_occurrence_individual
                               GROUP BY is_geovalid ;")
  
    geovalid %>%
      mutate(percent = count/sum(count))

#cultivation    
  not_cultivated <- BIEN:::.BIEN_sql("SELECT count(*) as not_cultivated
                               FROM view_full_occurrence_individual
                               WHERE ((is_cultivated_observation = 0 OR is_cultivated_observation IS NULL) AND is_location_cultivated IS NULL);")

  
  not_cultivated$not_cultivated/total$count
  ((total$count - not_cultivated)/total$count)*100
  
  
#non-native
  
  is_introduced_breakdown <- BIEN:::.BIEN_sql("SELECT is_introduced, count(*) AS total
                               FROM view_full_occurrence_individual
                              GROUP BY is_introduced
                              ORDER By total DESC ;")
  
  is_introduced_breakdown %>%
    mutate(percent = (total/sum(total))*100)
  
  74008865+28393107
  
#centroid  
  
  centroids <- BIEN:::.BIEN_sql("SELECT count(*) AS total
                               FROM view_full_occurrence_individual
                              WHERE georef_protocol='county centroid'OR is_centroid=1 ;")
  
  (centroids$total/total$count)*100
  
# taxonomy
  
  correct_names <- BIEN:::.BIEN_sql("SELECT count(*) AS total
                                    FROM view_full_occurrence_individual
                                    WHERE scrubbed_species_binomial=verbatim_scientific_name  ;")
  
  (total$count - correct_names$total)/total$count


  matched_status_breakdown <- BIEN:::.BIEN_sql("SELECT matched_taxonomic_status, count(*) AS total
                               FROM view_full_occurrence_individual
                              GROUP BY matched_taxonomic_status
                              ORDER By total DESC ;")

    matched_status_breakdown %>%
    mutate(pct = ((total/sum(total))*100) %>%
             round(digits = 2))
  
    matched_status_specimens_breakdown <- BIEN:::.BIEN_sql("SELECT matched_taxonomic_status, count(*) AS total
                               FROM view_full_occurrence_individual
                               WHERE observation_type IN ('specimen')
                              GROUP BY matched_taxonomic_status
                              ORDER By total DESC ;")
    
    

bien_head$matched_taxonomic_status
  

WHERE scrubbed_species_binomial in ( 'x' )
AND (is_cultivated_observation = 0 OR is_cultivated_observation IS NULL) AND is_location_cultivated IS NULL
AND (is_introduced=0 OR is_introduced IS NULL)
AND observation_type IN ('plot','specimen','literature','checklist')
AND is_geovalid = 1
AND higher_plant_group NOT IN ('Algae','Bacteria','Fungi')
AND (georef_protocol is NULL OR georef_protocol<>'county centroid')
AND (is_centroid IS NULL OR is_centroid=0)
AND scrubbed_species_binomial IS NOT NULL ;"


bien_head$verbatim_scientific_name
bien_head$name_submitted
bien_head$scrubbed_taxon_canonical
bien_head$scrubbed_taxon_name_with_author
bien_head$scrubbed_taxon_name_no_author
bien_head$name_matched