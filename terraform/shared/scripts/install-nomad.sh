#!/usr/bin/env bash
set -e

echo "Fetching Nomad..."
NOMAD="0.5.4"
cd /tmp
wget https://releases.hashicorp.com/nomad/${NOMAD}/nomad_${NOMAD}_linux_amd64.zip -O nomad.zip

echo "Installing Nomad..."
unzip nomad.zip >/dev/null
chmod +x nomad
sudo mv nomad /usr/local/bin/nomad

# Read from the file we created
SERVER_COUNT=$(cat /tmp/consul-server-count | tr -d '\n')
CONSUL_JOIN=$(cat /tmp/consul-server-addr | tr -d '\n')

# Write the flags to a temporary file
cat >/tmp/nomad_flags << EOF
CONSUL_FLAGS="-server -bootstrap-expect=${SERVER_COUNT} -join=${CONSUL_JOIN} -data-dir=/opt/consul/data"
EOF

#if [ -f /tmp/upstart.conf ];
#then
  echo "Installing Nomad  Upstart service..."
  sudo mkdir -p /etc/nomad.d
  sudo touch /etc/nomad.d/server.hcl
#  sudo chown root:root /tmp/upstart.conf
#  sudo mv /tmp/upstart.conf /etc/init/consul.conf
#  sudo chmod 0644 /etc/init/consul.conf
#  sudo mv /tmp/consul_flags /etc/service/consul
#  sudo chmod 0644 /etc/service/consul
#else
#  echo "Installing Systemd service..."
#  sudo mkdir -p /etc/systemd/system/consul.d
#  sudo chown root:root /tmp/consul.service
#  sudo mv /tmp/consul.service /etc/systemd/system/consul.service
#  sudo chmod 0644 /etc/systemd/system/consul.service
#  sudo mv /tmp/consul_flags /etc/sysconfig/consul
#  sudo chown root:root /etc/sysconfig/consul
#  sudo chmod 0644 /etc/sysconfig/consul
#fi
