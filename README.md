# Terraform script to setup a VPC
In this script, I am creating a **VPC** with 6 *subnets*(3 public and 3 private) along with an *Internet GateWay*, a *NAT GateWay* and 2 *Route Tables*(1 public and 1 private).
## 1.Create VPC
```html
resource "aws_vpc" "blog-vpc" {
  cidr_block            = var.blog-vpc-cidr
  instance_tenancy      = "default"
  enable_dns_hostnames  = true
  tags = {
    Name    = "${var.project}-vpc"
    Project = var.project
  }
}
```
## 2.Create Subnets
### Public Subnets
```html
resource "aws_subnet" "public1" {
  vpc_id                    = aws_vpc.blog-vpc.id
  cidr_block                = var.public1-cidr
  availability_zone         = "ap-south-1a"
  map_public_ip_on_launch   = true
  tags = {
    Name    = "${var.project}-public1"
    Project = var.project
  }
}
```
```html
resource "aws_subnet" "public2" {
  vpc_id                    = aws_vpc.blog-vpc.id
  cidr_block                = var.public2-cidr
  availability_zone         = "ap-south-1b"
  map_public_ip_on_launch   = true

 tags = {
    Name    = "${var.project}-public2"
    Project = var.project
  }
}
```
```html
resource "aws_subnet" "public3" {
  vpc_id                    = aws_vpc.blog-vpc.id
  cidr_block                = var.public3-cidr
  availability_zone         = "ap-south-1c"
  map_public_ip_on_launch   = true
 tags = {
    Name    = "${var.project}-public3"
    Project = var.project
  }
}
```
### Private Subnets
```html
resource "aws_subnet" "private1" {
  vpc_id                    = aws_vpc.blog-vpc.id
  cidr_block                = var.private1-cidr
  availability_zone         = "ap-south-1a"

 tags = {
    Name    = "${var.project}-private1"
    Project = var.project
  }
}
```
```html
resource "aws_subnet" "private2" {
  vpc_id                    = aws_vpc.blog-vpc.id
  cidr_block                = var.private2-cidr
  availability_zone         = "ap-south-1b"
 tags = {
    Name    = "${var.project}-private2"
    Project = var.project
  }
}
```
```html
resource "aws_subnet" "private3" {
  vpc_id     = aws_vpc.blog-vpc.id
  cidr_block = var.private3-cidr
  availability_zone         = "ap-south-1c"
 tags = {
    Name    = "${var.project}-private3"
    Project = var.project
  }
}
```
## 3.Create Internet Gateway
```html
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.blog-vpc.id

 tags = {
    Name    = "${var.project}-igw"
    Project = var.project
  }
}
```
## 4.Purchase Elastic IP
```html
resource "aws_eip" "eip" {
  vpc      = true
 tags = {
    Name    = "${var.project}-eip"
    Project = var.project
  }
}
```
## 5.Create NAT Gateway
```html
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public1.id

 tags = {
    Name    = "${var.project}-nat"
    Project = var.project
  }
}
```
## 6.Create Route Tables
### Create Public Route Table
```html
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.blog-vpc.id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.igw.id
    }
 tags = {
    Name    = "${var.project}-public-rtb"
    Project = var.project
  }
}
```
### Create Private Route Table
```html
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.blog-vpc.id

  route {
      cidr_block        = "0.0.0.0/0"
      nat_gateway_id    = aws_nat_gateway.nat.id
    }
 tags = {
    Name    = "${var.project}-private-rtb"
    Project = var.project
  }
}
```
