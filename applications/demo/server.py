import logging
import os
import requests

from flask import Flask
app = Flask(__name__)

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)
logger.addHandler(logging.StreamHandler())

MODE=str(os.environ['MODE'])
NODE=str(os.environ['NODE'])
BACKEND='http://localhost:5001'

@app.route('/')
def default():
    if MODE == '0': # Frontend
        logging.info("Frontend hit")
        backendchk = requests.get(BACKEND)
        return "Frontend %s - %s" % (NODE,backendchk.text)
    elif MODE == '1': # Backend
        logging.info("Backend hit")
        return 'Backend %s' % NODE
    else:
        logging.error("Invalid mode!")
        exit(1)

if __name__ == '__main__':
    app.run()
