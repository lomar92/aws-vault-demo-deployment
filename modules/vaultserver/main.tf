terraform {
  required_version = ">= 1.0.0"
}

resource "aws_instance" "vaultserver" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.key
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group]
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/vault.sh", {
    license    = var.VAULT_LICENSE
    cert       = tls_locally_signed_cert.vault.cert_pem
    key        = tls_private_key.vault.private_key_pem
    ca_cert    = var.cert_pem
    raft_node  = var.instance_name
    kms_key_id = var.kms
    account_id = var.account_id
  })

  iam_instance_profile = var.iam_profile

  ebs_block_device {
    device_name           = var.device_name
    delete_on_termination = true
    volume_type           = var.volume_type
    volume_size           = var.volume_size
  }

  tags = {
    Name    = var.instance_name
    project = "vault"
  }
}
