########################################################
# Fetching AZs
########################################################

data "aws_availability_zones" "az" {
  state = "available"
}

########################################################
# Outputs
########################################################
output "bastion-publicIP" {
    value = aws_instance.bastion.public_ip
}
output "webserver-publicIP" {
    value = aws_instance.webserver.public_ip
}
output "webserver-privateIP" {
    value = aws_instance.webserver.private_ip
}
output "dbserver-privateIP" {
    value = aws_instance.dbserver.private_ip
}

########################################################
# Create VPC
########################################################

resource "aws_vpc" "vpc" {
    cidr_block       = var.vpc-cidr

  tags = {
    Name    = "${var.project}-vpc"
    Project = var.project
  }
}
########################################################
# Create subnet - public-1
########################################################
resource "aws_subnet" "public1" {
  vpc_id                    = aws_vpc.vpc.id
  cidr_block                = cidrsubnet(var.vpc-cidr,var.vpc-subnet,0)
  map_public_ip_on_launch   = true
  availability_zone         = data.aws_availability_zones.az.names[0]

  tags = {
    Name    = "${var.project}-public1"
    Project = var.project
  }
}
########################################################
# Create subnet - public-2
########################################################
resource "aws_subnet" "public2" {
  vpc_id                    = aws_vpc.vpc.id
  cidr_block                = cidrsubnet(var.vpc-cidr,var.vpc-subnet,1)
  map_public_ip_on_launch   = true
  availability_zone         = data.aws_availability_zones.az.names[1]
  tags = {
    Name    = "${var.project}-public2"
    Project = var.project
  }
}
########################################################
# Create subnet - public-3
########################################################
resource "aws_subnet" "public3" {
  vpc_id                    = aws_vpc.vpc.id
  cidr_block                = cidrsubnet(var.vpc-cidr,var.vpc-subnet,2)
  map_public_ip_on_launch   = true
  availability_zone         = data.aws_availability_zones.az.names[2]

  tags = {
    Name    = "${var.project}-public3"
    Project = var.project
  }
}
########################################################
# Create subnet - private-1
########################################################
resource "aws_subnet" "private1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc-cidr,var.vpc-subnet,3)
  availability_zone         = data.aws_availability_zones.az.names[0]

  tags = {
    Name    = "${var.project}-private1"
    Project = var.project
  }
}
########################################################
# Create subnet - private-2
########################################################
resource "aws_subnet" "private2" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc-cidr,var.vpc-subnet,4)
  availability_zone         = data.aws_availability_zones.az.names[1]

  tags = {
    Name    = "${var.project}-private2"
    Project = var.project
  }
}
########################################################
# Create subnet - private-3
########################################################
resource "aws_subnet" "private3" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc-cidr,var.vpc-subnet,5)
  availability_zone         = data.aws_availability_zones.az.names[2]

  tags = {
    Name    = "${var.project}-private3"
    Project = var.project
  }
}

########################################################
# Create Internet Gateway
########################################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name    = "${var.project}-itgw"
    Project = var.project
  }
}

########################################################
# elastip IP
########################################################

resource "aws_eip" "eip" {
  vpc      = true
}

########################################################
# NAT
########################################################
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public1.id

  tags = {
    Name    = "${var.project}-nat"
    Project = var.project
  }
}
########################################################
# public route table
########################################################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route  {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.igw.id
    }

  tags = {
    Name    = "${var.project}-public-rtb"
    Project = var.project
  }
}
########################################################
# private route table
########################################################
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  route {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.nat.id
    }

  tags = {
    Name    = "${var.project}-private-rtb"
    Project = var.project
  }
}
########################################################
# public route table associations
########################################################
resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "public3" {
  subnet_id      = aws_subnet.public3.id
  route_table_id = aws_route_table.public.id
}
########################################################
# private route table associations
########################################################
resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "private3" {
  subnet_id      = aws_subnet.private3.id
  route_table_id = aws_route_table.private.id
}
