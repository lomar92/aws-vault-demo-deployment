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
    random = {
      source = "hashicorp/random"
      version = "3.6.3"
    }
  }
}
provider "aws" {
  region = var.region
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

/* module "server" {
  source            = "./modules/vaultserver/"

#  for_each = var.subnet
  
  subnet_id         = module.subnet[each.key].subnet_id
  security_group    = aws_security_group.sg_vpc.id
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

 */