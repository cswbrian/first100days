library(tidyverse)
library(stringr)
library(rvest)
library(httr)


# Guess Encoding
url <- "http://www.info.gov.hk/gia/general/201707/01c.htm"
x <- content(GET(url), "raw")
guess_encoding(x)

# Set Period
dates <- seq(as.Date("2017-07-01"), as.Date("2017-09-26"), by="days")

# Scrap
link_title_df <- data.frame()
for (d in seq_along(dates)) {
  url <- paste0("http://www.info.gov.hk/gia/general/", format(dates[d], format="%Y%m/%d"), "c.htm")
  page.source <- read_html(url)
  node <- page.source %>%
    html_nodes("ul.list") %>%
    html_nodes("li")
  link <- node %>% html_nodes("a") %>% html_attr("href")
  title <- node %>% html_text()
  
  # Combine dataframe
  temp <- data.frame(link, title) %>% 
    mutate(date = format(dates[d], format="%Y-%m-%d"))
  if (d == 1) {
    link_title_df <- data.frame(temp)
  } else {
    link_title_df <- rbind(link_title_df, temp)  
  }
}

link_title_df <- link_title_df[,c(3,2,1)] %>% write_csv("data/link_list_cl_926.csv")
