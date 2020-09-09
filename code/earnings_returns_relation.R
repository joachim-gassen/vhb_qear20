# VHB QEAR 20 - Joachim Gassen
# See LICENSE File for details

# Prepares return-earnings scatter plots for German data

library(tidyverse)
library(zoo)
library(lubridate)
library(ExPanDaR)

acc <- readRDS("data/cstat_global_acc_data_deu.rds")
mrets <- readRDS("data/cstat_global_monthly_returns_deu.rds") 
ff12 <- readRDS("raw_data/ff_12_ind.RDS")

ret12 <- mrets %>% 
  group_by(gvkey) %>%
  mutate(
    ret12 = rollapply(1 + monthly_ret, 12, prod, align='right',fill = NA) -1
  ) %>% select(gvkey, year, month, ret12)

ear <- acc %>%
  arrange(gvkey, datadate) %>%
  rename(month = fyr) %>%
  mutate(year = year(datadate)) %>%
  group_by(gvkey) %>%
  mutate(ear_ta = ib/(0.5*(lag(at) + at))) %>%
  filter(!is.na(ear_ta)) %>%
  select(gvkey, conm, year, month, sic, ear_ta)

smp <-
  ear %>%
  left_join(ret12, by = c("gvkey", "year", "month")) %>%
  left_join(ff12, by = "sic") %>%
  filter(!is.na(ret12), !is.na(ear_ta)) %>%
  rename(ff12ind = ff12ind_desc) %>%
  select(gvkey, conm, ff12ind, year, ret12, ear_ta) %>%
  filter (year >= 1990, year < 2020)


ggplot(smp, aes(x = ret12, y = ear_ta)) +
  geom_point(alpha = 0.1) + 
  labs(x = "", y = "") + 
  theme_classic()

ggsave("output/ear_ret_scatter_1.png")

ggplot(treat_outliers(smp), aes(x = ret12, y = ear_ta)) +
  geom_point(alpha = 0.1) + 
  labs(x = "", y = "") + 
  theme_classic()

ggsave("output/ear_ret_scatter_2.png")

ggplot(treat_outliers(smp, by = "year"), aes(x = ret12, y = ear_ta)) +
  geom_point(alpha = 0.1) + 
  labs(x = "", y = "") + 
  theme_classic()

ggsave("output/ear_ret_scatter_3.png")

byw_smp <- treat_outliers(smp, by = "year")

pl <- ggplot(byw_smp, aes(x = ret12, y = ear_ta)) +
  geom_point(alpha = 0.1) + 
  labs(x = "Fiscal year returns", y = "Earnings (deflated by total assets)") + 
  theme_classic()

pl

ggsave(plot = pl, "output/ear_ret_scatter_4.png")

basu <- lm(ear_ta ~ (ret12 <0)*ret12, data = smp) 

pl +
  geom_segment(aes(
    x = min(byw_smp$ret12), 
    y = basu$coefficients[1] + basu$coefficients[2] + 
      sum(basu$coefficients[3:4])*min(byw_smp$ret12),
    xend = 0,
    yend =  basu$coefficients[1] + basu$coefficients[2]),
    color = "blue", size = 1
  ) +
  geom_segment(aes(
    x = 0,
    y =  basu$coefficients[1],
    xend = max(byw_smp$ret12), 
    yend = basu$coefficients[1] + 
      basu$coefficients[3]*max(byw_smp$ret12)
    ),
    color = "blue", size = 1
  ) +
  theme_classic()

ggsave("output/ear_ret_scatter_5.png")

ExPanD(smp, cs_id = c("gvkey", "conm"), ts_id = "year")
