variable "vpc" {
    description = "VPC"
    type = string
}

variable "cidr_block" {
    description = "CIDR Block of the Subnet"
    default = "10.0.0.0/24"
}

variable "route_table" {
    description = "Route table associated to Subnet"
}

variable "az" {
    description = "availability zone to which the subnet is attached to"
    type = string
    default = "eu-central-1a"
}

variable "subnet_name" {
    description = "name of the subnet"
    type = string
}