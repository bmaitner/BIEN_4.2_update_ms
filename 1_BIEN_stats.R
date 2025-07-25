# Code to generate BIEN annotation statistics

library(BIEN)
library(tidyverse)

# Total number of records in view_full_occurrence_individual

  total <- BIEN:::.BIEN_sql(query = "SELECT count(*)
                            FROM view_full_occurrence_individual ;")

  #284466171 # Total number of records in vfoi


# Total of different observation types

  occurrence_type_breakdown <- 
  BIEN:::.BIEN_sql(query = "SELECT observation_type, COUNT(*) AS total
                            FROM view_full_occurrence_individual
                            GROUP BY observation_type
                            ORDER BY total DESC;")
  
  # observation_type     total
  # 1     human observation 153551098
  # 2              specimen  73927842
  # 3      trait occurrence  23032859
  # 4                  plot  17247823
  # 5               unknown  14732054
  # 6  checklist occurrence   1132361
  # 7            literature    492180
  # 8            occurrence    192280
  # 9       material sample    137133
  # 10      plot occurrence     20541


# Total number of trait observations
  BIEN:::.BIEN_sql(query = "SELECT COUNT(*)
                            FROM agg_traits ;")

  #25932628

#Total number of plots

  plot_md <- BIEN_plot_metadata()
  length(unique(plot_md$plot_name)) #363258

# Total number of ranges
  nrow(BIEN_ranges_list()) #98829 in species/maps in BIEN
  
  OpenRange:::ranges_sql("Select COUNT(*) from ranges.range;")  #289743 maps in Open Range
  OpenRange:::ranges_sql("Select COUNT(DISTINCT(species)) from ranges.range;") #112953 species in Open Range
  
# Number of records by hpg
  
  hpg_breakdown <- 
      BIEN:::.BIEN_sql(query = "SELECT higher_plant_group, COUNT(*) AS total
                            FROM view_full_occurrence_individual
                            GROUP BY higher_plant_group
                            ORDER BY total DESC;")
  
  # higher_plant_group     total
  # 1          flowering plants 241587178
  # 2    gymnosperms (conifers)  18936243
  # 3                bryophytes  11015217
  # 4          ferns and allies   8823896
  # 5                      <NA>   4010480
  # 6 gymnosperms (non-conifer)     92735
  # 7                     Fungi       415
  # 8                     Algae         5
  # 9                  Bacteria         2

# Number of species per hpg

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

  
# Taxonomic status
  
  tax_status_breakdown <- BIEN:::.BIEN_sql("SELECT scrubbed_taxonomic_status, count(*) AS total
                                 FROM view_full_occurrence_individual
                                WHERE scrubbed_species_binomial IS NOT NULL
                                GROUP BY scrubbed_taxonomic_status
                                ORDER By total DESC ;")
  
  # scrubbed_taxonomic_status     total
  # 1                  Accepted 259265077
  # 2                No opinion  10270675
  
  tax_status_breakdownv2 <- BIEN:::.BIEN_sql("SELECT scrubbed_taxonomic_status, count(*) AS total
                                 FROM view_full_occurrence_individual
                                GROUP BY scrubbed_taxonomic_status
                                ORDER By total DESC ;")
  
  #   scrubbed_taxonomic_status     total
  # 1                  Accepted 269912633
  # 2                No opinion  10912712
  # 3                      <NA>   3640826
  
  tax_status_breakdown %>%
    rename(count=total)%>%
    mutate(pct = round((count/total$count)*100,digits = 3))
  
  # scrubbed_taxonomic_status     count    pct
  # 1                  Accepted 269912633 94.884
  # 2                No opinion  10912712  3.836
  # 3                      <NA>   3640826  1.280

  #total number failing names =
    # (assuming accepted is good) 100-94.884 =5.116
    # total$count-269912633 =14553538
  # (assuming accepted or no opinion is good) = 1.280
  # total$count-269912633 = 3640826
  
  
  
# annotation table

# geovalidation

  geovalid <- BIEN:::.BIEN_sql("SELECT is_geovalid, count(*)
                               FROM view_full_occurrence_individual
                               GROUP BY is_geovalid ;")
  
    geovalid %>%
      mutate(percent = count/sum(count)*100)
    
    # is_geovalid     count percent
    # 1           0  62510599 21.9747
    # 2           1 221955572 78.0253
    
# cultivation    
  not_cultivated <- BIEN:::.BIEN_sql("SELECT count(*) as not_cultivated
                               FROM view_full_occurrence_individual
                               WHERE ((is_cultivated_observation = 0 OR is_cultivated_observation IS NULL) AND is_location_cultivated IS NULL);")

  #280877632 not cultivated, 3,588,539 cultivated
  not_cultivated$not_cultivated/total$count #0.987385
  ((total$count - not_cultivated)/total$count)*100 #1.26% cultivated
  
  
# non-native
  
  is_introduced_breakdown <- BIEN:::.BIEN_sql("SELECT is_introduced, count(*) AS total
                               FROM view_full_occurrence_individual
                              GROUP BY is_introduced
                              ORDER By total DESC ;")
  
  is_introduced_breakdown %>%
    mutate(percent = (total/sum(total))*100)
  
  # is_introduced     total   percent
  # 1             0 182064199 64.002056
  # 2             1  74008865 26.016754
  # 3            NA  28393107  9.981189
  

#centroid  
  
  centroids <- BIEN:::.BIEN_sql("SELECT count(*) AS total
                               FROM view_full_occurrence_individual
                              WHERE georef_protocol='county centroid'OR is_centroid=1 ;")
  
  (centroids$total/total$count)*100 # 861945 records,0.3030044%, are likely centroids

# taxonomy

  
  correct_names <- BIEN:::.BIEN_sql("SELECT count(*) AS total
                                    FROM view_full_occurrence_individual
                                    WHERE tnrs_name_matched_score=1
                                    AND matched_taxonomic_status = 'Accepted' ;")

  #190301322 names correct (assuming accepted = correct)
  total$count - correct_names$total
  #94164849 names incorrect

  (correct_names$total/total$count)*100 #66.90% are definitely correct,33.10% wrong
  (1-correct_names$total/total$count)*100
  
  possibly_correct_names <- BIEN:::.BIEN_sql("SELECT count(*) AS total
                                    FROM view_full_occurrence_individual
                                    WHERE tnrs_name_matched_score=1
                                    AND matched_taxonomic_status IN ('Accepted','No opinion') ;")

  #197188752 names possibly correct (assuming accepted or no opinion = correct)
  #87277419 names possibly wrong
  (possibly_correct_names$total/total$count)*100 # 69.32% are possibly correct,30.68% wrong
  (1-possibly_correct_names$total/total$count)*100
  total$count - possibly_correct_names$total
  

  matched_status_breakdown <- BIEN:::.BIEN_sql("SELECT matched_taxonomic_status, count(*) AS total
                               FROM view_full_occurrence_individual
                              GROUP BY matched_taxonomic_status
                              ORDER By total DESC ;")

    matched_status_breakdown %>%
    mutate(pct = ((total/sum(total))*100) %>%
             round(digits = 2))
    
    # matched_taxonomic_status     total   pct
    # 1                 Accepted 255489665 89.81
    # 2                  Synonym  14420777  5.07
    # 3               No opinion  10912712  3.84
    # 4                     <NA>   3640826  1.28
    # 5                  Invalid      2168  0.00
    # 6             Illegitimate        23  0.00
  
    matched_status_specimens_breakdown <- BIEN:::.BIEN_sql("SELECT matched_taxonomic_status, count(*) AS total
                               FROM view_full_occurrence_individual
                               WHERE observation_type IN ('specimen')
                              GROUP BY matched_taxonomic_status
                              ORDER By total DESC ;")
    
    

bien_head$matched_taxonomic_status
  

# WHERE scrubbed_species_binomial in ( 'x' )
# AND (is_cultivated_observation = 0 OR is_cultivated_observation IS NULL) AND is_location_cultivated IS NULL
# AND (is_introduced=0 OR is_introduced IS NULL)
# AND observation_type IN ('plot','specimen','literature','checklist')
# AND is_geovalid = 1
# AND higher_plant_group NOT IN ('Algae','Bacteria','Fungi')
# AND (georef_protocol is NULL OR georef_protocol<>'county centroid')
# AND (is_centroid IS NULL OR is_centroid=0)
# AND scrubbed_species_binomial IS NOT NULL ;"


bien_head$verbatim_scientific_name
bien_head$name_submitted
bien_head$scrubbed_taxon_canonical
bien_head$scrubbed_taxon_name_with_author
bien_head$scrubbed_taxon_name_no_author
bien_head$name_matched

###################

# Cumulative errors

cumul_0_liberal <- BIEN:::.BIEN_sql("SELECT count(*) AS total
                               FROM view_full_occurrence_individual ;")

cumul_1_liberal <- BIEN:::.BIEN_sql("SELECT count(*) AS total
                               FROM view_full_occurrence_individual
                              WHERE (is_introduced=0 OR is_introduced IS NULL) ;")

cumul_2_liberal <- BIEN:::.BIEN_sql("SELECT count(*) AS total
                               FROM view_full_occurrence_individual
                              WHERE (is_introduced=0 OR is_introduced IS NULL)
                              AND scrubbed_taxonomic_status IN ('Accepted','No opinion') ;")

cumul_3_liberal <- BIEN:::.BIEN_sql("SELECT count(*) AS total
                              FROM view_full_occurrence_individual
                              WHERE (is_introduced=0 OR is_introduced IS NULL)
                              AND scrubbed_taxonomic_status IN ('Accepted','No opinion')
                              AND is_geovalid=1;")

cumul_4_liberal <- BIEN:::.BIEN_sql("SELECT count(*) AS total
                              FROM view_full_occurrence_individual
                              WHERE (is_introduced=0 OR is_introduced IS NULL)
                              AND scrubbed_taxonomic_status IN ('Accepted','No opinion')
                              AND is_geovalid=1
                              AND (is_cultivated_observation = 0 OR
                              is_cultivated_observation IS NULL)
                                    AND is_location_cultivated IS NULL;")

cumul_5_liberal <- BIEN:::.BIEN_sql("SELECT count(*) AS total
                              FROM view_full_occurrence_individual
                              WHERE (is_introduced=0 OR is_introduced IS NULL)
                              AND scrubbed_taxonomic_status IN ('Accepted','No opinion')
                              AND is_geovalid=1
                              AND (is_cultivated_observation = 0 OR
                                    is_cultivated_observation IS NULL)
                                    AND is_location_cultivated IS NULL
                              AND (georef_protocol is NULL OR georef_protocol<>'county centroid')
                              AND (is_centroid IS NULL OR is_centroid=0);")


cumul_1_conservative <- BIEN:::.BIEN_sql("SELECT count(*) AS total
                               FROM view_full_occurrence_individual
                              WHERE (is_introduced=0) ;")


cumul_2_conservative <- BIEN:::.BIEN_sql("SELECT count(*) AS total
                               FROM view_full_occurrence_individual
                              WHERE (is_introduced=0)
                              AND scrubbed_taxonomic_status IN ('Accepted') ;")

cumul_3_conservative <- BIEN:::.BIEN_sql("SELECT count(*) AS total
                               FROM view_full_occurrence_individual
                              WHERE (is_introduced=0)
                              AND scrubbed_taxonomic_status IN ('Accepted')
                              AND is_geovalid=1 ;")

cumul_4_conservative <- BIEN:::.BIEN_sql("SELECT count(*) AS total
                               FROM view_full_occurrence_individual
                              WHERE (is_introduced=0)
                              AND scrubbed_taxonomic_status IN ('Accepted')
                              AND is_geovalid=1
                              AND (is_cultivated_observation = 0 OR
                              is_cultivated_observation IS NULL)
                                         AND is_location_cultivated IS NULL ; ")


cumul_5_conservative <- BIEN:::.BIEN_sql("SELECT count(*) AS total
                               FROM view_full_occurrence_individual
                              WHERE (is_introduced=0)
                              AND scrubbed_taxonomic_status IN ('Accepted')
                              AND is_geovalid=1
                              AND (is_cultivated_observation = 0 OR
                              is_cultivated_observation IS NULL)
                              AND is_location_cultivated IS NULL
                              AND (georef_protocol is NULL OR georef_protocol<>'county centroid')
                              AND (is_centroid IS NULL OR is_centroid=0)  ; ")

# put the stuff together

cleaning_step_counts <-

bind_rows(
data.frame(step = "All Records",
           threshold = "Liberal",
           n_records = cumul_0_liberal),

data.frame(step = "Natives Only",
           threshold = "Liberal",
           n_records = cumul_1_liberal),

data.frame(step = "Validated Names",
           threshold = "Liberal",
           n_records = cumul_2_liberal),

data.frame(step = "Geovalidated",
           threshold = "Liberal",
           n_records = cumul_3_liberal),

data.frame(step = "Exclude Cultivated",
           threshold = "Liberal",
           n_records = cumul_4_liberal),

data.frame(step = "Exclude Centroids",
           threshold = "Liberal",
           n_records = cumul_5_liberal),

data.frame(step = "All Records",
           threshold = "Conservative",
           n_records = cumul_0_liberal),

data.frame(step = "Natives Only",
           threshold = "Conservative",
           n_records = cumul_1_conservative),

data.frame(step = "Validated Names",
           threshold = "Conservative",
           n_records = cumul_2_conservative),

data.frame(step = "Geovalidated",
           threshold = "Conservative",
           n_records = cumul_3_conservative),

data.frame(step = "Exclude Cultivated",
           threshold = "Conservative",
           n_records = cumul_4_conservative),

data.frame(step = "Exclude Centroids",
           threshold = "Conservative",
           n_records = cumul_5_conservative),

)

library(ggplot2)


cleaning_plot <-
cleaning_step_counts %>%
  rename(Occurrences = total)%>%
  rename(Threshold = threshold) %>%
  mutate(Step = factor(step,
                       levels = c("All Records",
                                  "Natives Only",
                                  "Validated Names",
                                  "Geovalidated",
                                  "Exclude Cultivated",
                                  "Exclude Centroids" )))%>%
  # mutate(Threshold = factor(Threshold,
  #                      levels = c("Liberal","Conservative")))%>%
  mutate(Occurrences = Occurrences/1000000 ) %>%
  ggplot(mapping = aes(y=Step,
                       x=Occurrences,
                       fill=Threshold))+
  geom_bar(stat="identity",
           position=position_dodge(),
           #position = "identity",
           alpha=0.5)+
  scale_y_discrete(limits=rev)+
  scale_x_continuous(breaks = c(0,50,100,150,200,250,300),
                     limits = c(0,300),expand = c(0,0))+
  xlab("Occurrences (Millions)")+
  theme_bw()+
  scale_fill_manual(values=c("Liberal" = "blue",
                      "Conservative" = "lightblue"),
                    breaks=c("Liberal","Conservative"))


ggsave(filename = "figures/cumulative_cleaning.jpg",
       width = 10,
       height = 5,
       units = "in",
       dpi = 600)


ggsave(filename = "figures/cumulative_cleaning.png",
       width = 10,
       height = 5,
       units = "in",
       dpi = 600)


###################

# what fraction of of occurrence record have TNRS score of 1 and with
# no flags of Geovalidation  and Centroid?
  

correct_names_geovalid_and_not_centroid <-
  BIEN:::.BIEN_sql("SELECT count(*) AS total
  FROM view_full_occurrence_individual
  WHERE tnrs_name_matched_score=1
    AND scrubbed_taxonomic_status = 'Accepted'
    AND is_geovalid=1
    AND (georef_protocol is NULL OR georef_protocol<>'county centroid')
    AND (is_centroid IS NULL OR is_centroid=0) ;") #159,189,390


correct_names_geovalid_and_not_centroid$total/total$count #0.5596075

###################

# How many unique names are in BIEN?

BIEN:::.BIEN_sql("SELECT count( DISTINCT(verbatim_scientific_name)) AS total_names
  FROM view_full_occurrence_individual ;") #1323320


###################

traits <- BIEN::BIEN_trait_list() #54 traits


trait_obs <- BIEN:::.BIEN_sql("SELECT count(*) FROM agg_traits ;")#


trait_obs <- BIEN:::.BIEN_sql("SELECT count(*)
FROM agg_traits
WHERE trait_value IS NOT NULL
AND trait_name IS NOT NULL ;") #25 932 454

trait_counts <-
  BIEN:::.BIEN_sql(query = "SELECT DISTINCT trait_name,count(*)
                          FROM agg_traits
                          WHERE trait_name IS NOT NULL 
                          GROUP BY trait_name ;")

write.csv(x = trait_counts,
          file = "tables/trait_counts.csv",
          row.names = FALSE)

######################

# Calculating cleaning impacts per commonness of rarity paper

#"Calculating the total number of observation records before cleaning and standardization in both specimen data and plot data (i.e. data that have not passed through steps 1-4 in Fig. 1):

# count specimen data: 73,927,842

BIEN:::.BIEN_sql("SELECT COUNT(observation_type)
FROM view_full_occurrence_individual
WHERE observation_type IN ('specimen');")



# count plot records: 17,247,823

BIEN:::.BIEN_sql("SELECT COUNT(observation_type)
FROM view_full_occurrence_individual
WHERE observation_type IN ('plot')")


# Calculating the total number of records after BIEN standardization, validation and cleaning workflow (data that have passed through steps 1-4 in Fig. 1).

# count clean specimen data: 17,177,250

BIEN:::.BIEN_sql("SELECT COUNT(observation_type)
FROM view_full_occurrence_individual
WHERE scrubbed_species_binomial IS NOT NULL
AND higher_plant_group NOT IN ('Algae','Bacteria','Fungi')
AND (is_introduced = 0 OR is_introduced IS NULL)
AND (is_cultivated_observation = 0 OR is_cultivated_observation IS NULL)
AND is_location_cultivated IS NULL
AND is_geovalid=1
AND observation_type IN ('specimen');")

# count plot data: clean 13,386,568

BIEN:::.BIEN_sql("SELECT COUNT(observation_type)
FROM view_full_occurrence_individual
WHERE scrubbed_species_binomial IS NOT NULL
AND higher_plant_group NOT IN ('Algae','Bacteria','Fungi')
AND (is_introduced = 0 OR is_introduced IS NULL)
AND (is_cultivated_observation = 0 OR is_cultivated_observation IS NULL)
AND is_location_cultivated IS NULL
AND is_geovalid=1
AND observation_type IN ('plot');")

#Note: the sum of those two numbers"


############################################

# BIEN occurrence records that pass minimal cleaning


BIEN_occs <- BIEN:::.BIEN_sql("SELECT longitude, latitude 
                              FROM view_full_occurrence_individual
                              WHERE scrubbed_taxonomic_status IN ('Accepted','No opinion')
                              AND is_geovalid=1
                              AND (georef_protocol is NULL OR georef_protocol<>'county centroid')
                              AND (is_centroid IS NULL OR is_centroid=0);",
                              fetch.query=FALSE)


# BIEN plot locations


plot_md <- BIEN::BIEN_plot_metadata(fetch.query=FALSE)

###############################################

# GNRS 

# How many records initially have valid country information? #44,705,332

  countries_initially_correct <- BIEN:::.BIEN_sql("SELECT COUNT(country) as total
                   FROM view_full_occurrence_individual
                   WHERE country_verbatim = country
                   AND country_verbatim IS NOT NULL ;")

  round((countries_initially_correct$total/total$count)*100,3) #15.716%

# How many records have valid country information after cleaning? #269,434,901

  countries_correct_after_cleaning <- BIEN:::.BIEN_sql("SELECT COUNT(country) as total
                   FROM view_full_occurrence_individual
                   WHERE country IS NOT NULL ;")
  
  round((countries_correct_after_cleaning$total/total$count)*100,3) #94.716%

# How many records have country information? #269,434,901

  countries_with_info <- BIEN:::.BIEN_sql("SELECT COUNT(country) as total
                   FROM view_full_occurrence_individual
                   WHERE country_verbatim IS NOT NULL;")
  
  
# Country breakdown
country_breakdown <- 
    BIEN:::.BIEN_sql(query = "SELECT country, count(*) AS total
                            FROM view_full_occurrence_individual
                            GROUP BY country
                            ORDER BY total DESC;")
#########################################

# Count of observations from trait data that didn't come from plot data?

trait_obs_count <- 
  BIEN:::.BIEN_sql(query = "SELECT COUNT(*)
                            FROM agg_traits 
                          WHERE plant_trait_files != 'analytical_stem'
                          AND latitude IS NOT NULL
                          AND longitude IS NOT NULL ;")







trait_head$plant_trait_files



