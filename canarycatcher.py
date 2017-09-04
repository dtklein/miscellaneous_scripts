from flask import *
from json import *

app = Flask(__name__)

from app import views

@app.route("/")
def index():
    print JSONDecoder(Request.data)['memo']
