# to integrate with football pitch
stat_density2d(data=alonso_data, aes(x=x,y=y,fill=..level..,alpha=..level..),geom="polygon",colour="#eee9d6", show.legend=FALSE) +
lims(x = c(-5,113),y = c(-5,73)) + 
scale_fill_gradient2(low = "#218c74", mid="#227093", high = "#34ace0")
