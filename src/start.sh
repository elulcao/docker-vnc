#!/bin/sh

if [ "$#" -ne 0 ]; then
  echo "Usage: $0" >&2
  exit 1
fi

vncserver :0 -depth 24 -name "docker-vnc"

supervisord -c /root/supervisord.conf
