#!/bin/bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

sudo yum update -y
sudo yum install -y yum-utils
sudo yum install -y jq

curl --remote-name "https://releases.hashicorp.com/vault/1.7.3+ent/vault_1.7.3+ent_linux_amd64.zip"
curl --remote-name "https://releases.hashicorp.com/vault/1.7.3+ent/vault_1.7.3+ent_SHA256SUMS"
curl --remote-name "https://releases.hashicorp.com/vault/1.7.3+ent/1.7.3+ent/vault_1.7.3+ent_SHA256SUMS.sig"

unzip vault_1.7.3+ent_linux_amd64.zip -d /usr/local/bin/

chmod 0755 /usr/local/bin/vault
sudo chown awsuser:awsuser /usr/local/bin/vault
sudo touch /etc/vault.d/vault.hcl
sudo chown --recursive vault:vault /etc/vault.d
sudo chmod 640 /etc/vault.d/vault.hcl

sudo mkdir /opt/vault
sudo chown -R awsuser:awsuser /opt/vault

sudo cat << EOF > /lib/systemd/system/vault.service
[Unit]
Description=Vault Agent
Requires=network-online.target
After=network-online.target
[Service]
Restart=on-failure
PermissionsStartOnly=true
ExecStartPre=/sbin/setcap 'cap_ipc_lock=+ep' /usr/local/bin/vault
ExecStart=/usr/local/bin/vault agent -config /etc/vault.d/config.hcl
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGTERM
User=awsuser
Group=awsuser
[Install]
WantedBy=multi-user.target
EOF

cat << EOF > /etc/vault.d/config.hcl
exit_after_auth = true
pid_file = "./pidfile"

auto_auth {
  method "aws" {
      mount_path = "auth/aws"
      config = {
          type = "iam"
          role = "demo-iam-role"
      }
  }

  sink "file" {
      config = {
          path = "/home/ec2-user/vault-token-via-agent"
      }
  }
}

vault {
  address = "${vault_addr}"
}
EOF

cd /var/www/html
echo "Hallo Welt" > index.html
service httpd start
chkconfig httpd on
