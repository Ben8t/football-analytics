# Passnetwork with R

Create passnetwork thanks to data from WhoScored.com (Opta) in R with `igraph` library. 

## Gather data from Whoscored
You can get data directly from WhoScored with copy-paste command below in web navigator javascript console.
`copy(JSON.stringify(matchCentreData));`
This command put a json object in your clipboard that you can paste in a json file.

## PassNetwork builder
Run this command in a shell: 
`Rscript passNetwork.r "data/data.json" "home" "#90caf9"`
Which generate `g_passnetwork_tmp.png`.

