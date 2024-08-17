resource "aws_route_table" "route_table_second" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "2nd route table"
  }
}

resource "aws_route_table_association" "subnet_public_associations" {
  count = length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.public_subnets, count.index).id
  route_table_id = aws_route_table.route_table_second.id
}


# NATs

resource "aws_route_table" "route_table_nats" {
  count = length(var.public_subnet_cidrs)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = element(aws_nat_gateway.nats, count.index).id
  }

  tags = {
    Name = "Route Table NAT ${count.index + 1}"
  }
}


resource "aws_route_table_association" "subnet_private_associations" {
  count = length(var.private_subnet_cidrs)
  subnet_id = element(aws_subnet.private_subnets, count.index).id
  route_table_id = element(aws_route_table.route_table_nats, count.index).id
}
