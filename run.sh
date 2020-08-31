#!/bin/bash

usage()
{
  echo "docker run -e BACKEND_SERVER=<domain> -e BACKEND_PORT=<port> -p :port <image>"
}

if [ -z "${BACKEND_SERVER}" ]; then
  usage
  exit 1
fi

if [ -z "${BACKEND_PORT}" ]; then
  usage
  exit 1
fi

if [ ! -f /haproxy.cfg ]; then
  {
    echo "global"
    echo "    maxconn 5"
    echo "    user root"
    echo "    group root"
    echo ""
    echo "resolvers mydns"
    echo "    nameserver local 127.0.0.11:53"
    echo "    timeout retry 1s"
    echo "    hold valid 10s"
    echo "    hold nx 3s"
    echo "    hold other 3s"
    echo "    hold obsolete 0s"
    echo "    accepted_payload_size 8192"
    echo ""
    echo "defaults"
    echo "    mode tcp"
    echo "    option tcplog"
    echo "    option logasap"
    echo "    log stdout format short daemon"
    echo "    maxconn 5"
    echo "    timeout connect 5s"
    echo "    timeout client 3600s"
    echo "    timeout server 3600s"
    echo ""
    echo "frontend svc.io"
    echo "    bind 0.0.0.0:$BACKEND_PORT"
    echo "    default_backend backend1"
    echo ""
    echo "backend backend1"
    echo "    balance roundrobin"
    echo "    default-server check maxconn 5"
    echo "    server $BACKEND_SERVER $BACKEND_SERVER:$BACKEND_PORT resolvers mydns resolve-prefer ipv4"
    echo ""
  } > haproxy.cfg
fi

echo "====================="
cat /haproxy.cfg
echo "====================="

exec haproxy -f /haproxy.cfg
