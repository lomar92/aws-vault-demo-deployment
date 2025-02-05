/* output "public_ip1" {
  value = module.server1.public_ip_instance
}

output "public_ip2" {
  value = module.server2.public_ip_instance
}

output "public_ip3" {
  value = module.server3.public_ip_instance
} */

# The key expression produced an invalid result: string required.
/* output "public_ips" {
  value = { for k in module.server : k => module.server[k].public_ip_instance }
} */