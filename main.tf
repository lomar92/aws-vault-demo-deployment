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
  region = var.region
}



module "server" {
  source            = "./modules/vaultserver/"

  for_each = tomap({
    node1 = "0"
    node2 = "0"
    node3 = "1"
    node4 = "1"
    node5 = "2"
    node6 = "2"
  })
  
  instance_name     = each.key
  subnet_id         = aws_subnet.subnet_public[each.value].id
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

