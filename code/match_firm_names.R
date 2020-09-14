library(tidyverse)
library(stringdist)

source("code/utils.R")

orbis <- read_csv(gzfile("raw_data/orbis_wrds_de.csv.gz"))
insol_fin <- read_csv("raw_data/insolvency_filings_de_julaug2020.csv")

insol_names <- insol_fin %>% 
  filter(subject == "Eröffnungen") %>%
  select(name_debtor) %>% 
  distinct() %>%
  pull() %>%
  clean_firm_name() %>%
  unique()

orbis_names <- orbis %>%
  select(name_native) %>%
  distinct %>%
  pull() %>%
  clean_firm_name() %>%
  unique()

names_dist <- stringdistmatrix(insol_names, orbis_names)

min_name_dist <- apply(names_dist, 1, min)

return_machted_by_row <- function(i) {
  orbis_names_row <- which(names_dist[i,] %in% min_name_dist[i])
  tibble( 
    insol_names_row = i, 
    insol_name = insol_names[i],
    orbis_names_row = orbis_names_row,
    orbis_name = orbis_names[orbis_names_row],
    stringdist = min_name_dist[i]
  )
}

matched_names <- do.call(rbind, lapply(1:length(insol_names), return_machted_by_row))

matched_names %>% 
  group_by(insol_names_row) %>%
  filter(n() > 1) %>%
  filter(stringdist == 0)


hand_check <- matched_names %>%
  group_by(insol_names_row) %>%
  filter(n() == 1) %>%
  filter(stringdist <= 2) %>%
  ungroup()

clean_match <- matched_names %>%
  group_by(insol_names_row) %>%
  filter(n() == 1) %>%
  filter(stringdist == 0) %>%
  ungroup()

write_csv(hand_check, "data/matched_names_hand_check.csv")
write_csv(clean_match, "data/matched_names_clean.csv")
