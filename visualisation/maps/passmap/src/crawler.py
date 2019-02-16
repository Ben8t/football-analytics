import requests
from lxml import html
import os
import shutil
import re
import json
import sys
from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.common.keys import Keys


def last_whoscored_games():
    """
    Retrieve last WhoScored games (home page match slider)
    """
    url = "https://whoscored.com"
    options = webdriver.ChromeOptions()
    options.add_argument('headless')
    options.add_argument('--no-sandbox')
    driver = webdriver.Chrome(chrome_options=options)
    driver.implicitly_wait(30)
    driver.get(url)
    response = driver.page_source
    soup = BeautifulSoup(response, "lxml")
    data = soup.findAll('div', attrs={'class': 'post-match'})
    games_url = []
    for div in data:
        links = div.findAll('a')
        for a in links:
            games_url.append("https://whoscored.com" + a['href'])
    print(games_url)
    return games_url


def download_data(url):
    """
    Download games data and teams logo images, games data are writed into data/folder/data.json and 
    images as data/folder/home|away_logo.png
    :param url: url to download data
    :return: folder contaning downloaded data and images
    """
    options = webdriver.ChromeOptions()
    options.add_argument('headless')
    options.add_argument('--no-sandbox')
    driver = webdriver.Chrome(chrome_options=options)
    driver.implicitly_wait(30)

    folder_name = "data/" + url.split("/")[-1]
    file_name = "{folder_name}/data.json".format(folder_name=folder_name)
    if os.path.exists(folder_name):
        shutil.rmtree(folder_name)
    os.makedirs(folder_name)

    # Download game data
    driver.get(url)
    response = driver.page_source
    tree = html.fromstring(response)

    data = tree.xpath('//*[@id="layout-content-wrapper"]/script[1]/text()')[0].strip()
    processed_data = re.search("\\{.*\\}", data, re.IGNORECASE)
    if processed_data:
        json_data = processed_data.group()

    loaded_data = json.loads(json_data)

    with open(file_name, 'w') as outfile:
        json.dump(loaded_data, outfile)

    # Download teams logo
    soup = BeautifulSoup(response, "lxml")
    match_header = soup.findAll('div', attrs={'class': 'match-header'})
    images = [img["src"] for img in match_header[0].findAll("img")]
    team_images = {
        "home": images[0],
        "away": images[1]
    }

    for team, image in team_images.items():
        response = requests.get(image).content
        with open("{folder_name}/{team}_logo.png".format(folder_name=folder_name, team=team), "wb") as file:
            file.write(response)

    return folder_name

if __name__ == "__main__":
    url = sys.argv[1]
    download_data(url)
