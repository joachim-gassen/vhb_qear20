Codebook 

directory <- "C:/Users/wagne/Documents/vhb_qear20/raw_data"
insolv <- file.path(directory, "insolvency_filings_de_julaug2020_incomplete.csv")
dat1 <- read.csv(file = insolv, header = TRUE)