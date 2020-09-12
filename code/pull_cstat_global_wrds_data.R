# VHB QEAR 20 - Joachim Gassen
# See LICENSE File for details

# Pulls daily price data and accounting data from WRDS/Compustat Global
# Calculates monthly returns based on daily price data


library(tidyverse)
library(RPostgres)
library(lubridate)

if (!file.exists("host_access_keys.csv")) stop(paste(
  "Sourcing this file requires you to have acces to WRDS/Compustat Global.",
  "Your WRDS credentials need to be stored in a CSV file with the",
  "name 'host_access_keys.csv' in the project's root directory.",
  "the CSV file has to contain the fields 'host' (value: 'wrds'), 'user' and",
  "'password'. The file name is included in '.gitignore' so that the file is",
  "not commited automatically."
))


connect_wrds <- function(user, password) {
  dbConnect(
    Postgres(),
    host = 'wrds-pgdata.wharton.upenn.edu',
    port = 9737,
    dbname = 'wrds',
    sslmode = 'require',
    user = user,
    password = password
  )
}

pull_daily_price_cstat_global <- function(iso3c = "DEU") {  
  message(
    sprintf("%s: Pulling CS Global price data for primary listings... ", Sys.time())
  )
  csec <- tbl(wrds, "g_company") %>%
    filter(loc == iso3c, !is.na(prirow)) %>%
    select(gvkey, prirow) %>% 
    rename(iid = prirow) 
  
  secd <- tbl(wrds, "g_secd") %>%
    filter(loc == "DEU") %>%
    select(datadate, gvkey, iid, isin, prccd, split, div) 

  daily_price_cstat_global <- csec  %>%
    left_join(secd, by = c("gvkey", "iid")) %>%
    select(-iid) %>%
    arrange(gvkey, datadate) %>%
    collect()
  
  message(sprintf("%s: done", Sys.time()))
  
  daily_price_cstat_global
}

calc_monthly_returns <- function(df) {
  adj_prc <- df %>%
    group_by(gvkey) %>%
    mutate(
      split = ifelse(is.na(split), 1, split),
      split = ifelse(is.na(split), 1, split),
      cumsplit = cumprod(split),
      adj_factor = cumsplit/max(cumsplit),
      adj_prc = prccd*adj_factor,
      adj_div = div*adj_factor
    ) %>%
    select(gvkey, datadate, adj_prc, adj_div) %>%
    mutate(
      year = year(datadate),
      month = month(datadate)
    ) %>%
    group_by(gvkey, year, month) %>%
    mutate(adj_div = sum(adj_div, na.rm = TRUE)) %>%
    filter(datadate == max(datadate)) %>%
    select(gvkey, year, month, adj_prc, adj_div)
    
  base_grid <- expand_grid(
    gvkey = unique(adj_prc$gvkey),
    year = min(adj_prc$year):2020,
    month = 1:12
  )           
  
  df <- base_grid %>%
    left_join(adj_prc, by = c("gvkey", "year", "month")) %>%
    group_by(gvkey) %>%
    mutate(
      monthly_ret = ((adj_prc + adj_div)/lag(adj_prc)) - 1 
    ) %>%
    select(gvkey, year, month, adj_prc, adj_div, monthly_ret) %>%
    filter(!is.na(monthly_ret))
  
  df 
}

pull_static_data_cstat_global <- function(iso3c = "DEU") {
  message(
    sprintf("%s: Pulling CS Global static data... ", Sys.time())
  )
  static <- tbl(wrds, "g_company") %>%
    filter(loc == iso3c, !is.na(prirow)) %>%
    select(gvkey, conm, sic, spcindcd) %>%
    collect()
  
  message(sprintf("%s: done", Sys.time()))
  
  static
}

pull_panel_data_cstat_global <- function(iso3c = "DEU") {
  message(
    sprintf("%s: Pulling CS Global fundamental data... ", Sys.time())
  )
  gfund <- tbl(wrds, "g_funda") %>%
    filter(
      consol == 'C',
      (indfmt == 'INDL' | indfmt == 'FS'),
      datafmt == 'HIST_STD', 
      popsrc == 'I',
      loc == iso3c
    ) %>%
    select(
      gvkey, datadate, fyr, exchg, 
      at, ceq, ib, ibc, nicon, oancf, ivncf, fincf, oiadp, sale
    ) %>% collect() 

  message(sprintf("%s: done", Sys.time()))
  
  gfund
}


hk <- read_csv("host_access_keys.csv", col_types = cols())

wrds <- connect_wrds(
  hk %>% filter(host == "wrds") %>% pull(user),
  hk %>% filter(host == "wrds") %>% pull(password)
)

prc <- pull_daily_price_cstat_global()

stopifnot(anyDuplicated(prc %>% select(gvkey, datadate)) == 0)

saveRDS(prc, "data/cstat_global_daily_price_data_deu.rds")

ret <-calc_monthly_returns(prc)
saveRDS(ret, "data/cstat_global_monthly_returns_deu.rds")

static <- pull_static_data_cstat_global()

panel <- pull_panel_data_cstat_global()

acc <- static %>% 
  left_join(panel, by = "gvkey") %>%
  filter(!is.na(at)) %>%
  arrange(gvkey, datadate)

stopifnot(anyDuplicated(acc %>% select(gvkey, datadate)) == 0)

saveRDS(acc, "data/cstat_global_acc_data_deu.rds")

dbDisconnect(wrds)
