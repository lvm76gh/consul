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
sudo mkdir -p /opt/nomad/data

# Read from the file we created
SERVER_COUNT=$(cat /tmp/consul-server-count | tr -d '\n')
CONSUL_JOIN=$(cat /tmp/consul-server-addr | tr -d '\n')

# Write the flags to a temporary file
cat >/tmp/nomad_flags << EOF
NOMAD_FLAGS="-config=/etc/nomad.d/server.hcl -data-dir=/opt/nomad/data"
EOF

cat >/tmp/nomad_client_flags << EOF
NOMAD_CLIENT_FLAGS="-config=/etc/nomad.d/client.hcl -data-dir=/opt/nomad/data"
EOF

#if [ -f /tmp/debian_nomad_upstart.conf ];
#then
  echo "Installing Nomad Upstart service..."
  sudo mkdir -p /etc/nomad.d

# Write server.hcl file
  cat >/tmp/server.hcl << EOF  
server { enabled=true bootstrap_expect=3 } 
EOF

# Write client.hcl file
  cat >/tmp/client.hcl << EOF  
datacenter = "dc1"
client { enabled=true } 
port { http=5656 }
EOF

  sudo mv /tmp/server.hcl /etc/nomad.d
  sudo chown root:root /etc/nomad.d/server.hcl
  sudo chmod 0644 /etc/nomad.d/server.hcl
 
  sudo mv /tmp/client.hcl /etc/nomad.d
  sudo chown root:root /etc/nomad.d/client.hcl
  sudo chmod 0644 /etc/nomad.d/client.hcl

  sudo mv /tmp/debian_nomad_upstart.conf /etc/init/nomad.conf
  sudo chown root:root /etc/init/nomad.conf
  sudo chmod 0644 /etc/init/nomad.conf
  sudo mv /tmp/nomad_flags /etc/service/nomad
  sudo chmod 0644 /etc/service/nomad

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
