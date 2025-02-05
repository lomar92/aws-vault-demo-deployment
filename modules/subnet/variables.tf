/* variable "vpc" {
    description = "VPC"
    type = string
}

variable "route_table" {
    description = "Route table associated to Subnet"
}

variable "az" {
    description = "availability zone to which the subnet is attached to"
    type = string

}

variable "subnet_name" {
    description = "name of the subnet"
    type = string
} 

variable "cidr_block" {
  type = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
} */