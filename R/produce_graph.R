library(tidyverse)
library(stringr)
library(lubridate)

cy100_ec <- cy100_ec %>% mutate(word_count = nchar(cleanspeech))
cl100_ec <- cl100_ec %>% mutate(word_count = nchar(cleanspeech))

pyramid <- rbind(cy100_ec %>%
                      mutate(person = "cy") %>% 
                      mutate(week = difftime(ymd(date), ymd(20120703),units="weeks")), 
                    cl100_ec %>% 
                      mutate(person = "cl") %>% 
                      mutate(week = difftime(ymd(date), ymd(20170704),units="weeks"))) %>% 
  select(date, week, person, word_count)

pyramid %>% 
  select(week, person, word_count) %>%
  spread(person, word_count) %>%
  mutate_if(is.numeric, funs(ifelse(is.na(.), 0, .))) %>% 
  arrange(week) %>%
  write.csv("output/chart.csv", row.names = FALSE)

pyramid %>% arrange(week) %>% 
  ggplot(aes(week, word_count, fill = person)) + 
  geom_bar(data = filter(pyramid, person == "cy"), stat = "identity") + 
  geom_bar(data = filter(pyramid, person == "cl"), stat = "identity", aes(y=word_count*(-1))) +
  coord_flip() +
  scale_x_continuous(name="week", breaks=seq(0,12,1))
  