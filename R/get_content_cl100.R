library(tidyverse)
library(stringr)
library(rvest)

link_list_cl <- read_csv("data/link_list_cl_926.csv") %>% 
  filter(str_detect(title, "行政長官")) %>% 
  mutate(link = paste0("http://www.info.gov.hk",link))


url <- link_list_cl$link

cl_selected <- data.frame()
for (i in seq_along(url)) {
  page.source <- read_html(url[i])
  content <- page.source %>%
    html_nodes("span#pressrelease") %>%
    html_text() 
  link <- url[i]
  
  # Combine dataframe
  temp <- data.frame(link, content)
  if (i == 1) {
    cl_selected <- data.frame(temp)
  } else {
    cl_selected <- rbind(cl_selected, temp)  
  }
}

cl100 <- cl_selected %>% left_join(link_list_cl)
cl100 %>% write_csv("data/cl100.csv")

cl100_clean <- cl100 %>%
  mutate(content = str_replace_all(content, "\\s","")) %>% 
  mutate(content = str_match(content, "(.*)完\\X+年\\X+月\\X+日")[,2])
cl100_clean %>% write_csv("data/cl100_clean.csv")