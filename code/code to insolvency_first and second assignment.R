getwd()
setwd("C:/Users/Olga Sagradov/Desktop/Seminar QERA")

install.packages("tidyverse")
library(tidyverse)

orbis_wrds <- read.csv("orbis_wrds_de.csv.gz", sep = ",")
#the dataset "insolvency.." was loaded from github-connection with r

#1. Analysis of insolvency data
#view structure of data:
str(insolvency_filings_de_julaug2020_incomplete)

#Is there a missing data?
is.na(insolvency_filings_de_julaug2020_incomplete)
sum(is.na(insolvency_filings_de_julaug2020_incomplete$date))
sum(is.na(insolvency_filings_de_julaug2020_incomplete$insolvency_court))
sum(is.na(insolvency_filings_de_julaug2020_incomplete$court_file_number))
sum(is.na(insolvency_filings_de_julaug2020_incomplete$subject))
sum(is.na(insolvency_filings_de_julaug2020_incomplete$name_debtor))
sum(is.na(insolvency_filings_de_julaug2020_incomplete$domicile_debtor))
#to ignore missing values use the function:
#new_inslvnc <- na.omit(insolvency_filings_de_julaug2020_incomplete)

## 1. Analysis of the subject categories.
table(insolvency_filings_de_julaug2020_incomplete$subject)

## a. Subject -> Eröffnungen
#How many "Eröffnung" per day were recorded? ->
#Extraction of two variables from the dataset with a function subset()
inslv_date_erffng <- subset(insolvency_filings_de_julaug2020_incomplete, subject == "Eröffnungen",
                  select=c(date, subject))
#Now we can count the amount of Eröffnungen per day:
library(plyr)
count_eroeffn <- count(inslv_date_erffng,"date")
#and then visualize the observations:
library(ggplot2)
library(scales)
ggplot(count_eroeffn, aes(x = date, y = freq)) +
  geom_point(colour="darkgreen") +
  scale_y_continuous(breaks = seq(0, 110, 10)) +
  scale_x_date(breaks = date_breaks(width= "3 days"), 
               labels = date_format("%m/%d")) +
  ylab("Eröffnungen")

#The average of "Eröffnungen" per day:
mean(count_eroeffn[["freq"]])

## b. Subject -> Abweisungen mangels Masse
#How many observations per day were recorded? ->
#Extraction of two variables from the dataset with a function subset()
inslv_date_abw <- subset(insolvency_filings_de_julaug2020_incomplete, subject == "Abweisungen mangels Masse",
                            select=c(date, subject))
#Now we can count the amount of Abweisungen mangels Masse per day:
count_abw <- count(inslv_date_abw,"date")
#and then visualize the observations:
ggplot(count_abw, aes(x = date, y = freq)) +
  geom_point(colour="darkred") +
  scale_y_continuous(breaks = seq(0, 20, 4)) +
  scale_x_date(breaks = date_breaks(width= "3 days"), 
               labels = date_format("%m/%d")) +
  ylab("Abweisungen mangels Masse")

#The average of "Abweisungen" per day:
mean(count_abw[["freq"]])

## c. Subject -> Entscheidungen im Verfahren
#How many observations per day were recorded? ->
#Extraction of two variables from the dataset with a function subset()
inslv_date_entverf <- subset(insolvency_filings_de_julaug2020_incomplete, subject == "Entscheidungen im Verfahren",
                         select=c(date, subject))
#Now we can count the amount of Abweisungen mangels Masse per day:
count_entverf <- count(inslv_date_entverf,"date")
#and then visualize the observations:
ggplot(count_entverf, aes(x = date, y = freq)) +
  geom_point(colour="darkred") +
  scale_y_continuous(breaks = seq(0, 140, 20)) +
  scale_x_date(breaks = date_breaks(width= "3 days"), 
               labels = date_format("%m/%d")) +
  ylab("Entscheidungen im Verfahren")

#The average of "Entscheidungen im Verfahren" per day:
mean(count_entverf[["freq"]])

## 2. Analysis of the court location.
inslv_geogr <- subset(insolvency_filings_de_julaug2020_incomplete, select=c(insolvency_court, subject))
count_court <- count(inslv_geogr,"insolvency_court")
count_court %>% top_n(5) #highest values

## 3. Analysis of duplication/amount of subjects per one insolvency petition
table(insolvency_filings_de_julaug2020_incomplete$court_file_number)
total_cases <- insolvency_filings_de_julaug2020_incomplete %>% group_by(court_file_number) %>% tally()





summarise(insolvency_filings_de_julaug2020_incomplete)

install.packages("kableExtra")
library(kableExtra)
inslv <- insolvency_filings_de_julaug2020_incomplete[1:5,]

table(orbis_wrds$ctryiso)
table(orbis_wrds$category_of_company)
