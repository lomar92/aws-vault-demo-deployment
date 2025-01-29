/* variable "subnet" {
  description = "subnet into which instance is deployed"
  type = map(any)
  default = {
    subnet1 = {
      az          = "eu-central-1a"
      cidr_block  = "10.0.1.0/24"
    }
    subnet2 = {
      az          = "eu-central-1b"
      cidr_block  = "10.0.2.0/24"
    }
    subnet3 = {
      az          = "eu-central-1c"
      cidr_block  = "10.0.3.0/24"
    }
  }
}
 */

variable "cidr_block" {
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "region" {
  default = "eu-central-1"
}

variable "ami" {
  description = "AMI for EC2 instance"
  type = string
  default = "ami-043097594a7df80ec"
}

variable "instance_type" {
  description = "EC2 instance type"
  type = string
  default = "t2.micro"
}

variable "key" {
  description = "Key for SSHing into EC2 instance"
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
  default = "/dev/sdf"
  type = string
}

variable "VAULT_LICENSE" {
  type = string
}

variable "common_name" {
  description = "common name of CA"
  type = string
  default = "Vault CA"
}

variable "organization" {
  description = "name of organization"
  type = string
} 

variable "account_id" {
  description = "AWS account ID"
}

variable "username" {
  default = "admin"
}

variable "dbpassword" {
  default = "supergeheim"
  sensitive = true
}