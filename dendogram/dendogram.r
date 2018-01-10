# dendogram.r
# http://www.sthda.com/english/articles/28-hierarchical-clustering-essentials/92-visualizing-dendrograms-ultimate-guide/?utm_content=buffer4e393&utm_medium=social&utm_source=twitter.com&utm_campaign=buffer

library(tidyverse)
library(tibble)
library(factoextra)
library(dendextend)
library(hrbrthemes)

# Data processing
data <- read.csv2("data.csv") 
data <- data  %>% filter(Minutes.played>=3000, Goals.per.90>=0.3) %>% column_to_rownames('Player') %>% select(-Position)

data = data %>% select(Dribbles.per.90,Goals.per.90)

dd <- dist(scale(data), method = "euclidean")
hc <- hclust(dd, method = "ward.D2")

dend <- fviz_dend(hc, k = 4, # Cut in four groups
          cex = 0.5, # label size
          #k_colors = c("#2E9FDF", "#00AFBB", "#E7B800", "#FC4E07"),
          color_labels_by_k = TRUE, # color labels by groups
          #rect = TRUE, # Add rectangle around groups
          #rect_border = c("#2E9FDF", "#00AFBB", "#E7B800", "#FC4E07"), 
          #rect_fill = TRUE,
          horiz = TRUE)

dend + theme_ipsum_rc() + labs(x="", y="Distance",title="Cluster Dendogram",subtitle="Hierarchical clustering with Dribbles and Goals per 90 minutes",caption='by Benoit Pimpaud / @Ben8t',color="") + theme(axis.ticks=element_blank(),panel.grid.major = element_blank(), panel.grid.minor = element_blank(),panel.background = element_blank())
