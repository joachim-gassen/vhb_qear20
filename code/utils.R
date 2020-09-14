clean_firm_name <- function(name_str) {
  str_replace_all(name_str, "[üöäÜÖÄß]", "") %>%
    tolower() %>%
    str_replace_all(fixed("gesellschaft mit beschrnkter haftung"), "gmbh") %>%
    str_replace_all(fixed("(haftungsbeschrnkt)"), "") %>%
    str_squish()
}
