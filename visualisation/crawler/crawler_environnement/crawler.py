# https://krbnite.github.io/Driving-Headless-Chrome-with-Selenium-on-AWS-EC2/
# https://gist.github.com/ziadoz/3e8ab7e944d02fe872c3454d17af31a5
import requests
from lxml import html
import re
import json
from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.common.keys import Keys 


service = webdriver.chrome.service.Service('/usr/local/bin/chromedriver')
service.start()  
options = webdriver.ChromeOptions()                
options.add_argument('--headless')
options = options.to_capabilities()
driver = webdriver.Remote(service.service_url, options)

url = "https://whoscored.com"

driver.get(url)
response = driver.page_source

soup = BeautifulSoup(response,"lxml")
data = soup.findAll('div',attrs={'class':'post-match'})

games_url = []
for div in data:
    links = div.findAll('a')
    for a in links:
        games_url.append("https://whoscored.com" + a['href'])

with open("url.txt", "w") as outfile:
    for line in games_url:
        outfile.write("%s\n" % line)

driver.close()

for url in games_url:
    print url
    service = webdriver.chrome.service.Service('/usr/local/bin/chromedriver')
    service.start()  
    options = webdriver.ChromeOptions()                
    options.add_argument('--headless')
    options = options.to_capabilities()
    driver = webdriver.Remote(service.service_url, options)
    driver.get(url)
    #response = requests.get(url,headers={'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36'})
    #tree = html.fromstring(response.content)
    #print response.content
    response = driver.page_source
    tree = html.fromstring(response.text)
    data = tree.xpath('//*[@id="layout-content-wrapper"]/script[1]/text()')[0].strip()
    processed_data = re.search("\\{.*\\}", data, re.IGNORECASE)

    if processed_data:
        json_data = processed_data.group()

    loaded_data = json.loads(json_data)

    with open('data_'+ url.split("/")[-1]+'.json', 'w') as outfile:
        json.dump(loaded_data, outfile)
