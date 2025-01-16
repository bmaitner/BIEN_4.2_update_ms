library(BIEN)

# Get all of the unique datasource IDs needed for citing the occurrence/plot records

  occ_ids <- BIEN:::.BIEN_sql("SELECT DISTINCT datasource_id
                    FROM view_full_occurrence_individual ;")

# Get all of the unique IDs needed to cite trait datasets

  trait_ids <- BIEN:::.BIEN_sql("SELECT DISTINCT id
                    FROM agg_traits ;",
                                fetch.query=FALSE)

# Feed the IDs into the citation function

  full_citations <- BIEN_metadata_citation(dataframe = occ_ids,
                                           trait.dataframe = trait_ids,
                                           bibtex_file = "citations/BIEN_42_citations.bib",
                                           acknowledgement_file = "citations/BIEN_42_acknowledgements.txt")

# Trait only data citations
  
  trait_citations <- BIEN_metadata_citation(trait.dataframe = trait_ids,
                                           bibtex_file = "citations/BIEN_42_trait_citations.bib")
  
# Non-trait data citations
  
  

# Total number of herbaria included? #804
  
  datasources <- occ_ids$datasource_id %>% na.omit()
  
  query<-paste("WITH a AS (SELECT * FROM datasource where datasource_id in (", paste(shQuote(datasources, type = "sh"),collapse = ', '),")) 
                 SELECT * FROM datasource where datasource_id in (SELECT proximate_provider_datasource_id FROM a) OR datasource_id in (SELECT datasource_id FROM a) ;")
  
  sources <- BIEN:::.BIEN_sql(query,fetch.query = FALSE)

  sources %>%
    filter(sources$is_herbarium==1)%>%
    select(source_name)%>%
    unique()%>%nrow()
  

