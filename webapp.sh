#!/bin/bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

sudo yum update -y
sudo yum install -y yum-utils
sudo yum install -y jq

cd /var/www/html
echo "Hallo Welt" > index.html
service httpd start
chkconfig httpd on
