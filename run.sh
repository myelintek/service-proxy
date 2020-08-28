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
    echo "    nbproc 2"
    echo ""
    echo "defaults"
    echo "    timeout connect 10s"
    echo "    timeout client 15s"
    echo "    timeout server 5s"
    echo "    mode tcp"
    echo "    maxconn 5"
    echo ""
    echo "frontend svc.io"
    echo "    bind 0.0.0.0:$BACKEND_PORT"
    echo "    default_backend backend1"
    echo ""
    echo "backend backend1"
    echo "    balance roundrobin"
    echo "    default-server check maxconn 5"
    echo "    server $BACKEND_SERVER $BACKEND_SERVER:$BACKEND_PORT"
    echo ""
  } > haproxy.cfg
fi

echo "====================="
cat /haproxy.cfg
echo "====================="

exec haproxy -f /haproxy.cfg
