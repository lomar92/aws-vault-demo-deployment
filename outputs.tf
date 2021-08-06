output "public_ip1" {
  value = module.server1.public_ip_instance
}

output "public_ip2" {
  value = module.server2.public_ip_instance
}

output "public_ip3" {
  value = module.server3.public_ip_instance
}
