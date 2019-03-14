"""
WhoScoredToDataBase.py
Connector to transform WhoScored (Opta) data to relational database
"""
import json
from lxml import html
import os
import re
import requests
from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.common.keys import Keys

class WhoScoredCrawler():

    def __init__(self):
        """
        """
        options = webdriver.ChromeOptions()
        options.add_argument('headless')
        options.add_argument('--no-sandbox')
        driver = webdriver.Chrome(chrome_options=options)
        driver.implicitly_wait(30)
        self.__driver = driver

    def crawl(self, url):
        """
        Crawl data from url
        :param url: a WhoScored URL
        :return file_path: file path
        """
        file_path = "data/raw/" + url.split("/")[-1].replace("\n","") + ".json"
        if os.path.isfile(file_path):
            print("Data already download: ", file_path)
            return  
        print("Processing: ", url)
        self.__driver.get(url)
        response = self.__driver.page_source
        tree = html.fromstring(response)
        data = tree.xpath('//*[@id="layout-content-wrapper"]/script[1]/text()')[0].strip()
        processed_data = re.search("\\{.*\\}", data, re.IGNORECASE)
        if processed_data:
            json_data = processed_data.group()

        loaded_data = json.loads(json_data)

        with open(file_path, 'w') as outfile:
            json.dump(loaded_data, outfile)

        self.__download_images(loaded_data)
        return file_path
    

    def __download_images(self, json_data):
        """
        Download team logo images (thanks to team id)
        :param json_data: loaded data to gather team id
        """
        base_url = "https://d2zywfiolv4f83.cloudfront.net/img/teams/"
        team_id = [str(json_data["home"]["teamId"]), str(json_data["away"]["teamId"])]
        for id in team_id:
            response = requests.get(base_url + id + ".png").content
            with open("data/images/" + id + ".png", "wb") as file:
                file.write(response)

    def close(self):
        self.__driver.quit()