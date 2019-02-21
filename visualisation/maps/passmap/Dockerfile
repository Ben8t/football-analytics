FROM atavares/rocker-geospatial-magick

RUN apt-get -qq update -y && \
    apt-get install curl -y && \
    apt-get install unzip -y && \
    apt-get -y install python3 python3-pip python3-pandas python-urllib3 && \
    apt-get install -my wget gnupg

# Install Chrome WebDriver
RUN CHROMEDRIVER_VERSION=`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE` && \
    mkdir -p /opt/chromedriver-$CHROMEDRIVER_VERSION && \
    curl -sS -o /tmp/chromedriver_linux64.zip http://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux64.zip && \
    unzip -qq /tmp/chromedriver_linux64.zip -d /opt/chromedriver-$CHROMEDRIVER_VERSION && \
    rm /tmp/chromedriver_linux64.zip && \
    chmod +x /opt/chromedriver-$CHROMEDRIVER_VERSION/chromedriver && \
    ln -fs /opt/chromedriver-$CHROMEDRIVER_VERSION/chromedriver /usr/local/bin/chromedriver

# Install Google Chrome
RUN curl -sS -o - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list && \
    apt-get -yqq update && \
    apt-get -yqq install google-chrome-stable && \
    rm -rf /var/lib/apt/lists/*

# Install python dependencies
RUN pip3 install urllib3==1.23 && \
    pip3 install requests && \
    pip3 install flask && \
    pip3 install pandas && \
    pip3 install lxml && \
    pip3 install beautifulsoup4 && \
    pip3 install selenium && \
    pip3 install dropbox

# Install R dependencies
RUN apt-get update -y && \
    apt-get install libssl-dev -y && \
    apt-get install libmagick++-dev -y && \
    apt-get install libcurl4-openssl-dev -y && \
    Rscript -e "install.packages('dplyr', repos='http://cran.rstudio.com/')" && \
    Rscript -e "install.packages('ggplot2', repos='http://cran.rstudio.com/')" && \
    Rscript -e "install.packages('rvest', repos='http://cran.rstudio.com/')" && \
    Rscript -e "install.packages('hrbrthemes', repos='http://cran.rstudio.com/')" && \
    Rscript -e "install.packages('jsonlite', repos='http://cran.rstudio.com/')" && \
    Rscript -e "install.packages('igraph', repos='http://cran.rstudio.com/')" && \
    Rscript -e "install.packages('ggnetwork', repos='http://cran.rstudio.com/')" && \
    Rscript -e "install.packages('intergraph', repos='http://cran.rstudio.com/')" && \
    Rscript -e "install.packages('magick', repos='http://cran.rstudio.com/')" && \
    Rscript -e "install.packages('ggforce', repos='http://cran.rstudio.com/')" && \
    Rscript -e "install.packages('gtable', repos='http://cran.rstudio.com/')" && \
    Rscript -e "install.packages('gridExtra', repos='http://cran.rstudio.com/')" && \
    Rscript -e "install.packages('grid', repos='http://cran.rstudio.com/')"

WORKDIR /data/visualisation/maps/passmap

CMD python3 -m main
