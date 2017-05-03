#!/usr/bin/env bash

# Check yo' privledge
if [[ $(id -u) != '0' ]]; then
  echo "$0 must be ran as root!"
  exit 1
fi

# Dependancy installation
yum install java-1.8.0-openjdk tomcat tomcat-admin-webapps tomcat-docs-webapp tomcat-webapps -y

# Symlink config file from Vagrant
ln -sf /vagrant/application/server.xml /etc/tomcat/server.xml

systemctl enable tomcat
systemctl restart tomcat
