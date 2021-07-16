#!/bin/bash

PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
PUBLIC_IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
HOSTNAME=$(curl http://169.254.169.254/latest/meta-data/local-hostname)
PUBLIC_HOSTNAME=$(curl http://169.254.169.254/latest/meta-data/public-hostname)

sudo yum install -y yum-utils

curl --remote-name "https://releases.hashicorp.com/vault/1.7.3+ent/vault_1.7.3+ent_linux_amd64.zip"
curl --remote-name "https://releases.hashicorp.com/vault/1.7.3+ent/vault_1.7.3+ent_SHA256SUMS"
curl --remote-name "https://releases.hashicorp.com/vault/1.7.3+ent/1.7.3+ent/vault_1.7.3+ent_SHA256SUMS.sig"

unzip vault_1.7.3+ent_linux_amd64.zip

sudo chown root:root vault

sudo mv vault /usr/local/bin/

vault -autocomplete-install
complete -C /usr/local/bin/vault vault

#mlock nutzen
sudo setcap cap_ipc_lock=+ep /usr/local/bin/vault
sudo useradd --system --home /etc/vault.d --shell /bin/false vault

sudo mkdir --parents /etc/vault.d
sudo echo "${cert}" > /etc/ssl/certs/fullchain.crt
sudo echo "${key}" > /etc/ssl/certs/privkey.key
sudo echo "${ca_cert}" > /etc/ssl/certs/ca.crt
sudo echo "${license}" > /etc/vault.d/license.hclic

sudo touch /etc/vault.d/vault.hcl
sudo chown --recursive vault:vault /etc/vault.d
sudo chmod 640 /etc/vault.d/vault.hcl
sudo mkdir /opt/raft
sudo chown -R vault:vault /opt/raft

sudo cat << EOF > /etc/vault.d/vault.hcl
listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_cert_file = "/etc/ssl/certs/fullchain.crt"
  tls_key_file  = "/etc/ssl/certs/privkey.key"
}
storage "raft" {
  path = "/opt/raft"
  node_id = "${raft_node}"
   retry_join {
    auto_join = "provider=aws addr_type=public_v4 region=eu-central-1 tag_key=project tag_value=vault"
    leader_tls_servername = "vault-raft.eu-central-1.compute.internal"
  }
}
seal "awskms" {
  region     = "eu-central-1"
  kms_key_id = "${kms_key_id}"
}
disable_mlock = true
license_path = "/etc/vault.d/license.hclic"
api_addr = "https://$${PUBLIC_HOSTNAME}:8200"
cluster_addr = "https://$${HOSTNAME}:8201"
ui = true 
EOF

sudo touch /etc/systemd/system/vault.service

sudo cat << EOF > /etc/systemd/system/vault.service
[Unit]
Description="HashiCorp Vault - A tool for managing secrets"
Documentation=https://www.vaultproject.io/docs/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/vault.d/vault.hcl
StartLimitIntervalSec=60
StartLimitBurst=3

[Service]
User=vault
Group=vault
ProtectSystem=full
ProtectHome=read-only
PrivateTmp=yes
PrivateDevices=yes
SecureBits=keep-caps
AmbientCapabilities=CAP_IPC_LOCK
Capabilities=CAP_IPC_LOCK+ep
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK
NoNewPrivileges=yes
ExecStart=/usr/local/bin/vault server -config=/etc/vault.d/vault.hcl
ExecReload=/bin/kill --signal HUP $MAINPID
KillMode=process
KillSignal=SIGINT
Restart=on-failure
RestartSec=5
TimeoutStopSec=30
LimitNOFILE=65536
LimitMEMLOCK=infinity

[Install]
WantedBy=multi-user.target
EOF

sudo cat << EOF > /etc/profile.d/vault.sh
export VAULT_ADDR=https://127.0.0.1:8200
EOF

sudo systemctl enable vault
sudo systemctl start vault
vault operator init

