# See http://econ.lse.ac.uk/staff/spischke/ec533/did.pdf
# and: https://pubs.aeaweb.org/doi/pdfplus/10.1257/aer.20181169
# Two-Way Fixed Effects Estimators with Heterogeneous Treatment Effects
# de Chaisemartin and D’Haultfœuille (AER, 2020)

library(tidyverse)

df <- expand.grid(
  period = 1:3,
  csid = 1:2
) %>%
  mutate(
    tment = c(0, 1, 1, 0, 0, 1),
    outcome = c(0, 1, 4, 0, 0, 1)
  )

mod <- lfe::felm(outcome ~ tment | period + csid, data = df)
summary(mod)
broom::tidy(mod, fe = TRUE)
