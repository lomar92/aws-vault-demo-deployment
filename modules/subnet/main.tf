terraform {
  required_version = ">= 1.0.0"
  }


resource "aws_subnet" "subnet_public" {
  vpc_id     = var.vpc
  cidr_block = var.cidr_block
  availability_zone = var.az
  tags = {
    Name = "Vaultsubnet"
  }
}

resource "aws_route_table_association" "rtb_subnet_public" {
  subnet_id      = aws_subnet.subnet_public.id
  route_table_id = var.route_table
}