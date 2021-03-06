#----------------------------------------------------------#
#
#
#                Exclosure experiment PNG
#
#                       Leaf area
#
#             Ondrej Mottl - Marketa Tahadlova
#                         2020
#
#----------------------------------------------------------#

source("R/00_config.R")

#----------------------------------------------------------#
# 4. Leaf area exporatory figures -----
#----------------------------------------------------------#

library(see)

# per treatments
(ext_plot_01 <- 
   dataset_fin %>% 
   ggplot(
     aes(
       x = Treatment,
       y = leaf_area_total,
       fill = Treatment,
       col = Treatment)) +
   
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
     size = 1) +
   
   geom_boxplot(
     width=0.2,
     outlier.shape = NA,
     col = "gray30",
     alpha = 1) +
   
   labs(
     x = "Treatment", 
     y = expression(paste("Total leaf area per tree individual (m" ^ 2,")"))) +
   scale_fill_manual(values = pallete_1) +
   scale_color_manual(values = pallete_1) +
   theme(
     text = element_text(size = text_size),
     legend.position = "none"))

ggsave(
  "fig/leaf_area/ext_plot_01.pdf",
  ext_plot_01,
  width = PDF_width,
  height = PDF_height,
  units = "in")

# per habitat
(ext_plot_02 <- 
    dataset_fin %>% 
    ggplot(
      aes(
        x = Hab,
        y = leaf_area_total,
        fill = Hab,
        col = Hab)) +
    
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
    
    labs(
      x = "Habitat",
      y = expression(paste("Total leaf area per tree individual (m" ^ 2,")")) )+
    scale_fill_manual(values = pallete_2)+
    scale_color_manual(values = pallete_2)+
    theme(
      text = element_text(size = text_size),
      legend.position = "none"))

ggsave(
  "fig/leaf_area/ext_plot_02.pdf",
  ext_plot_02,
  width = PDF_width,
  height = PDF_height,
  units = "in")


# per species
(ext_plot_03 <- 
    dataset_fin %>% 
    ggplot(
      aes(
        x = Spec,
        y = leaf_area_total,
        fill = Spec,
        col = Spec)) +
    
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
    
    labs(
      x = "Species",
      y = expression(paste("Total leaf area per tree individual (m" ^ 2,")")) )+
    scale_fill_manual(values = pallete_3)+
    scale_color_manual(values = pallete_3)+
    theme(
      text = element_text(size = text_size),
      legend.position = "none"))

ggsave(
  "fig/leaf_area/ext_plot_03.pdf",
  ext_plot_03,
  width = PDF_width,
  height = PDF_height,
  units = "in")

library (randomForest)

#----------------------------------------------------------#
# 5. Model build -----
#----------------------------------------------------------#

dataset_leaf_area <-
  dataset_fin %>% 
  mutate_if(is.character,as.factor) %>% 
  dplyr::select( Hab, Treatment, Spec, TreeID, leaf_area_total) %>% 
  drop_na() %>% 
  mutate_if(is.character,as.factor)
  

summary(dataset_leaf_area)

# cretae full model with all interaction
glm_leaf_area_full <-
  glmmTMB(leaf_area_total ~ Hab * Treatment * Spec,
      data = dataset_leaf_area,
      family = Gamma(),
      na.action = "na.fail")

summary(glm_leaf_area_full)
check_model(glm_leaf_area_full) 
check_distribution(glm_leaf_area_full)
model_performance(glm_leaf_area_full)
qplot(residuals(glm_leaf_area_full))
check_heteroscedasticity(glm_leaf_area_full)

# compute all posible combinations
glm_leaf_area_dd <- 
  MuMIn::dredge(
    glm_leaf_area_full,
    trace = T)

# save result table
glm_leaf_area_dd %>% 
  as_tibble() %>% 
  write_csv("data/output/leaf_area_model_result.csv")

# observe the best model
glm_leaf_area_dd %>% 
  as_tibble() %>% 
  filter(delta < 2 ) %>% 
  View()

# fit the all the models with similar parsimony
glm_leaf_m1 <- 
  glm(leaf_area_total ~ Hab,
      data = dataset_leaf_area,
      family = Gamma(),
      na.action = "na.fail")

glm_leaf_m2 <- 
  glm(leaf_area_total ~ Hab + Treatment,
      data = dataset_leaf_area,
      family = Gamma(),
      na.action = "na.fail")


# compare models
compare_performance(
  glm_leaf_m1, glm_leaf_m2,
  rank = TRUE) 

compare_performance(
  glm_leaf_m1, glm_leaf_m2,
  rank = TRUE) %>% 
  as_tibble() %>% 
  write_csv("data/output/leaf_area_model_performance_comparison.csv")

# m1 is better
glm_leaf_area_select <- glm_leaf_m1

summary(glm_leaf_area_select)
check_model(glm_leaf_area_select)
model_performance(glm_leaf_area_select)
check_heteroscedasticity(glm_leaf_area_select)
qplot(residuals(glm_leaf_area_select))


# calculate emmeans
glm_leaf_area_emmeans <-
  emmeans(
    glm_leaf_area_select,
    pairwise ~ Hab,
    type = "response") 

(model_plot_01 <- 
  glm_leaf_area_emmeans$emmeans %>% 
  as_tibble() %>% 
  ggplot(
    aes(
      x = Hab,
      y = response,
      col = Hab)) + 
  
  geom_point(
    data = dataset_leaf_area,
    aes(y = leaf_area_total),
    alpha = 1,
    position = position_jitterdodge(
      dodge.width = 0.5,
      jitter.width = 0.15)) +
  
  geom_errorbar(
    aes(
      ymin =  asymp.LCL,
      ymax = asymp.UCL),
    width=0.2,
    position = position_dodge(width = 0.5, preserve = "single"),
    size = 1)+
  
  geom_point(
    shape = 0,
    position = position_dodge(width = 0.5),
    size = 3) +
  
  labs(
    x = "Habitat",
    y = expression(paste("Total leaf area per tree individual (m" ^ 2,")")) ) +
  scale_color_manual(values = pallete_2) +
  theme(
    text = element_text(size = text_size),
    legend.position = "right"))

# save pdf
ggsave(
  "fig/leaf_area/model_plot_01.pdf",
  model_plot_01,
  width = PDF_width,
  height = PDF_height,
  units = "in")

# save the pairwise test 
glm_leaf_area_emmeans$contrasts %>% 
  as_tibble() %>% 
  arrange(p.value) %>% 
  write_csv("data/output/leaf_area_pairwise_contrast.csv")

glm_leaf_area_emmeans$emmeans %>% 
  as_tibble() %>% 
  write_csv("data/output/leaf_area_pairwise_emmeans.csv")

