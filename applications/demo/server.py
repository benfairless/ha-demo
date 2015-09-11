import logging
import socket
import requests
from flask import Flask, Response, jsonify
import json
app = Flask(__name__)

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)
logger.addHandler(logging.StreamHandler())

HOST=socket.gethostname()

@app.route('/')
def pretty():
    line1 = '<h1><b>Frontend</b> - %s</h1>' % HOST
    line2 = '<h1><b>Backend</b> - %s</h1>' % HOST
    return Response(line1 + line2,status=200)

@app.route('/frontend')
def frontend():
    logging.info("Frontend triggered on %s" % HOST)
    reply = { 'frontend': HOST, 'backend': HOST }
    return jsonify(reply)

@app.route('/backend')
def backend():
    logging.info("Backend triggered on %s" % HOST)
    reply = { 'backend': HOST }
    return jsonify(reply)

if __name__ == '__main__':
    app.run()
