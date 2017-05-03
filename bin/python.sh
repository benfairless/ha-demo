#!/usr/bin/env bash

# Check yo' privledge
if [[ $(id -u) != '0' ]]; then
  echo "$0 must be ran as root!"
  exit 1
fi

# Install IUS repository for Python3
yum install https://centos7.iuscommunity.org/ius-release.rpm -q -y

# Install Python utilities
yum install python34u python34u-utils python34u-devel python34u-pip -q -y

# Temporary FOLDER
[[ ! -d '/vagrant/tmp' ]] && mkdir -p '/vagrant/tmp'

# Application setup
VENV='/vagrant/tmp/virtualenv'
if [[ ! -d "${VENV}" ]]; then
  echo 'Creating VirtualEnv'
  sudo -u vagrant mkdir -p "${VENV}"
  sudo -u vagrant pyvenv "${VENV}"
  sudo -u vagrant "${VENV}/bin/pip3" install -r /vagrant/application/requirements.txt
fi
cat <<SYSTEMD > /usr/lib/systemd/system/ha-demo.service
[Unit]
Description=High Availability demo application
After=network.target

[Service]
Type=forking
PIDFile=/tmp/ha-demo.pid
User=vagrant
Group=vagrant
WorkingDirectory=/vagrant/application
ExecStart=${VENV}/bin/gunicorn --config '/vagrant/application/gunicorn.py' server:app >/vagrant/tmp/application.log
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s TERM $MAINPID
Restart=on-failure

[Install]
WantedBy=multi-user.target
SYSTEMD
systemctl daemon-reload
systemctl restart ha-demo
systemctl enable ha-demo
