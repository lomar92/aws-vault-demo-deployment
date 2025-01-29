terraform {
  required_version = ">= 1.0.0"
  }

/* resource "random_id" "raft_node" {
  byte_length = 1
} */
# raft_node  = "vault-${random_id.raft_node.id}"

data "template_file" "user_data" {
  template = file("${path.module}/vault.sh")
  vars = {
    license    = "${var.VAULT_LICENSE}"
    cert       = "${tls_locally_signed_cert.vault.cert_pem}"
    key        = "${tls_private_key.vault.private_key_pem}"
    ca_cert    = "${var.cert_pem}"
    raft_node  = "${var.server_name}"
    kms_key_id = "${var.kms}"
    account_id = "${var.account_id}"
  }
}


resource "aws_instance" "vaultserver" {     
#  count = var.instance_count

  ami                         = var.ami 
  instance_type               = var.instance_type
  key_name                    = var.key
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group]
  associate_public_ip_address = true
  user_data                   = data.template_file.user_data.rendered
  iam_instance_profile        = var.iam_profile
  ebs_block_device {
    device_name = var.device_name
    delete_on_termination = true
    volume_type = var.volume_type
    volume_size = var.volume_size
  }
  tags = {
    Name    = "${var.server_name}"
    project = "vault"
  }
}

