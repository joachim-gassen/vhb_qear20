# VHB QEAR 20 - Joachim Gassen
# See LICENSE File for details

# This is a small simulation to show the effect of self-selections introducing
# an implicit collider variable on which you (have to) condition your 
# analysis

library(tidyverse)
library(truncnorm)

smp_size <- 1000

smp <- tibble(
  csr_activities = rtruncnorm(smp_size, 0, 10, 5, 2),
  profitability = rtruncnorm(smp_size, 0, 10, 5, 2),
  csr_reporter = csr_activities + profitability + rnorm(smp_size) > 10
)

ggplot(smp, aes(x = csr_activities, y = profitability)) + 
  geom_point(color = "lightblue") +
  geom_smooth(method = "lm") +
  theme_classic()

ggplot(smp %>% filter(csr_reporter), aes(x = csr_activities, y = profitability)) + 
  geom_point(color = "lightblue") +
  geom_smooth(method = "lm") +
  theme_classic()

ggplot(smp, aes(x = csr_activities, y = profitability)) + 
  geom_point(aes(color = csr_reporter)) +
  geom_smooth(method = "lm") +
  theme_classic()

summary(lm(profitability ~ csr_activities, smp))

summary(lm(profitability ~ csr_activities, smp %>% filter(csr_reporter)))

summary(lm(profitability ~ csr_activities + csr_reporter, smp))

summary(lm(profitability ~ csr_activities*csr_reporter, smp))
