library(tidyverse)

source("code/utils.R")

orbis <- read_csv(gzfile("raw_data/orbis_wrds_de.csv.gz")) %>%
  mutate(link_name = clean_firm_name(name_native))

insol_names <- read_csv("data/matched_names_clean.csv") %>%
  select(insol_name) %>%
  mutate(insolvent = TRUE)

ff12 <- readRDS("raw_data/ff_12_ind.RDS")

raw_smp <- orbis %>%
  left_join(insol_names, by = c("link_name" = "insol_name"))

raw_smp$insolvent[is.na(raw_smp$insolvent)] <- FALSE

dup_matches <- raw_smp %>% 
  group_by(bvdid) %>%
  filter(insolvent, year == max(year)) %>%
  group_by(link_name) %>%
  filter(n() > 1) %>%
  arrange(link_name, bvdid)

length(unique(dup_matches$link_name))

# We have 23 non-unique link names. Need to be excluded from the cross-sectional
# sample.

# The cross-sectional sample will contain the 
# last 2010+ year with accounting data,

smp <- raw_smp %>%
  filter(insolvent | status_str == "Active") %>%
  group_by(bvdid) %>%
  arrange(bvdid, year) %>%
  mutate(
    ln_toas = log(toas),
    ln_opre = log(opre),
    ln_empl = log(empl),
    fias_ta = fias/toas,
    cuas_ta = cuas/toas,
    cash_ta = cash/toas,
    eqr = shfd/toas,
    loan_ta = loan/toas,
    culi_ta = culi/toas,
    cred_ta = cred/toas,
    opre_aveta = opre/(0.5*(toas + lag(toas))),
    pl_aveta = pl/(0.5*(toas + lag(toas))),
    fipl_aveta = fipl/(0.5*(toas + lag(toas)))
  ) %>%
  filter(year == max(year)) %>%
  group_by(link_name) %>%
  filter(!insolvent | n() == 1) %>%
  ungroup() %>%
  mutate(sic = as.character(ussicpcod)) %>%
  left_join(ff12, by = "sic") %>%
  select(
    bvdid, year, name_native, insolvent,
    major_sector, ff12ind_desc,
    legalfrm, indepind, listed, conscode, 
    filing_type, accpractice, audstatus, source,
    toas, opre, empl,
    ln_toas, ln_opre, ln_empl, 
    fias_ta, cuas_ta, cash_ta, eqr, loan_ta, cred_ta, culi_ta, 
    opre_aveta, pl_aveta, fipl_aveta
  )

# Check for duplicates - there should be none
anyDuplicated(smp$bvdid) == 0

addmargins(table(smp$year, smp$insolvent), 1:2)

write_csv(smp, "data/cross_sectional_sample.csv")  
