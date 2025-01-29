variable "ami" {
  description = "AMI for EC2 instance"
  type = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type = string
}

/* variable "instance_name" {
  description = "Name of the instance"
  type = string
} */

variable "key" {
  description = "Key for SSHing into EC2 instance"
  default = "sasano"
}

variable "kms" {
  description = "KMS Key for auto unsealing Vault"
}

variable "subnet_id" {
  type = string
}

variable "security_group" {
  type = string
}

variable "volume_type" {
  description = "Underlying disk type"
  default = "gp3"
} 

variable "volume_size" {
  description = "Size of the Volume in GiB"
  default = "100"
} 

variable "device_name" {
  description = "name of EBS block device"
  type = string
}

variable "common_name" {
  description = "common name of server certificates"
  type = string
  default = "Vault Node"
}

variable "organization" {
  description = "name of organization"
  type = string
} 

/* variable "raft_node" {
  description = "Node number in Raft cluster"
}   */

variable "VAULT_LICENSE" {
  default = "standard"
}

variable "iam_profile" {
  type = string
}

variable "algorithm" {
  type = string
}

variable "private_key_pem" {
  type = string
}

variable "cert_pem" {
  description = "certificate of CA"
  type = string
}

variable "account_id" {
  description = "AWS account ID"
}

variable "instance_count" {
  type = number
  default = 2
}