#!/bin/bash

# at this point this script is a complete mess and used for learning by failure

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


cat << EOF > /home/ec2-user/vault-agent.hcl
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
  address = "https://vault-server-private-ip:8200"
}
EOF

cd /var/www/html
echo "Hallo Welt" > index.html
service httpd start
chkconfig httpd on
