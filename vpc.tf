resource "aws_vpc" "demovpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "Main"
    Project = "demo"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "Private_1" {
  vpc_id     = aws_vpc.demovpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = false
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "demo"
    Project = "demo"
  }
}

resource "aws_subnet" "Private_2" {
  vpc_id     = aws_vpc.demovpc.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = false
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "demo"
    Project = "demo"
  }
}

resource "aws_subnet" "Public_1" {
  vpc_id     = aws_vpc.demovpc.id
  cidr_block = "10.0.3.0/24"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "demo"
    Project = "demo"
  }
}

resource "aws_subnet" "Public_2" {
  vpc_id     = aws_vpc.demovpc.id
  cidr_block = "10.0.4.0/24"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "demo"
    Project = "demo"
  }
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.demovpc.id

  tags = {
    Name = "demo"
    Project = "demo"
  }
}

resource "aws_eip" "Nat_IP" {
  vpc = true
  tags = {
    Name = "demo"
    Project = "demo"
  }
}

resource "aws_nat_gateway" "NGW_1" {
  allocation_id = aws_eip.Nat_IP.id
  subnet_id     = aws_subnet.Public_1.id
  tags = {
    Name = "demo"
    Project = "demo"
  }
}

resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.demovpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }

  tags = {
    Name = "Public-Route"
    Project = "demo"
  }
}

resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.demovpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.NGW_1.id
  }

  tags = {
    Name = "Private-Route"
    Project = "demo"
  }
}

resource "aws_route_table_association" "Route_association_Public_1" {
  subnet_id      = aws_subnet.Public_1.id
  route_table_id = aws_route_table.public_route.id
}

resource "aws_route_table_association" "Route_association_Public_2" {
  subnet_id      = aws_subnet.Public_2.id
  route_table_id = aws_route_table.public_route.id
}

resource "aws_route_table_association" "Route_association_Private_1" {
  subnet_id      = aws_subnet.Private_1.id
  route_table_id = aws_route_table.private_route.id
}

