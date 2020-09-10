# VHB QEAR 20 - Joachim Gassen
# See LICENSE File for details

# This is a small simulation to show the effect of outliers on OLS

library(tidyverse)

set.seed(1904)

smp <- tibble(
  x = rnorm(100),
  y = x + rnorm(100) 
)

ggplot(smp, aes(x = x, y = y)) + 
  geom_point(color = "lightblue") +
  geom_smooth(method = "lm") +
  theme_classic()

smp2 <- rbind(smp, c(10, -10))

ggplot(smp2, aes(x = x, y = y)) + 
  geom_point(color = "lightblue") +
  geom_smooth(method = "lm") +
  theme_classic()
