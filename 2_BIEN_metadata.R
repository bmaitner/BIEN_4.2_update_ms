library(BIEN)

schemas <- BIEN:::.BIEN_sql(query = "select schema_name
                 from information_schema.schemata ;")

tables <- BIEN:::.BIEN_sql(query = "SELECT * FROM pg_catalog.pg_tables;")

