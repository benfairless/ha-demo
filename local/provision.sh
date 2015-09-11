#!/usr/bin/env bash

# Check yo' privledge
if [[ $(id -u) != '0' ]]; then
  echo "$0 must be ran as root!"
  exit 1
fi

# Create hostfile
cat <<HOSTS > /etc/hosts
127.0.0.1 localhost

## Host entries for High Availability
# Frontend
192.158.99.10 frontend-00
192.168.99.11 frontend-01
192.168.99.12 frontend-02
# Backend
192.168.99.20 backend-00
192.168.99.21 backend-01
192.168.99.22 backend-02
HOSTS

# Basic install of tools
yum install https://github.com/LandRegistry-Ops/puppet-control/raw/development/site/profiles/files/lr-python3-3.4.3-1.x86_64.rpm -y

# High Availability installation
yum install haproxy keepalived -y


# Python setup
FOLDER='/opt/ha-demo'
if [[ ! -d ${FOLDER} ]]; then
  mkdir -p ${FOLDER}
  pyvenv "${FOLDER}/venv"
  ${FOLDER}/venv/bin/pip install -r /vagrant/applications/requirements.txt
fi
