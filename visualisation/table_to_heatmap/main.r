library(dplyr)
library(ggplot)
library(viridis)

data %>% na.omit() %>%
    rownames_to_column("row") %>%
    gather(col, Value, -row) %>%
    mutate(
        row = factor(row, levels = rev(unique(row))),
        Value = Value) %>% arrange(desc(Value)) %>%
    ggplot(aes(x=reorder(row, Value), y=col, fill = Value)) +
    geom_tile() +
    scale_fill_viridis(option="magma") + 
    theme_minimal() + 
    labs(x="", y="") +
    theme(legend.position = "none") +
    theme(axis.title.x=element_blank(),
          axis.text.x=element_blank(),
          axis.ticks.x=element_blank()) + 
    theme(axis.title.y=element_blank(),
          axis.text.y=element_blank(),
          axis.ticks.y=element_blank())