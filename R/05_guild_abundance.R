#----------------------------------------------------------#
#
#
#                Exclosure experiment PNG
#
#                  abundace of guilds
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
library(ggpubr)
library(RColorBrewer)
library(glmmTMB)
library(MuMIn)
library(emmeans)
library(performance)

#----------------------------------------------------------#
# 2. Import data -----
#----------------------------------------------------------#

list_files <-  list.files("data/output/")

if(any(list_files %in% "dataset_fin.csv")) {
  dataset_fin <-  read.csv("data/output/dataset_fin.csv") %>% 
    as_tibble()
} else {
  source("R/01_Data.R")
}

#----------------------------------------------------------#
# 3. graphical properties definition  -----
#----------------------------------------------------------#

theme_set(theme_classic())
text_size <-  10

PDF_width <-  10
PDF_height <-  6

abundance_log_breaks <-  
  c(0,1,10,100,
    paste0("1e", seq(1:15)) %>% 
      noquote()) %>%  
  as.numeric()

# display.brewer.all()

# Treatment pallete
pallete_1 <-  brewer.pal(3,"Pastel1")
names(pallete_1) <-  
  dataset_fin$Treatment %>% 
  unique()

# habitat pallete
pallete_2 <-  brewer.pal(4,"Set2")
names(pallete_2) <-  
  dataset_fin$Hab %>% 
  unique()

# Species pallete
pallete_3 <-  brewer.pal(4,"Accent")
names(pallete_3) <-  
  dataset_fin$Spec %>% 
  unique()

# Guild pallete
pallete_4 <-  brewer.pal(4,"Set1")
names(pallete_4) <-  c("CHEW", "NR", "PRE", "SUC")


# get the flat violin geom
source("https://gist.githubusercontent.com/benmarwick/2a1bb0133ff568cbe28d/raw/fb53bd97121f7f9ce947837ef1a4c65a73bffb3f/geom_flat_violin.R")

#----------------------------------------------------------#
# 4. calculation of Abundance -----
#----------------------------------------------------------#

dataset_guild_abundance <-
  dataset_fin %>% 
  dplyr::select(
    Plot, Treatment, Hab, Spec, TreeID,
    leaf_area_total,
    CHEW, NR, PRE, SUC) %>% 
  pivot_longer(
    cols = -c(Plot, Treatment, Hab, Spec,  TreeID, leaf_area_total),
    names_to = "guild",
    values_to = "abundance"  ) %>% 
  mutate(abundance_per_leaf_area = abundance / leaf_area_total ) %>% 
  mutate(TreeID = as.character(TreeID)) %>% 
  mutate_if(is.character,as.factor)

summary(dataset_guild_abundance)

#----------------------------------------------------------#
# 5. Exploratory figures -----
#----------------------------------------------------------#

# per treatmetns
(ext_plot_01 <- 
   dataset_guild_abundance %>% 
   ggplot(
     aes(
       x = Treatment,
       y = abundance_per_leaf_area,
       fill = guild,
       col = guild)) +
   
   geom_flat_violin(
     col = "gray30",
     alpha = 1/2,
     trim = TRUE,
     position = position_nudge(
       x = 0.2,
       y = 0)) +
   
   geom_point(
     position = position_jitter(width = 0.15),
     alpha = 1,
     size = 1)+
   
   geom_boxplot(
     width=0.2,
     outlier.shape = NA,
     col = "gray30",
     alpha = 1) +
   
   facet_grid( ~ guild)+
   
   labs(
     x = "Treatment", 
     y = expression(paste("Invertebrates abundance per m" ^ 2))) +
   scale_fill_manual(values = pallete_4) +
   scale_color_manual(values = pallete_4) +
   theme(
     text = element_text(size = text_size),
     legend.position = "none"))

ggsave(
  "fig/guild_abundance/ext_plot_01.pdf",
  ext_plot_01,
  width = PDF_width,
  height = PDF_height,
  units = "in")

# per habitat
(ext_plot_02 <- 
    dataset_guild_abundance %>% 
    ggplot(
      aes(
        x = Hab,
        y = abundance_per_leaf_area,
        fill = guild,
        col = guild)) +
    
    geom_flat_violin(
      col = "gray30",
      alpha = 1/2,
      trim = TRUE,
      position = position_nudge(
        x = 0.2,
        y = 0)) +
    
    geom_point(
      position = position_jitter(width = 0.15),
      alpha = 1,
      size = 1)+
    
    geom_boxplot(
      width=0.2,
      outlier.shape = NA,
      col = "gray30",
      alpha = 1) +
    
    facet_grid( ~ guild)+
    
    labs(
      x = "Habitat",
      y = expression(paste("Invertebrates abundance per m" ^ 2)) )+
    scale_color_manual(values = pallete_4) +
    scale_fill_manual(values = pallete_4) +
    theme(
      text = element_text(size = text_size),
      legend.position = "none"))

ggsave(
  "fig/guild_abundance/ext_plot_02.pdf",
  ext_plot_02,
  width = PDF_width,
  height = PDF_height,
  units = "in")


# per species
(ext_plot_03 <- 
    dataset_guild_abundance %>% 
    ggplot(
      aes(
        x = Spec,
        y = abundance_per_leaf_area,
        fill = guild,
        col = guild)) +
    
    geom_flat_violin(
      col = "gray30",
      alpha = 1/2,
      trim = TRUE,
      position = position_nudge(
        x = 0.2,
        y = 0)) +
    
    geom_point(
      position = position_jitter(width = 0.15),
      alpha = 1,
      size = 1)+
    
    geom_boxplot(
      width=0.2,
      outlier.shape = NA,
      col = "gray30",
      alpha = 1) +
    
    facet_grid( ~ guild)+
    
    labs(
      x = "Ficus species",
      y = expression(paste("Invertebrates abundance per m" ^ 2)) )+
    scale_fill_manual(values = pallete_4) +
    scale_color_manual(values = pallete_4) +
    theme(
      text = element_text(size = text_size),
      legend.position = "none"))

ggsave(
  "fig/guild_abundance/ext_plot_03.pdf",
  ext_plot_03,
  width = PDF_width,
  height = PDF_height,
  units = "in")


#----------------------------------------------------------#
# 6. CHEW -----
#----------------------------------------------------------#

dataset_guild_chew <-
  dataset_guild_abundance %>% 
  filter(guild == "CHEW") %>%
  dplyr::select(TreeID, Hab, Treatment, Spec, guild,  abundance_per_leaf_area) %>% 
  drop_na() %>% 
  mutate_if(is.character,as.factor) %>% 
  mutate(abundance_per_leaf_area = ifelse(
    abundance_per_leaf_area == 0,
    abundance_per_leaf_area + .Machine$double.eps*100,
    abundance_per_leaf_area))

summary(dataset_guild_chew)

# 6.1. model -----

glm_invertebrates_guild_chew_full <-
  glmmTMB(
    abundance_per_leaf_area ~ Hab * Treatment * Spec, 
    data = dataset_guild_chew,
    family = tweedie(),
    na.action = "na.fail")

summary(glm_invertebrates_guild_chew_full)
check_model(glm_invertebrates_guild_chew_full) 
model_performance(glm_invertebrates_guild_chew_full)
check_distribution(glm_invertebrates_guild_chew_full)
qplot(residuals(glm_invertebrates_guild_chew_full))

# calculate
glm_invertebrates_guild_chew_dd <-  
  pdredge(
    glm_invertebrates_guild_chew_full,
    trace = T)

# save result table
glm_invertebrates_guild_chew_dd %>% 
  as_tibble() %>% 
  write_csv("data/output/invertebrates_chew_model_result.csv")

# observe the best model
glm_invertebrates_guild_chew_dd %>% 
  as_tibble() %>% 
  filter(delta < 2 ) %>% 
  View()


glm_invertebrates_guild_chew_select <- 
  glmmTMB(
    abundance_per_leaf_area ~ Hab + Treatment,
    data = dataset_guild_chew,
    family = tweedie(),
    na.action = "na.fail")


summary(glm_invertebrates_guild_chew_select)
check_model(glm_invertebrates_guild_chew_select)
model_performance(glm_invertebrates_guild_chew_select)
check_distribution(glm_invertebrates_guild_chew_select)
qplot(residuals(glm_invertebrates_guild_chew_select))

# 6.2. plot -----

# calculate emmeans
glm_invertebrates_guild_chew_emmeans_treat <-
  emmeans(
    glm_invertebrates_guild_chew_select,
    pairwise ~ Treatment,
    type = "response") 


(model_plot_chew_01 <-
    glm_invertebrates_guild_chew_emmeans_treat$emmeans %>% 
    as_tibble() %>% 
    ggplot(
      aes(
        x = Treatment,
        y = response,
        col = Treatment,
        fill = Treatment)) +
    
    geom_point(
      data = dataset_guild_chew,
      aes(y = abundance_per_leaf_area),
      alpha = 1,
      position = position_jitterdodge(
        dodge.width = 0.5,
        jitter.width = 0.15)) +
    
    geom_errorbar(
      aes(
        ymin =  lower.CL,
        ymax = upper.CL),
      width = 0.2,
      position = position_dodge(width = 0.5, preserve = "single"),
      size = 1)+
    
    geom_point(
      shape = 0,
      size = 3,
      position = position_dodge(width = 0.5)) +
    
    labs(
      x = "Treatment",
      y = expression(paste("Invertebrates abundance per m" ^ 2)),
      title = "CHEW") +
    scale_color_manual(values = pallete_1) +
    scale_fill_manual(values = pallete_1) +
    theme(
      text = element_text(size = text_size),
      legend.position = "none"))



# save the pairwise test 
glm_invertebrates_guild_chew_emmeans_treat$contrasts %>% 
  as_tibble() %>% 
  arrange(p.value) %>% 
  write_csv("data/output/invertebrates_chew_pairwise_test.csv")


#----------------------------------------------------------#
# 7. PRE -----
#----------------------------------------------------------#

dataset_guild_pre <-
  dataset_guild_abundance %>% 
  filter(guild == "PRE") %>%
  dplyr::select(TreeID, Hab, Treatment, Spec, guild,  abundance_per_leaf_area) %>% 
  drop_na() %>% 
  mutate_if(is.character,as.factor) %>% 
  mutate(abundance_per_leaf_area = ifelse(
    abundance_per_leaf_area == 0,
    abundance_per_leaf_area + .Machine$double.eps*100,
    abundance_per_leaf_area))

summary(dataset_guild_pre)

# 7.1. model -----

glm_invertebrates_guild_pre_full <-
  glmmTMB(
    abundance_per_leaf_area ~ Hab * Treatment * Spec, 
    data = dataset_guild_pre,
    family = gaussian(link = "log"),
    na.action = "na.fail")

summary(glm_invertebrates_guild_pre_full)
check_model(glm_invertebrates_guild_pre_full) 
model_performance(glm_invertebrates_guild_pre_full)
check_distribution(glm_invertebrates_guild_pre_full)
qplot(residuals(glm_invertebrates_guild_pre_full))

# calculate
glm_invertebrates_guild_pre_dd <-  
  pdredge(
    glm_invertebrates_guild_pre_full,
    trace = T)

# save result table
glm_invertebrates_guild_pre_dd %>% 
  as_tibble() %>% 
  write_csv("data/output/invertebrates_pre_model_result.csv")

# observe the best model
glm_invertebrates_guild_pre_dd %>% 
  as_tibble() %>% 
  filter(delta < 2 ) %>% 
  View()


glm_invertebrates_guild_pre_m1 <- 
  glmmTMB(
    abundance_per_leaf_area ~ Hab,
    data = dataset_guild_pre,
    family = gaussian(link = "log"),
    na.action = "na.fail")

glm_invertebrates_guild_pre_m2 <- 
  glmmTMB(
    abundance_per_leaf_area ~ Hab + Treatment,
    data = dataset_guild_pre,
    family = gaussian(link = "log"),
    na.action = "na.fail")

compare_performance(
  glm_invertebrates_guild_pre_m1, glm_invertebrates_guild_pre_m2,
  rank = T
)


glm_invertebrates_guild_pre_select <- glm_invertebrates_guild_pre_m2


summary(glm_invertebrates_guild_pre_select)
check_model(glm_invertebrates_guild_pre_select)
model_performance(glm_invertebrates_guild_pre_select)
check_distribution(glm_invertebrates_guild_pre_select)
qplot(residuals(glm_invertebrates_guild_pre_select))

# 7.2. plot -----

# calculate emmeans
glm_invertebrates_guild_pre_emmeans_treat <-
  emmeans(
    glm_invertebrates_guild_pre_select,
    pairwise ~ Treatment,
    type = "response") 


(model_plot_pre_01 <-
    glm_invertebrates_guild_pre_emmeans_treat$emmeans %>% 
    as_tibble() %>% 
    ggplot(
      aes(
        x = Treatment,
        y = response,
        col = Treatment,
        fill = Treatment)) +
    
    geom_point(
      data = dataset_guild_pre,
      aes(y = abundance_per_leaf_area),
      alpha = 1,
      position = position_jitterdodge(
        dodge.width = 0.5,
        jitter.width = 0.15)) +
    
    geom_errorbar(
      aes(
        ymin =  lower.CL,
        ymax = upper.CL),
      width = 0.2,
      position = position_dodge(width = 0.5, preserve = "single"),
      size = 1)+
    
    geom_point(
      shape = 0,
      size = 3,
      position = position_dodge(width = 0.5)) +
    
    labs(
      x = "Treatment",
      y = expression(paste("Invertebrates abundance per m" ^ 2)),
      title = "PRE") +
    scale_color_manual(values = pallete_1) +
    scale_fill_manual(values = pallete_1) +
    theme(
      text = element_text(size = text_size),
      legend.position = "none"))



# save the pairwise test 
glm_invertebrates_guild_pre_emmeans_treat$contrasts %>% 
  as_tibble() %>% 
  arrange(p.value) %>% 
  write_csv("data/output/invertebrates_pre_pairwise_test.csv")


#----------------------------------------------------------#
# 8. NR -----
#----------------------------------------------------------#

dataset_guild_nr <-
  dataset_guild_abundance %>% 
  filter(guild == "NR") %>%
  dplyr::select(TreeID, Hab, Treatment, Spec, guild,  abundance_per_leaf_area) %>% 
  drop_na() %>% 
  mutate_if(is.character,as.factor) %>% 
  mutate(abundance_per_leaf_area = ifelse(
    abundance_per_leaf_area == 0,
    abundance_per_leaf_area + .Machine$double.eps*100,
    abundance_per_leaf_area))

summary(dataset_guild_nr)

# 8.1. model -----

glm_invertebrates_guild_nr_full <-
  glmmTMB(
    abundance_per_leaf_area ~ Hab * Treatment * Spec, 
    data = dataset_guild_nr,
    family = tweedie(),
    na.action = "na.fail")

summary(glm_invertebrates_guild_nr_full)
check_model(glm_invertebrates_guild_nr_full) 
model_performance(glm_invertebrates_guild_nr_full)
check_distribution(glm_invertebrates_guild_nr_full)
qplot(residuals(glm_invertebrates_guild_nr_full))

# calculate
glm_invertebrates_guild_nr_dd <-  
  pdredge(
    glm_invertebrates_guild_nr_full,
    trace = T)

# save result table
glm_invertebrates_guild_nr_dd %>% 
  as_tibble() %>% 
  write_csv("data/output/invertebrates_nr_model_result.csv")

# observe the best model
glm_invertebrates_guild_nr_dd %>% 
  as_tibble() %>% 
  filter(delta < 2 ) %>% 
  View()


glm_invertebrates_guild_nr_select <- 
  glmmTMB(
    abundance_per_leaf_area ~ Treatment,
    data = dataset_guild_nr,
    family = tweedie(),
    na.action = "na.fail")


summary(glm_invertebrates_guild_nr_select)
check_model(glm_invertebrates_guild_nr_select)
model_performance(glm_invertebrates_guild_nr_select)
check_distribution(glm_invertebrates_guild_nr_select)
qplot(residuals(glm_invertebrates_guild_nr_select))

# 8.2. plot -----

# calculate emmeans
glm_invertebrates_guild_nr_emmeans_treat <-
  emmeans(
    glm_invertebrates_guild_nr_select,
    pairwise ~ Treatment,
    type = "response") 


(model_plot_nr_01 <-
    glm_invertebrates_guild_nr_emmeans_treat$emmeans %>% 
    as_tibble() %>% 
    ggplot(
      aes(
        x = Treatment,
        y = response,
        col = Treatment,
        fill = Treatment)) +
    
    geom_point(
      data = dataset_guild_nr,
      aes(y = abundance_per_leaf_area),
      alpha = 1,
      position = position_jitterdodge(
        dodge.width = 0.5,
        jitter.width = 0.15)) +
    
    geom_errorbar(
      aes(
        ymin =  lower.CL,
        ymax = upper.CL),
      width = 0.2,
      position = position_dodge(width = 0.5, preserve = "single"),
      size = 1)+
    
    geom_point(
      shape = 0,
      size = 3,
      position = position_dodge(width = 0.5)) +
    
    labs(
      x = "Treatment",
      y = expression(paste("Invertebrates abundance per m" ^ 2)),
      title = "NR") +
    scale_color_manual(values = pallete_1) +
    scale_fill_manual(values = pallete_1) +
    theme(
      text = element_text(size = text_size),
      legend.position = "none"))


# save the pairwise test 
glm_invertebrates_guild_nr_emmeans_treat$contrasts %>% 
  as_tibble() %>% 
  arrange(p.value) %>% 
  write_csv("data/output/invertebrates_nr_pairwise_test.csv")


#----------------------------------------------------------#
# 9. SUC -----
#----------------------------------------------------------#

dataset_guild_suc <-
  dataset_guild_abundance %>% 
  filter(guild == "SUC") %>%
  dplyr::select(TreeID, Hab, Treatment, Spec, guild,  abundance_per_leaf_area) %>% 
  drop_na() %>% 
  mutate_if(is.character,as.factor) %>% 
  mutate(abundance_per_leaf_area = ifelse(
    abundance_per_leaf_area == 0,
    abundance_per_leaf_area + .Machine$double.eps*100,
    abundance_per_leaf_area))

summary(dataset_guild_suc)

# 9.1. model -----

glm_invertebrates_guild_suc_full <-
  glmmTMB(
    abundance_per_leaf_area ~ Hab * Treatment * Spec, 
    data = dataset_guild_suc,
    family = tweedie(),
    na.action = "na.fail")

summary(glm_invertebrates_guild_suc_full)
check_model(glm_invertebrates_guild_suc_full) 
model_performance(glm_invertebrates_guild_suc_full)
check_distribution(glm_invertebrates_guild_suc_full)
qplot(residuals(glm_invertebrates_guild_suc_full))

# calculate
glm_invertebrates_guild_suc_dd <-  
  pdredge(
    glm_invertebrates_guild_suc_full,
    trace = T)

# save result table
glm_invertebrates_guild_suc_dd %>% 
  as_tibble() %>% 
  write_csv("data/output/invertebrates_suc_model_result.csv")

# observe the best model
glm_invertebrates_guild_suc_dd %>% 
  as_tibble() %>% 
  filter(delta < 2 ) %>% 
  View()


glm_invertebrates_guild_suc_m1 <- 
  glmmTMB(
    abundance_per_leaf_area ~ 1,
    data = dataset_guild_suc,
    family = tweedie(),
    na.action = "na.fail")

glm_invertebrates_guild_suc_m2 <- 
  glmmTMB(
    abundance_per_leaf_area ~ Treatment,
    data = dataset_guild_suc,
    family = tweedie(),
    na.action = "na.fail")

compare_performance(
  glm_invertebrates_guild_suc_m1, glm_invertebrates_guild_suc_m2,
  rank = T
)

glm_invertebrates_guild_suc_select <- glm_invertebrates_guild_suc_m2


summary(glm_invertebrates_guild_suc_select)
check_model(glm_invertebrates_guild_suc_select)
model_performance(glm_invertebrates_guild_suc_select)
check_distribution(glm_invertebrates_guild_suc_select)
qplot(residuals(glm_invertebrates_guild_suc_select))

# 9.2. plot -----

# calculate emmeans
glm_invertebrates_guild_suc_emmeans_treat <-
  emmeans(
    glm_invertebrates_guild_suc_select,
    pairwise ~ Treatment,
    type = "response") 


(model_plot_suc_01 <-
    glm_invertebrates_guild_suc_emmeans_treat$emmeans %>% 
    as_tibble() %>% 
    ggplot(
      aes(
        x = Treatment,
        y = response,
        col = Treatment,
        fill = Treatment)) +
    
    geom_point(
      data = dataset_guild_suc,
      aes(y = abundance_per_leaf_area),
      alpha = 1,
      position = position_jitterdodge(
        dodge.width = 0.5,
        jitter.width = 0.15)) +
    
    geom_errorbar(
      aes(
        ymin =  lower.CL,
        ymax = upper.CL),
      width = 0.2,
      position = position_dodge(width = 0.5, preserve = "single"),
      size = 1)+
    
    geom_point(
      shape = 0,
      size = 3,
      position = position_dodge(width = 0.5)) +
    
    labs(
      x = "Treatment",
      y = expression(paste("Invertebrates abundance per m" ^ 2)),
      title = "SUC") +
    scale_color_manual(values = pallete_1) +
    scale_fill_manual(values = pallete_1) +
    theme(
      text = element_text(size = text_size),
      legend.position = "none"))



# save the pairwise test 
glm_invertebrates_guild_suc_emmeans_treat$contrasts %>% 
  as_tibble() %>% 
  arrange(p.value) %>% 
  write_csv("data/output/invertebrates_suc_pairwise_test.csv")

#----------------------------------------------------------#
# 10. Summary -----
#----------------------------------------------------------#

model_plot_guild_01 <- 
  ggarrange(
    
    model_plot_chew_01 + 
      scale_y_continuous(limits = c(0,150)) +
      rremove("xylab"),
    
    model_plot_pre_01 +
      scale_y_continuous(limits = c(0,150)) +
      rremove("xylab") +
      rremove("y.text"),
    
    model_plot_nr_01 + 
      scale_y_continuous(limits = c(0,150)) +
      rremove("xylab") +
      rremove("y.text"),
    
    model_plot_suc_01 + 
      scale_y_continuous(limits = c(0,150)) +
      rremove("xylab") + 
      rremove("y.text"),
    
    nrow = 1,
    align = "hv" ) %>% 
  annotate_figure(
    left = text_grob(
      expression(paste("Invertebrates abundance per m" ^ 2)),
      size = text_size,
      rot = 90),
    bottom = text_grob(
      "Treatment",
      size = text_size)
  )


# save pdf
ggsave(
  "fig/guild_abundance/model_plot_01.pdf",
  model_plot_guild_01,
  width = PDF_width,
  height = PDF_height,
  units = "in")