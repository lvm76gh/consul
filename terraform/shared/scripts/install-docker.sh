#!/usr/bin/env bash
set -e



echo "Fetching Docker..."
sudo curl -fsSL https://get.docker.com/ | sh
echo "Fetching Docker Key..."
curl -fsSL https://get.docker.com/gpg | sudo apt-key add -




