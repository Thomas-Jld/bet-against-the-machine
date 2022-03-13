from flask import Flask, render_template, send_from_directory
from flask_cors import CORS

app = Flask(__name__)
app.secret_key = "AVeryUniquePasswordL1KeThis"
CORS(app)

@app.route('/batm', methods=["GET"])
def home():
    return render_template("index.html")

@app.route('/batm/static/<path:path>', methods=["GET", "POST"])
def static_serving(path):
    return send_from_directory('./static', path)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=27151)
