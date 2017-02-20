#!/usr/bin/env bash
set -e

echo "Starting Vault..."
if [ -x "$(command -v systemctl)" ]; then
  echo "using systemctl"
  sudo systemctl enable vault.service
  sudo systemctl start vault
else 
  echo "using upstart"
  sudo start vault
# curl -X POST -H "X-Vault-Token:9fbfbe48-8a5a-b50e-dbfc-0b7189f546b0" -d '{"type":"approle"}' http://172.31.28.194:8200/v1/sys/auth/approle
fi
