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

# Installs an RPM from a remote URL
remoteinstall() {
  local PKG=$1
  local URI=$2
  [[ -z $PKG ]] && echo 'remoteinstall() - No package variable set'
  [[ -z $URI ]] && echo 'remoteinstall() - No uri variable set'
  if [[ $(rpm -q $PKG) == false ]]; then
    echo "Installing ${PKG}" | output
    if [[ ! -f "/tmp/${PKG}.rpm" ]]; then
      curl -L -o "/tmp/${PKG}.rpm" $URI 2>/dev/null
    fi
    yum install "${DOWNLOADS_DIR}/${PKG}.rpm" -y
  fi
}

# High Availability installation
yum install haproxy keepalived gcc -y

# Python setup
remoteinstall lr-python3 https://github.com/LandRegistry-Ops/puppet-control/raw/development/site/profiles/files/lr-python3-3.4.3-1.x86_64.rpm

# Python setup
FOLDER='/home/vagrant/ha-demo'
if [[ ! -d ${FOLDER} ]]; then
  echo 'Creating VirtualEnv'
  sudo -u vagrant mkdir -p ${FOLDER}
  sudo -u vagrant /usr/local/bin/pyvenv3 "${FOLDER}/venv"
  sudo -u vagrant ${FOLDER}/venv/bin/pip install -r /vagrant/applications/requirements.txt
fi
