from flask import Flask
from flask import request, render_template, send_file
from src.crawler import download_data, last_whoscored_games
import subprocess
import os
import sys
import time
import zipfile

app = Flask(__name__, template_folder="public", static_folder="public")

@app.route('/')
def home():
    last_urls = last_whoscored_games()
    # last_urls = ["Europa League 1st game", "UEFA Champions League Arsenal BATE"]
    return render_template('index.html', last_urls=last_urls)

@app.route('/result')
def result():
    game_url = request.args.get('jsdata')
    # folder = "/folder/" + game_url
    # folder = "data/Italy-Serie-A-2018-2019-Atalanta-AC-Milan"
    # time.sleep(2)
    folder = download_data(game_url)
    subprocess.run(["Rscript", "passnetwork.r", folder.replace("./", "") + "/"])
    subprocess.run(["Rscript", "passsonar.r", folder.replace("./", "") + "/"])
    return render_template("result.html", folder=folder)

@app.route('/download', methods=["GET"])
def download():
    folder = request.args.get('folder')
    zipf = zipfile.ZipFile('data.zip', 'w', zipfile.ZIP_DEFLATED)
    zipdir(folder, zipf)
    zipf.close()
    return send_file('data.zip',
            mimetype = 'zip',
            attachment_filename= 'data.zip',
            as_attachment = True)

def zipdir(path, ziph):
    # ziph is zipfile handle
    for root, dirs, files in os.walk(path):
        for file in files:
            ziph.write(os.path.join(root, file))

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8082)
