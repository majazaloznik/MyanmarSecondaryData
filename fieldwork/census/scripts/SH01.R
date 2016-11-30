# load required packages
library(memisc)
library(dplyr)
library(tidyr)

# clean environment
rm(list= ls())

# import dataset from SPSS file 
importer <- spss.system.file('/home/mz/music/mnm.sav')

# only selected variables as needed
data <- subset(importer, select = c(batch_state_region, 
                                    batch_district, 
                                    batch_township, 
                                    batch_ward, 
                                    batch_ea, 
                                    household_number,
                                    form_type,
                                    p03_relationship,
                                    p04_sex,
                                    p05_age,
                                    p09a_disability_seeing,
                                    p09b_disability_hearing,
                                    p09c_disability_walking,
                                    p09d_disability_remembering))

# convert to data.frame and remove institutions
data %>% as.data.frame() %>%
  filter(form_type == "Conventional household") -> df

# clean 
rm(data)

# dummy variable for disability
# HH_ID
# within households calculate 
# head of HH over 65 indicator
# son coresiding indicator
# daughter coresiding indicator
# remove younger Heads of HH

df %>%
  mutate(p09_disablity_seeing_D = ifelse(p09a_disability_seeing== "None",0,1),
         p09_disablity_hearing_D = ifelse(p09b_disability_hearing== "None",0,1),
         p09_disablity_walking_D = ifelse(p09c_disability_walking== "None",0,1),
         p09_disablity_remembering_D = ifelse(p09d_disability_remembering== "None",0,1),
         p09_disablity_D_sum = p09_disablity_seeing_D+p09_disablity_hearing_D+
                                   p09_disablity_walking_D+p09_disablity_remembering_D) %>% # disability index
  unite(HH_ID, batch_state_region, batch_district, batch_township, 
        batch_ward, batch_ea, household_number) %>%
  group_by(HH_ID) %>%
  mutate(HoH_over65 = ifelse(p05_age[p03_relationship == "Head"] >= 65, 1, 0),
         Son_coresident = ifelse("Male" %in% p04_sex[p03_relationship == 
                                                       "Son/Daughter"], 1,0 ),
         Daughter_coresident = ifelse("Female" %in% p04_sex[p03_relationship == 
                                                              "Son/Daughter"], 1,0 )) %>%
  ungroup() %>%
  filter(HoH_over65 == 1) -> df.HoHo_over65

## proportion of HH by p09_disablity_D_sum for coresident sons
df.HoHo_over65 %>%  
  filter(Son_coresident == 1) %>%
  filter(p03_relationship == "Head") %>%
  group_by(p09_disablity_D_sum) %>%
  summarise(n_Son_coresident= n()) %>%
  ungroup() %>%
  mutate(prop_Son_coresident = n_Son_coresident/sum(n_Son_coresident)) -> SH01_sons_dis

## proportion of HH by p09_disablity_D_sum for coresident daughters
df.HoHo_over65 %>%  
  filter(Daughter_coresident == 1) %>%
  filter(p03_relationship == "Head") %>%
  group_by(p09_disablity_D_sum) %>%
  summarise(n_Daughter_coresident= n()) %>%
  ungroup() %>%
  mutate(prop_Daughter_coresident = n_Daughter_coresident/sum(n_Daughter_coresident)) -> SH01_daughters_dis

## proportion of HH by p09_disablity_D_sum for no children coresident 
df.HoHo_over65 %>%  
  filter(Daughter_coresident == 0 & Son_coresident == 0) %>%
  filter(p03_relationship == "Head") %>%
  group_by(p09_disablity_D_sum) %>%
  summarise(n_No_child_coresident= n()) %>%
  ungroup() %>%
  mutate(prop_No_child_coresident = n_No_child_coresident/sum(n_No_child_coresident)) -> SH01_none_dis

## proportion of HH by p09_disablity_D_sum for min one son and min one daughter coresident 
df.HoHo_over65 %>%  
  filter(Daughter_coresident == 1 & Son_coresident == 1) %>%
  filter(p03_relationship == "Head") %>%
  group_by(p09_disablity_D_sum) %>%
  summarise(n_Daughter_Son_coresident= n()) %>%
  ungroup() %>%
  mutate(prop_Daughter_Son_coresident= n_Daughter_Son_coresident/sum(n_Daughter_Son_coresident)) -> SH01_both_dis

# merge all relevant output
SH01 <- cbind(SH01_daughters_dis[,1:3],
              SH01_sons_dis[,2:3],
              SH01_both_dis[,2:3],
              SH01_none_dis[,2:3])

# save and clean
write.csv(SH01, file = "SH01.csv" )
rm(SH01_both_dis, SH01_none_dis, SH01_sons_dis, SH01_daughters_dis, df.HoHo_over65)

