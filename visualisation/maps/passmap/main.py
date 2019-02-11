from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello_world():
    return '<html><body><h1>Passmap</h1><spam>Coming soon...</spam></body></html>'

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')