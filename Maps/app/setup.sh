# setup.sh

# link
# https://support.rstudio.com/hc/en-us/articles/115003717168-Shiny-Server-Error-Logs
# https://towardsdatascience.com/how-to-host-a-r-shiny-app-on-aws-cloud-in-7-simple-steps-5595e7885722
# http://www.exegetic.biz/blog/2015/05/hosting-shiny-on-amazon-ec2/


# install ubuntu depencies
sudo apt-get update
sudo apt-get install libxml2-dev
sudo apt-get install libcurl4-openssl-dev
sudo apt-get install libssl-dev
sudo apt-get install libmagick++-dev

# install r and r shiny server
sudo apt-get install r-base
sudo su - -c "R -q -e \"install.packages('shiny', repos='http://cran.rstudio.com/')\""
sudo apt-get install gdebi-core
wget https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-1.5.7.907-amd64.deb
sudo gdebi shiny-server-1.5.7.907-amd64.deb

sudo chmod 777 /srv/shiny-server
sudo mkdir /srv/shiny-server/passnetwork
sudo chmod 777 /etc/shiny-server

# don't forget to chmod all image in directory
# install packages

sudo su - -c "R -q -e \"install.packages('dplyr', repos='http://cran.rstudio.com/')\""
sudo su - -c "R -q -e \"install.packages('ggplot2', repos='http://cran.rstudio.com/')\""
sudo su - -c "R -q -e \"install.packages('rvest', repos='http://cran.rstudio.com/')\""
sudo su - -c "R -q -e \"install.packages('hrbrthemes', repos='http://cran.rstudio.com/')\""
sudo su - -c "R -q -e \"install.packages('jsonlite', repos='http://cran.rstudio.com/')\""
sudo su - -c "R -q -e \"install.packages('igraph', repos='http://cran.rstudio.com/')\""
sudo su - -c "R -q -e \"install.packages('ggnetwork', repos='http://cran.rstudio.com/')\""
sudo su - -c "R -q -e \"install.packages('magick', repos='http://cran.rstudio.com/')\""
sudo su - -c "R -q -e \"install.packages('colourpicker', repos='http://cran.rstudio.com/')\""
sudo su - -c "R -q -e \"install.packages('shinythemes', repos='http://cran.rstudio.com/')\""
sudo su - -c "R -q -e \"install.packages('intergraph', repos='http://cran.rstudio.com/')\""

# how to restart server
# sudo systemctl restart shiny-server
# sudo systemctl status shiny-server
# sudo systemctl start shiny-server
# sudo systemctl stop shiny-server

# log can be find in  (as example) /var/log/shiny-server/passnetwork-shiny-20180413-173651-46455.log 


