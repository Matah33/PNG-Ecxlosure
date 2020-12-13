#----------------------------------------------------------#
#
#
#                Exclosure experiment PNG
#
#                         Data
#
#             Ondrej Mottl - Marketa Tahadlova
#                         2020
#
#----------------------------------------------------------#

#----------------------------------------------------------#
# 1. Load libraries and functions -----
#----------------------------------------------------------#

# delete existing workspace to start clean
rm(list = ls())

# Package version control
library(renv)
# renv::init()
# renv::snapshot(lockfile = "data/lock/revn.lock")
renv::restore(lockfile = "data/lock/revn.lock")

# libraries
library(tidyverse)

#----------------------------------------------------------#
# 2. Import data and merge -----
#----------------------------------------------------------#

# 2.1 desing data-----
dataset_desing <-  
  readxl::read_xlsx("data/input/data_input_clean.xlsx","Design_data")  %>% 
  mutate(TreeID = as.character(TreeID))

# calculate total tree leaf area
dataset_desing <-  
  dataset_desing %>% 
  mutate(
    LA_cm = LeafAreaF1 / 10e3,
    LA_W_ratio = LA_cm / WeightFrame,
    leaf_area_total = WeightTot * LA_W_ratio
  ) 

# 2.2 herbivory data -----
dataset_herbivory <-  
  readxl::read_xlsx("data/input/data_input_clean.xlsx","Leaf_frames")  %>% 
  rename(
    Age_Leaf = `Age Leaf`) %>% 
  mutate(TreeID = as.character(Tree_ID)) %>% 
  dplyr::select(-Tree_ID)

# sum herbivory per tree
dataset_herbivory_sum <-
  dataset_herbivory %>% 
    mutate(
      Percentage = (HerbivoryArea / LeafAreaIdeal) * 100) %>%  # recalculate 
    group_by(Plot, Treatment, TreeID) %>% 
    summarise(
      .groups = "keep",
    #  leaf_area_total = sum(LeafAreaIdeal)/10e3,
      herbivory_percentage_median = median(Percentage),
      herbivory_percentage_mean = mean(Percentage)
    )

# 2.3 invertebrates data -----
dataset_invertebrates <-  
  readxl::read_xlsx("data/input/data_input_clean.xlsx","Invertebrates")  %>% 
  rename(
    Size = 'Size (mm)') %>% 
  mutate(
    TreeID = as.character(TreeID),
    Plot = case_when(
      Plot == "BAI" ~ "BAI", 
      Plot == "WAN1" ~ "WA1",
      Plot == "WAN3" ~ "WA3",
      Plot == "YAW" ~ "YAW" 
    ))

# invertebrates abunance
dataset_invertebrates_sum_abund <-
  dataset_invertebrates %>% 
  group_by(Plot, Treatment, TreeID, Guild) %>% 
  summarise(
    .groups = "keep",
    Abundance = n()
  ) %>% 
  ungroup() %>% 
  pivot_wider(names_from = Guild, values_from = Abundance) %>% 
  replace(is.na(.), 0)
  
dataset_invertebrates_sum_abund <-
  dataset_invertebrates_sum_abund %>% 
  mutate(Total_abundance = dataset_invertebrates_sum_abund %>% 
           dplyr::select(
             dataset_invertebrates$Guild %>% 
               unique()) %>% 
           rowSums())

# artropod sizes
dataset_invertebrates_mean_size_guild <-
  dataset_invertebrates %>% 
  group_by(Plot, Treatment, TreeID, Guild) %>% 
  summarise(
    .groups = "keep",
    Mean_size = mean(Size)
  ) %>% 
  ungroup() %>%
  mutate(Guild = paste0("size_",Guild)) %>% 
  pivot_wider(names_from = Guild, values_from = Mean_size)

dataset_invertebrates_mean_size_total <-
dataset_invertebrates %>% 
  group_by(Plot, Treatment, TreeID) %>% 
  summarise(
    .groups = "keep",
    Mean_size = mean(Size)
  ) %>% 
  ungroup()


# merging artropods data
dataset_invertebrates_final <-
  dataset_invertebrates_sum_abund %>% 
  left_join(
    dataset_invertebrates_mean_size_guild,
    by = c("Plot", "Treatment", "TreeID")) %>% 
  left_join(
    dataset_invertebrates_mean_size_total,
    by = c("Plot", "Treatment", "TreeID"))

# 2.4 summary -----
# merge all together
dataset_fin <-
  dataset_desing %>% 
  left_join(
    dataset_herbivory_sum,
    by = c("Plot", "Treatment", "TreeID")) %>% 
  left_join(
    dataset_invertebrates_final,
    by = c("Plot", "Treatment", "TreeID") 
  )



#----------------------------------------------------------#
# 3. save data  -----
#----------------------------------------------------------#

write_csv(
  dataset_fin,
  "data/output/dataset_fin.csv")