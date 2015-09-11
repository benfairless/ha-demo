#!/usr/bin/env bash

source /opt/ha-demo/venv/bin/activate

export BACKEND='http://backend-00/'
export NODE=$(hostname)
export PORT='5000'

cd /vagrant/applications

case $1 in
  frontend-01) export MODE=0 ;; # backend
  frontend-02) export MODE=0 ;; # backend
   backend-01) export MODE=1 ;; # backend
   backend-02) export MODE=1 ;; # backend
esac

python run.py
