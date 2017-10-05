library(tidyverse)
library(stringr)
library(rvest)

link_list_cy <- read_csv("data/link_list_cy.csv") %>% 
  filter(str_detect(title, "行政長官"))


url <- link_list_cy$link

cy_selected <- data.frame()
for (i in seq_along(url)) {
  page.source <- read_html(url[i], encoding = "ISO-8859-1")
  content <- page.source %>%
    html_nodes("div#pressrelease") %>%
    html_text() %>% 
    iconv("UTF-8", "ISO-8859-1")
  link <- url[i]
  
  # Combine dataframe
  temp <- data.frame(link, content)
  if (i == 1) {
    cy_selected <- data.frame(temp)
  } else {
    cy_selected <- rbind(cy_selected, temp)  
  }
}

cy100 <- cy_selected %>% left_join(link_list_cy)
cy100 %>% write_csv("data/cy100.csv")

cy100_clean <- cy100 %>% 
  mutate(content = str_replace_all(content, "\\s","")) %>% 
  mutate(content = str_match(content, "＊+(.*)完\\X+年\\X+月\\X+日")[,2])
cy100_clean %>% write_csv("data/cy100_clean.csv")

