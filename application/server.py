import os
import logging
import socket
import requests
from flask import Flask, Response, jsonify
import json

app = Flask(__name__)
app.config['JSONIFY_PRETTYPRINT_REGULAR'] = False

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)
logger.addHandler(logging.StreamHandler())

hostname = socket.gethostname()

backend_host = os.getenv('BACKEND_HOST','127.0.0.1')
backend_port = os.getenv('BACKEND_PORT',5000)

def lookupBackend(host,port=80):
    baseurl = host + ':' + str(port)
    try:
        call = requests.get('http://' + baseurl + '/backend')
        if call.status_code == 200:
            lookup = json.loads(call.text)
            return lookup['backend']
        else:
            return baseurl
    except requests.exceptions.RequestException:
        logging.error('Unable to connect backend ' + baseurl)
        return None

@app.route('/')
# Provides a 'pretty' output
def pretty():
    line1 = '<h1><b>Frontend</b> - %s</h1>' % hostname
    line2 = '<h1><b>Backend</b> - %s</h1>' % lookupBackend(backend_host,backend_port)
    return Response(line1 + line2,status=200)

@app.route('/frontend')
def frontend():
    logging.info("Frontend triggered on %s" % hostname)
    reply = { 'frontend': hostname, 'backend': lookupBackend(backend_host,backend_port) }
    return jsonify(reply)

@app.route('/backend')
def backend():
    logging.info("Backend triggered on %s" % hostname)
    reply = { 'backend': hostname }
    return jsonify(reply)

if __name__ == '__main__':
    app.run()
