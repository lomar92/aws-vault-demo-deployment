#!/bin/bash
# Installiere benötigte Pakete
# checke cloud-init logs sobald Instanz online ist: sudo tail -f /var/log/cloud-init-output.log
yum install -y git golang make

# Repository klonen und Binary erstellen
git clone https://github.com/hashicorp/vault-benchmark.git /home/ec2-user/vault-benchmark
cd /home/ec2-user/vault-benchmark 
# Build Start
make bin GOFLAGS='-buildvcs=false'

# Verschieben in ins global bin
mv /vault-benchmark/dist/linux/amd64/vault-benchmark /usr/local/bin/vault-benchmark

# Dateiberechtigungen sicherstellen
chmod +x /usr/local/bin/vault-benchmark

cd /home/ec2-user

curl --remote-name "https://releases.hashicorp.com/vault/1.18.0+ent.hsm/vault_1.18.0+ent.hsm_linux_amd64.zip"
curl --remote-name "https://releases.hashicorp.com/vault/1.18.0+ent.hsm/vault_1.18.0+ent.hsm_SHA256SUMS"
curl --remote-name "https://releases.hashicorp.com/vault/1.18.0+ent.hsm/vault_1.18.0+ent.hsm_SHA256SUMS.sig"

unzip vault_1.18.0+ent.hsm_linux_amd64.zip

chown root:root vault

mv vault /usr/local/bin/

yum install -y jq

echo "export VAULT_SKIP_VERIFY=true" | sudo tee -a /home/ec2-user/.bashrc
source /home/ec2-user/.bashrc