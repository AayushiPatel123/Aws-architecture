################################################################################
# VPC
################################################################################

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = false
  enable_dns_hostnames = false
  tags = {
    Name = "my_vpc"
  }
}

################################################################################
# internet gateway
################################################################################

resource "aws_internet_gateway" "my_igw" {
    vpc_id = aws_vpc.my_vpc.id
    tags = {
      Name = "my_igw"
    }
}



################################################################################
# public subnets
################################################################################

resource "aws_subnet" "public_subnet_az1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.6.0/24"
  availability_zone = "us-east-1a" # AZ of your choice
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet_az1"
  }
}

resource "aws_subnet" "public_subnet_az2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "us-east-1b" # Another AZ of your choice
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet_az2"
  }
}

################################################################################
# public routes
################################################################################

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

resource "aws_route_table_association" "public_subnet_association_az1" {
  subnet_id      = aws_subnet.public_subnet_az1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_association_az2" {
  subnet_id      = aws_subnet.public_subnet_az2.id
  route_table_id = aws_route_table.public_route_table.id
}
################################################################################
# EIP
################################################################################

resource "aws_eip" "eip_nat" {
  domain = "vpc"

  tags = {
    Name = "eip_nat"
  }
}

################################################################################
# NAT
################################################################################


resource "aws_nat_gateway" "nat_1"{
  allocation_id = aws_eip.eip_nat.id
  subnet_id = aws_subnet.public_subnet_az1.id
  tags = {
    Name = "nat_1"
  }
}
################################################################################
# private subnet
################################################################################

resource "aws_subnet" "app_private_subnet_az1"{
    vpc_id = aws_vpc.my_vpc.id
    cidr_block        = "10.0.4.0/24"
    availability_zone = "us-east-1a"
    tags = {
        Name = "app_private_subnet_az1"
    }
}

resource "aws_subnet" "app_private_subnet_az2"{
    vpc_id = aws_vpc.my_vpc.id
    cidr_block        = "10.0.3.0/24"
    availability_zone = "us-east-1b"
    tags = {
        Name = "app_private_subnet_az2"
    }
}

################################################################################
# private routes
################################################################################

resource "aws_route_table" "app_private_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_1.id
  }
}

resource "aws_route_table_association" "app_private_subnet_association_az1" {
  subnet_id      = aws_subnet.app_private_subnet_az1.id
  route_table_id = aws_route_table.app_private_route_table.id
}

resource "aws_route_table_association" "app_private_subnet_association_az2" {
  subnet_id      = aws_subnet.app_private_subnet_az2.id
  route_table_id = aws_route_table.app_private_route_table.id
}

  ################################################################################
  # database subnets
  ################################################################################

resource "aws_subnet" "data_private_subnet_az1"{
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1a"
    tags = {
        Name = "data_private_subnet_az1"
    }
}

resource "aws_subnet" "data_private_subnet_az2"{
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1b"
    tags = {
        Name = "data_private_subnet_az2"
    }
}

  ################################################################################
  # database route association
  ################################################################################

resource "aws_route_table_association" "data_private_subnet_association_az1" {
  subnet_id      = aws_subnet.data_private_subnet_az1.id
  route_table_id = aws_route_table.app_private_route_table.id
}

resource "aws_route_table_association" "data_private_subnet_association_az2" {
  subnet_id      = aws_subnet.data_private_subnet_az2.id
  route_table_id = aws_route_table.app_private_route_table.id
}


