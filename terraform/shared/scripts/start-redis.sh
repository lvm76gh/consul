#!/usr/bin/env bash
set -e



echo "Starting Redis..."
cd /home/ubuntu
sudo nomad init

# Change count to "3" servers
sed -i -e 's/count = 1/count = 3/' example.nomad

nomad start example.nomad




