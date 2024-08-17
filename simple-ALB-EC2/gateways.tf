resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Main Gateway"
  }
}

resource "aws_nat_gateway" "nats" {
  count         = length(var.public_subnet_cidrs)
  subnet_id     = element(aws_subnet.public_subnets, count.index).id
  allocation_id = element(aws_eip.eips, count.index).id
  tags = {
    Name = "NAT ${count.index + 1}"
  }
}

resource "aws_eip" "eips" {
  count = length(var.public_subnet_cidrs)
  domain = "vpc"
}
