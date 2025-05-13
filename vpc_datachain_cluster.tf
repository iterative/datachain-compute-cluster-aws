data "aws_availability_zones" "available" {}

resource "aws_vpc" "datachain_cluster" {
  cidr_block           = "172.18.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "datachain-cluster"
  }
}

resource "aws_internet_gateway" "datachain_cluster" {
  vpc_id = aws_vpc.datachain_cluster.id
  tags = {
    Name = "datachain-cluster"
  }
}

resource "aws_route_table" "datachain_cluster" {
  vpc_id = aws_vpc.datachain_cluster.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.datachain_cluster.id
  }
  tags = {
    Name = "datachain-cluster"
  }
}

resource "aws_subnet" "datachain_cluster" {
  for_each                = toset(data.aws_availability_zones.available.names)
  vpc_id                  = aws_vpc.datachain_cluster.id
  cidr_block              = cidrsubnet("172.18.0.0/16", 8, index(data.aws_availability_zones.available.names, each.key))
  map_public_ip_on_launch = true
  availability_zone       = each.key

  tags = {
    Name = "datachain-cluster-${each.key}"
  }
}

resource "aws_route_table_association" "datachain_cluster" {
  for_each       = aws_subnet.datachain_cluster
  subnet_id      = each.value.id
  route_table_id = aws_route_table.datachain_cluster.id
}

resource "aws_security_group" "datachain_cluster" {
  name   = "datachain-cluster"
  vpc_id = aws_vpc.datachain_cluster.id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
