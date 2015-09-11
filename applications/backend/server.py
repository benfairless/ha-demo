import logging

from flask import Flask
app = Flask(__name__)

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)
logger.addHandler(logging.StreamHandler())

@app.route('/')
def hello_world():
    logging.info("Hello World indeed!")
    return 'Hello World!'

if __name__ == '__main__':
    app.run()
