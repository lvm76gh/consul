#!/usr/bin/env bash
set -e



echo "Initializing Nomad with Redis example..."
cd /home/ubuntu
nomad init

SERVER_COUNT=$(cat /tmp/consul-server-count | tr -d '\n')

# Change count to "3" servers
sed -i -e "s/count = 1/count = $SERVER_COUNT/" example.nomad





