#Codebook 
#-------------------------------------------------------------------------------
#used packages
#install.packages("expss")
library(tidyverse)
library(expss)
library(dplyr)
library(lubridate)

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

#1. Import and clean insolvency data

#shows your current working directory (wd)
getwd()

#set new wd to "vhb_qear20" repository folder
directory <- setwd("C:/Users/wagne/Desktop/vhb_qear20")

#import data
insolv <- paste0(getwd(),"/raw_data/insolvency_filings_de_julaug2020_incomplete.csv")
dat1 <- read.csv(file = insolv, header = TRUE, fileEncoding = "UTF-8")
view(dat1)

#check type of data
typeof(dat1)

#check if variable is a dataframe or not
is.data.frame(dat1)
class(dat1)

#dataframe characteristics
names(dat1) #variable names
ncol(dat1) #number of columns
nrow(dat1) #number of rows

#check variable type
lapply(dat1, class)

#change variable type
dat1$date <- as.Date(dat1$date, ymd)
dat1$subject <- as.factor(dat1$subject)

#remove rows that are complete duplicates of other rows
dat1 <- dat1 %>% distinct()
dup <- duplicated(dat1)
sum(dup>0)

#checks if cout file number is a unique identifier
length(unique(dat1$`Court file number`)) == length(dat1$`Court file number`)

#safe clean file
write.csv(dat1, file.path("./data", "dat1_clean.csv"), row.names = TRUE)

#label variables

##Character variables
dat1 = apply_labels(dat1,
                    insolvency_court = "Insolvency Court",
                    court_file_number = "File Number in Court",
                    subject = "Subject",
                    name_debtor = "Name of Debtor",
                    domicile_debtor = "Debtor Domicile"
)
##Date variables
dat1 = apply_labels(dat1,
                    date = "Date of Insolvency Filing"
)

#-------------------------------------------------------------------------------
#Descriptives

#number of filings after removin duplicates: 9355
nrow(dat1)


#data arranged by subject
Subject <- table(dat1$subject) ##e.g., new insolvecy cases (Eröffnungen) opened: 897
Subject


tab1 <- dat1 %>% ##does the same as above but prettier
  group_by(subject) %>%
  summarize(freq = n())


#by filing court
tab2 <- dat1 %>% 
  group_by(insolvency_court) %>%
  summarize(freq = n())


#Cases per filing type per day (would be nice if we can set this to month, but I fail to extract the month from year)
cro(dat1$date, dat1$subject)
tab1 <- cro(dat1$date, dat1$subject)
view(tab1)









#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

#2. Import and clean orbis data

#import data
orbis <- paste0(getwd(),"/raw_data/orbis_wrds_de.csv.gz")
dat2 <- read.csv(file = orbis, header = TRUE, fileEncoding = "UTF-8")
view(dat2)



#check type of data
typeof(dat2)

#check if variable is a dataframe or not
is.data.frame(dat2)
class(dat2)

#dataframe characteristics
names(dat2) #variable names
ncol(dat2) #number of columns 
nrow(dat2) #number of rows


#check variable type
lapply(dat2, class)

#change variable type
dat2$closdate <- as.Date(dat2$closdate)

#remove rows that are complete duplicates of other rows
dat2 <- dat2 %>% distinct()

#safe clean file -> are we supposed to save this file?
#write.csv(dat2, file.path("./data", "dat2_clean.csv"), row.names = TRUE)

#label variables

##Integer variables
dat2 = apply_labels(dat2,
                    X = "Line",
                    naceccod2 = "Nace 2 Code",
                    ussicpcod = "xxx",
                    year = "Year"
)
##Character variables
dat2 = apply_labels(dat2,
                    ctryiso = "Countrycode",
                    bvdid = "Bureau van Dijk ID",
                    name_internat = "International Name",
                    name_native = "Native Name",
                    major_sector = "Major Sector",
                    nace2_main_section = "NACE 2 Main Section",
                    category_of_company = "Company Size",
                    status_str = "Exit Type",
                    legalfrm = "Legal Form",
                    indepind = "xxx",
                    listed = "Listed",
                    conscode = "Consolidation Code",
                    filing_type = "Type of Filing",
                    accpractice = "Account Standard",
                    audstatus = "Audit",
                    source = "Source"
)
##Date variables
dat2 = apply_labels(dat2,
                    closdate = "Closing date"
)
##Numerical variables
dat2 = apply_labels(dat2,
                    fias = "Fixed Assets",
                    cuas = "Current Assets",
                    stok = "Stocks",
                    debt = "Debtors",
                    ocas = "Other Current Assets",
                    cash = "Cash and Cash Equivalent",
                    toas = "Total Assets",
                    shfd = "Shareholder Funds",
                    ncli = "Non Current Liabilities",
                    culi = "Current Liabilities",
                    loan = "Loans",
                    cred = "Creditors",
                    ocli = "Other Current Liabilities",
                    tshf = "Total Shareholder Funds and Liabilities",
                    empl = "Number of Employees",
                    opre = "Operating Revenue / Turnover",
                    turn = "Sales",
                    cost = "Cost of Goods Sold",
                    fipl = "Financial Profit / Loss",
                    taxa = "Taxation",
                    exex = "Extraordinary and other Expenses",
                    pl = "Profit / Loss for Period"
)

#-------------------------------------------------------------------------------
#Descriptives

#Show different categories within a variable
Filetype <- table(dat2$filing_type)
Filetype

#Cases per filing type per year
cro(dat2$year, dat2$filing_type)

#-------------------------------------------------------------------------------
# further data analysis of the insolvency data set

