# VHB QEAR 20 - Joachim Gassen
# See LICENSE File for details

# This is a small simulation to explore endogenous test variables and 
# common remedies

library(tidyverse)

set.seed(1904)

# --- Base simulation with flexible parameters ---------------------------------

sim_sample <- function(
  smp_size = 1000,
  effect = 1,
  endog_effect_1st_stage = 0,
  endog_effect_2nd_stage = 0
) {
  tibble(
    managerial_skill = rnorm(smp_size),
    csr_activities = endog_effect_1st_stage * managerial_skill + rnorm(smp_size),
    profitability = effect * csr_activities + 
      endog_effect_2nd_stage * managerial_skill + rnorm(smp_size)
  )
}


# --- No endogeneity, simple OLS is fine ---------------------------------------

smp <- sim_sample()

ggplot(smp, aes(x = csr_activities, y = profitability)) + 
  geom_point(color = "lightblue") +
  geom_smooth(method = "lm") +
  theme_classic()

summary(lm(profitability ~ csr_activities, data = smp))

summary(lm(profitability ~ csr_activities + managerial_skill, data = smp))


# --- No direct effect but endogeneity, univariate OLS biased, multiple fine ---

smp <- sim_sample(
  effect = 0, 
  endog_effect_1st_stage = 1,
  endog_effect_2nd_stage = 1
)

ggplot(smp, aes(x = csr_activities, y = profitability)) + 
  geom_point(color = "lightblue") +
  geom_smooth(method = "lm") +
  theme_classic()

summary(lm(profitability ~ csr_activities, data = smp))

summary(lm(profitability ~ csr_activities + managerial_skill, data = smp))


# --- Non-linear endogeneity, univariate and multiple OLS biased ---------------

smp_size <- 1000
smp <- tibble(
    managerial_skill = rnorm(smp_size),
    csr_activities = (managerial_skill > 0)  * managerial_skill + rnorm(smp_size),
    profitability = (managerial_skill > 0)  * managerial_skill + rnorm(smp_size)
)

ggplot(smp, aes(x = csr_activities, y = profitability)) + 
  geom_point(color = "lightblue") +
  geom_smooth(method = "lm") +
  theme_classic()

summary(lm(profitability ~ csr_activities, data = smp))

summary(lm(profitability ~ csr_activities + managerial_skill, data = smp))


# --- Non-linear endogeneity, stratified OLS is fine ---------------------------

summary(lm(profitability ~ csr_activities + managerial_skill, 
           data = smp %>% filter(managerial_skill > 0)))

summary(lm(profitability ~ csr_activities + managerial_skill, 
           data = smp %>% filter(managerial_skill < 0)))


# --- Selection on unsoberservables, reulatory instrument, 2 SLS IV is fine ----

smp <- tibble(
  managerial_skill = rnorm(smp_size),
  reg_incentive = rnorm(smp_size),
  csr_activities = (managerial_skill > 0)  * managerial_skill + 
    0.5*reg_incentive + 0.5*rnorm(smp_size),
  profitability = (managerial_skill > 0)  * managerial_skill + rnorm(smp_size)
)

ggplot(smp, aes(x = csr_activities, y = profitability)) + 
  geom_point(color = "lightblue") +
  geom_smooth(method = "lm") +
  theme_classic()

summary(lm(profitability ~ csr_activities, data = smp))
summary(lm(profitability ~ reg_incentive, data = smp))

library(AER)
summary(ivreg(profitability ~ csr_activities | reg_incentive, data = smp), diagnostics = TRUE)

smp <- tibble(
  managerial_skill = rnorm(smp_size),
  reg_incentive = rnorm(smp_size),
  csr_activities = (managerial_skill > 0)  * managerial_skill + 
    0.5*reg_incentive + 0.5*rnorm(smp_size),
  profitability = (managerial_skill > 0)  * managerial_skill + 
    csr_activities + rnorm(smp_size)
)

ggplot(smp, aes(x = csr_activities, y = profitability)) + 
  geom_point(color = "lightblue") +
  geom_smooth(method = "lm") +
  theme_classic()

summary(lm(profitability ~ csr_activities, data = smp))
summary(lm(profitability ~ reg_incentive, data = smp))

summary(ivreg(profitability ~ csr_activities | reg_incentive, data = smp), diagnostics = TRUE)
