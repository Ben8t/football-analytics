library(tidyverse)
library(ggplot)
library(viridis)
library(gghighlight)

set.seed(42)
cluster_number = 10
kmeans_result = kmeans(test %>% na.omit(), cluster_number)
cluster_centroid = kmeans_result$centers %>% as.data.frame() %>% mutate(size=kmeans_result$size,cluster_name=c(LETTERS, sapply(LETTERS, function(x) paste0(x, LETTERS)))[1:cluster_number])


ggplot(cluster_centroid) + 
    geom_segment(aes(x=pass0_x_begin, y=pass0_y_begin, xend=pass0_x_end, yend=pass0_y_end, color=cluster_name), size=1,
                lineend='butt',
                linejoin='mitre',
                arrow = arrow(length = unit(0.25, "cm"),type="closed")) + 
    geom_segment(aes(x=pass1_x_begin, y=pass1_y_begin, xend=pass1_x_end, yend=pass1_y_end, color=cluster_name), size=1,
                lineend='butt',
                linejoin='mitre',
                arrow = arrow(length = unit(0.25, "cm"),type="closed")) + 
    geom_segment(aes(x=pass2_x_begin, y=pass2_y_begin, xend=pass2_x_end, yend=pass2_y_end, color=cluster_name), size=1,
                lineend='butt',
                linejoin='mitre',
                arrow = arrow(length = unit(0.25, "cm"),type="closed")) + 
    geom_segment(aes(x=pass3_x_begin, y=pass3_y_begin, xend=pass3_x_end, yend=pass3_y_end, color=cluster_name), size=1,
                lineend='butt',
                linejoin='mitre',
                arrow = arrow(length = unit(0.25, "cm"),type="closed")) + 
    geom_segment(aes(x=pass4_x_begin, y=pass4_y_begin, xend=pass4_x_end, yend=pass4_y_end, color=cluster_name), size=1,
                lineend='butt',
                linejoin='mitre',
                arrow = arrow(length = unit(0.25, "cm"),type="closed")) + 
    geom_segment(aes(x=pass5_x_begin, y=pass5_y_begin, xend=pass5_x_end, yend=pass5_y_end, color=cluster_name), size=1,
                lineend='butt',
                linejoin='mitre',
                arrow = arrow(length = unit(0.25, "cm"),type="closed")) + 
    geom_text(data=cluster_centroid, aes(x=pass2_x_end, y=pass2_y_end, label=cluster_name, colour=cluster_name),
        hjust=-1.2, 
        vjust=1.2) + 
    scale_color_viridis_d() + 
    gghighlight(max(size) > 200) +
    theme_minimal() + 
    labs(x="", y="") +
    theme(legend.position="none") +
    theme(axis.title.x=element_blank(),
          axis.text.x=element_blank(),
          axis.ticks.x=element_blank()) + 
    theme(axis.title.y=element_blank(),
          axis.text.y=element_blank(),
          axis.ticks.y=element_blank()) + 
    theme(rect = element_blank(), #remove additional ggplot2 features: lines, axis, etc...
        line = element_blank(),axis.title.y = element_blank())