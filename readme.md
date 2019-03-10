# Football Models and Visualisations

---

This repository is a personal project where I develop football models and visualisations.

It's build on top of different technologies such as:
* Python: for data processing and machine learning (Tensorflow, Scikit-Learn and MLFlow).
* R: all data-visualisation stuff (dplyr, ggplot2, magick).
* Postgres SQL: storing and querying data easily.
* Docker: to orchestrate all these elements together and easy install/startup.

## Samples & Results

![pass-network](https://pbs.twimg.com/media/Dw-y1twX0AESyYK.jpg)

![pass-sonar](https://pbs.twimg.com/media/DwBMF3wXQAIsQPB.jpg)

![assist-shot cluster map](visualisation/maps/assist_shot_cluster_map/img/arsenal1819_cluster10_assists_shots_cluster_map.png)

![rollmean](visualisation/rollmean/img/manU_xgvs_xgc.png)

![xg-map](visualisation/maps/xg_map/img/lacazette_xgmap.jpg)

![xa-map](visualisation/maps/xa_map/img/lukaku_xa_map_1718.jpg)

![image](visualisation/lineup/img/arsenal_lineup.png)

![image](visualisation/PCA/ozil_comparison.png)

![image](visualisation/dendogram/dribble_goals.png)




## Architecture

The project contains five folders:

* `./app` : maybe deprecated design, mostly for data integration and easy of use.
* `./data`: where raw data are stored (in addition to the database). Not in git :wink:.
* `./model`: machine learning models (expected goal for example).
* `./src`: source file for crawlers, database connection/ingestion, SQL queries, etc...
* `./visualisation`: source code for data-visualization, most recent works (on maps) are in `./visualisation/maps` subfolders.

## TODO

* Improve models
* [WIP] Moving to [MLFlow](https://www.mlflow.org/docs/latest/index.html) for modelisation setup.


## Contacts
This folder is a kind of POC toolkit for me, so it is not necessarily clean. I try to keep things organized anyway. Any questions/improves on [Twitter @Ben8t](https://twitter.com/Ben8t).
