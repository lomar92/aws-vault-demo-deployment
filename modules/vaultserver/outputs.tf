output "public_ip_instance" {
  value = aws_instance.vaultserver.public_ip
}

output "instance_id" {
  value = aws_instance.vaultserver.id
}

output "vault_license" {
  value = var.VAULT_LICENSE
}

output "public_dns_instance" {
  value = aws_instance.vaultserver.public_dns
}

output "private_ip_instance" {
  value = aws_instance.vaultserver.private_ip
}