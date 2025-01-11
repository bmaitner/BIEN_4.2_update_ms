library(BIEN)

# Get all of the unique datasource IDs needed for citing the occcurrence/plot records

  occ_ids <- BIEN:::.BIEN_sql("SELECT DISTINCT datasource_id
                    FROM view_full_occurrence_individual ;")

# Get all of the unique IDs needed to cite trait datasets

  trait_ids <- BIEN:::.BIEN_sql("SELECT DISTINCT id
                    FROM agg_traits ;",
                                fetch.query=FALSE)

# Feed the traits into the citation function

  full_citations <- BIEN_metadata_citation(dataframe = occ_ids,
                                           trait.dataframe = trait_ids,
                                           bibtex_file = "citations/BIEN_42_citations.bib",
                                           acknowledgement_file = "citations/BIEN_42_acknowledgements.txt")
