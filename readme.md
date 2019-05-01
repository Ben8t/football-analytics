# Football Models and Visualisations

---

This repository is a personal project where I develop football models and visualisations.

It's build on top of different technologies such as:
* Python: for data processing and machine learning (Tensorflow, Scikit-Learn and MLFlow).
* R: all data-visualisation stuff (dplyr, ggplot2, magick).
* Postgres SQL: storing and querying data easily.
* Docker: to orchestrate all these elements together and easy install/startup.
* Google Cloud Plateform: to run heavy jobs in cloud.

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


## Usage

### Running model applications

1. Start corresponding container: `docker-compose up -d model`.
2. For ease of use, going into the container: `docker exec -it model bash`
3. All data are mapped to the local environment: `cd /data`
* Expected goal model: `python -m model.expected_goal.main --help`.
* Expected assist model: `python -m model.expected_assist.main --help`.
* Possession2Vec model: `python -m model.pass2vec.main --help`

### Running Passmaps vizualisations

1. Start corresponding container: `docker-compose up -d passmap`.
2. Go to `http://localhost:8082/`.


## TODO

* Improve models
* Add more documentations.
* Clean some viz stuff.
* Better Docker management.


## Contacts
Any questions/improves on [Twitter @Ben8t](https://twitter.com/Ben8t).
