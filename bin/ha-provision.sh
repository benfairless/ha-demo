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
192.168.99.10 frontend-00
192.168.99.11 frontend-01
192.168.99.12 frontend-02

# Backend
192.168.99.20 backend-00
192.168.99.21 backend-01
192.168.99.22 backend-02
HOSTS

# Dependency installation
yum install haproxy keepalived gcc -q -y

# VIP setup
case $(hostname) in
  frontend-01) export PRIORITY='100'
               export NAME='FRONTEND'
               export ID='10'
              ;;
  frontend-02) export PRIORITY='99'
               export NAME='FRONTEND'
               export ID='10'
              ;;
   backend-01) export PRIORITY='100'
               export NAME='BACKEND'
               export ID='20'
              ;;
   backend-02) export PRIORITY='99'
               export NAME='BACKEND'
               export ID='20'
              ;;
esac
cat <<KEEPALIVE > /etc/keepalived/keepalived.conf
vrrp_script haproxy {
  script "pgrep haproxy"
  interval 2
  wait 2
}
vrrp_instance ${NAME} {
    state MASTER
    interface eth1
    virtual_router_id ${ID}
    priority ${PRIORITY}
    advert_int 1
    virtual_ipaddress {
        192.168.99.${ID}
    }
    track_script {
      haproxy
    }
}
KEEPALIVE
systemctl start keepalived
systemctl enable keepalived

# HA Proxy setup
case $(hostname) in
  frontend*) export CLUSTER='frontend' ;;
   backend*) export CLUSTER='backend'  ;;
esac
cat <<HAPROXY > /etc/haproxy/haproxy.cfg
global
    log         127.0.0.1 local2
    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    user        haproxy
    group       haproxy
    daemon
    stats socket /var/lib/haproxy/stats

defaults
    mode                    http
    log                     global
    option                  httplog
    option                  dontlognull
    option                  http-server-close
    option                  redispatch
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 3000

listen ha-demo *:5050
    balance roundrobin
    option  httpchk GET /backend
    server  ${CLUSTER}-01 ${CLUSTER}-01:5000 check
    server  ${CLUSTER}-02 ${CLUSTER}-02:5000 check

listen tomcat-demo *:5051
    balance roundrobin
    option httpchk GET /
    server ${CLUSTER}-01 ${CLUSTER}-01:8080 check
    server ${CLUSTER}-02 ${CLUSTER}-02:8080 check

listen tomcat-sticky-demo *:5052
    balance roundrobin
    option httpchk GET /
    #cookie JSESSIONID prefix
    cookie SERVERID insert indirect nocache
    server ${CLUSTER}-01 ${CLUSTER}-01:8080 check cookie ${CLUSTER}-01
    server ${CLUSTER}-02 ${CLUSTER}-02:8080 check cookie ${CLUSTER}-02

listen admin *:80
    mode http
    stats enable
    stats hide-version
    stats realm HA Proxy\ Statistics
    stats uri /
HAPROXY
systemctl restart haproxy
systemctl enable haproxy
