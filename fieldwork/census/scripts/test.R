
library(memisc)
library(dplyr)
library(tidyr)

data <- as.data.set(spss.system.file('/home/mz/music/mnm.sav'))
nrow(data)
table(data$p21_highest_grade)
data[10:20, 43:48]
colnames(data)
data %>% as.data.frame() %>%
  filter(p03_relationship == "Head") -> heads
num_abr <- table(heads$h40_number_abroad)

data[1:5, 47:49]
barplot(num_abr[-1], xlab = "Number of hh members abroad")

table(as.data.frame(data)$p17_prev_res_township)[-1]

hist(data$p15_duration_of_residence)

head(data[,57:63])

data %>% as.data.frame() %>%
  filter(p13_usual_res_township == 0) -> moved
moved %>%
  select(p15_duration_of_residence) -> time
  hist(unlist(time))
str(time)
str(data[,58])
nrow(data)
data.x <- as.data.frame(data[1:1000,])

data.x %>%
  filter(p13_usual_res_township == "Enumeration township") -> moved
left_join(data.x, moved) -> test

