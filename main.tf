terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.45.0"
    }
     tls = {
      source = "hashicorp/tls"
      version = "3.1.0"
    }
  }
}
provider "aws" {
  region = "eu-central-1"
}

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "vault vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "vault internet gateway"
  }
}

resource "aws_route_table" "rtb_public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
   tags = {
    Name = "Vault public RTB"
  } 
}

 module "subnet" {
  source      = "./modules/subnet/"

  for_each = var.subnet

  vpc         = aws_vpc.vpc.id
  route_table = aws_route_table.rtb_public.id
  subnet_name = each.key
  az          = each.value.az
  cidr_block  = each.value.cidr_block
}


resource "aws_security_group" "sg_vpc" {
  name   = "sg_vpc"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8201
    to_port     = 8201
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 2223
    to_port     = 2225
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_kms_key" "kms_key_vault" {
 description             = "Vault KMS key"
}

resource "tls_private_key" "ca" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_self_signed_cert" "ca" {
  key_algorithm     = "${tls_private_key.ca.algorithm}"
  private_key_pem   = "${tls_private_key.ca.private_key_pem}"
  is_ca_certificate = true

  validity_period_hours = 12
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "cert_signing",
    "server_auth",
  ]
  subject {
    common_name  = "${var.common_name}"
    organization = "${var.organization}"
  }
}

module "server" {
  source            = "./modules/vaultserver/"
  count = 3
  
  subnet_id         = module.subnet[each.key].subnet_id
  security_group    = aws_security_group.sg_vpc.id
  raft_node         = "vault ${count.index}"
  instance_name     = "vault ${count.index}"
  key               = var.key
  ami               = var.ami
  instance_type     = var.instance_type
  iam_profile       = aws_iam_instance_profile.vault-server.id
  device_name       = var.device_name
  volume_type       = var.volume_type
  volume_size       = var.volume_size
  VAULT_LICENSE     = var.VAULT_LICENSE
  algorithm         = tls_private_key.ca.algorithm
  private_key_pem   = tls_private_key.ca.private_key_pem
  cert_pem          = tls_self_signed_cert.ca.cert_pem
  kms               = aws_kms_key.kms_key_vault.key_id
  organization      = var.organization
  account_id        = var.account_id
}

/* module "server1" {
  subnet_id         = module.subnet1.subnet_id
  security_group    = aws_security_group.sg_vpc.id
  source            = "./modules/vaultserver/"
  raft_node         = "vault1"
  key               = var.key
  ami               = var.ami
  instance_type     = var.instance_type
  iam_profile       = aws_iam_instance_profile.vault-server.id
  device_name       = var.device_name
  volume_type       = var.volume_type
  volume_size       = var.volume_size
  instance_name     = "vault1"
  VAULT_LICENSE     = var.VAULT_LICENSE
  algorithm         = tls_private_key.ca.algorithm
  private_key_pem   = tls_private_key.ca.private_key_pem
  cert_pem          = tls_self_signed_cert.ca.cert_pem
  kms               = aws_kms_key.kms_key_vault.key_id
  organization      = var.organization
  account_id        = var.account_id
}

module "server2" {
  subnet_id         = module.subnet2.subnet_id
  security_group    = aws_security_group.sg_vpc.id
  source            = "./modules/vaultserver/"
  raft_node         = "vault2"
  key               = var.key
  ami               = var.ami
  instance_type     = var.instance_type
  iam_profile       = aws_iam_instance_profile.vault-server.id
  device_name       = var.device_name
  volume_type       = var.volume_type
  volume_size       = var.volume_size
  instance_name     = "vault2"
  VAULT_LICENSE     = var.VAULT_LICENSE 
  algorithm         = tls_private_key.ca.algorithm
  private_key_pem   = tls_private_key.ca.private_key_pem
  cert_pem          = tls_self_signed_cert.ca.cert_pem
  kms               = aws_kms_key.kms_key_vault.key_id
  organization      = var.organization
  account_id        = var.account_id
}

module "server3" {
  subnet_id         = module.subnet3.subnet_id
  security_group    = aws_security_group.sg_vpc.id
  source            = "./modules/vaultserver/"
  raft_node         = "vault3"
  key               = var.key
  ami               = var.ami
  instance_type     = var.instance_type
  iam_profile       = aws_iam_instance_profile.vault-server.id
  device_name       = var.device_name
  volume_type       = var.volume_type
  volume_size       = var.volume_size
  instance_name     = "vault3"
  VAULT_LICENSE     = var.VAULT_LICENSE
  algorithm         = tls_private_key.ca.algorithm
  private_key_pem   = tls_private_key.ca.private_key_pem
  cert_pem          = tls_self_signed_cert.ca.cert_pem
  kms               = aws_kms_key.kms_key_vault.key_id
  organization      = var.organization
  account_id        = var.account_id
}

module "server4" {
  subnet_id         = module.subnet2.subnet_id
  security_group    = aws_security_group.sg_vpc.id
  source            = "./modules/vaultserver/"
  raft_node         = "vault4"
  key               = var.key
  ami               = var.ami
  instance_type     = var.instance_type
  iam_profile       = aws_iam_instance_profile.vault-server.id
  device_name       = var.device_name
  volume_type       = var.volume_type
  volume_size       = var.volume_size
  instance_name     = "vault4"
  VAULT_LICENSE     = var.VAULT_LICENSE
  algorithm         = tls_private_key.ca.algorithm
  private_key_pem   = tls_private_key.ca.private_key_pem
  cert_pem          = tls_self_signed_cert.ca.cert_pem
  kms               = aws_kms_key.kms_key_vault.key_id
  organization      = var.organization
  account_id        = var.account_id
}

module "server5" {
  subnet_id         = module.subnet3.subnet_id
  security_group    = aws_security_group.sg_vpc.id
  source            = "./modules/vaultserver/"
  raft_node         = "vault5"
  key               = var.key
  ami               = var.ami
  instance_type     = var.instance_type
  iam_profile       = aws_iam_instance_profile.vault-server.id
  device_name       = var.device_name
  volume_type       = var.volume_type
  volume_size       = var.volume_size
  instance_name     = "vault5"
  VAULT_LICENSE     = var.VAULT_LICENSE
  algorithm         = tls_private_key.ca.algorithm
  private_key_pem   = tls_private_key.ca.private_key_pem
  cert_pem          = tls_self_signed_cert.ca.cert_pem
  kms               = aws_kms_key.kms_key_vault.key_id
  organization      = var.organization
  account_id        = var.account_id
} */

# resource "aws_db_subnet_group" "db-subnetgroup" {
#   name       = "dbsubnetgroup"
#   subnet_ids = [module.subnet1.subnet_id, module.subnet2.subnet_id, module.subnet3.subnet_id]

#   tags = {
#     Name = "Vault DB subnet group"
#   }
# }

# resource "aws_db_instance" "rds-db" {
#   allocated_storage    = 10
#   db_name              = "vaultdemoinstance"
#   engine               = "mysql"
#   engine_version       = "8.0.28"
#   instance_class       = "db.t3.micro"
#   username             = var.username
#   password             = var.dbpassword
#   db_subnet_group_name = aws_db_subnet_group.db-subnetgroup.name
#   skip_final_snapshot  = true
#   publicly_accessible  = true
# }

