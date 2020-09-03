getwd()
setwd("C:/Users/Olga Sagradov/Desktop/Seminar QERA")

#the dataset "insolvency.." was loaded from github
#or use setwd()

#to define data type in R: class(dataset$label) or str()
class(insolvency_filings_de_julaug2020_incomplete$date)
str(insolvency_filings_de_julaug2020_incomplete)

#to count the observations:
library(tidyverse)
total_cases <- insolvency_filings_de_julaug2020_incomplete %>% 
  group_by(court_file_number) %>% tally()

#to find the missing values:
sum(is.na(insolvency_filings_de_julaug2020_incomplete$date))
