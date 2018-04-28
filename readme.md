# FootScrapeViz repository

This repository consist of data-visualization and some R scripts on football data.
Most of these works are developed in R, especially with :

* dplyr
* ggplot2
* rvest

and all the awesome tidyverse...

## More developed works

### Maps

It's better to see directly [details here](https://github.com/DevBen8/FootScrapeViz/tree/master/Maps). Inspired by [@11tegen11](https://twitter.com/11tegen11) on Twitter.

While data is the main problem for that kind of plot, I found that WhoScored let they data in their javascript. I dev a crawler to get them easly and save them into a json file.

This work live now in a webapp (beta) : [passnetwork.pimpaudben.fr](passnetwork.pimpaudben.fr)
![example pass network](Maps/img/passnetwork/arsenal/arsenal03012018.jpg)

![example shot map](Maps/img/shotmap/realmadrid14022017.jpg)
### Lineup

Plot lineups evolution

![image](lineup/img/arsenal_lineup.png)

### PCA

![image](PCA/ozil_comparison.png)

### Dendogram (hierarchical clustering)

![image](dendogram/dribble_goals.png)

### Others

There are also classic stuff like barchart or piechart...
