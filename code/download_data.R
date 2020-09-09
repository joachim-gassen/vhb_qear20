# ------------------------------------------------------------------------------
# Code to download the data used for the class project
# You won't be able to run the code without access to WRDS/Orbis and
# the database server of TRR 266. It is included here for documentation
# purposes.
# ------------------------------------------------------------------------------
# Joachim Gassen, gassen@wiwi.hu-berlin.de
# MIT Licence, see LICENSE file for details
# ------------------------------------------------------------------------------

library(tidyverse)
library(RMySQL)
library(RPostgres)


# ------------------------------------------------------------------------------
# The insolvency filing data has been scraped from the official filings at:
# # https://www.insolvenzbekanntmachungen.de
# You can find further information on German insolvencies from the Statistische
# Bundesamt: 
# https://www.destatis.de/DE/Themen/Branchen-Unternehmen/Unternehmen/Gewerbemeldungen-Insolvenzen/_inhalt.html
# ------------------------------------------------------------------------------

# To run this code you need the file below containing the access data
# (and you won't - sorry ;-))

if (!file.exists("host_access_keys.csv")) stop(paste(
  "Sourcing 'download_data.R' requires you to have acces to WRDS/Orbis",
  "and the database server of TRR 266. If you are enrolled to the VHB",
  "ProDok course, you have received the link to the Orbis data by email.",
  "Please copy the data file your 'raw_data' directory. Then sourcing this",
  "file is no longer necessary."
))

hk <- read_csv("host_access_keys.csv", col_types = cols())

# Need to be inside Humboldt VPN to access mysql server
con <- dbConnect(
  MySQL(),
  user = hk %>% filter(host == "trr266") %>% pull(user),
  host = "trr266.wiwi.hu-berlin.de",
  port = 3306,
  password = hk %>% filter(host == "trr266") %>% pull(password),
  db = "insol_de"
)

dbSendQuery(con, 'set character set "utf8mb4"')
df <- dbReadTable(con, "_insol_proceedings_parsed")
dbDisconnect(con)

data_for_course <- df %>%
  select(
    date, insolvency_court, court_file_number, subject, 
    name_debtor, domicile_debtor
  ) %>% arrange(date, insolvency_court, court_file_number, subject)

write_csv(data_for_course, "raw_data/insolvency_filings_de_julaug2020.csv")

wrds <- dbConnect(
  Postgres(),
  host = 'wrds-pgdata.wharton.upenn.edu',
  port = 9737,
  dbname = 'wrds',
  sslmode = 'require',
  user = hk %>% filter(host == "wrds") %>% pull(user),
  password = hk %>% filter(host == "wrds") %>% pull(password)
)

dload_orbis_data <- function(ctries, size) {
  contact_info <- tbl(wrds, sprintf('ob_contact_info_%s', size))
  legal_info <- tbl(wrds, sprintf('ob_legal_info_%s', size))
  ind_g <- tbl(wrds, sprintf('ob_ind_g_fins_eur_%s', size))
  basic_sholder_info <- tbl(wrds, sprintf('ob_basic_shareholder_info_%s', size))
  ind_class <- tbl(wrds, sprintf('ob_industry_classifications_%s', size))
  
  message(sprintf(
    "%s: Pulling data for size group '%s' of %s",
    Sys.time(), size, paste(ctries, collapse = ", ")
  ))

  message(sprintf("%s: Pulling contact info data...", Sys.time()), appendLF = FALSE)
  ci <- contact_info %>%
    select(
      ctryiso, bvdid, name_internat, name_native
    ) %>%
    filter(ctryiso %in% ctries) %>%
    collect()
  message(
    sprintf("done (%s obs)", format(nrow(ci), big.mark = ","))
  )

  
  message(sprintf("%s: Pulling legal info data...", Sys.time()), appendLF = FALSE)
  li <- legal_info %>%
    select(
      ctryiso, bvdid, category_of_company, dateinc, historic_statusdate,
      historic_status_str, legalfrm, listed
    ) %>%
    filter(ctryiso %in% ctries) %>%
    collect()
  message(
    sprintf("done (%s obs)", format(nrow(li), big.mark = ","))
  )
  
  # The below is complicated as WRDS has duplicate observations up to 
  # all selected columns being equal
  
  message(sprintf("%s: Pulling financial data...", Sys.time()), appendLF = FALSE)
  ig <- ind_g %>%
    filter(
      ctryiso %in% ctries,
      toas > 0,
      nr_months == "12",
    ) %>%
    mutate(year = year(closdate)) %>%
    select(
      ctryiso, bvdid, year, closdate, conscode, filing_type, accpractice, 
      audstatus, source, category_of_company, 
      fias, cuas, stok, debt, ocas, cash, toas, 
      shfd, ncli, culi, loan, cred, ocli, tshf,
      empl, 
      opre, turn, cost, fipl, taxa, exex, pl
    ) %>% 
    mutate(
      cc_rank = if_else(conscode == "C1", 4,
                        ifelse(conscode == "C2", 3,
                               ifelse(conscode == "U1", 2, 1))),
      ft_rank = ifelse(filing_type == "Annual report", 2, 1)
    ) %>% 
    group_by(bvdid, closdate) %>%
    filter(cc_rank == max(cc_rank, na.rm = TRUE)) %>%
    filter(ft_rank == max(ft_rank, na.rm = TRUE)) %>%
    group_by(bvdid, year) %>%
    filter(cc_rank == max(cc_rank, na.rm = TRUE)) %>%
    filter(closdate == max(closdate, na.rm = TRUE)) %>%
    select(-cc_rank, -ft_rank) %>%
    collect()
  
  message(
    sprintf("done (%s obs)", format(nrow(ig), big.mark = ","))
  )
  dups <- ig %>% filter(n() > 1)
  if (nrow(dups) > 0) {
    message(sprintf(
      paste(
        "%s: %s firm-year duplicates found,", 
        "using the ones with fewer missing values."
      ), Sys.time(), format(nrow(dups), big.mark = ",")
    ))
    ig$nas <- rowSums(is.na(ig))
    ig <- ig %>% 
      filter(nas == min(nas, na.rm = TRUE)) %>%
      select(-nas)
    
    dups <- ig %>% filter(n() > 1)
    if (nrow(dups) > 0) {
      message(sprintf(
        paste(
          "%s: After this, still %s firm-year duplicates found,", 
          "taking the first observation of each group (sigh...)."
        ), Sys.time(), format(nrow(dups), big.mark = ",")
      ))
      ig <- ig %>% 
        distinct(bvdid, year, .keep_all = TRUE)
      message(sprintf(
        "%s: Done (%s obs)", 
        Sys.time(), format(nrow(ig), big.mark = ",")
      ))
    } else  message(sprintf(
      "%s: Done (%s obs)", 
      Sys.time(), format(nrow(ig), big.mark = ",")
    ))
  } else message(sprintf("%s: No firm year duplicates found!", Sys.time()))
  
  message(sprintf("%s: Pulling independence data...", Sys.time()), appendLF = FALSE)
  bsi <- basic_sholder_info %>%
    select(bvdid, ctryiso, `_9427`) %>%
    rename(indepind = `_9427`) %>%
    filter(
      ctryiso %in% ctries
    ) %>%
    collect()
  message(
    sprintf("done (%s obs)", format(nrow(bsi), big.mark = ","))
  )
  
  stopifnot(length(unique(li$bvdid)) == nrow(li))
  # TRUE: No historical statuses present in WRDS

  # Industry classification provides multiple SIC codes for some firms. Using
  # only the first one.
  message(sprintf("%s: Pulling industry classification data...", Sys.time()), appendLF = FALSE)
  ic_s <- ind_class %>%
    select(
      bvdid, ctryiso, major_sector, nace2_main_section, naceccod2, ussicpcod
    ) %>%
    filter(
      ctryiso %in% ctries,
      !is.na(major_sector)
    ) %>%
    collect()
  message(
    sprintf("done (%s obs)", format(nrow(ic), big.mark = ","))
  )
  
  message(sprintf("%s: Merging data...", Sys.time()), appendLF = FALSE)
  panel <- ig %>% left_join(bsi, by = c("ctryiso", "bvdid")) %>%
    left_join(ci, by = c("ctryiso", "bvdid")) %>%
    left_join(
      li %>% select(ctryiso, bvdid, historic_status_str, legalfrm, listed), 
      by = c("ctryiso", "bvdid")
    ) %>%
    left_join(ic, by = c("ctryiso", "bvdid")) %>%
    rename(status_str = historic_status_str) %>%
    mutate(year = lubridate::year(closdate)) %>%
    select(
      ctryiso, bvdid, name_internat, name_native,
      major_sector, nace2_main_section, naceccod2, ussicpcod,
      category_of_company, status_str, legalfrm, indepind, listed,
      year, closdate, conscode, filing_type, accpractice, audstatus, source,
      fias, cuas, stok, debt, ocas, cash, toas, 
      shfd, ncli, culi, loan, cred, ocli, tshf,
      empl, 
      opre, turn, cost, fipl, taxa, exex, pl
    ) %>%
    arrange(ctryiso, bvdid, year)
  
  message(
    sprintf("done (%s obs)", format(nrow(panel), big.mark = ","))
  )
  
  stopifnot(nrow(panel %>% select(bvdid, year) %>% distinct()) == nrow(panel))
  
  panel
}

for (size in c("l", "m", "s")) {
  panel <- dload_orbis_data("DE", size)
  saveRDS(panel, sprintf("raw_data/orbis_wrds_de_%s.rds", size))
}

dbDisconnect(wrds)  

df <- rbind(
  readRDS("raw_data/orbis_wrds_de_l.rds"),
  readRDS("raw_data/orbis_wrds_de_m.rds"),
  readRDS("raw_data/orbis_wrds_de_s.rds")
) %>% arrange(bvdid, year)

write.csv(df, file = gzfile("raw_data/orbis_wrds_de.csv.gz"))
