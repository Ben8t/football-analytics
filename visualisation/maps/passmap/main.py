from flask import Flask
from flask import request, render_template
from src.crawler import download_data, last_whoscored_games
import subprocess
import os
import sys

app = Flask(__name__, template_folder="public", static_folder="public")

@app.route('/')
def home():
    last_urls = last_whoscored_games()
    return render_template('index.html', last_urls=last_urls)

@app.route('/result', methods = ['POST'])
def result():
    game_url = request.form['game_url']
    last_urls = last_whoscored_games()
    folder = download_data(game_url)
    subprocess.run(["Rscript", "passnetwork.r", folder.replace("./", "") + "/"])
    subprocess.run(["Rscript", "passsonar.r", folder.replace("./", "") + "/"])
    return render_template("index.html", folder=folder, last_urls=last_urls)


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')