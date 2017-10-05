library(tidyverse)
library(stringr)
library(jiebaR)

cy100_clean <- read_csv("data/cy100_clean.csv")
cl100_clean <- read_csv("data/cl100_clean.csv")

cy100_ec <- cy100_clean %>% 
  filter(str_detect(content, "出席行政會議前")) %>%
  mutate(cleanspeech = str_replace_all(content,"記者：(.+?)(行政長官(：|︰)|$)","\\2")) %>% 
  mutate(cleanspeech = str_replace_all(cleanspeech,"(.*)全文(：|︰)","")) %>% 
  mutate(cleanspeech = str_replace_all(cleanspeech,"(行政長官|署理行政長官)(：|︰)",""))

wk = worker()
segment <- wk[cy100_ec$cleanspeech]
report_cy <- freq(segment) %>% 
  arrange(desc(freq)) %>% 
  mutate(length = nchar(char)) %>% 
  filter(length > 1)


cl100_ec <- cl100_clean %>% 
  filter(str_detect(content, "出席行政會議前")) %>%
  mutate(cleanspeech = str_replace_all(content,"記者：(.+?)(行政長官(：|︰)|$)","\\2")) %>% 
  mutate(cleanspeech = str_replace_all(cleanspeech,"(.*)全文(：|︰)","")) %>% 
  mutate(cleanspeech = str_replace_all(cleanspeech,"(行政長官|署理行政長官)(：|︰)",""))

wk = worker()
segment <- wk[cl100_ec$cleanspeech]
report_cl <- freq(segment) %>% 
  arrange(desc(freq)) %>% 
  mutate(length = nchar(char)) %>% 
  filter(length > 1)

combine <- rbind(report_cl %>% 
                   mutate(person = "cl") %>% 
                   mutate(total = n()) %>% 
                   rename("n" = "freq"), 
                 report_cy %>% 
                   mutate(person = "cy") %>% 
                   mutate(total = n()) %>% 
                   rename("n" = "freq")) %>%  
  select(person, char, n, total) %>%
  rename("word" = "char") %>% 
  mutate(freq = n/total)

combine %>% 
  select(person, word, freq) %>% 
  spread(person, freq) %>%
  arrange(cl, cy) %>% 
  mutate(cy = ifelse(is.na(cy),0,cy)) %>% 
  ggplot(aes(cl, cy)) +
  geom_jitter(alpha = 0.1, size = 2.5, width = 0.25, height = 0.25) +
  geom_text(aes(label = word), check_overlap = TRUE, vjust = 1.5) +
  scale_x_log10(labels = percent_format()) +
  scale_y_log10(labels = percent_format()) +
  geom_abline(color = "red")

word_ratios <- combine %>%
  select(word, person, n) %>%
  filter(n >= 10) %>% #optional
  spread(person, n, fill = 0) %>% 
  mutate_if(is.numeric, funs((. + 1) / sum(. + 1))) %>% 
  mutate(logratio = log(cl / cy)) %>%
  arrange(desc(logratio))

word_ratios %>% arrange(abs(logratio))

word_ratios %>%
  group_by(logratio < 0) %>%
  top_n(30, abs(logratio)) %>%
  ungroup() %>%
  mutate(word = reorder(word, logratio)) %>%
  ggplot(aes(word, logratio, fill = logratio < 0)) +
  geom_col() +
  coord_flip() +
  ylab("log odds ratio (cl/cy)") +
  scale_fill_discrete(name = "", labels = c("Carrie Lam", "CY Leung"))
