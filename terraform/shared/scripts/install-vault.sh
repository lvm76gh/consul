#!/usr/bin/env bash
set -e

echo "Fetching Vault..."
VAULT="0.6.5"
cd /tmp
wget https://releases.hashicorp.com/vault/${VAULT}/vault_${VAULT}_linux_amd64.zip -O vault.zip

echo "Installing Vault..."
unzip vault.zip >/dev/null
chmod +x vault
sudo mv vault /usr/local/bin/vault
sudo mkdir -p /opt/vault/data

# Read from the file we created
SERVER_COUNT=$(cat /tmp/consul-server-count | tr -d '\n')
CONSUL_JOIN=$(cat /tmp/consul-server-addr | tr -d '\n')

# Write the flags to a temporary file
cat >/tmp/vault_flags << EOF
VAULT_FLAGS="-config=/etc/vault.d/vaultserver.hcl -data-dir=/opt/vault/data"
EOF


#if [ -f /tmp/debian_vault_upstart.conf ];
#then
  echo "Installing Nomad Upstart service..."
  sudo mkdir -p /etc/vault.d

# Write server.hcl file
  cat >/tmp/vault.hcl << EOF  
backend "consul" {
  address = "127.0.0.1:8500"
  path = "vault"
}

listener "tcp" {
 address = "127.0.0.1:8200"
 tls_disable = 1
}
EOF



echo "Injecting Vault Startup Services..."
  sudo mv /tmp/vault.hcl /etc/vault.d
  sudo chown root:root /etc/vault.d/vault.hcl
  sudo chmod 0644 /etc/vault.d/vault.hcl
 

  sudo mv /tmp/debian_vault_upstart.conf /etc/init/vault.conf
  sudo chown root:root /etc/init/vault.conf
  sudo chmod 0644 /etc/init/vault.conf


  sudo mv /tmp/vault_flags /etc/service/vault
  sudo chmod 0644 /etc/service/vault

