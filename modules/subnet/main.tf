terraform {
  required_version = ">= 1.0.0"
  }



data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "subnet_public" {
  count = 3
  vpc_id            = aws_vpc.vpc.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = var.cidr_block[count.index]

  tags = {
    Name = "Subnet ${count.index}"
  }
}

resource "aws_route_table_association" "rtb_subnet_public" {
  subnet_id      = aws_subnet.subnet_public.id
  route_table_id = var.route_table
}