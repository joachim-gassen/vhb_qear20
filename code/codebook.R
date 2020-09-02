Codebook 

#1. Import and clean insolvency data

#shows your current working directory (wd)
getwd()

#set new wd to "vhb_qear20" repository folder
directory <- setwd("C:/Users/wagne/Desktop/vhb_qear20")

#import data
insolv <- paste0(getwd(),"/raw_data/insolvency_filings_de_julaug2020_incomplete.csv"
dat1 <- read.csv(file = insolv, header = TRUE, fileEncoding = "UTF-8")
print(dat1)

#check type of data
typeof(dat1)

#check if variable is a dataframe or not
is.data.frame(dat1)

#dataframe characteristics
names(dat1) #variable names
ncol(dat1) #number of columns
nrow(dat1) #number of rows

#check variable type
lapply(dat1, class)

#change variable type
dat1$date <- as.Date(dat1$date)

#remove rows that are complete duplicates of other rows
library(dplyr)
dat1 <- dat1 %>% distinct()

#safe clean file
write.csv(dat1, file.path("./data", "dat1_clean.csv"), row.names = TRUE)

#label variables
install.packages("expss")
library(expss)
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

#Show different categories within a variable
Subject <- table(dat1$subject)
Subject

#Cases per filing type per year
cro(dat1$date, dat1$subject)

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

#2. Import and clean orbis data

#import data
orbis <- paste0(getwd(),"/raw_data/orbis_wrds_de.csv.gz")
dat2 <- read.csv(file = orbis, header = TRUE, fileEncoding = "UTF-8")
print(dat2)

#check type of data
typeof(dat2)

#check if variable is a dataframe or not
is.data.frame(dat2)

#dataframe characteristics
names(dat2) #variable names
ncol(dat2) #number of columns
nrow(dat2) #number of rows

#check variable type
lapply(dat2, class)

#change variable type
dat2$closdate <- as.Date(dat2$closdate)

#remove rows that are complete duplicates of other rows
library(dplyr)
dat2 <- dat2 %>% distinct()

#safe clean file -> are we supposed to save this file?
#write.csv(dat2, file.path("./data", "dat2_clean.csv"), row.names = TRUE)

#label variables
install.packages("expss")
library(expss)
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
