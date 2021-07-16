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

module "subnet1" {
  source      = "./modules/subnet/"
  vpc         = aws_vpc.vpc.id
  cidr_block  = "10.0.1.0/24"
  az          = "eu-central-1a"
  route_table = aws_route_table.rtb_public.id
}
module "subnet2" {
  source      = "./modules/subnet/"
  vpc         = aws_vpc.vpc.id
  cidr_block  = "10.0.2.0/24"
  az          = "eu-central-1b"
  route_table = aws_route_table.rtb_public.id
}
module "subnet3" {
  source      = "./modules/subnet/"
  vpc         = aws_vpc.vpc.id
  cidr_block  = "10.0.3.0/24"
  az          = "eu-central-1c"
  route_table = aws_route_table.rtb_public.id
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

resource "aws_iam_instance_profile" "vault-server" {
  name = "vault-server-instance-profile"
  role = aws_iam_role.vault-server.name
}

resource "aws_iam_role" "vault-server" {
  name               = "vault-server-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy" "vault-server" {
  name   = "vault-server-role-policy"
  role   = aws_iam_role.vault-server.id
  policy = data.aws_iam_policy_document.vault-server.json
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "vault-server" {
  statement {
    sid    = "1"
    effect = "Allow"

    actions = ["ec2:DescribeInstances", "ec2:*"]

    resources = ["*"]
  }

  statement {
    sid    = "VaultAWSAuthMethod"
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances",
      "iam:GetInstanceProfile",
      "iam:GetUser",
      "iam:GetRole",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "VaultKMSUnseal"
    effect = "Allow"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:DescribeKey",
    ]

    resources = ["*"]
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

module "server1" {
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
}


# # Classic Load Balancer

# resource "aws_elb" "elb" {
#   name               = "vault-elb"
#   subnets = [module.subnet1.subnet_id, module.subnet2.subnet_id, module.subnet3.subnet_id]
#   security_groups = [aws_security_group.sg_vpc.id]
  
#   listener {
#     instance_port     = 8000
#     instance_protocol = "http"
#     lb_port           = 80
#     lb_protocol       = "http"
#   }

# /* hier muss noch ein Zertifikat rein
#   listener {
#     instance_port      = 8000
#     instance_protocol  = "http"
#     lb_port            = 443
#     lb_protocol        = "https"
#   }
# */

#   health_check {
#     healthy_threshold   = 2
#     unhealthy_threshold = 5
#     timeout             = 25
#     target              = "HTTP:8000/"
#     interval            = 30
#   }

#   instances                   = [module.server1.instance_id, module.server2.instance_id, module.server3.instance_id, module.server4.instance_id, module.server5.instance_id]
#   cross_zone_load_balancing   = true
#   idle_timeout                = 400
#   connection_draining         = true
#   connection_draining_timeout = 400

#   tags = {
#     Name = "vault-elb"
#   }
# }