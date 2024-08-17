resource "aws_instance" "instances" {
  count = length(var.private_subnet_cidrs)
  ami           = var.ami_id
  instance_type = var.instance_type
  # key_name        = var.ami_key_pair_name
  security_groups = [aws_security_group.ec2_sg.id]

  tags = {
    Name = "Instance ${count.index + 1}"
  }

  subnet_id = element(aws_subnet.private_subnets, count.index).id

  user_data                   = file("ec2-user-data.sh")
  user_data_replace_on_change = true

  depends_on = [aws_subnet.private_subnets, aws_nat_gateway.nats]
}

resource "aws_security_group" "ec2_sg" {
  name   = "EC2 SG"
  vpc_id = aws_vpc.main.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_from_alb" {
  security_group_id = aws_security_group.ec2_sg.id
  referenced_security_group_id = aws_security_group.alb_sg.id
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_in" {
  security_group_id = aws_security_group.ec2_sg.id
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_out_ipv4" {
  security_group_id = aws_security_group.ec2_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
